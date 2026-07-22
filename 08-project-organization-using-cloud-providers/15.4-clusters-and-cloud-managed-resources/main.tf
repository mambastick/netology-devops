locals {
  private_subnets = {
    a = { zone = "ru-central1-a", cidr = "10.10.10.0/24" }
    b = { zone = "ru-central1-b", cidr = "10.10.20.0/24" }
    d = { zone = "ru-central1-d", cidr = "10.10.30.0/24" }
  }

  public_subnets = {
    a = { zone = "ru-central1-a", cidr = "10.20.10.0/24" }
    b = { zone = "ru-central1-b", cidr = "10.20.20.0/24" }
    d = { zone = "ru-central1-d", cidr = "10.20.30.0/24" }
  }
}

resource "yandex_vpc_network" "main" {
  name = "netology-15-4"
}

resource "yandex_vpc_subnet" "private" {
  for_each = local.private_subnets

  name           = "netology-15-4-private-${each.key}"
  zone           = each.value.zone
  network_id     = yandex_vpc_network.main.id
  v4_cidr_blocks = [each.value.cidr]
}

resource "yandex_vpc_subnet" "public" {
  for_each = local.public_subnets

  name           = "netology-15-4-public-${each.key}"
  zone           = each.value.zone
  network_id     = yandex_vpc_network.main.id
  v4_cidr_blocks = [each.value.cidr]
}

resource "yandex_vpc_security_group" "kubernetes" {
  name       = "netology-15-4-kubernetes"
  network_id = yandex_vpc_network.main.id

  ingress {
    protocol          = "ANY"
    description       = "Traffic inside the Kubernetes security group"
    predefined_target = "self_security_group"
  }

  ingress {
    protocol       = "TCP"
    description    = "Kubernetes API"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 443
  }

  ingress {
    protocol       = "ICMP"
    description    = "Path MTU discovery and diagnostics"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol       = "ANY"
    description    = "Outbound access"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "yandex_mdb_mysql_cluster" "netology" {
  name                = "netology-15-4-mysql"
  environment         = "PRESTABLE"
  network_id          = yandex_vpc_network.main.id
  version             = "8.0"
  deletion_protection = true

  resources {
    resource_preset_id = "b2.medium"
    disk_type_id       = "network-ssd"
    disk_size          = 20
  }

  backup_window_start {
    hours   = 23
    minutes = 59
  }

  maintenance_window {
    type = "ANYTIME"
  }

  dynamic "host" {
    for_each = yandex_vpc_subnet.private
    content {
      zone             = host.value.zone
      subnet_id        = host.value.id
      assign_public_ip = false
    }
  }
}

resource "yandex_mdb_mysql_database" "netology" {
  cluster_id = yandex_mdb_mysql_cluster.netology.id
  name       = "netology_db"
}

resource "yandex_mdb_mysql_user" "netology" {
  cluster_id = yandex_mdb_mysql_cluster.netology.id
  name       = "netology"
  password   = var.mysql_password

  permission {
    database_name = yandex_mdb_mysql_database.netology.name
    roles         = ["ALL"]
  }
}

resource "yandex_iam_service_account" "kubernetes" {
  name = "netology-15-4-kubernetes"
}

resource "yandex_resourcemanager_folder_iam_member" "kubernetes_agent" {
  folder_id = var.folder_id
  role      = "k8s.clusters.agent"
  member    = "serviceAccount:${yandex_iam_service_account.kubernetes.id}"
}

resource "yandex_resourcemanager_folder_iam_member" "vpc_public_admin" {
  folder_id = var.folder_id
  role      = "vpc.publicAdmin"
  member    = "serviceAccount:${yandex_iam_service_account.kubernetes.id}"
}

resource "yandex_resourcemanager_folder_iam_member" "image_puller" {
  folder_id = var.folder_id
  role      = "container-registry.images.puller"
  member    = "serviceAccount:${yandex_iam_service_account.kubernetes.id}"
}

resource "yandex_resourcemanager_folder_iam_member" "kms_encrypter_decrypter" {
  folder_id = var.folder_id
  role      = "kms.keys.encrypterDecrypter"
  member    = "serviceAccount:${yandex_iam_service_account.kubernetes.id}"
}

resource "yandex_kubernetes_cluster" "regional" {
  name        = "netology-15-4-kubernetes"
  description = "Regional Managed Kubernetes cluster for Netology homework"
  network_id  = yandex_vpc_network.main.id

  master {
    regional {
      region = "ru-central1"

      location {
        zone      = yandex_vpc_subnet.public["a"].zone
        subnet_id = yandex_vpc_subnet.public["a"].id
      }

      location {
        zone      = yandex_vpc_subnet.public["b"].zone
        subnet_id = yandex_vpc_subnet.public["b"].id
      }

      location {
        zone      = yandex_vpc_subnet.public["d"].zone
        subnet_id = yandex_vpc_subnet.public["d"].id
      }
    }

    public_ip          = true
    security_group_ids = [yandex_vpc_security_group.kubernetes.id]
  }

  service_account_id      = yandex_iam_service_account.kubernetes.id
  node_service_account_id = yandex_iam_service_account.kubernetes.id
  release_channel         = "STABLE"
  network_policy_provider = "CALICO"

  kms_provider {
    key_id = var.kms_key_id
  }

  depends_on = [
    yandex_resourcemanager_folder_iam_member.kubernetes_agent,
    yandex_resourcemanager_folder_iam_member.vpc_public_admin,
    yandex_resourcemanager_folder_iam_member.image_puller,
    yandex_resourcemanager_folder_iam_member.kms_encrypter_decrypter,
  ]
}

resource "yandex_kubernetes_node_group" "workers" {
  cluster_id  = yandex_kubernetes_cluster.regional.id
  name        = "netology-15-4-workers"
  description = "Autoscaled worker nodes across three zones"

  instance_template {
    platform_id = "standard-v3"

    network_interface {
      nat                = true
      subnet_ids         = [yandex_vpc_subnet.public["a"].id]
      security_group_ids = [yandex_vpc_security_group.kubernetes.id]
    }

    resources {
      memory        = 4
      cores         = 2
      core_fraction = 50
    }

    boot_disk {
      type = "network-hdd"
      size = 64
    }

    scheduling_policy {
      preemptible = false
    }

    container_runtime {
      type = "containerd"
    }
  }

  scale_policy {
    auto_scale {
      min     = 3
      initial = 3
      max     = 6
    }
  }

  allocation_policy {
    location {
      zone = yandex_vpc_subnet.public["a"].zone
    }
  }

  deploy_policy {
    max_expansion   = 3
    max_unavailable = 1
  }

  maintenance_policy {
    auto_upgrade = true
    auto_repair  = true
  }
}
