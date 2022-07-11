#!/bin/bash

yum remove  -y awscli
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
./aws/install
rm -rf aws awscliv2.zip

yum install -y postgresql nmap
yum install -y "https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/linux_amd64/amazon-ssm-agent.rpm"

curl -sLO "https://storage.googleapis.com/kubernetes-release/release/v1.21.14/bin/linux/amd64/kubectl"
mv kubectl /usr/bin/kubectl
chmod +x /usr/bin/kubectl

curl -sLO "https://get.helm.sh/helm-v3.5.4-linux-amd64.tar.gz"
tar -xzf "helm-v3.5.4-linux-amd64.tar.gz"
mv linux-amd64/helm /usr/bin/helm
chmod +x /usr/bin/helm
