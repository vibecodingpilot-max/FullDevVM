# FullDevVM - Complete Linux Development Environment

A complete, bootable Linux development environment with desktop GUI and full polyglot developer toolchain, optimized for Cursor AI IDE.

## 🚀 Quick Start

### Download & Use
1. **Download** `FullDevVM.iso` from releases
2. **Create VM** in your virtualization platform
3. **Boot** from the ISO
4. **Wait** 10-15 minutes for automatic setup
5. **Connect** and start coding!

### Supported Platforms
- **UTM** (macOS) - Recommended
- **VirtualBox** (All platforms)
- **VMware** (All platforms)
- **QEMU/KVM** (Linux)
- **Parallels** (macOS)

## 📋 VM Configuration

| Setting | Value |
|---------|-------|
| **RAM** | 4GB minimum |
| **CPU** | 2 cores minimum |
| **Disk** | 25GB minimum |
| **Network** | NAT or Bridged |

## 🔗 Connection Methods

| Method | Access | Credentials |
|--------|--------|-------------|
| **SSH** | `ssh dev@<vm-ip>` | SSH key only |
| **VNC** | `<vm-ip>:5901` | Password: `dev123` |
| **noVNC** | `http://<vm-ip>:6080` | Password: `dev123` |
| **VS Code** | `http://<vm-ip>:8080` | No auth required |

## 🛠️ Pre-installed Tools

### Languages & Runtimes
- **Python 3.11+** with pip, virtualenv
- **Node.js 18.x** with npm, yarn
- **Java 17** (OpenJDK)
- **Go 1.20+**
- **Rust** with cargo
- **C/C++** with GCC, Make, CMake

### Development Tools
- **Git** - Version control
- **Docker** - Containerization
- **VS Code Server** - Web-based IDE
- **Vim** - Text editor
- **htop, tree** - System tools

### Desktop Environment
- **XFCE4** - Lightweight desktop
- **Firefox** - Web browser
- **VNC/noVNC** - Remote desktop access

## 🎯 Perfect For

- **Cursor AI IDE** development
- **Remote development** workflows
- **Cross-platform** development
- **Learning** Linux development
- **Isolated** development environments

## 📖 Platform-Specific Instructions

### UTM (macOS)
1. Open UTM
2. Create new VM → Linux
3. Select `FullDevVM.iso`
4. Configure: 4GB RAM, 2 CPU cores, 25GB disk
5. Start VM

### VirtualBox
1. Open VirtualBox
2. Create new VM → Linux → Ubuntu (64-bit)
3. Select `FullDevVM.iso`
4. Configure: 4GB RAM, 2 CPU cores, 25GB disk
5. Start VM

### VMware
1. Open VMware
2. Create new VM → Custom
3. Select `FullDevVM.iso`
4. Configure: 4GB RAM, 2 CPU cores, 25GB disk
5. Start VM

## 🔧 Building from Source

If you want to build your own ISO:

```bash
# Clone repository
git clone https://github.com/yourusername/FullDevVM.git
cd FullDevVM

# Build ISO
./build-iso.sh

# Creates: output/FullDevVM.iso
```

## 🛡️ Security Features

- **SSH key-only** authentication
- **UFW firewall** enabled
- **Fail2ban** intrusion detection
- **No root login** allowed
- **Audit logging** enabled

## 📁 Project Structure

```
FullDevVM/
├── build-iso.sh          # ISO builder
├── quick-setup.sh        # Quick VM setup
├── create-distribution.sh # Distribution creator
├── docs/                 # Documentation
├── scripts/              # Provisioning scripts
└── output/               # Built images
```

## 🆘 Troubleshooting

| Issue | Solution |
|-------|----------|
| **Installation takes time** | Wait 10-15 minutes for complete setup |
| **SSH not working** | Check VM network configuration |
| **VNC not working** | Ensure ports 5901 and 6080 are accessible |
| **Desktop not loading** | Check VNC service status |

## 📚 Documentation

- [INSTALL.md](INSTALL.md) - Complete installation guide
- [CONNECT.md](docs/CONNECT.md) - Detailed connection guide
- [SECURITY.md](docs/SECURITY.md) - Security configuration
- [CONTEXT.md](docs/CONTEXT.md) - Full project specification

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request

## 📄 License

This project is open source. See LICENSE file for details.

## ⭐ Star This Project

If FullDevVM helps you with your development workflow, please give it a star!

---

**Ready to code? Download the ISO and start developing in minutes!** 🚀