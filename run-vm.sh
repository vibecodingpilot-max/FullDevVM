#!/bin/bash
set -euo pipefail

# FullDevVM Run Script
# This script starts the FullDevVM with proper configuration

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

# Check if VM image exists
check_vm_image() {
    if [ ! -f "output/FullDevVM.qcow2" ]; then
        print_error "VM image not found: output/FullDevVM.qcow2"
        print_status "Please run ./build.sh first to build the VM"
        exit 1
    fi
    print_success "VM image found"
}

# Check if QEMU is available
check_qemu() {
    if ! command -v qemu-system-x86_64 >/dev/null 2>&1; then
        print_error "QEMU is not installed. Please install QEMU/KVM."
        exit 1
    fi
    print_success "QEMU is available"
}

# Check if KVM is available
check_kvm() {
    if [ -e /dev/kvm ]; then
        print_success "KVM acceleration is available"
        return 0
    else
        print_warning "KVM is not available. VM will run in software emulation mode (slower)."
        return 1
    fi
}

# Get system resources
get_system_info() {
    # Get available memory
    if command -v free >/dev/null 2>&1; then
        AVAILABLE_MEM=$(free -m | awk 'NR==2{printf "%.0f", $7}')
        if [ "$AVAILABLE_MEM" -gt 4096 ]; then
            VM_MEMORY="4096"
        elif [ "$AVAILABLE_MEM" -gt 2048 ]; then
            VM_MEMORY="2048"
        else
            VM_MEMORY="1024"
            print_warning "Low memory available. VM will use 1GB RAM."
        fi
    else
        VM_MEMORY="2048"
    fi
    
    # Get CPU count
    if command -v nproc >/dev/null 2>&1; then
        CPU_COUNT=$(nproc)
        if [ "$CPU_COUNT" -gt 4 ]; then
            VM_CPUS="4"
        elif [ "$CPU_COUNT" -gt 2 ]; then
            VM_CPUS="2"
        else
            VM_CPUS="1"
        fi
    else
        VM_CPUS="2"
    fi
    
    print_status "VM will use ${VM_MEMORY}MB RAM and ${VM_CPUS} CPU cores"
}

# Start the VM
start_vm() {
    print_status "Starting FullDevVM..."
    
    # Check if VM is already running
    if pgrep -f "FullDevVM.qcow2" >/dev/null; then
        print_warning "VM appears to be already running"
        print_status "If you want to start a new instance, please stop the existing one first"
        exit 1
    fi
    
    # Build QEMU command
    QEMU_CMD="qemu-system-x86_64"
    QEMU_CMD="$QEMU_CMD -m $VM_MEMORY"
    QEMU_CMD="$QEMU_CMD -smp $VM_CPUS"
    QEMU_CMD="$QEMU_CMD -drive file=output/FullDevVM.qcow2,format=qcow2"
    QEMU_CMD="$QEMU_CMD -netdev user,id=net0,hostfwd=tcp::2222-:22,hostfwd=tcp::6080-:6080,hostfwd=tcp::8080-:8080"
    QEMU_CMD="$QEMU_CMD -device virtio-net-pci,netdev=net0"
    
    # Add KVM acceleration if available
    if check_kvm; then
        QEMU_CMD="$QEMU_CMD -enable-kvm"
    fi
    
    # Add display options
    QEMU_CMD="$QEMU_CMD -display gtk"
    
    print_status "Starting VM with command:"
    echo "$QEMU_CMD"
    echo
    
    # Start VM in background
    $QEMU_CMD &
    VM_PID=$!
    
    print_success "VM started with PID: $VM_PID"
    
    # Wait a moment for VM to start
    sleep 5
    
    # Check if VM is still running
    if kill -0 $VM_PID 2>/dev/null; then
        print_success "VM is running successfully!"
        show_connection_info
    else
        print_error "VM failed to start"
        exit 1
    fi
}

# Show connection information
show_connection_info() {
    echo
    echo "=========================================="
    echo "FullDevVM is now running!"
    echo "=========================================="
    echo
    echo "Connection Information:"
    echo "  SSH:        ssh -p 2222 dev@localhost"
    echo "  Desktop:    http://localhost:6080"
    echo "  VS Code:    http://localhost:8080"
    echo "  VNC:        localhost:5901"
    echo
    echo "Credentials:"
    echo "  VNC Password: dev123"
    echo "  SSH: Key-based authentication only"
    echo
    echo "Useful Commands:"
    echo "  Stop VM:    kill $VM_PID"
    echo "  Check Status: ps aux | grep FullDevVM"
    echo
    echo "See docs/CONNECT.md for detailed connection instructions."
    echo
}

# Main execution
main() {
    echo "=========================================="
    echo "FullDevVM Run Script"
    echo "=========================================="
    echo
    
    check_vm_image
    check_qemu
    get_system_info
    start_vm
}

# Run main function
main "$@"
