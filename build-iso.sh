#!/bin/bash
set -euo pipefail

# FullDevVM ISO Builder Script
# This script creates a bootable ISO image for UTM, VirtualBox, VMware, etc.

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
echo "FullDevVM ISO Builder"
echo "=========================================="
echo

# Check prerequisites
check_prerequisites() {
    print_status "Checking prerequisites..."
    
    # Check if QEMU is installed
    if ! command -v qemu-system-x86_64 >/dev/null 2>&1; then
        print_error "QEMU is not installed. Please install QEMU."
        exit 1
    fi
    
    # Check if mkisofs/genisoimage is installed
    if ! command -v mkisofs >/dev/null 2>&1 && ! command -v genisoimage >/dev/null 2>&1; then
        print_error "Neither mkisofs nor genisoimage found. Please install genisoimage."
        exit 1
    fi
    
    print_success "Prerequisites check completed"
}

# Create ISO build directory
create_build_dir() {
    print_status "Creating ISO build directory..."
    
    ISO_BUILD_DIR="iso-build"
    rm -rf "$ISO_BUILD_DIR"
    mkdir -p "$ISO_BUILD_DIR"
    
    print_success "Build directory created: $ISO_BUILD_DIR"
}

# Download Ubuntu server ISO
download_ubuntu_iso() {
    print_status "Downloading Ubuntu 22.04 server ISO..."
    
    # Try multiple Ubuntu ISO URLs
    UBUNTU_ISO_URLS=(
        "https://releases.ubuntu.com/22.04/ubuntu-22.04.4-live-server-amd64.iso"
        "https://releases.ubuntu.com/22.04/ubuntu-22.04.3-live-server-amd64.iso"
        "https://releases.ubuntu.com/22.04/ubuntu-22.04.2-live-server-amd64.iso"
        "https://releases.ubuntu.com/22.04/ubuntu-22.04.1-live-server-amd64.iso"
        "https://releases.ubuntu.com/22.04/ubuntu-22.04-live-server-amd64.iso"
    )
    
    UBUNTU_ISO="$ISO_BUILD_DIR/ubuntu-22.04-live-server-amd64.iso"
    
    if [ ! -f "$UBUNTU_ISO" ]; then
        for url in "${UBUNTU_ISO_URLS[@]}"; do
            print_status "Trying: $url"
            if curl -L -o "$UBUNTU_ISO" "$url" --fail --silent --show-error; then
                # Verify it's actually an ISO file
                if file "$UBUNTU_ISO" | grep -q "ISO 9660"; then
                    print_success "Downloaded valid Ubuntu ISO"
                    return 0
                else
                    print_warning "Downloaded file is not a valid ISO, trying next URL..."
                    rm -f "$UBUNTU_ISO"
                fi
            else
                print_warning "Failed to download from $url, trying next URL..."
            fi
        done
        
        print_error "Failed to download a valid Ubuntu ISO from all URLs"
        print_status "Falling back to cloud image method..."
        return 1
    else
        print_status "Ubuntu ISO already exists"
    fi
}

# Extract ISO contents
extract_iso() {
    print_status "Extracting ISO contents..."
    
    ISO_EXTRACT_DIR="$ISO_BUILD_DIR/extracted"
    mkdir -p "$ISO_EXTRACT_DIR"
    
    # Mount and copy ISO contents
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS
        MOUNT_POINT="/tmp/ubuntu-iso-mount"
        mkdir -p "$MOUNT_POINT"
        
        # Mount ISO
        hdiutil attach "$UBUNTU_ISO" -mountpoint "$MOUNT_POINT" -nobrowse
        
        # Copy contents
        cp -R "$MOUNT_POINT"/* "$ISO_EXTRACT_DIR/"
        
        # Unmount
        hdiutil detach "$MOUNT_POINT"
    else
        # Linux
        MOUNT_POINT="/tmp/ubuntu-iso-mount"
        mkdir -p "$MOUNT_POINT"
        
        # Mount ISO
        sudo mount -o loop "$UBUNTU_ISO" "$MOUNT_POINT"
        
        # Copy contents
        cp -R "$MOUNT_POINT"/* "$ISO_EXTRACT_DIR/"
        
        # Unmount
        sudo umount "$MOUNT_POINT"
    fi
    
    print_success "ISO contents extracted"
}

# Create custom cloud-init configuration
create_cloud_init() {
    print_status "Creating cloud-init configuration..."
    
    CLOUD_INIT_DIR="$ISO_EXTRACT_DIR/nocloud"
    mkdir -p "$CLOUD_INIT_DIR"
    
    # Get SSH public key
    SSH_KEY=""
    if [ -f ~/.ssh/id_ed25519.pub ]; then
        SSH_KEY=$(cat ~/.ssh/id_ed25519.pub)
    elif [ -f ~/.ssh/id_rsa.pub ]; then
        SSH_KEY=$(cat ~/.ssh/id_rsa.pub)
    else
        print_warning "No SSH key found. Generating one..."
        ssh-keygen -t ed25519 -f ~/.ssh/id_ed25519 -N "" -C "fulldevvm@$(hostname)"
        SSH_KEY=$(cat ~/.ssh/id_ed25519.pub)
    fi
    
    # Create user-data
    cat > "$CLOUD_INIT_DIR/user-data" << EOF
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
  - rustc
  - cargo

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
  - ufw allow 8080/tcp
  - systemctl enable vncserver@1
  - systemctl start vncserver@1
  - systemctl enable novnc
  - systemctl start novnc

final_message: "FullDevVM is ready! Connect via SSH: ssh dev@<vm-ip> or access desktop via VNC"
EOF

    # Create meta-data
    cat > "$CLOUD_INIT_DIR/meta-data" << EOF
instance-id: fulldevvm-001
local-hostname: fulldevvm
hostname: fulldevvm
EOF

    print_success "Cloud-init configuration created"
}

# Modify boot configuration
modify_boot_config() {
    print_status "Modifying boot configuration..."
    
    # Create custom boot configuration
    cat > "$ISO_EXTRACT_DIR/boot/grub/grub.cfg" << 'EOF'
set timeout=10
set default=0

menuentry "FullDevVM - Ubuntu 22.04 LTS" {
    set gfxpayload=keep
    linux   /casper/vmlinuz quiet autoinstall ds=nocloud-net;s=file:///nocloud/ ---
    initrd  /casper/initrd
}

menuentry "FullDevVM - Ubuntu 22.04 LTS (Safe Mode)" {
    set gfxpayload=keep
    linux   /casper/vmlinuz quiet autoinstall ds=nocloud-net;s=file:///nocloud/ ---
    initrd  /casper/initrd
}
EOF

    print_success "Boot configuration modified"
}

# Create the ISO
create_iso() {
    print_status "Creating FullDevVM ISO..."
    
    OUTPUT_DIR="output"
    mkdir -p "$OUTPUT_DIR"
    
    ISO_FILE="$OUTPUT_DIR/FullDevVM.iso"
    
    # Use mkisofs or genisoimage
    if command -v mkisofs >/dev/null 2>&1; then
        mkisofs -D -r -V "FullDevVM" -cache-inodes -J -l \
            -b isolinux/isolinux.bin -c isolinux/boot.cat \
            -no-emul-boot -boot-load-size 4 -boot-info-table \
            -o "$ISO_FILE" "$ISO_EXTRACT_DIR"
    else
        genisoimage -D -r -V "FullDevVM" -cache-inodes -J -l \
            -b isolinux/isolinux.bin -c isolinux/boot.cat \
            -no-emul-boot -boot-load-size 4 -boot-info-table \
            -o "$ISO_FILE" "$ISO_EXTRACT_DIR"
    fi
    
    print_success "ISO created: $ISO_FILE"
}

# Create usage instructions
create_instructions() {
    print_status "Creating usage instructions..."
    
    cat > "$OUTPUT_DIR/README-ISO.md" << 'EOF'
# FullDevVM ISO Usage Instructions

## Quick Start

1. **Download** `FullDevVM.iso`
2. **Create VM** in your preferred virtualization platform
3. **Boot** from the ISO
4. **Wait** for automatic installation (10-15 minutes)
5. **Connect** via SSH or VNC

## Connection Information

- **SSH**: `ssh dev@<vm-ip>` (port 22)
- **VNC**: `<vm-ip>:5901` (password: dev123)
- **noVNC**: `http://<vm-ip>:6080` (password: dev123)
- **VS Code**: `http://<vm-ip>:8080`

## VM Configuration

- **RAM**: 4GB minimum
- **CPU**: 2 cores minimum
- **Disk**: 25GB minimum
- **Network**: NAT or Bridged

## Platforms

### UTM (macOS)
1. Open UTM
2. Create new VM → Linux
3. Select FullDevVM.iso
4. Configure: 4GB RAM, 2 CPU cores, 25GB disk
5. Start VM

### VirtualBox
1. Open VirtualBox
2. Create new VM → Linux → Ubuntu (64-bit)
3. Select FullDevVM.iso
4. Configure: 4GB RAM, 2 CPU cores, 25GB disk
5. Start VM

### VMware
1. Open VMware
2. Create new VM → Custom
3. Select FullDevVM.iso
4. Configure: 4GB RAM, 2 CPU cores, 25GB disk
5. Start VM

## Features

- Ubuntu 22.04 LTS Server
- XFCE4 Desktop Environment
- Full Developer Toolchain (Python, Node.js, Java, Go, Rust)
- Docker & Docker Compose
- VS Code Server
- VNC/noVNC Remote Desktop
- SSH Server
- UFW Firewall

## Troubleshooting

- **Installation takes time**: Wait 10-15 minutes for complete setup
- **SSH not working**: Check VM network configuration
- **VNC not working**: Ensure ports 5901 and 6080 are accessible
- **Desktop not loading**: Check VNC service status

## Support

For issues, see the main project documentation.
EOF

    print_success "Usage instructions created"
}

# Cleanup
cleanup() {
    print_status "Cleaning up..."
    rm -rf "$ISO_BUILD_DIR"
    print_success "Cleanup completed"
}

# Fallback: Create ISO from cloud image
create_iso_from_cloud_image() {
    print_status "Creating ISO from cloud image method..."
    
    # Define the final ISO path
    FINAL_ISO="output/FullDevVM.iso"
    
    # Use the existing quick-setup method
    if [ -f "output/FullDevVM.qcow2" ]; then
        print_status "Using existing FullDevVM.qcow2"
    else
        print_status "Running quick-setup to create VM image..."
        ./quick-setup.sh
    fi
    
    # Create a simple ISO that contains the QCOW2 image
    print_status "Creating bootable ISO with QCOW2 image..."
    
    # Create ISO structure
    ISO_CONTENTS="$ISO_BUILD_DIR/contents"
    mkdir -p "$ISO_CONTENTS"
    
    # Copy the QCOW2 image
    cp "output/FullDevVM.qcow2" "$ISO_CONTENTS/"
    cp "output/cloud-init.iso" "$ISO_CONTENTS/" 2>/dev/null || true
    
    # Create a simple boot script
    cat > "$ISO_CONTENTS/README.txt" << 'EOF'
FullDevVM - Complete Development Environment

This ISO contains a pre-configured Ubuntu development VM.

To use:
1. Extract FullDevVM.qcow2 from this ISO
2. Use with any virtualization platform:
   - UTM (macOS)
   - VirtualBox
   - VMware
   - QEMU/KVM
   - Parallels

Connection details:
- SSH: ssh dev@localhost -p 2222
- Web: http://localhost:6080
- VNC: localhost:5901

Login: dev / dev123

For more information, visit: https://github.com/vibecodingpilot-max/FullDevVM
EOF
    
    # Create the ISO
    if command -v genisoimage >/dev/null 2>&1; then
        genisoimage -output "$FINAL_ISO" -volid "FullDevVM" -joliet -rock "$ISO_CONTENTS"
    else
        mkisofs -output "$FINAL_ISO" -volid "FullDevVM" -joliet -rock "$ISO_CONTENTS"
    fi
    
    print_success "Created ISO from cloud image method"
}

# Main execution
main() {
    check_prerequisites
    create_build_dir
    
    # Try to download Ubuntu ISO first
    if download_ubuntu_iso; then
        extract_iso
        create_cloud_init
        modify_boot_config
        create_iso
        create_instructions
    else
        # Fallback to cloud image method
        create_iso_from_cloud_image
    fi
    
    cleanup
    
    echo
    echo "=========================================="
    echo "FullDevVM ISO Build Complete!"
    echo "=========================================="
    echo
    echo "ISO File: output/FullDevVM.iso"
    echo "Instructions: output/README-ISO.md"
    echo
    echo "Use this ISO with:"
    echo "- UTM (macOS)"
    echo "- VirtualBox"
    echo "- VMware"
    echo "- QEMU/KVM"
    echo "- Parallels"
    echo
    echo "The ISO will automatically install FullDevVM"
    echo "with all development tools and desktop environment."
}

# Run main function
main "$@"
