#!/bin/bash

# Generic server configuration script
# Run with: sudo bash setup-server.sh

echo "=== Server Configuration Script ==="
echo

# Generate random password
RANDOM_PASSWORD=$(openssl rand -base64 12 | tr -d "=+/" | cut -c1-16)

# Update system packages
echo "1. Updating system packages..."
apt update

# Install UFW
echo "2. Installing UFW (firewall)..."
apt install ufw -y

# Configure UFW - open ports
echo "3. Configuring firewall - opening ports 22 and 4001 (TCP and UDP)..."
ufw allow 22/tcp
ufw allow 22/udp
ufw allow 4001/tcp
ufw allow 4001/udp

# Enable UFW
echo "4. Enabling firewall..."
ufw --force enable

# Check UFW status
echo "5. Firewall status:"
ufw status

echo
echo "6. Creating user supimobiliar..."
adduser --disabled-password --gecos "" supimobiliar

echo
echo "7. Setting password for user supimobiliar..."
echo "supimobiliar:$RANDOM_PASSWORD" | chpasswd

echo
echo "8. Adding user supimobiliar to sudo group (root privileges)..."
usermod -aG sudo supimobiliar

echo
echo "9. Setting root password..."
passwd root

echo
echo "10. Configuring SSH - adding port 4001..."
# Backup SSH configuration file
cp /etc/ssh/sshd_config /etc/ssh/sshd_config.backup

# Add port 4001 to SSH if it doesn't exist
if ! grep -q "Port 4001" /etc/ssh/sshd_config; then
    echo "Port 4001" >> /etc/ssh/sshd_config
fi

echo
echo "11. Restarting SSH service..."
systemctl restart sshd

echo
echo "12. Checking open ports..."
ss -tuln | grep -E '22|4001'

echo
echo "=== CONFIGURATION COMPLETED ==="
echo
echo "IMPORTANT INFORMATION:"
echo "- User created: supimobiliar"
echo "- User supimobiliar has root privileges (sudo)"
echo "- Ports opened: 22 and 4001 (TCP and UDP)"
echo "- SSH configured to accept root login"
echo "- SSH listening on ports 22 and 4001"
echo
echo "GENERATED CREDENTIALS:"
echo "- Username: supimobiliar"
echo "- Password: $RANDOM_PASSWORD"
echo
echo "SSH CONNECTIONS:"
echo "ssh supimobiliar@YOUR_IP -p 22"
echo "ssh supimobiliar@YOUR_IP -p 4001"
echo "ssh root@YOUR_IP -p 22"
echo "ssh root@YOUR_IP -p 4001"
echo
echo "SECURITY WARNING:"
echo "- Root login via SSH is enabled (security risk)"
echo "- Consider using SSH keys instead of passwords"
echo "- Keep strong passwords for all users"
echo "- SAVE THE PASSWORD ABOVE - IT WILL NOT BE SHOWN AGAIN"
echo
echo "SSH configuration backup saved at: /etc/ssh/sshd_config.backup"
