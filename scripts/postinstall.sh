#!/bin/bash
set -euo pipefail

# FullDevVM Post-Installation Script
# This script sets up the desktop environment and developer toolchain

LOG_FILE="/var/log/packer-provision.log"
exec > >(tee -a "$LOG_FILE") 2>&1

echo "Starting FullDevVM post-installation at $(date)"

# Update package lists
apt-get update

# Install desktop environment and VNC
echo "Installing desktop environment..."
apt-get install -y \
    xfce4 \
    xfce4-goodies \
    tigervnc-standalone-server \
    tigervnc-common \
    xrdp \
    firefox \
    thunar \
    xfce4-terminal \
    xfce4-screenshooter \
    xfce4-taskmanager \
    xfce4-whiskermenu-plugin

# Install development tools
echo "Installing development tools..."
apt-get install -y \
    cmake \
    python3-pip \
    python3-venv \
    python3-dev \
    nodejs \
    npm \
    openjdk-17-jdk \
    golang-go \
    rustc \
    cargo \
    docker.io \
    docker-compose \
    strace \
    lsof \
    tcpdump \
    openssh-client

# Install noVNC
echo "Installing noVNC..."
apt-get install -y \
    novnc \
    websockify

# Install additional useful packages
apt-get install -y \
    htop \
    tree \
    jq \
    ripgrep \
    fd-find \
    bat \
    exa \
    neofetch

# Configure VNC for dev user
echo "Configuring VNC..."
sudo -u dev mkdir -p /home/dev/.vnc
sudo -u dev bash -c 'echo "xfce4-session &" > /home/dev/.vnc/xstartup'
sudo -u dev chmod +x /home/dev/.vnc/xstartup

# Set VNC password (default: dev123)
sudo -u dev bash -c 'echo "dev123" | vncpasswd -f > /home/dev/.vnc/passwd'
sudo -u dev chmod 600 /home/dev/.vnc/passwd

# Install and configure code-server
echo "Installing code-server..."
curl -fsSL https://code-server.dev/install.sh | sh
sudo -u dev mkdir -p /home/dev/.config/code-server

# Create code-server config
sudo -u dev bash -c 'cat > /home/dev/.config/code-server/config.yaml << EOF
bind-addr: 0.0.0.0:8080
auth: none
password: ""
cert: false
EOF'

# Install Python packages
echo "Installing Python packages..."
sudo -u dev pip3 install --user \
    virtualenv \
    pipenv \
    black \
    flake8 \
    pytest \
    requests \
    numpy \
    pandas

# Install Node.js global packages
echo "Installing Node.js global packages..."
sudo -u dev npm install -g \
    typescript \
    ts-node \
    nodemon \
    eslint \
    prettier \
    yarn \
    pnpm

# Install Rust tools
echo "Installing Rust tools..."
sudo -u dev bash -c 'curl --proto "=https" --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y'
sudo -u dev bash -c 'source ~/.cargo/env && cargo install --locked bat exa ripgrep fd-find'

# Configure Go
echo "Configuring Go..."
sudo -u dev bash -c 'echo "export GOPATH=\$HOME/go" >> /home/dev/.bashrc'
sudo -u dev bash -c 'echo "export PATH=\$PATH:\$GOPATH/bin" >> /home/dev/.bashrc'

# Create desktop shortcuts
echo "Creating desktop shortcuts..."
sudo -u dev mkdir -p /home/dev/Desktop
sudo -u dev bash -c 'cat > /home/dev/Desktop/Terminal.desktop << EOF
[Desktop Entry]
Version=1.0
Type=Application
Name=Terminal
Comment=Terminal Emulator
Exec=xfce4-terminal
Icon=utilities-terminal
Terminal=false
Categories=System;TerminalEmulator;
EOF'

sudo -u dev bash -c 'cat > /home/dev/Desktop/Projects.desktop << EOF
[Desktop Entry]
Version=1.0
Type=Application
Name=Projects
Comment=Open Projects Folder
Exec=thunar /home/dev/projects
Icon=folder
Terminal=false
Categories=System;FileManager;
EOF'

sudo -u dev chmod +x /home/dev/Desktop/*.desktop

# Create developer menu
echo "Creating developer menu..."
sudo -u dev mkdir -p /home/dev/.local/share/applications
sudo -u dev bash -c 'cat > /home/dev/.local/share/applications/code-server.desktop << EOF
[Desktop Entry]
Version=1.0
Type=Application
Name=VS Code Server
Comment=VS Code in Browser
Exec=code-server --bind-addr 0.0.0.0:8080
Icon=code
Terminal=false
Categories=Development;IDE;
EOF'

# Copy systemd services
echo "Installing systemd services..."
cp /tmp/systemd/*.service /etc/systemd/system/
systemctl daemon-reload

# Enable and start services
echo "Enabling services..."
systemctl enable vncserver@1.service
systemctl enable novnc.service
systemctl enable code-server.service

# Configure firewall
echo "Configuring firewall..."
ufw --force enable
ufw default deny incoming
ufw default allow outgoing
ufw allow ssh
ufw allow 5901/tcp  # VNC
ufw allow 6080/tcp  # noVNC
ufw allow 8080/tcp  # code-server

# Create setup scripts
echo "Creating setup scripts..."
cat > /home/dev/setup-firewall.sh << 'EOF'
#!/bin/bash
# Toggle firewall rules for development
if [ "$1" = "open" ]; then
    sudo ufw allow 5901/tcp  # VNC
    sudo ufw allow 6080/tcp  # noVNC
    sudo ufw allow 8080/tcp  # code-server
    echo "Firewall opened for development ports"
elif [ "$1" = "close" ]; then
    sudo ufw delete allow 5901/tcp
    sudo ufw delete allow 6080/tcp
    sudo ufw delete allow 8080/tcp
    echo "Firewall closed development ports"
else
    echo "Usage: $0 [open|close]"
fi
EOF

cat > /home/dev/enable-auto-updates.sh << 'EOF'
#!/bin/bash
# Enable automatic security updates
sudo apt-get install -y unattended-upgrades
sudo dpkg-reconfigure -plow unattended-upgrades
echo "Automatic updates enabled"
EOF

chmod +x /home/dev/setup-firewall.sh
chmod +x /home/dev/enable-auto-updates.sh
chown dev:dev /home/dev/setup-firewall.sh
chown dev:dev /home/dev/enable-auto-updates.sh

# Create welcome message
echo "Creating welcome message..."
cat > /home/dev/welcome.txt << 'EOF'
Welcome to FullDevVM!

This VM is configured with:
- XFCE4 Desktop Environment
- VNC Server (port 5901)
- noVNC Web Interface (port 6080)
- VS Code Server (port 8080)
- Full Developer Toolchain

Access Methods:
1. SSH: ssh -p 2222 dev@localhost
2. Desktop: http://localhost:6080
3. VS Code: http://localhost:8080

Projects folder: /home/dev/projects
Setup scripts: /home/dev/setup-firewall.sh, /home/dev/enable-auto-updates.sh

Default VNC password: dev123
EOF

chown dev:dev /home/dev/welcome.txt

# Final cleanup
echo "Cleaning up..."
apt-get autoremove -y
apt-get autoclean

echo "FullDevVM post-installation completed at $(date)"
