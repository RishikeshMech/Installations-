#!/bin/bash
####################################
# Name:- Rishikesh Gulhane         #
# Purpose :- Jenkins Installation  #
# Version :- 1.0                   #
####################################

# Function to display the menu
menu(){
    echo "####################"
    echo "1 Jenkins On Master"
    echo "2 Jenkins On Worker"
    echo "3 Exit"
    echo "####################"
    read -p "Enter your choice: " choice
}

# Function to install Java
install_java(){
    echo "Installing Java..."
    sudo yum upgrade -y
    sudo yum install -y fontconfig java-17-openjdk
    java --version
}

# Function to install Jenkins on Master
install_jenkins_master(){
    echo "Installing Jenkins on Master..."
    install_java
    sudo wget -O /etc/yum.repos.d/jenkins.repo \
        https://pkg.jenkins.io/redhat-stable/jenkins.repo
    sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key
    sudo yum install -y jenkins
    sudo systemctl daemon-reload
    sudo systemctl enable jenkins
    sudo systemctl start jenkins
    sudo systemctl status jenkins
}

# Function to install Java on Worker (if needed)
install_jenkins_worker(){
    echo "Installing Java on Worker..."
    install_java
    echo "Worker setup complete. Jenkins is typically not installed here."
}

# Main script execution
while true; do
    menu
    case $choice in
        1) install_jenkins_master ;;
        2) install_jenkins_worker ;;
        3) echo "Exiting..."; exit 0 ;;
        *) echo "Invalid choice. Please select again." ;;
    esac
    read -p "Press Enter to continue..."
done


