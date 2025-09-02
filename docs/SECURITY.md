# FullDevVM Security Configuration

This document describes the security configuration and hardening measures implemented in FullDevVM.

## Security Overview

FullDevVM implements a defense-in-depth security approach with multiple layers of protection:

- **Network Security**: UFW firewall, fail2ban, SSH hardening
- **Access Control**: SSH key-only authentication, no root login
- **System Security**: Automatic updates, audit logging, service hardening
- **Application Security**: Secure defaults, minimal attack surface

## Default Security Configuration

### SSH Security

- **Password Authentication**: Disabled
- **Root Login**: Disabled
- **Key Authentication**: Required
- **Protocol**: SSH v2 only
- **Max Auth Tries**: 3 attempts
- **Max Sessions**: 10 concurrent
- **Client Alive**: 300 seconds timeout

```bash
# SSH configuration files
/etc/ssh/sshd_config.d/99-dev-config.conf
/etc/ssh/sshd_config.d/99-security.conf
```

### Firewall Configuration

UFW (Uncomplicated Firewall) is enabled with default-deny policy:

```bash
# Default rules
ufw default deny incoming
ufw default allow outgoing

# Allowed services
ufw allow ssh          # Port 22
ufw allow 5901/tcp     # VNC Server
ufw allow 6080/tcp     # noVNC Web Interface
ufw allow 8080/tcp     # VS Code Server
```

### User Configuration

- **Default User**: `dev` (UID >= 1000)
- **Sudo Access**: Passwordless sudo for `dev` user only
- **Home Directory**: `/home/dev`
- **Shell**: `/bin/bash`

### Service Security

- **Unnecessary Services**: Disabled (snapd, bluetooth, cups)
- **Essential Services**: Enabled with secure defaults
- **Service Isolation**: Services run as non-root users where possible

## Security Hardening Scripts

### Automatic Security Updates

```bash
# Enable automatic security updates
sudo /home/dev/enable-auto-updates.sh
```

This script:
- Installs `unattended-upgrades`
- Configures automatic security updates
- Sets up update notifications

### Firewall Management

```bash
# Open development ports
sudo /home/dev/setup-firewall.sh open

# Close development ports
sudo /home/dev/setup-firewall.sh close
```

### Security Status Check

```bash
# Check security status
/home/dev/security-check.sh
```

This script provides:
- Firewall status
- SSH configuration
- Failed login attempts
- System update status
- Audit log summary

## Advanced Security Features

### Fail2ban Protection

Fail2ban monitors and blocks suspicious activity:

```bash
# Configuration
/etc/fail2ban/jail.local

# Monitor SSH
[sshd]
enabled = true
port = ssh
logpath = /var/log/auth.log
maxretry = 3
bantime = 3600
```

### Audit Logging

System audit logging is enabled for:

- System calls (time changes, file modifications)
- Authentication events
- Network configuration changes
- File system access

```bash
# View audit logs
sudo ausearch -m AVC,USER_LOGIN,USER_LOGOUT
sudo aureport -i
```

### System Limits

Increased system limits for development:

```bash
# Configuration
/etc/security/limits.d/99-fulldevvm.conf

# Limits
* soft nofile 65536
* hard nofile 65536
* soft nproc 32768
* hard nproc 32768
```

## Security Best Practices

### For Development Use

1. **Change Default Passwords**
   ```bash
   # Change VNC password
   vncpasswd
   
   # Change user password (if needed)
   passwd
   ```

2. **Use Strong SSH Keys**
   ```bash
   # Generate new SSH key
   ssh-keygen -t ed25519 -C "your-email@example.com"
   
   # Add to VM
   ssh-copy-id -p 2222 dev@localhost
   ```

3. **Regular Updates**
   ```bash
   # Check for updates
   sudo apt update && sudo apt list --upgradable
   
   # Apply updates
   sudo apt upgrade
   ```

4. **Monitor Logs**
   ```bash
   # Check authentication logs
   sudo tail -f /var/log/auth.log
   
   # Check system logs
   sudo journalctl -f
   ```

### For Production Use

1. **Disable Development Services**
   ```bash
   # Disable VNC and noVNC
   sudo systemctl disable vncserver@1 novnc
   
   # Disable VS Code Server
   sudo systemctl disable code-server
   ```

2. **Restrict Network Access**
   ```bash
   # Remove development port rules
   sudo ufw delete allow 5901/tcp
   sudo ufw delete allow 6080/tcp
   sudo ufw delete allow 8080/tcp
   ```

3. **Enable Additional Monitoring**
   ```bash
   # Install additional security tools
   sudo apt install aide rkhunter chkrootkit
   
   # Configure AIDE
   sudo aideinit
   sudo mv /var/lib/aide/aide.db.new /var/lib/aide/aide.db
   ```

4. **Regular Security Scans**
   ```bash
   # Run security scan
   sudo rkhunter --check
   sudo chkrootkit
   ```

## Security Incident Response

### Detecting Intrusions

1. **Check Failed Login Attempts**
   ```bash
   sudo grep "Failed password" /var/log/auth.log
   sudo fail2ban-client status sshd
   ```

2. **Monitor Network Connections**
   ```bash
   sudo netstat -tlnp
   sudo ss -tulpn
   ```

3. **Check Running Processes**
   ```bash
   sudo ps aux
   sudo htop
   ```

### Responding to Incidents

1. **Immediate Response**
   ```bash
   # Block suspicious IPs
   sudo ufw deny from <suspicious-ip>
   
   # Disable affected services
   sudo systemctl stop <affected-service>
   ```

2. **Investigation**
   ```bash
   # Check audit logs
   sudo ausearch -m AVC
   
   # Check system integrity
   sudo aide --check
   ```

3. **Recovery**
   ```bash
   # Restore from backup
   # Rebuild VM if necessary
   # Update security configuration
   ```

## Compliance and Standards

### Security Standards

FullDevVM follows these security standards:

- **CIS Benchmarks**: Ubuntu 22.04 LTS
- **NIST Guidelines**: Cybersecurity Framework
- **OWASP**: Secure Development Practices

### Compliance Features

- **Audit Logging**: Comprehensive system audit
- **Access Control**: Role-based access control
- **Network Security**: Firewall and intrusion detection
- **System Hardening**: Minimal attack surface

## Security Updates

### Regular Maintenance

1. **Weekly Tasks**
   - Check security updates
   - Review audit logs
   - Monitor failed login attempts

2. **Monthly Tasks**
   - Run security scans
   - Update security tools
   - Review firewall rules

3. **Quarterly Tasks**
   - Security assessment
   - Penetration testing
   - Security policy review

### Emergency Updates

For critical security vulnerabilities:

```bash
# Emergency update
sudo apt update && sudo apt upgrade -y

# Restart affected services
sudo systemctl restart ssh
sudo systemctl restart fail2ban
```

## Contact and Support

For security-related issues:

1. Check the troubleshooting section in [CONNECT.md](CONNECT.md)
2. Review system logs and audit trails
3. Run security verification scripts
4. Consider rebuilding the VM for critical issues

## Security Checklist

- [ ] SSH key authentication configured
- [ ] Password authentication disabled
- [ ] Root login disabled
- [ ] UFW firewall enabled
- [ ] Fail2ban configured
- [ ] Automatic updates enabled
- [ ] Audit logging enabled
- [ ] Unnecessary services disabled
- [ ] Strong passwords set
- [ ] Regular security monitoring
