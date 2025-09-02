#!/bin/bash
set -euo pipefail

# FullDevVM Quick Setup Script
# This script downloads and configures a Ubuntu cloud image for development

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

echo "=========================================="
echo "FullDevVM Quick Setup"
echo "=========================================="
echo

# Create output directory
mkdir -p output

# Download Ubuntu cloud image
print_status "Downloading Ubuntu 22.04 cloud image..."
CLOUD_IMAGE_URL="https://cloud-images.ubuntu.com/releases/jammy/release/ubuntu-22.04-server-cloudimg-amd64.img"
CLOUD_IMAGE="output/ubuntu-22.04-base.img"

if [ ! -f "$CLOUD_IMAGE" ]; then
    curl -L -o "$CLOUD_IMAGE" "$CLOUD_IMAGE_URL"
    print_success "Downloaded Ubuntu cloud image"
else
    print_status "Ubuntu cloud image already exists"
fi

# Create a larger disk image
print_status "Creating FullDevVM disk image..."
qemu-img create -f qcow2 -F qcow2 -b "ubuntu-22.04-base.img" output/FullDevVM.qcow2 25G
print_success "Created FullDevVM disk image"

# Create cloud-init configuration
print_status "Creating cloud-init configuration..."
mkdir -p output/cloud-init

# Generate SSH key if none exists
if [ ! -f ~/.ssh/id_rsa.pub ] && [ ! -f ~/.ssh/id_ed25519.pub ]; then
    print_warning "No SSH key found. Generating one..."
    ssh-keygen -t ed25519 -f ~/.ssh/id_ed25519 -N "" -C "fulldevvm@$(hostname)"
fi

# Get SSH public key
SSH_KEY=""
if [ -f ~/.ssh/id_ed25519.pub ]; then
    SSH_KEY=$(cat ~/.ssh/id_ed25519.pub)
elif [ -f ~/.ssh/id_rsa.pub ]; then
    SSH_KEY=$(cat ~/.ssh/id_rsa.pub)
fi

# Create user-data
cat > output/cloud-init/user-data << EOF
#cloud-config
users:
  - name: dev
    groups: [adm, audio, cdrom, dialout, dip, floppy, lxd, netdev, plugdev, sudo, video, docker]
    shell: /bin/bash
    sudo: ['ALL=(ALL) NOPASSWD:ALL']
    ssh_authorized_keys:
      - $SSH_KEY
    home: /home/dev
    create_home: true

package_update: true
package_upgrade: true

packages:
  - build-essential
  - curl
  - wget
  - git
  - vim
  - less
  - unzip
  - net-tools
  - openssh-server
  - qemu-guest-agent
  - xfce4
  - xfce4-goodies
  - tigervnc-standalone-server
  - novnc
  - websockify
  - firefox
  - docker.io
  - docker-compose
  - python3-pip
  - nodejs
  - npm
  - openjdk-17-jdk
  - golang-go
  - cmake
  - htop
  - tree

runcmd:
  - systemctl enable ssh
  - systemctl start ssh
  - systemctl enable qemu-guest-agent
  - systemctl start qemu-guest-agent
  - mkdir -p /home/dev/projects /home/dev/.vnc
  - chown -R dev:dev /home/dev/projects /home/dev/.vnc
  - sudo -u dev bash -c 'echo "xfce4-session &" > /home/dev/.vnc/xstartup'
  - sudo -u dev chmod +x /home/dev/.vnc/xstartup
  - sudo -u dev bash -c 'echo "dev123" | vncpasswd -f > /home/dev/.vnc/passwd'
  - sudo -u dev chmod 600 /home/dev/.vnc/passwd
  - usermod -aG docker dev
  - ufw --force enable
  - ufw default deny incoming
  - ufw default allow outgoing
  - ufw allow ssh
  - ufw allow 5901/tcp
  - ufw allow 6080/tcp

final_message: "FullDevVM is ready! Connect via SSH: ssh -p 2222 dev@localhost"
EOF

# Create meta-data
cat > output/cloud-init/meta-data << EOF
instance-id: fulldevvm-001
local-hostname: fulldevvm
hostname: fulldevvm
EOF

    # Create cloud-init ISO
    print_status "Creating cloud-init configuration ISO..."
    if command -v genisoimage >/dev/null 2>&1; then
        genisoimage -output output/cloud-init.iso -volid cidata -joliet -rock output/cloud-init/
    elif command -v mkisofs >/dev/null 2>&1; then
        mkisofs -output output/cloud-init.iso -volid cidata -joliet -rock output/cloud-init/
    else
        print_error "Neither genisoimage nor mkisofs found. Please install genisoimage."
        exit 1
    fi

print_success "Created cloud-init configuration"

# Create start script
print_status "Creating VM start script..."
cat > output/start-vm.sh << 'EOF'
#!/bin/bash
qemu-system-x86_64 \
  -m 4G \
  -smp 2 \
  -drive file=FullDevVM.qcow2,format=qcow2 \
  -drive file=cloud-init.iso,media=cdrom \
  -netdev user,id=net0,hostfwd=tcp::2222-:22,hostfwd=tcp::6080-:6080,hostfwd=tcp::5901-:5901 \
  -device virtio-net-pci,netdev=net0 \
  -enable-kvm \
  -display none \
  -daemonize
EOF

chmod +x output/start-vm.sh

print_success "FullDevVM setup complete!"
echo
echo "To start the VM:"
echo "  cd output && ./start-vm.sh"
echo
echo "To connect:"
echo "  SSH: ssh -p 2222 dev@localhost"
echo "  VNC: localhost:5901 (password: dev123)"
echo "  noVNC: http://localhost:6080"
echo
echo "The VM will take a few minutes to complete initial setup."
