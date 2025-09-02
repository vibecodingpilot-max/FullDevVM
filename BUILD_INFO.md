# FullDevVM Build Information

## Build Configuration

- **Base OS**: Ubuntu 22.04.3 LTS Server
- **ISO Checksum**: `sha256:5e38b55d57d94ff029719342357325ed3bda38fa80054f9330dc789cd2d43931`
- **Build Date**: $(date)
- **Packer Version**: $(packer version)
- **Build Host**: $(hostname)

## Target Specifications

- **VM Name**: FullDevVM
- **Memory**: 4GB (configurable)
- **CPUs**: 2 (configurable)
- **Disk Size**: 25GB (configurable)
- **Format**: QCOW2 (QEMU/KVM) / OVA (VirtualBox)

## Included Components

### Desktop Environment
- XFCE4 Desktop Environment
- TigerVNC Server
- noVNC Web Interface
- XRDP (optional)

### Development Tools
- **Languages**: Python 3.11+, Node.js 18.x, Java 17, Go 1.20+, Rust
- **Build Tools**: GCC, G++, Make, CMake
- **Version Control**: Git
- **Containers**: Docker, Docker Compose
- **Editors**: VS Code Server
- **Utilities**: htop, tree, jq, ripgrep, fd-find, bat, exa

### Security Features
- UFW Firewall
- Fail2ban
- SSH Key Authentication
- Audit Logging
- Automatic Security Updates

## Network Configuration

- **SSH**: Port 22 (forwarded to 2222)
- **VNC**: Port 5901
- **noVNC**: Port 6080
- **VS Code Server**: Port 8080

## Default Credentials

- **User**: dev
- **VNC Password**: dev123
- **SSH**: Key-based authentication only

## Build Artifacts

- `output/FullDevVM.qcow2` - QEMU/KVM image
- `output/FullDevVM.ova` - VirtualBox image
- `output/FullDevVM.ovf` - VirtualBox descriptor
- `output/FullDevVM-disk001.vmdk` - VirtualBox disk

## Reproducibility

This build is designed to be reproducible. Key factors:

1. **Pinned ISO**: Specific Ubuntu 22.04.3 LTS ISO with checksum
2. **Pinned Packages**: Specific package versions from Ubuntu repositories
3. **Deterministic Scripts**: All provisioning scripts are idempotent
4. **Version Control**: All configuration files are version controlled

## Build Logs

Build logs are available at:
- `/var/log/packer-provision.log` - Main provisioning log
- `/var/log/security-hardening.log` - Security configuration log

## Verification

Run the verification suite after build:
```bash
./tests/run-all-tests.sh
```

## Support

For build issues:
1. Check build logs
2. Verify prerequisites (Packer, QEMU/VirtualBox)
3. Check network connectivity for ISO download
4. Review troubleshooting section in CONNECT.md
