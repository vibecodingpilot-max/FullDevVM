#!/bin/bash
set -euo pipefail

# FullDevVM GitHub Setup Automation
# This script automatically creates GitHub repository and pushes code

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
echo "FullDevVM GitHub Setup Automation"
echo "=========================================="
echo

# Check if GitHub CLI is installed
check_gh_cli() {
    if ! command -v gh >/dev/null 2>&1; then
        print_status "Installing GitHub CLI..."
        brew install gh
        print_success "GitHub CLI installed"
    else
        print_success "GitHub CLI is available"
    fi
}

# Authenticate with GitHub
authenticate_github() {
    print_status "Authenticating with GitHub..."
    
    if gh auth status >/dev/null 2>&1; then
        print_success "Already authenticated with GitHub"
        return 0
    fi
    
    print_warning "You need to authenticate with GitHub"
    print_status "This will open a browser window for authentication"
    
    # Start authentication in background
    gh auth login --web --scopes repo,workflow &
    AUTH_PID=$!
    
    print_status "Waiting for authentication to complete..."
    print_status "Please complete the authentication in your browser"
    
    # Wait for authentication to complete
    while ! gh auth status >/dev/null 2>&1; do
        sleep 2
        if ! kill -0 $AUTH_PID 2>/dev/null; then
            print_error "Authentication failed or was cancelled"
            exit 1
        fi
    done
    
    print_success "Successfully authenticated with GitHub"
}

# Get repository name
get_repo_name() {
    if [ -z "${REPO_NAME:-}" ]; then
        read -p "Enter GitHub repository name (default: FullDevVM): " REPO_NAME
        REPO_NAME=${REPO_NAME:-FullDevVM}
    fi
    
    print_status "Repository name: $REPO_NAME"
}

# Create GitHub repository
create_repository() {
    print_status "Creating GitHub repository: $REPO_NAME"
    
    # Check if repository already exists
    if gh repo view "$REPO_NAME" >/dev/null 2>&1; then
        print_warning "Repository $REPO_NAME already exists"
        read -p "Do you want to use the existing repository? (y/n): " USE_EXISTING
        if [[ "$USE_EXISTING" != "y" && "$USE_EXISTING" != "Y" ]]; then
            print_error "Please choose a different repository name"
            exit 1
        fi
        print_success "Using existing repository: $REPO_NAME"
        return 0
    fi
    
    # Create new repository
    gh repo create "$REPO_NAME" \
        --public \
        --description "Complete Linux development environment for Cursor AI IDE" \
        --source=. \
        --remote=origin \
        --push
    
    print_success "Repository created and code pushed to GitHub"
}

# Set up remote if not already set
setup_remote() {
    if git remote get-url origin >/dev/null 2>&1; then
        print_success "Remote origin already configured"
    else
        print_status "Setting up remote origin..."
        git remote add origin "https://github.com/$(gh api user --jq .login)/$REPO_NAME.git"
        print_success "Remote origin configured"
    fi
}

# Push code to GitHub
push_code() {
    print_status "Pushing code to GitHub..."
    
    # Ensure we're on main branch
    git branch -M main
    
    # Push to GitHub
    git push -u origin main
    
    print_success "Code pushed to GitHub successfully"
}

# Build ISO
build_iso() {
    print_status "Building ISO for release..."
    
    if [ ! -f "output/FullDevVM.iso" ]; then
        ./build-iso.sh
    else
        print_status "ISO already exists, skipping build"
    fi
    
    print_success "ISO ready for release"
}

# Create first release
create_first_release() {
    print_status "Creating first release..."
    
    # Create release notes
    cat > "RELEASE_NOTES.md" << 'EOF'
# FullDevVM v1.0.0

## 🚀 Complete Linux Development Environment

A complete, bootable Linux development environment with desktop GUI and full polyglot developer toolchain, optimized for Cursor AI IDE.

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
| **SSH** | `ssh dev@<vm-ip>` | SSH key only |
| **VNC** | `<vm-ip>:5901` | Password: `dev123` |
| **noVNC** | `http://<vm-ip>:6080` | Password: `dev123` |
| **VS Code** | `http://<vm-ip>:8080` | No auth required |

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
- [INSTALL.md](INSTALL.md) - Complete installation guide
- [CONNECT.md](docs/CONNECT.md) - Detailed connection guide
- [SECURITY.md](docs/SECURITY.md) - Security configuration

## 🤝 Contributing

Found a bug or want to contribute? Please open an issue or pull request!

## 📄 License

This project is open source. See LICENSE file for details.

---

**Ready to code? Download the ISO and start developing in minutes!** 🚀
EOF

    # Create checksum if it doesn't exist
    if [ ! -f "output/FullDevVM-SHA256.txt" ]; then
        cd output
        sha256sum FullDevVM.iso > FullDevVM-SHA256.txt
        cd ..
    fi
    
    # Create release
    gh release create v1.0.0 \
        --title "FullDevVM v1.0.0" \
        --notes-file "RELEASE_NOTES.md" \
        "output/FullDevVM.iso" \
        "output/FullDevVM-SHA256.txt"
    
    print_success "First release created successfully"
}

# Show final information
show_final_info() {
    echo
    echo "=========================================="
    echo "GitHub Setup Complete!"
    echo "=========================================="
    echo
    echo "Repository URL: https://github.com/$(gh api user --jq .login)/$REPO_NAME"
    echo "Releases URL: https://github.com/$(gh api user --jq .login)/$REPO_NAME/releases"
    echo
    echo "Your FullDevVM is now live on GitHub!"
    echo
    echo "Users can now:"
    echo "1. Go to the releases page"
    echo "2. Download FullDevVM.iso"
    echo "3. Follow the installation guide"
    echo "4. Start coding in minutes!"
    echo
    echo "Next steps:"
    echo "- Share the repository URL"
    echo "- Monitor downloads and feedback"
    echo "- Create new releases for updates"
    echo
}

# Main execution
main() {
    check_gh_cli
    authenticate_github
    get_repo_name
    create_repository
    setup_remote
    push_code
    build_iso
    create_first_release
    show_final_info
}

# Run main function
main "$@"
