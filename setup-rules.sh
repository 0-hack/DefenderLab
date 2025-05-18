#!/bin/bash

echo "Enabling UFW and configuring rules..."

# Enable UFW if not already enabled
sudo ufw --force enable

# Allow SSH from anywhere
echo "Allowing SSH (port 22) from anywhere..."
sudo ufw allow ssh

# Allow local access to port 3000
echo "Allowing localhost access to port 3000..."
sudo ufw allow from 127.0.0.1 to any port 3000
echo "Denying external access to port 3000..."
sudo ufw deny 3000

# Allow local access to port 5000
echo "Allowing localhost access to port 5000..."
sudo ufw allow from 127.0.0.1 to any port 5000
echo "Denying external access to port 5000..."
sudo ufw deny 5000

# Add iptables rules for Docker
echo "Adding iptables rules for Docker..."
sudo iptables -I DOCKER-USER -p tcp --dport 3000 ! -s 127.0.0.1 -j DROP

# Install iptables-persistent and save rules
echo "Installing iptables-persistent and saving rules..."
sudo apt-get update
sudo apt-get install iptables-persistent -y
sudo iptables-save | sudo tee /etc/iptables/rules.v4 > /dev/null

# Show final UFW status
echo ""
echo "Final UFW rules:"
sudo ufw status numbered
