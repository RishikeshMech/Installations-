#!/bin/bash
echo "This Script will help you to set up k8 master node" 

sudo yum update -y

# Swap memory may interupt k8 operation. To disable swap space, run the command:

sudo swapoff -a
echo "Swap disabled"

# To make the changes persistent, run

sudo sed -i '/swap/d' /etc/fstab

echo "Swap entry deleted from /etc/fstab"

# To achieve this, open the SELinux configuration file.
# sudo vi /etc/selinux/config
#Change the SELINUX value from enforcing to permissive.
#SELINUX=permissive
#Alternatively, you use the sed command as follows.

sudo sed -i 's/^SELINUX=enforcing$/SELINUX=permissive/' /etc/selinux/config

sudo cat /etc/containerd/config.toml | grep SystemdCgroup

# install the traffic control utility package

echo "traffic controlling utility package"
sudo yum install -y iproute-tc
echo "traffic controlling package instaaled"

# First, create a modules configuration file for Kubernetes.

sudo touch /etc/modules-load.d/k8s.conf

# Add these lines and save the changes

cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF

# Then load both modules using the modprobe command.

sudo modprobe overlay
sudo modprobe br_netfilter

echo "network modules loaded"

# Next, configure the required sysctl parameters as follows

# sudo vi /etc/sysctl.d/k8s.conf

# Add the following lines:

cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables  = 1
net.ipv4.ip_forward                 = 1
net.bridge.bridge-nf-call-ip6tables = 1
EOF

echo "sysctl parameter for ip forward added"

# Save the changes and exit. To confirm the changes have been applied, run the command:

sudo sysctl --system

echo "loaded stsctl"

#Install Docker-CE on RHEL 8
#You will need to add the Docker repository first as it is no longer in the default package list using the following dnf config-manager command.

echo "Adding repo for container runtime"
sudo yum config-manager --add-repo=https://download.docker.com/linux/centos/docker-ce.repo
sudo yum update -y

#Also install containerd.io package which is available as a daemon that manages the complete container lifecycle of its host system, from image transfer and storage to container execution and supervision to low-level storage to network attachments and beyond.
echo "installing containerd io packages"
sudo yum install https://download.docker.com/linux/centos/7/x86_64/stable/Packages/containerd.io-1.2.6-3.3.el7.x86_64.rpm

#Now install the latest version of a docker-ce package.

echo "installing docker-ce"

yum install docker-ce

sudo yum remove runc -y

echo "instaaling docker-ce-cli & containered io"

sudo yum install -y docker-ce docker-ce-cli containerd.io

# You can now enable and start the containerd service.

echo "stating containered service"
sudo systemctl enable containerd
sudo systemctl start containerd
sudo systemctl status containerd

echo "adding cggroup"
# Check if containerd is configured to use the Kubernetes CRI (Container Runtime Interface):
# sudo cat /etc/containerd/config.toml | grep SystemdCgroup
# If you don't see SystemdCgroup = true, update it:

sudo containerd config default | sudo tee /etc/containerd/config.toml > /dev/null
sudo sed -i 's/SystemdCgroup = false/SystemdCgroup = true/' /etc/containerd/config.toml
sudo systemctl restart containerd
sudo cat /etc/containerd/config.toml | grep SystemdCgroup

# Install Kubernetes Packages
# With everything required for Kubernetes to work installed, let us go ahead and install Kubernetes packages like kubelet, kubeadm and kubectl.
# Set the Kubernetes version variable as shown below:

echo "Adding k8 repo"
# This overwrites any existing configuration in /etc/yum.repos.d/kubernetes.repo
cat <<EOF | sudo tee /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://pkgs.k8s.io/core:/stable:/v1.29/rpm/
enabled=1
gpgcheck=1
gpgkey=https://pkgs.k8s.io/core:/stable:/v1.29/rpm/repodata/repomd.xml.key
exclude=kubelet kubeadm kubectl cri-tools kubernetes-cni
EOF

echo "insttaling k8 components"

sudo yum install -y kubelet kubeadm kubectl --disableexcludes=kubernetes

echo "installing jq processor"
sudo yum install -y jq

# validating installation 
rpm -qa | grep -i *kube
rpm -qa | grep -i *jq
kubectl version --client && kubeadm version

# starting kubelet

sudo systemctl enable --now kubelet
sudo systemctl start kubelet


sudo kubeadm reset pre-flight checks
