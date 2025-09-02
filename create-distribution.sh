#!/bin/bash
set -euo pipefail

# FullDevVM Distribution Creator
# This script creates a distribution package with ISO and instructions

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
echo "FullDevVM Distribution Creator"
echo "=========================================="
echo

# Create distribution directory
create_distribution() {
    print_status "Creating distribution package..."
    
    DIST_DIR="FullDevVM-Distribution"
    rm -rf "$DIST_DIR"
    mkdir -p "$DIST_DIR"
    
    # Copy essential files
    cp README.md "$DIST_DIR/"
    cp docs/CONNECT.md "$DIST_DIR/"
    cp docs/SECURITY.md "$DIST_DIR/"
    cp docs/CONTEXT.md "$DIST_DIR/"
    
    # Copy build scripts
    cp build-iso.sh "$DIST_DIR/"
    cp quick-setup.sh "$DIST_DIR/"
    
    # Copy cloud-init configuration
    cp -r cloud-init "$DIST_DIR/"
    
    # Copy systemd services
    cp -r systemd "$DIST_DIR/"
    
    # Copy scripts
    cp -r scripts "$DIST_DIR/"
    
    # Copy tests
    cp -r tests "$DIST_DIR/"
    
    print_success "Distribution directory created: $DIST_DIR"
}

# Create distribution README
create_distribution_readme() {
    print_status "Creating distribution README..."
    
    cat > "$DIST_DIR/README.md" << 'EOF'
# FullDevVM - Complete Linux OS for Cursor AI IDE

A complete, installable full Linux operating system image configured with a graphical desktop and a full polyglot developer toolchain for Cursor AI IDE.

## Quick Start

### Prerequisites
- QEMU/KVM, VirtualBox, VMware, or UTM
- 8GB+ RAM, 20GB+ disk space

### Option 1: Build Bootable ISO (Recommended)
```bash
# Create bootable ISO for any virtualization platform
./build-iso.sh

# This creates: FullDevVM.iso
# Use with UTM, VirtualBox, VMware, QEMU/KVM, Parallels
```

### Option 2: Quick Setup (For testing)
```bash
# Fast setup using Ubuntu cloud image
./quick-setup.sh
```

## Using the ISO

### UTM (macOS)
1. Download `FullDevVM.iso`
2. Open UTM
3. Create new VM → Linux
4. Select the ISO file
5. Configure: 4GB RAM, 2 CPU cores, 25GB disk
6. Start the VM

### VirtualBox
1. Download `FullDevVM.iso`
2. Open VirtualBox
3. Create new VM → Linux → Ubuntu (64-bit)
4. Select the ISO file
5. Configure: 4GB RAM, 2 CPU cores, 25GB disk
6. Start the VM

### VMware
1. Download `FullDevVM.iso`
2. Open VMware
3. Create new VM → Custom
4. Select the ISO file
5. Configure: 4GB RAM, 2 CPU cores, 25GB disk
6. Start the VM

## Connection Information

- **SSH**: `ssh dev@<vm-ip>` (port 22)
- **VNC**: `<vm-ip>:5901` (password: dev123)
- **noVNC**: `http://<vm-ip>:6080` (password: dev123)
- **VS Code**: `http://<vm-ip>:8080`

## Features

- **Base OS**: Ubuntu 22.04 LTS Server
- **Desktop**: XFCE4 with noVNC web interface
- **Languages**: Python 3.11+, Node.js 18.x, Java 17, Go 1.20+, Rust
- **Tools**: Docker, Git, VS Code Server, debugging tools
- **Security**: SSH key-only, UFW firewall, no root login

## Installation Process

1. **Boot** from the ISO
2. **Wait** for automatic installation (10-15 minutes)
3. **Connect** via SSH or VNC
4. **Start developing** with Cursor AI IDE

## Troubleshooting

- **Installation takes time**: Wait 10-15 minutes for complete setup
- **SSH not working**: Check VM network configuration
- **VNC not working**: Ensure ports 5901 and 6080 are accessible
- **Desktop not loading**: Check VNC service status

## Support

For detailed documentation, see:
- [CONNECT.md](CONNECT.md) - Connection instructions
- [SECURITY.md](SECURITY.md) - Security configuration
- [CONTEXT.md](CONTEXT.md) - Full project specification

## License

This project is open source. See the main repository for license information.
EOF

    print_success "Distribution README created"
}

# Create installation script
create_install_script() {
    print_status "Creating installation script..."
    
    cat > "$DIST_DIR/install.sh" << 'EOF'
#!/bin/bash
set -euo pipefail

# FullDevVM Installation Script
# This script helps users install FullDevVM

echo "=========================================="
echo "FullDevVM Installation Helper"
echo "=========================================="
echo

# Check if running on macOS
if [[ "$OSTYPE" == "darwin"* ]]; then
    echo "macOS detected. Recommended options:"
    echo "1. UTM (Free, App Store)"
    echo "2. VirtualBox (Free)"
    echo "3. VMware Fusion (Paid)"
    echo "4. Parallels (Paid)"
    echo
    echo "For UTM:"
    echo "1. Install UTM from App Store"
    echo "2. Create new VM → Linux"
    echo "3. Select FullDevVM.iso"
    echo "4. Configure: 4GB RAM, 2 CPU cores, 25GB disk"
    echo
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    echo "Linux detected. Recommended options:"
    echo "1. QEMU/KVM (Free)"
    echo "2. VirtualBox (Free)"
    echo "3. VMware Workstation (Paid)"
    echo
    echo "For QEMU/KVM:"
    echo "qemu-system-x86_64 -m 4G -smp 2 -cdrom FullDevVM.iso -boot d -enable-kvm"
    echo
elif [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "cygwin" ]]; then
    echo "Windows detected. Recommended options:"
    echo "1. VirtualBox (Free)"
    echo "2. VMware Workstation (Paid)"
    echo "3. Hyper-V (Windows Pro/Enterprise)"
    echo
fi

echo "General steps:"
echo "1. Download FullDevVM.iso"
echo "2. Create new VM in your virtualization platform"
echo "3. Select the ISO file"
echo "4. Configure: 4GB RAM, 2 CPU cores, 25GB disk"
echo "5. Start the VM"
echo "6. Wait for installation (10-15 minutes)"
echo "7. Connect via SSH or VNC"
echo
echo "Connection information:"
echo "- SSH: ssh dev@<vm-ip>"
echo "- VNC: <vm-ip>:5901 (password: dev123)"
echo "- noVNC: http://<vm-ip>:6080 (password: dev123)"
echo "- VS Code: http://<vm-ip>:8080"
EOF

    chmod +x "$DIST_DIR/install.sh"
    print_success "Installation script created"
}

# Create archive
create_archive() {
    print_status "Creating distribution archive..."
    
    ARCHIVE_NAME="FullDevVM-Distribution-$(date +%Y%m%d).tar.gz"
    
    tar -czf "$ARCHIVE_NAME" "$DIST_DIR"
    
    print_success "Distribution archive created: $ARCHIVE_NAME"
    
    # Show archive info
    ARCHIVE_SIZE=$(du -h "$ARCHIVE_NAME" | cut -f1)
    print_status "Archive size: $ARCHIVE_SIZE"
}

# Main execution
main() {
    create_distribution
    create_distribution_readme
    create_install_script
    create_archive
    
    echo
    echo "=========================================="
    echo "Distribution Package Complete!"
    echo "=========================================="
    echo
    echo "Distribution directory: $DIST_DIR"
    echo "Archive: $ARCHIVE_NAME"
    echo
    echo "To distribute:"
    echo "1. Share the archive file"
    echo "2. Users extract and run ./build-iso.sh"
    echo "3. Users get FullDevVM.iso for their platform"
    echo
    echo "The distribution includes:"
    echo "- Build scripts"
    echo "- Documentation"
    echo "- Configuration files"
    echo "- Installation helper"
}

# Run main function
main "$@"
