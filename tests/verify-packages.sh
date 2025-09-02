#!/bin/bash
set -euo pipefail

# Package Verification Script
# Tests installed packages and system configuration

echo "=== Package Verification Test ==="
echo "Date: $(date)"
echo

# Test essential system packages
echo "1. Checking essential system packages..."
essential_packages=(
    "build-essential"
    "curl"
    "wget"
    "git"
    "vim"
    "less"
    "unzip"
    "net-tools"
    "openssh-server"
    "cloud-init"
    "qemu-guest-agent"
)

for package in "${essential_packages[@]}"; do
    if dpkg -l | grep -q "^ii  $package "; then
        echo "✓ $package is installed"
    else
        echo "✗ $package is not installed"
    fi
done

# Test desktop environment packages
echo "2. Checking desktop environment packages..."
desktop_packages=(
    "xfce4"
    "xfce4-goodies"
    "tigervnc-standalone-server"
    "tigervnc-common"
    "xrdp"
    "firefox"
    "thunar"
    "xfce4-terminal"
    "novnc"
    "websockify"
)

for package in "${desktop_packages[@]}"; do
    if dpkg -l | grep -q "^ii  $package "; then
        echo "✓ $package is installed"
    else
        echo "✗ $package is not installed"
    fi
done

# Test development packages
echo "3. Checking development packages..."
dev_packages=(
    "cmake"
    "python3-pip"
    "python3-venv"
    "python3-dev"
    "nodejs"
    "npm"
    "openjdk-17-jdk"
    "golang-go"
    "rustc"
    "cargo"
    "docker.io"
    "docker-compose"
    "strace"
    "lsof"
    "tcpdump"
    "openssh-client"
)

for package in "${dev_packages[@]}"; do
    if dpkg -l | grep -q "^ii  $package "; then
        echo "✓ $package is installed"
    else
        echo "✗ $package is not installed"
    fi
done

# Test utility packages
echo "4. Checking utility packages..."
utility_packages=(
    "htop"
    "tree"
    "jq"
    "ripgrep"
    "fd-find"
    "bat"
    "exa"
    "neofetch"
)

for package in "${utility_packages[@]}"; do
    if dpkg -l | grep -q "^ii  $package "; then
        echo "✓ $package is installed"
    else
        echo "✗ $package is not installed"
    fi
done

# Test security packages
echo "5. Checking security packages..."
security_packages=(
    "ufw"
    "fail2ban"
    "unattended-upgrades"
    "auditd"
    "audispd-plugins"
)

for package in "${security_packages[@]}"; do
    if dpkg -l | grep -q "^ii  $package "; then
        echo "✓ $package is installed"
    else
        echo "✗ $package is not installed"
    fi
done

# Test system services
echo "6. Checking system services..."
services=(
    "ssh"
    "qemu-guest-agent"
    "vncserver@1"
    "novnc"
    "code-server"
    "docker"
    "fail2ban"
    "auditd"
)

for service in "${services[@]}"; do
    if systemctl is-enabled --quiet "$service" 2>/dev/null; then
        echo "✓ $service service is enabled"
    else
        echo "⚠ $service service is not enabled"
    fi
    
    if systemctl is-active --quiet "$service" 2>/dev/null; then
        echo "✓ $service service is running"
    else
        echo "⚠ $service service is not running"
    fi
done

# Test file permissions
echo "7. Checking file permissions..."
if [ -d "/home/dev" ]; then
    echo "✓ /home/dev directory exists"
    if [ "$(stat -c %U /home/dev)" = "dev" ]; then
        echo "✓ /home/dev has correct ownership"
    else
        echo "✗ /home/dev has incorrect ownership"
    fi
else
    echo "✗ /home/dev directory not found"
fi

if [ -d "/home/dev/projects" ]; then
    echo "✓ /home/dev/projects directory exists"
else
    echo "✗ /home/dev/projects directory not found"
fi

# Test network configuration
echo "8. Checking network configuration..."
if netstat -tlnp | grep -q ":22 "; then
    echo "✓ SSH is listening on port 22"
else
    echo "✗ SSH is not listening on port 22"
fi

if netstat -tlnp | grep -q ":5901 "; then
    echo "✓ VNC is listening on port 5901"
else
    echo "✗ VNC is not listening on port 5901"
fi

if netstat -tlnp | grep -q ":6080 "; then
    echo "✓ noVNC is listening on port 6080"
else
    echo "✗ noVNC is not listening on port 6080"
fi

if netstat -tlnp | grep -q ":8080 "; then
    echo "✓ VS Code Server is listening on port 8080"
else
    echo "✗ VS Code Server is not listening on port 8080"
fi

# Test firewall
echo "9. Checking firewall configuration..."
if ufw status | grep -q "Status: active"; then
    echo "✓ UFW firewall is active"
else
    echo "✗ UFW firewall is not active"
fi

# Test disk space
echo "10. Checking disk space..."
disk_usage=$(df / | awk 'NR==2 {print $5}' | sed 's/%//')
if [ "$disk_usage" -lt 80 ]; then
    echo "✓ Disk usage is acceptable: ${disk_usage}%"
else
    echo "⚠ Disk usage is high: ${disk_usage}%"
fi

echo
echo "=== Package Verification Complete ==="
