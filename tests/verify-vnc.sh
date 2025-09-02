#!/bin/bash
set -euo pipefail

# VNC Verification Script
# Tests VNC server and noVNC configuration

echo "=== VNC Verification Test ==="
echo "Date: $(date)"
echo

# Test VNC service status
echo "1. Checking VNC service status..."
if systemctl is-active --quiet vncserver@1; then
    echo "✓ VNC server service is running"
else
    echo "✗ VNC server service is not running"
    exit 1
fi

# Test VNC port
echo "2. Checking VNC port..."
if netstat -tlnp | grep -q ":5901 "; then
    echo "✓ VNC is listening on port 5901"
else
    echo "✗ VNC is not listening on port 5901"
fi

# Test VNC configuration files
echo "3. Checking VNC configuration..."
if [ -f "/home/dev/.vnc/xstartup" ]; then
    echo "✓ VNC xstartup file exists"
    if [ -x "/home/dev/.vnc/xstartup" ]; then
        echo "✓ VNC xstartup file is executable"
    else
        echo "✗ VNC xstartup file is not executable"
    fi
else
    echo "✗ VNC xstartup file not found"
fi

if [ -f "/home/dev/.vnc/passwd" ]; then
    echo "✓ VNC password file exists"
else
    echo "✗ VNC password file not found"
fi

# Test noVNC service
echo "4. Checking noVNC service..."
if systemctl is-active --quiet novnc; then
    echo "✓ noVNC service is running"
else
    echo "✗ noVNC service is not running"
fi

# Test noVNC port
echo "5. Checking noVNC port..."
if netstat -tlnp | grep -q ":6080 "; then
    echo "✓ noVNC is listening on port 6080"
else
    echo "✗ noVNC is not listening on port 6080"
fi

# Test websockify
echo "6. Checking websockify..."
if command -v websockify >/dev/null 2>&1; then
    echo "✓ websockify is installed"
else
    echo "✗ websockify is not installed"
fi

# Test VNC processes
echo "7. Checking VNC processes..."
vnc_processes=$(pgrep -f "Xvnc" | wc -l)
if [ "$vnc_processes" -gt 0 ]; then
    echo "✓ VNC processes are running ($vnc_processes found)"
else
    echo "✗ No VNC processes found"
fi

# Test desktop environment
echo "8. Checking desktop environment..."
if command -v xfce4-session >/dev/null 2>&1; then
    echo "✓ XFCE4 is installed"
else
    echo "✗ XFCE4 is not installed"
fi

echo
echo "=== VNC Verification Complete ==="
echo "Access the desktop at: http://localhost:6080"
echo "VNC password: dev123"
