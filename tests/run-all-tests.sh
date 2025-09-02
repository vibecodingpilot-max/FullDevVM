#!/bin/bash
set -euo pipefail

# Run All Verification Tests
# Executes all verification scripts and provides a summary

echo "=========================================="
echo "FullDevVM Verification Test Suite"
echo "=========================================="
echo "Date: $(date)"
echo

# Change to the tests directory
cd "$(dirname "$0")"

# Run all verification tests
echo "Running SSH verification..."
./verify-ssh.sh
echo

echo "Running VNC verification..."
./verify-vnc.sh
echo

echo "Running language runtime verification..."
./verify-langs.sh
echo

echo "Running package verification..."
./verify-packages.sh
echo

echo "=========================================="
echo "Verification Test Suite Complete"
echo "=========================================="
echo "Date: $(date)"
echo
echo "Access Information:"
echo "- SSH: ssh -p 2222 dev@localhost"
echo "- Desktop: http://localhost:6080"
echo "- VS Code: http://localhost:8080"
echo "- VNC Password: dev123"
echo
echo "Useful Commands:"
echo "- Check security status: /home/dev/security-check.sh"
echo "- Open firewall for development: /home/dev/setup-firewall.sh open"
echo "- Enable auto-updates: /home/dev/enable-auto-updates.sh"
