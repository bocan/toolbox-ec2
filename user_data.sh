#!/bin/bash

# Install Tools and Dependencies
dnf install -y postgresql16 nmap git

# Install Kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

# Install Helm
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
bash ./get_helm.sh

# Versions
echo "Kubectl version: $(kubectl version --client)"
echo "Helm version: $(helm version)"
