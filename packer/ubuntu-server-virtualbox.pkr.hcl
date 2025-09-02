packer {
  required_plugins {
    virtualbox = {
      version = "~> 1"
      source  = "github.com/hashicorp/virtualbox"
    }
  }
}

variable "ubuntu_version" {
  type    = string
  default = "22.04"
}

variable "ubuntu_iso_checksum" {
  type    = string
  default = "sha256:5e38b55d57d94ff029719342357325ed3bda38fa80054f9330dc789cd2d43931"
}

variable "ssh_public_key" {
  type    = string
  default = ""
  description = "SSH public key for the dev user"
}

variable "vm_name" {
  type    = string
  default = "FullDevVM"
}

variable "memory" {
  type    = string
  default = "2048"
}

variable "cpus" {
  type    = string
  default = "2"
}

variable "disk_size" {
  type    = string
  default = "20G"
}

locals {
  timestamp = regex_replace(timestamp(), "[- TZ:]", "")
}

source "virtualbox-iso" "ubuntu-server" {
  # ISO Configuration
  iso_url      = "https://releases.ubuntu.com/${var.ubuntu_version}/ubuntu-${var.ubuntu_version}.04.3-live-server-amd64.iso"
  iso_checksum = var.ubuntu_iso_checksum
  
  # VM Configuration
  vm_name     = "${var.vm_name}-${local.timestamp}"
  memory      = var.memory
  cpus        = var.cpus
  disk_size   = var.disk_size
  
  # Boot Configuration
  boot_wait = "10s"
  boot_command = [
    "<esc><wait><esc><wait><f6><wait><esc><wait>",
    "<bs><bs><bs><bs><bs>",
    "autoinstall ds=nocloud-net\\;s=http://{{ .HTTPIP }}:{{ .HTTPPort }}/ ",
    "--- <enter>"
  ]
  
  # Network Configuration
  http_directory = "cloud-init"
  http_port_min  = 8000
  http_port_max  = 8000
  
  # SSH Configuration
  ssh_username = "ubuntu"
  ssh_timeout  = "20m"
  
  # VirtualBox Configuration
  guest_os_type = "Ubuntu_64"
  hard_drive_interface = "sata"
  sata_port_count = 1
  
  # Port forwarding
  vboxmanage = [
    ["modifyvm", "{{.Name}}", "--natpf1", "ssh,tcp,,2222,,22"],
    ["modifyvm", "{{.Name}}", "--natpf1", "vnc,tcp,,5901,,5901"],
    ["modifyvm", "{{.Name}}", "--natpf1", "novnc,tcp,,6080,,6080"],
    ["modifyvm", "{{.Name}}", "--natpf1", "code-server,tcp,,8080,,8080"]
  ]
  
  shutdown_command = "echo 'packer' | sudo -S shutdown -P now"
  shutdown_timeout = "5m"
}

build {
  name = "fulldevvm-virtualbox"
  sources = ["source.virtualbox-iso.ubuntu-server"]

  # Copy provisioning scripts
  provisioner "file" {
    source      = "../scripts/"
    destination = "/tmp/scripts/"
  }

  # Copy systemd services
  provisioner "file" {
    source      = "../systemd/"
    destination = "/tmp/systemd/"
  }

  # Main provisioning script
  provisioner "shell" {
    script = "scripts/postinstall.sh"
    environment_vars = [
      "SSH_PUBLIC_KEY=${var.ssh_public_key}",
      "VM_NAME=${var.vm_name}"
    ]
  }

  # Cleanup
  provisioner "shell" {
    inline = [
      "sudo rm -rf /tmp/scripts /tmp/systemd",
      "sudo rm -rf /var/log/cloud-init*",
      "sudo rm -rf /var/lib/cloud/instances",
      "sudo rm -rf /home/ubuntu/.ssh/authorized_keys",
      "sudo rm -rf /root/.ssh/authorized_keys",
      "sudo apt-get clean",
      "sudo rm -rf /var/lib/apt/lists/*",
      "sudo rm -rf /tmp/*",
      "sudo rm -rf /var/tmp/*"
    ]
  }

  post-processor "shell-local" {
    inline = [
      "mv ${var.vm_name}-${local.timestamp}.ovf output/FullDevVM.ovf",
      "mv ${var.vm_name}-${local.timestamp}-disk001.vmdk output/FullDevVM-disk001.vmdk",
      "cd output && tar -czf FullDevVM.ova FullDevVM.ovf FullDevVM-disk001.vmdk"
    ]
  }
}
