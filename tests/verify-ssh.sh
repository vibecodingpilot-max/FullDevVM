#!/bin/bash
set -euo pipefail

# SSH Verification Script
# Tests SSH connectivity and configuration

echo "=== SSH Verification Test ==="
echo "Date: $(date)"
echo

# Test SSH service status
echo "1. Checking SSH service status..."
if systemctl is-active --quiet ssh; then
    echo "✓ SSH service is running"
else
    echo "✗ SSH service is not running"
    exit 1
fi

# Test SSH configuration
echo "2. Checking SSH configuration..."
if grep -q "PasswordAuthentication no" /etc/ssh/sshd_config.d/*.conf; then
    echo "✓ Password authentication is disabled"
else
    echo "✗ Password authentication is enabled (security risk)"
fi

if grep -q "PermitRootLogin no" /etc/ssh/sshd_config.d/*.conf; then
    echo "✓ Root login is disabled"
else
    echo "✗ Root login is enabled (security risk)"
fi

# Test SSH key authentication
echo "3. Checking SSH key configuration..."
if [ -f "/home/dev/.ssh/authorized_keys" ]; then
    key_count=$(wc -l < /home/dev/.ssh/authorized_keys)
    echo "✓ SSH authorized_keys file exists with $key_count key(s)"
else
    echo "✗ SSH authorized_keys file not found"
fi

# Test SSH port
echo "4. Checking SSH port..."
if netstat -tlnp | grep -q ":22 "; then
    echo "✓ SSH is listening on port 22"
else
    echo "✗ SSH is not listening on port 22"
fi

# Test SSH connectivity (if possible)
echo "5. Testing SSH connectivity..."
if command -v ssh >/dev/null 2>&1; then
    if timeout 5 ssh -o ConnectTimeout=5 -o BatchMode=yes -o StrictHostKeyChecking=no dev@localhost "echo 'SSH test successful'" 2>/dev/null; then
        echo "✓ SSH connectivity test passed"
    else
        echo "⚠ SSH connectivity test failed (may be expected if no keys configured)"
    fi
else
    echo "⚠ SSH client not available for connectivity test"
fi

echo
echo "=== SSH Verification Complete ==="
