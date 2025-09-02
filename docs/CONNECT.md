# Connecting to FullDevVM

This guide explains how to connect Cursor AI IDE and other tools to your FullDevVM instance.

## Prerequisites

- FullDevVM running (see [README.md](../README.md) for build instructions)
- SSH client installed on your host machine
- Web browser for desktop access

## Connection Methods

### 1. SSH Connection (Primary)

SSH is the primary method for Cursor AI IDE to connect and edit files.

```bash
# Connect via SSH
ssh -p 2222 dev@localhost

# With specific SSH key
ssh -i ~/.ssh/your_key -p 2222 dev@localhost
```

**For Cursor AI IDE:**
1. Open Cursor IDE
2. Use "Connect to Remote" or "Remote-SSH" extension
3. Add connection: `dev@localhost:2222`
4. Select your SSH key when prompted

### 2. Desktop Access (Secondary)

Access the full graphical desktop environment through your web browser.

**noVNC Web Interface:**
- URL: `http://localhost:6080`
- Password: `dev123`
- Resolution: 1920x1080

**Direct VNC (if needed):**
- Host: `localhost`
- Port: `5901`
- Password: `dev123`

### 3. VS Code Server (Optional)

Access VS Code directly in your browser.

- URL: `http://localhost:8080`
- No authentication required (development mode)

## File Sharing

### Method 1: Shared Projects Folder (Recommended)

The VM includes a dedicated projects folder that can be shared with the host:

```bash
# On host machine - mount VM projects folder
sshfs -p 2222 dev@localhost:/home/dev/projects ./local-projects

# Unmount when done
fusermount -u ./local-projects
```

### Method 2: rsync Synchronization

Sync files between host and VM:

```bash
# Sync from host to VM
rsync -avz -e "ssh -p 2222" ./local-project/ dev@localhost:/home/dev/projects/

# Sync from VM to host
rsync -avz -e "ssh -p 2222" dev@localhost:/home/dev/projects/ ./local-project/
```

### Method 3: Git Workflow

Use Git for version control and synchronization:

```bash
# On VM
cd /home/dev/projects
git clone https://github.com/your-repo/your-project.git

# Work on files, commit changes
git add .
git commit -m "Your changes"
git push
```

## Port Forwarding

The VM exposes the following ports:

| Service | Port | Description |
|---------|------|-------------|
| SSH | 2222 | SSH access |
| VNC | 5901 | Direct VNC access |
| noVNC | 6080 | Web-based VNC |
| VS Code | 8080 | VS Code Server |

### Custom Port Forwarding

If you need additional ports, modify the QEMU command:

```bash
qemu-system-x86_64 \
  -m 4G \
  -smp 2 \
  -drive file=output/FullDevVM.qcow2,format=qcow2 \
  -netdev user,id=net0,hostfwd=tcp::2222-:22,hostfwd=tcp::6080-:6080,hostfwd=tcp::8080-:8080,hostfwd=tcp::3000-:3000 \
  -device virtio-net-pci,netdev=net0 \
  -enable-kvm
```

## Development Workflow

### 1. Start the VM
```bash
# Start FullDevVM
qemu-system-x86_64 -m 4G -smp 2 -drive file=output/FullDevVM.qcow2,format=qcow2 -netdev user,id=net0,hostfwd=tcp::2222-:22,hostfwd=tcp::6080-:6080 -device virtio-net-pci,netdev=net0 -enable-kvm
```

### 2. Connect Cursor IDE
1. Open Cursor IDE
2. Connect to `dev@localhost:2222`
3. Open folder `/home/dev/projects`

### 3. Access Desktop (if needed)
1. Open browser to `http://localhost:6080`
2. Enter password `dev123`
3. Use XFCE desktop for GUI applications

### 4. Run and Debug
- Use Cursor's integrated terminal
- Access VS Code Server at `http://localhost:8080`
- Use desktop for GUI debugging tools

## Troubleshooting

### SSH Connection Issues

**Problem:** Cannot connect via SSH
```bash
# Check if VM is running
ps aux | grep qemu

# Check SSH service status
ssh -p 2222 dev@localhost "systemctl status ssh"

# Verify port forwarding
netstat -tlnp | grep 2222
```

**Problem:** Permission denied (publickey)
```bash
# Check SSH key
ssh-add -l

# Test with verbose output
ssh -v -p 2222 dev@localhost
```

### Desktop Access Issues

**Problem:** noVNC not loading
```bash
# Check noVNC service
ssh -p 2222 dev@localhost "systemctl status novnc"

# Check VNC service
ssh -p 2222 dev@localhost "systemctl status vncserver@1"

# Restart services
ssh -p 2222 dev@localhost "sudo systemctl restart vncserver@1 novnc"
```

**Problem:** VNC password not working
```bash
# Reset VNC password
ssh -p 2222 dev@localhost "vncpasswd"
```

### Performance Issues

**Problem:** Slow performance
- Increase VM memory: `-m 8G`
- Increase CPU cores: `-smp 4`
- Enable KVM acceleration: `-enable-kvm`

**Problem:** Network issues
```bash
# Check network configuration
ssh -p 2222 dev@localhost "ip addr show"

# Test connectivity
ssh -p 2222 dev@localhost "ping -c 3 8.8.8.8"
```

### Service Issues

**Problem:** Services not starting
```bash
# Check service status
ssh -p 2222 dev@localhost "systemctl status --failed"

# View service logs
ssh -p 2222 dev@localhost "journalctl -u vncserver@1 -f"
ssh -p 2222 dev@localhost "journalctl -u novnc -f"
```

## Security Notes

- SSH key authentication is required
- Password authentication is disabled
- Root login is disabled
- UFW firewall is enabled by default
- VNC password is set to `dev123` (change for production use)

## Next Steps

- See [SECURITY.md](SECURITY.md) for security configuration
- See [README.md](../README.md) for build instructions
- Run verification tests: `./tests/run-all-tests.sh`
