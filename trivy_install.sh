#!/bin/bash

#============== Below steps will help for sonarqube installation 

sudo rpm -ivh https://github.com/aquasecurity/trivy/releases/download/v0.37.3/trivy_0.37.3_Linux-64bit.rpm

trivy --version
