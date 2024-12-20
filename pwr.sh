#!/bin/bash

cd $HOME
if [ ! -d "pwr-hca" ]; then
  mkdir -p pwr-hca
fi
cd pwr-hca

# Ensure firewall is configured
if ! sudo ufw status | grep -q "Status: active"; then
  yes | sudo ufw enable
fi

if ! sudo ufw status | grep -q "22/tcp"; then
  sudo ufw allow 22
fi

if ! sudo ufw status | grep -q "80/tcp"; then
  sudo ufw allow 80
fi

if ! sudo ufw status | grep -q "8231/tcp"; then
  sudo ufw allow 8231/tcp
fi

if ! sudo ufw status | grep -q "8085/tcp"; then
  sudo ufw allow 8085/tcp
fi

if ! sudo ufw status | grep -q "7621/udp"; then
  sudo ufw allow 7621/udp
fi

# Update system packages
sudo apt update && sudo apt upgrade -y

# Install Java if not already installed
if ! command -v java &> /dev/null; then
  sudo apt install -y openjdk-19-jre-headless
fi

# Download the latest validator and config files
wget -O validator.jar https://github.com/pwrlabs/PWR-Validator/releases/download/13.2.37/validator.jar
wget -O config.json https://github.com/pwrlabs/PWR-Validator/raw/refs/heads/main/config.json

# Prompt for password
read -p "Enter your desired password: " password
echo $password | sudo tee password

# Get the server IP address
SERVER_IP=$(hostname -I | awk '{print $1}')

# Start the validator in a detached screen session
screen -S pwr -dm bash -c "sudo java -jar validator.jar password $SERVER_IP --loop-udp-test"

# Confirmation message
echo "Validator node is now running in the background within the 'screen' session."
echo "To reattach to the screen session, use: screen -r pwr"
echo "Logs can be found in validator.log."
echo "Subscribe: https://t.me/HappyCuanAirdrop"
