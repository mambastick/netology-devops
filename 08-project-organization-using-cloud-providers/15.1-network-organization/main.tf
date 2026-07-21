locals {
  public_cidr  = "192.168.10.0/24"
  private_cidr = "192.168.20.0/24"

  cloud_init = <<-EOT
    #cloud-config
    users:
      - name: ${var.vm_user}
        groups: sudo
        shell: /bin/bash
        sudo: ALL=(ALL) NOPASSWD:ALL
        ssh_authorized_keys:
          - ${trimspace(file(pathexpand(var.ssh_public_key_path)))}
    runcmd:
      - [bash, -lc, 'grep -qxF "Port 443" /etc/ssh/sshd_config || echo "Port 443" >> /etc/ssh/sshd_config']
      - [systemctl, restart, ssh]
  EOT
}

resource "yandex_vpc_network" "homework" {
  name        = "netology-15-1"
  description = "Network for homework 15.1"
}

resource "yandex_vpc_subnet" "public" {
  name           = "public"
  zone           = var.zone
  network_id     = yandex_vpc_network.homework.id
  v4_cidr_blocks = [local.public_cidr]
}

resource "yandex_vpc_route_table" "private" {
  name       = "private-nat-route"
  network_id = yandex_vpc_network.homework.id

  static_route {
    destination_prefix = "0.0.0.0/0"
    next_hop_address   = "192.168.10.254"
  }
}

resource "yandex_vpc_subnet" "private" {
  name           = "private"
  zone           = var.zone
  network_id     = yandex_vpc_network.homework.id
  v4_cidr_blocks = [local.private_cidr]
  route_table_id = yandex_vpc_route_table.private.id
}

resource "yandex_vpc_security_group" "homework" {
  name       = "netology-15-1-sg"
  network_id = yandex_vpc_network.homework.id

  ingress {
    description    = "SSH access"
    protocol       = "TCP"
    port           = 22
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description    = "SSH access over port 443"
    protocol       = "TCP"
    port           = 443
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description    = "Traffic inside the homework network"
    protocol       = "ANY"
    v4_cidr_blocks = [local.public_cidr, local.private_cidr]
  }

  egress {
    description    = "Internet access"
    protocol       = "ANY"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "yandex_compute_instance" "nat" {
  name                      = "nat-instance"
  hostname                  = "nat-instance"
  platform_id               = "standard-v3"
  zone                      = var.zone
  allow_stopping_for_update = true

  resources {
    cores         = 2
    memory        = 2
    core_fraction = 20
  }

  boot_disk {
    initialize_params {
      image_id = var.nat_image_id
      size     = 10
      type     = "network-hdd"
    }
  }

  network_interface {
    subnet_id          = yandex_vpc_subnet.public.id
    ip_address         = "192.168.10.254"
    nat                = true
    security_group_ids = [yandex_vpc_security_group.homework.id]
  }

  scheduling_policy {
    preemptible = true
  }

  metadata = {
    user-data          = local.cloud_init
    ssh-keys           = "${var.vm_user}:${trimspace(file(pathexpand(var.ssh_public_key_path)))}"
    serial-port-enable = "1"
  }
}

resource "yandex_compute_instance" "public" {
  name                      = "public-vm"
  hostname                  = "public-vm"
  platform_id               = "standard-v3"
  zone                      = var.zone
  allow_stopping_for_update = true

  resources {
    cores         = 2
    memory        = 2
    core_fraction = 20
  }

  boot_disk {
    initialize_params {
      image_id = var.nat_image_id
      size     = 10
      type     = "network-hdd"
    }
  }

  network_interface {
    subnet_id          = yandex_vpc_subnet.public.id
    nat                = true
    security_group_ids = [yandex_vpc_security_group.homework.id]
  }

  scheduling_policy {
    preemptible = true
  }

  metadata = {
    user-data          = local.cloud_init
    ssh-keys           = "${var.vm_user}:${trimspace(file(pathexpand(var.ssh_public_key_path)))}"
    serial-port-enable = "1"
  }
}

resource "yandex_compute_instance" "private" {
  name                      = "private-vm"
  hostname                  = "private-vm"
  platform_id               = "standard-v3"
  zone                      = var.zone
  allow_stopping_for_update = true

  resources {
    cores         = 2
    memory        = 2
    core_fraction = 20
  }

  boot_disk {
    initialize_params {
      image_id = var.nat_image_id
      size     = 10
      type     = "network-hdd"
    }
  }

  network_interface {
    subnet_id          = yandex_vpc_subnet.private.id
    security_group_ids = [yandex_vpc_security_group.homework.id]
  }

  scheduling_policy {
    preemptible = true
  }

  metadata = {
    user-data          = local.cloud_init
    ssh-keys           = "${var.vm_user}:${trimspace(file(pathexpand(var.ssh_public_key_path)))}"
    serial-port-enable = "1"
  }

  depends_on = [yandex_compute_instance.nat]
}
