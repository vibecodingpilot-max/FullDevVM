# FullDevVM Installation Guide

## 🚀 Quick Installation

### Step 1: Download
1. Go to the [Releases](https://github.com/yourusername/FullDevVM/releases) page
2. Download `FullDevVM.iso` (latest version)
3. Optionally download `FullDevVM-SHA256.txt` for verification

### Step 2: Verify Download (Optional)
```bash
# Verify ISO integrity
sha256sum -c FullDevVM-SHA256.txt
```

### Step 3: Create VM
Choose your platform and follow the instructions below.

## 🖥️ Platform-Specific Instructions

### UTM (macOS) - Recommended
1. **Install UTM** from App Store
2. **Open UTM** and click "Create a New Virtual Machine"
3. **Select "Virtualize"** → **"Linux"**
4. **Choose "Browse"** and select `FullDevVM.iso`
5. **Configure VM:**
   - RAM: 4GB
   - CPU: 2 cores
   - Disk: 25GB
6. **Click "Save"** and start the VM

### VirtualBox (All Platforms)
1. **Install VirtualBox** from [virtualbox.org](https://www.virtualbox.org/)
2. **Open VirtualBox** and click "New"
3. **Configure VM:**
   - Name: FullDevVM
   - Type: Linux
   - Version: Ubuntu (64-bit)
   - RAM: 4GB
   - Create virtual hard disk: 25GB
4. **Select VM** → **Settings** → **Storage**
5. **Click CD icon** → **Choose Virtual Optical Disk File**
6. **Select** `FullDevVM.iso`
7. **Click "Start"**

### VMware (All Platforms)
1. **Install VMware** (Workstation/Fusion)
2. **Open VMware** and click "Create a New Virtual Machine"
3. **Select "Custom"** configuration
4. **Choose "I will install the operating system later"**
5. **Select "Linux"** → **"Ubuntu 64-bit"**
6. **Configure VM:**
   - RAM: 4GB
   - CPU: 2 cores
   - Disk: 25GB
7. **Select VM** → **Settings** → **CD/DVD**
8. **Choose "Use ISO image file"** and select `FullDevVM.iso`
9. **Power on** the VM

### QEMU/KVM (Linux)
```bash
# Install QEMU
sudo apt install qemu-kvm qemu-system-x86

# Create VM
qemu-system-x86_64 \
  -m 4G \
  -smp 2 \
  -cdrom FullDevVM.iso \
  -boot d \
  -enable-kvm
```

## ⏳ Installation Process

1. **Boot** from the ISO
2. **Wait** for automatic installation (10-15 minutes)
3. **VM will restart** automatically when ready
4. **Login** is not required - services start automatically

## 🔗 Connect to Your VM

### Find VM IP Address
- **UTM**: Check network settings in VM
- **VirtualBox**: Usually `10.0.2.15`
- **VMware**: Check network adapter settings
- **QEMU**: Usually `10.0.2.15`

### Connection Methods

| Method | Command/URL | Credentials |
|--------|-------------|-------------|
| **SSH** | `ssh dev@<vm-ip>` | SSH key only |
| **VNC** | `<vm-ip>:5901` | Password: `dev123` |
| **noVNC** | `http://<vm-ip>:6080` | Password: `dev123` |
| **VS Code** | `http://<vm-ip>:8080` | No auth required |

## 🛠️ First Steps

1. **Connect via SSH** (recommended for Cursor AI IDE)
2. **Navigate to projects folder**: `cd /home/dev/projects`
3. **Start coding** with your favorite editor
4. **Access desktop** via VNC if needed

## 🆘 Troubleshooting

### VM Won't Start
- **Check RAM**: Ensure you have 4GB+ available
- **Check CPU**: Ensure you have 2+ cores available
- **Check disk space**: Ensure you have 25GB+ available

### Installation Takes Too Long
- **Normal**: Installation takes 10-15 minutes
- **Check logs**: Look for error messages in VM console
- **Restart**: Try restarting the VM

### Can't Connect via SSH
- **Check network**: Ensure VM has network access
- **Check IP**: Verify VM IP address
- **Check SSH**: Ensure SSH service is running

### VNC/Desktop Not Working
- **Check ports**: Ensure ports 5901 and 6080 are accessible
- **Check VNC**: Ensure VNC service is running
- **Check firewall**: Ensure firewall allows VNC traffic

## 📚 Next Steps

- **Read** [CONNECT.md](docs/CONNECT.md) for detailed connection guide
- **Read** [SECURITY.md](docs/SECURITY.md) for security configuration
- **Read** [README.md](README.md) for feature overview

## 🤝 Need Help?

- **Open an issue** on GitHub
- **Check** the troubleshooting section
- **Read** the documentation
- **Join** the community discussions

---

**Happy coding with FullDevVM!** 🚀
