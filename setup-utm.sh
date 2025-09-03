#!/bin/bash

# FullDevVM UTM Setup Script
# Helps extract and configure FullDevVM for UTM on macOS

set -euo pipefail

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
echo "FullDevVM UTM Setup for macOS"
echo "=========================================="
echo

# Check if UTM is installed
if ! command -v utmctl >/dev/null 2>&1; then
    print_warning "UTM command line tools not found"
    print_status "Please install UTM from the Mac App Store or:"
    print_status "brew install --cask utm"
    echo
fi

# Check if ISO exists
if [ ! -f "output/FullDevVM.iso" ]; then
    print_error "FullDevVM.iso not found in output/ directory"
    print_status "Please run ./build-iso.sh first"
    exit 1
fi

print_status "Setting up FullDevVM for UTM..."

# Create UTM directory
UTM_DIR="output/utm-setup"
mkdir -p "$UTM_DIR"

# Mount the ISO to extract files
print_status "Mounting FullDevVM.iso..."
MOUNT_POINT="/tmp/fulldevvm-iso-mount"
mkdir -p "$MOUNT_POINT"

# Mount ISO (macOS)
hdiutil attach "output/FullDevVM.iso" -mountpoint "$MOUNT_POINT" -nobrowse

# Copy files
print_status "Extracting files from ISO..."
cp "$MOUNT_POINT"/* "$UTM_DIR/"

# Unmount
hdiutil detach "$MOUNT_POINT"

print_success "Files extracted to: $UTM_DIR"

# Create UTM configuration
print_status "Creating UTM configuration..."

cat > "$UTM_DIR/FullDevVM.utm" << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>ConfigurationVersion</key>
    <integer>2</integer>
    <key>Name</key>
    <string>FullDevVM</string>
    <key>System</key>
    <dict>
        <key>Architecture</key>
        <string>arm64</string>
        <key>Boot</key>
        <dict>
            <key>BootUefi</key>
            <true/>
        </dict>
        <key>CPU</key>
        <integer>2</integer>
        <key>Memory</key>
        <integer>4096</integer>
        <key>Target</key>
        <string>qemu</string>
    </dict>
    <key>Drives</key>
    <array>
        <dict>
            <key>ImagePath</key>
            <string>FullDevVM.qcow2</string>
            <key>ImageType</key>
            <string>disk</string>
            <key>Interface</key>
            <string>virtio</string>
        </dict>
    </array>
    <key>Network</key>
    <dict>
        <key>Mode</key>
        <string>shared</string>
    </dict>
    <key>Display</key>
    <dict>
        <key>ConsoleOnly</key>
        <false/>
        <key>Width</key>
        <integer>1024</integer>
        <key>Height</key>
        <integer>768</integer>
    </dict>
</dict>
</plist>
EOF

print_success "UTM configuration created: $UTM_DIR/FullDevVM.utm"

# Create setup instructions
cat > "$UTM_DIR/README-UTM.txt" << 'EOF'
FullDevVM UTM Setup Instructions
================================

1. Open UTM
2. Click "Open" and select FullDevVM.utm
3. The VM will start with FullDevVM

Connection Details:
- SSH: ssh dev@localhost -p 2222
- Web Desktop: http://localhost:6080
- VNC Desktop: localhost:5901

Login Credentials:
- Username: dev
- Password: dev123

Features:
- Ubuntu 22.04 LTS with XFCE4 desktop
- Full development toolchain (Python, Node.js, Java, Go, Rust)
- Docker & VS Code Server
- VNC/noVNC remote access
- SSH server

For more information, visit:
https://github.com/vibecodingpilot-max/FullDevVM
EOF

print_success "Setup instructions created: $UTM_DIR/README-UTM.txt"

echo
echo "=========================================="
echo "UTM Setup Complete!"
echo "=========================================="
echo
print_status "Files created in: $UTM_DIR"
print_status "1. Open UTM"
print_status "2. Click 'Open' and select: $UTM_DIR/FullDevVM.utm"
print_status "3. The VM will start with FullDevVM"
echo
print_status "Connection details:"
print_status "  SSH: ssh dev@localhost -p 2222"
print_status "  Web: http://localhost:6080"
print_status "  VNC: localhost:5901"
echo
print_status "Login: dev / dev123"
echo
print_success "Ready to code! 🚀"
