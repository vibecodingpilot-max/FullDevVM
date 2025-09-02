#!/bin/bash
set -euo pipefail

# FullDevVM Build Script
# This script builds the FullDevVM image using Packer

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
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

# Check prerequisites
check_prerequisites() {
    print_status "Checking prerequisites..."
    
    # Check if Packer is installed
    if ! command -v packer >/dev/null 2>&1; then
        print_error "Packer is not installed. Please install HashiCorp Packer."
        exit 1
    fi
    
    # Check if QEMU is installed
    if ! command -v qemu-system-x86_64 >/dev/null 2>&1; then
        print_error "QEMU is not installed. Please install QEMU/KVM."
        exit 1
    fi
    
    # Check if KVM is available
    if [ ! -e /dev/kvm ]; then
        print_warning "KVM is not available. VM will run in software emulation mode (slower)."
    fi
    
    print_success "Prerequisites check completed"
}

# Get SSH public key
get_ssh_key() {
    print_status "Checking for SSH public key..."
    
    # Check for common SSH key locations
    SSH_KEY_LOCATIONS=(
        "$HOME/.ssh/id_rsa.pub"
        "$HOME/.ssh/id_ed25519.pub"
        "$HOME/.ssh/id_ecdsa.pub"
        "$HOME/.ssh/id_dsa.pub"
    )
    
    SSH_PUBLIC_KEY=""
    for key_path in "${SSH_KEY_LOCATIONS[@]}"; do
        if [ -f "$key_path" ]; then
            SSH_PUBLIC_KEY=$(cat "$key_path")
            print_success "Found SSH public key: $key_path"
            break
        fi
    done
    
    if [ -z "$SSH_PUBLIC_KEY" ]; then
        print_warning "No SSH public key found. You will need to add one manually after build."
        print_status "To generate a new SSH key: ssh-keygen -t ed25519 -C 'your-email@example.com'"
        SSH_PUBLIC_KEY=""
    fi
}

# Create variables file
create_variables() {
    print_status "Creating variables file..."
    
    cat > packer/variables.json << EOF
{
  "ubuntu_version": "22.04",
  "ubuntu_iso_checksum": "sha256:5e38b55d57d94ff029719342357325ed3bda38fa80054f9330dc789cd2d43931",
  "ssh_public_key": "$SSH_PUBLIC_KEY",
  "vm_name": "FullDevVM",
  "memory": "4096",
  "cpus": "2",
  "disk_size": "25G"
}
EOF
    
    print_success "Variables file created"
}

# Build the VM
build_vm() {
    print_status "Starting VM build process..."
    print_status "This may take 30-60 minutes depending on your system..."
    
    # Create output directory
    mkdir -p output
    
    # Build with Packer
    if packer build -var-file="packer/variables.json" packer/ubuntu-server.pkr.hcl; then
        print_success "VM build completed successfully!"
    else
        print_error "VM build failed!"
        exit 1
    fi
}

# Verify build
verify_build() {
    print_status "Verifying build..."
    
    if [ -f "output/FullDevVM.qcow2" ]; then
        print_success "VM image created: output/FullDevVM.qcow2"
        
        # Get image size
        IMAGE_SIZE=$(du -h output/FullDevVM.qcow2 | cut -f1)
        print_status "Image size: $IMAGE_SIZE"
        
        # Get image info
        if command -v qemu-img >/dev/null 2>&1; then
            print_status "Image information:"
            qemu-img info output/FullDevVM.qcow2
        fi
    else
        print_error "VM image not found!"
        exit 1
    fi
}

# Show usage instructions
show_usage() {
    print_success "Build completed! Next steps:"
    echo
    echo "1. Start the VM:"
    echo "   qemu-system-x86_64 \\"
    echo "     -m 4G \\"
    echo "     -smp 2 \\"
    echo "     -drive file=output/FullDevVM.qcow2,format=qcow2 \\"
    echo "     -netdev user,id=net0,hostfwd=tcp::2222-:22,hostfwd=tcp::6080-:6080 \\"
    echo "     -device virtio-net-pci,netdev=net0 \\"
    echo "     -enable-kvm"
    echo
    echo "2. Connect via SSH:"
    echo "   ssh -p 2222 dev@localhost"
    echo
    echo "3. Access desktop:"
    echo "   http://localhost:6080 (password: dev123)"
    echo
    echo "4. Access VS Code:"
    echo "   http://localhost:8080"
    echo
    echo "See docs/CONNECT.md for detailed connection instructions."
}

# Main execution
main() {
    echo "=========================================="
    echo "FullDevVM Build Script"
    echo "=========================================="
    echo
    
    check_prerequisites
    get_ssh_key
    create_variables
    build_vm
    verify_build
    show_usage
}

# Run main function
main "$@"
