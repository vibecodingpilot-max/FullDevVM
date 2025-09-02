# Context: Full Linux OS for Cursor AI IDE: FullDevVM

## Purpose / Goal
Provide a **complete, installable full Linux operating system image** (not a container) configured with a graphical desktop and a full polyglot developer toolchain so Cursor AI IDE (or any remote developer agent) can connect, edit, build, run and debug projects as if working on a native machine.

This `context.md` describes the high-level objectives, constraints, automation expectations, security defaults, integration points, and deliverables an agent should produce when asked to "build the full OS" for Cursor AI.

---

## High-level design decisions
- **Target distribution:** Ubuntu LTS (22.04 or 24.04 when available) as the base. Use the *server*/minimal ISO as the starting point for reproducibility and small base footprint. Alternatives: Debian Stable (bookworm) if strictly preferred.
- **Virtualization target:** Produce artifacts for full virtualization (QCOW2 image for QEMU/KVM, OVA for VirtualBox, optionally Vagrantfile). Prefer QEMU/KVM as the primary target because of performance and automation compatibility with cloud-init and libvirt.
- **Desktop Environment:** XFCE4 (lightweight, reliable). Include options for MATE or GNOME in separate build variants if requested.
- **Remote Display:** SPICE or VNC for full graphical sessions; include **noVNC** wrapper for browser access. Include `qemu-guest-agent` and `spice-vdagent` for clipboard/screen sync when using SPICE.
- **Automation:** Fully automated image build using **HashiCorp Packer** (primary) and optional shell scripts. Use `cloud-init` or preseed for first-boot provisioning and user creation.

---

## Cursor AI integration expectations
1. **How Cursor should connect**
   - Primary: **SSH (key-based)** on a forwarded/host-accessible port.
   - Secondary (for UI): connect to exposed SPICE/VNC port or open the provided noVNC HTTP endpoint.
2. **File-sharing**
   - Preferred: `virtiofsd`/virtio-fs mounts or 9p for host ↔ guest shared folders. Provide instructions for mounting project folders at `/home/dev/projects`.
   - Fallback: configure an `rsync`/`sshfs` recipe in the README.
3. **Credentials & Keys**
   - The image should include a `cloud-init` user that expects the agent's public SSH key. Do NOT bake private keys into images.
4. **Services**
   - SSHD enabled by default and configured for key-only access by default.
   - `qemu-guest-agent` and `cloud-init` installed and enabled.

---

## Security & defaults
- **Default user:** `dev` (UID >= 1000). Use `sudo` without password for `dev` only if explicitly requested; otherwise keep sudo protected.
- **SSH policy:** disable password authentication; enable `PermitRootLogin no`. Only allow specific public keys on first boot via `cloud-init` input.
- **Firewall:** enable `ufw` default-deny incoming, allow SSH and VNC/SPICE/noVNC ports by rule as needed; provide a `setup-firewall.sh` script to toggle exposures for development.
- **Automatic updates:** disabled by default for reproducibility; include an optional script `enable-auto-updates.sh` that turns on unattended-upgrades.
- **Snapshots:** recommend using QCOW2 backing snapshots; create documentation for snapshot/restore.

---

## Developer toolchain (preinstalled)
Install and configure the following runtime tools and languages:

- **System & basics:** build-essential (gcc, g++, make), cmake, git, curl, wget, net-tools, vim, less, unzip
- **Python:** Python 3.11+ + pip, virtualenv
- **Node.js:** Node 18.x (LTS) + npm; include `nvm` helper
- **Java:** OpenJDK 17 (or 21 if requested)
- **Go:** Go 1.20+
- **Rust:** rustup + stable toolchain
- **Containers:** Docker Engine (optional toggle), `docker-compose`
- **Editors/IDEs:** code-server (VS Code in browser) *optional*
- **Debugging / Networking:** strace, lsof, tcpdump (optional install), openssh-client

Provide `dev-setup.sh` to install toolchains and `dev-prune.sh` to remove optional heavy items.

---

## Desktop and UX configuration
- **Display manager:** no heavy GDM by default; start XFCE session on a VNC/Spice display server (xrdp or tigervnc + xstartup).
- **noVNC:** set up a `systemd` service that runs noVNC pointing to the active VNC instance so users can open the desktop in a browser on `http://<host>:6080`.
- **Spice:** offer a build variant with `qemu` spice agent + `virt-viewer` instructions.
- **User experience:** preconfigure Thunar, terminal shortcut, and a "Developer" menu with shortcuts to dev tools and the `projects` folder.

---

### Packer expectations
- Build a minimal Ubuntu server install from ISO, then run provisioning scripts.
- Use `cloud-init` to inject SSH public key at first boot for `dev` user.
- Produce a QCOW2 output for KVM and an OVA/VirtualBox image.

---

## First-boot & provisioning behaviour
- On first boot, `cloud-init` should
  - create `dev` user and populate `/home/dev/.ssh/authorized_keys`
  - set hostname based on `meta-data`
  - run `postinstall.sh` in non-interactive mode
- The `postinstall.sh` script should be idempotent.

---

## Testing checklist
- `tests/verify-ssh.sh` — ensures SSH key login works.
- `tests/verify-vnc.sh` — checks VNC server is listening.
- `tests/verify-langs.sh` — check `python --version`, `node --version`, `go version`, `rustc --version`, `javac -version`.
- `tests/verify-packages.sh` — sanity-check installed packages.

---

## Documentation deliverables
- `README.md` — build/run commands, required host packages, qemu/VirtualBox steps.
- `CONNECT.md` — how Cursor IDE connects (SSH, noVNC, file-sharing).
- `SECURITY.md` — security defaults and hardening guide.

---

## Deliverables
1. QCOW2 disk image for QEMU/KVM OR OVA for VirtualBox.
2. Packer template + cloud-init files.
3. Provisioning scripts (`/scripts/*.sh`).
4. Systemd service units for noVNC, VNC, and optional code-server.
5. Documentation (`README.md`, `CONNECT.md`, `SECURITY.md`).
6. Automated verification scripts under `/tests`.

---

## Versioning & reproducibility
- Pin package versions where practical.
- Record ISO checksum and build date in `BUILD_INFO.md`.
- Provisioner scripts should log to `/var/log/packer-provision.log`.

---

## Notes & constraints
- No secrets baked into images.
- Keep base image minimal.
- Document image size targets (< 6GB QCOW2 if possible).
- Prefer XFCE + noVNC as default.

---

## Example user story
> As a Cursor AI user, I should be able to: import or boot the provided QCOW2/OVA, plug my SSH public key into cloud-init, start the VM, open `http://localhost:6080` to see a full desktop running XFCE, and connect Cursor IDE via SSH to edit `/home/dev/projects` and run/debug code in Python, Node, Java, Go, Rust, or C/C++.

---

## Troubleshooting hints
- **Network issues:** check `systemd-resolved`, netplan, or libvirt config.
- **VNC errors:** check `~/.vnc` xstartup or tigervnc config.
- **SSH key errors:** check `authorized_keys` permissions and `sshd_config`.

---
