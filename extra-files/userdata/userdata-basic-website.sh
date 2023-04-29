#!/bin/bash

# Enable logs
exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1

# Install Git
echo "Installing Git"
yum update -y
yum install git -y

# Install NodeJS
echo "Installing NodeJS"
touch .bashrc
curl -fsSL https://rpm.nodesource.com/setup_16.x | sudo bash -
yum update
yum install -y nodejs

# Clone website code
echo "Cloning website"
mkdir -p /demo-website
cd /demo-website
git clone https://github.com/leegodden/aws-demos.git .
cd dynamic-website-basic

# Install dependencies
echo "Installing dependencies"
npm install

# Create data directory (later => EBS)
echo "Creating data directory & file"
mkdir -p /demo/data
echo '{"topics": []}' | tee "/demo/data/data-storage.json"

# Forward port 80 traffic to port 3000
echo "Forwarding 80 -> 3000"
iptables -t nat -A PREROUTING -p tcp --dport 80 -j REDIRECT --to-ports 3000

# Install & use pm2 to run Node app in background
echo "Installing & starting pm2"
npm install pm2@latest -g
pm2 start app.js
