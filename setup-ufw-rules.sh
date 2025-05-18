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

# Show final UFW status
echo ""
echo "Final UFW rules:"
sudo ufw status numbered
