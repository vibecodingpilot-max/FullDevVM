#!/bin/bash
set -euo pipefail

# FullDevVM Release Creator
# This script creates a GitHub release with the ISO file

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
echo "FullDevVM Release Creator"
echo "=========================================="
echo

# Check if ISO exists
check_iso() {
    if [ ! -f "output/FullDevVM.iso" ]; then
        print_error "FullDevVM.iso not found. Please run ./build-iso.sh first."
        exit 1
    fi
    print_success "ISO file found"
}

# Get version
get_version() {
    if [ -z "${VERSION:-}" ]; then
        read -p "Enter version (e.g., v1.0.0): " VERSION
    fi
    
    if [ -z "$VERSION" ]; then
        VERSION="v1.0.0"
        print_warning "Using default version: $VERSION"
    fi
    
    print_status "Release version: $VERSION"
}

# Create release notes
create_release_notes() {
    print_status "Creating release notes..."
    
    cat > "RELEASE_NOTES.md" << EOF
# FullDevVM $VERSION

## 🚀 What's New

- Complete Linux development environment
- Ubuntu 22.04 LTS with XFCE4 desktop
- Full polyglot developer toolchain
- Cursor AI IDE optimized
- Cross-platform ISO support

## 📦 What's Included

- **FullDevVM.iso** - Bootable ISO image
- **FullDevVM-SHA256.txt** - Checksum verification

## 🛠️ Pre-installed Tools

### Languages & Runtimes
- Python 3.11+ with pip, virtualenv
- Node.js 18.x with npm, yarn
- Java 17 (OpenJDK)
- Go 1.20+
- Rust with cargo
- C/C++ with GCC, Make, CMake

### Development Tools
- Git - Version control
- Docker - Containerization
- VS Code Server - Web-based IDE
- Vim - Text editor
- htop, tree - System tools

### Desktop Environment
- XFCE4 - Lightweight desktop
- Firefox - Web browser
- VNC/noVNC - Remote desktop access

## 🚀 Quick Start

1. **Download** FullDevVM.iso
2. **Create VM** in your virtualization platform
3. **Boot** from the ISO
4. **Wait** 10-15 minutes for automatic setup
5. **Connect** and start coding!

## 🔗 Connection Methods

| Method | Access | Credentials |
|--------|--------|-------------|
| **SSH** | \`ssh dev@<vm-ip>\` | SSH key only |
| **VNC** | \`<vm-ip>:5901\` | Password: \`dev123\` |
| **noVNC** | \`http://<vm-ip>:6080\` | Password: \`dev123\` |
| **VS Code** | \`http://<vm-ip>:8080\` | No auth required |

## 📋 VM Configuration

| Setting | Value |
|---------|-------|
| **RAM** | 4GB minimum |
| **CPU** | 2 cores minimum |
| **Disk** | 25GB minimum |
| **Network** | NAT or Bridged |

## 🖥️ Supported Platforms

- **UTM** (macOS) - Recommended
- **VirtualBox** (All platforms)
- **VMware** (All platforms)
- **QEMU/KVM** (Linux)
- **Parallels** (macOS)

## 🛡️ Security Features

- SSH key-only authentication
- UFW firewall enabled
- Fail2ban intrusion detection
- No root login allowed
- Audit logging enabled

## 🆘 Troubleshooting

| Issue | Solution |
|-------|----------|
| **Installation takes time** | Wait 10-15 minutes for complete setup |
| **SSH not working** | Check VM network configuration |
| **VNC not working** | Ensure ports 5901 and 6080 are accessible |
| **Desktop not loading** | Check VNC service status |

## 📚 Documentation

- [README.md](README.md) - Quick start guide
- [CONNECT.md](docs/CONNECT.md) - Detailed connection guide
- [SECURITY.md](docs/SECURITY.md) - Security configuration

## 🤝 Contributing

Found a bug or want to contribute? Please open an issue or pull request!

## 📄 License

This project is open source. See LICENSE file for details.

---

**Ready to code? Download the ISO and start developing in minutes!** 🚀
EOF

    print_success "Release notes created"
}

# Create checksum
create_checksum() {
    print_status "Creating checksum file..."
    
    cd output
    sha256sum FullDevVM.iso > FullDevVM-SHA256.txt
    cd ..
    
    print_success "Checksum created: output/FullDevVM-SHA256.txt"
}

# Create GitHub release
create_github_release() {
    print_status "Creating GitHub release..."
    
    # Check if gh CLI is installed
    if ! command -v gh >/dev/null 2>&1; then
        print_warning "GitHub CLI (gh) not installed. Please install it or create release manually."
        print_status "To install: brew install gh (macOS) or visit https://cli.github.com/"
        print_status "Manual release creation:"
        echo "1. Go to GitHub repository"
        echo "2. Click 'Releases' → 'Create a new release'"
        echo "3. Tag: $VERSION"
        echo "4. Title: FullDevVM $VERSION"
        echo "5. Upload: output/FullDevVM.iso"
        echo "6. Upload: output/FullDevVM-SHA256.txt"
        echo "7. Copy content from RELEASE_NOTES.md"
        return 0
    fi
    
    # Check if user is logged in
    if ! gh auth status >/dev/null 2>&1; then
        print_warning "Not logged in to GitHub CLI. Please run: gh auth login"
        return 0
    fi
    
    # Create release
    gh release create "$VERSION" \
        --title "FullDevVM $VERSION" \
        --notes-file "RELEASE_NOTES.md" \
        "output/FullDevVM.iso" \
        "output/FullDevVM-SHA256.txt"
    
    print_success "GitHub release created: $VERSION"
}

# Show release info
show_release_info() {
    echo
    echo "=========================================="
    echo "Release Information"
    echo "=========================================="
    echo
    echo "Version: $VERSION"
    echo "ISO File: output/FullDevVM.iso"
    echo "Checksum: output/FullDevVM-SHA256.txt"
    echo "Release Notes: RELEASE_NOTES.md"
    echo
    echo "File sizes:"
    ls -lh output/FullDevVM.iso output/FullDevVM-SHA256.txt
    echo
    echo "Next steps:"
    echo "1. Upload to GitHub releases"
    echo "2. Share the release URL"
    echo "3. Users can download directly"
    echo
}

# Main execution
main() {
    check_iso
    get_version
    create_release_notes
    create_checksum
    create_github_release
    show_release_info
}

# Run main function
main "$@"
