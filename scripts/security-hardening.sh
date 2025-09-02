#!/bin/bash
set -euo pipefail

# FullDevVM Security Hardening Script
# This script applies additional security configurations

LOG_FILE="/var/log/security-hardening.log"
exec > >(tee -a "$LOG_FILE") 2>&1

echo "Starting security hardening at $(date)"

# SSH Hardening
echo "Hardening SSH configuration..."
cat > /etc/ssh/sshd_config.d/99-security.conf << 'EOF'
# Security hardening
Protocol 2
PermitRootLogin no
PasswordAuthentication no
PubkeyAuthentication yes
AuthorizedKeysFile .ssh/authorized_keys
PermitEmptyPasswords no
MaxAuthTries 3
MaxSessions 10
ClientAliveInterval 300
ClientAliveCountMax 2
LoginGraceTime 60
AllowUsers dev
EOF

# Restart SSH service
systemctl restart ssh

# Configure UFW firewall
echo "Configuring UFW firewall..."
ufw --force reset
ufw default deny incoming
ufw default allow outgoing

# Allow essential services
ufw allow ssh
ufw allow 5901/tcp comment 'VNC Server'
ufw allow 6080/tcp comment 'noVNC Web Interface'
ufw allow 8080/tcp comment 'VS Code Server'

# Enable firewall
ufw --force enable

# Configure fail2ban
echo "Installing and configuring fail2ban..."
apt-get install -y fail2ban

cat > /etc/fail2ban/jail.local << 'EOF'
[DEFAULT]
bantime = 3600
findtime = 600
maxretry = 3

[sshd]
enabled = true
port = ssh
logpath = /var/log/auth.log
maxretry = 3
bantime = 3600
EOF

systemctl enable fail2ban
systemctl start fail2ban

# Disable unnecessary services
echo "Disabling unnecessary services..."
systemctl disable snapd
systemctl disable snapd.socket
systemctl disable snapd.seeded
systemctl disable bluetooth
systemctl disable cups
systemctl disable cups-browsed

# Configure automatic security updates
echo "Configuring automatic security updates..."
apt-get install -y unattended-upgrades

cat > /etc/apt/apt.conf.d/50unattended-upgrades << 'EOF'
Unattended-Upgrade::Allowed-Origins {
    "${distro_id}:${distro_codename}-security";
    "${distro_id}ESMApps:${distro_codename}-apps-security";
    "${distro_id}ESM:${distro_codename}-infra-security";
};

Unattended-Upgrade::AutoFixInterruptedDpkg "true";
Unattended-Upgrade::MinimalSteps "true";
Unattended-Upgrade::Remove-Unused-Dependencies "true";
Unattended-Upgrade::Automatic-Reboot "false";
EOF

cat > /etc/apt/apt.conf.d/20auto-upgrades << 'EOF'
APT::Periodic::Update-Package-Lists "1";
APT::Periodic::Unattended-Upgrade "1";
APT::Periodic::AutocleanInterval "7";
EOF

# Set up log rotation
echo "Configuring log rotation..."
cat > /etc/logrotate.d/fulldevvm << 'EOF'
/var/log/packer-provision.log {
    weekly
    rotate 4
    compress
    delaycompress
    missingok
    notifempty
    create 644 root root
}

/var/log/security-hardening.log {
    weekly
    rotate 4
    compress
    delaycompress
    missingok
    notifempty
    create 644 root root
}
EOF

# Configure system limits
echo "Configuring system limits..."
cat > /etc/security/limits.d/99-fulldevvm.conf << 'EOF'
# Increase limits for development
* soft nofile 65536
* hard nofile 65536
* soft nproc 32768
* hard nproc 32768
EOF

# Set up audit logging
echo "Configuring audit logging..."
apt-get install -y auditd audispd-plugins

cat > /etc/audit/rules.d/99-fulldevvm.rules << 'EOF'
# Monitor system calls
-a always,exit -F arch=b64 -S adjtimex -S settimeofday -k time-change
-a always,exit -F arch=b32 -S adjtimex -S settimeofday -S stime -k time-change
-a always,exit -F arch=b64 -S clock_settime -k time-change
-a always,exit -F arch=b32 -S clock_settime -k time-change

# Monitor file system changes
-w /etc/passwd -p wa -k identity
-w /etc/group -p wa -k identity
-w /etc/shadow -p wa -k identity
-w /etc/sudoers -p wa -k identity

# Monitor network configuration
-w /etc/network/ -p wa -k network-config
-w /etc/hosts -p wa -k network-config
-w /etc/hostname -p wa -k network-config
EOF

systemctl enable auditd
systemctl start auditd

# Create security monitoring script
echo "Creating security monitoring script..."
cat > /home/dev/security-check.sh << 'EOF'
#!/bin/bash
# Security status check script

echo "=== FullDevVM Security Status ==="
echo "Date: $(date)"
echo

echo "=== Firewall Status ==="
sudo ufw status verbose
echo

echo "=== SSH Status ==="
sudo systemctl status ssh --no-pager -l
echo

echo "=== Fail2ban Status ==="
sudo systemctl status fail2ban --no-pager -l
echo

echo "=== Recent SSH Logins ==="
sudo last -n 10
echo

echo "=== Failed Login Attempts ==="
sudo grep "Failed password" /var/log/auth.log | tail -5
echo

echo "=== System Updates ==="
sudo apt list --upgradable 2>/dev/null | grep -v "Listing..."
echo

echo "=== Audit Log Summary ==="
sudo ausearch -m AVC,USER_LOGIN,USER_LOGOUT 2>/dev/null | tail -5
EOF

chmod +x /home/dev/security-check.sh
chown dev:dev /home/dev/security-check.sh

echo "Security hardening completed at $(date)"
echo "Run /home/dev/security-check.sh to check security status"
