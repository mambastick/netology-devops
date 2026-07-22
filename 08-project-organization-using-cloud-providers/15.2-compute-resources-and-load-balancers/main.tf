locals {
  image_key = "netology-cloud.svg"
  image_url = "https://storage.yandexcloud.net/${var.bucket_name}/${local.image_key}"
}

resource "yandex_vpc_network" "homework" {
  name        = "netology-15-2"
  description = "Network for homework 15.2"
}

resource "yandex_vpc_subnet" "public" {
  name           = "public"
  zone           = var.zone
  network_id     = yandex_vpc_network.homework.id
  v4_cidr_blocks = ["192.168.10.0/24"]
}

resource "yandex_vpc_security_group" "web" {
  name       = "netology-15-2-web"
  network_id = yandex_vpc_network.homework.id

  ingress {
    description    = "HTTP from the internet"
    protocol       = "TCP"
    port           = 80
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description    = "Load balancer health checks"
    protocol       = "TCP"
    port           = 80
    v4_cidr_blocks = ["198.18.235.0/24", "198.18.248.0/24"]
  }

  egress {
    description    = "Internet access"
    protocol       = "ANY"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "yandex_iam_service_account" "storage" {
  name        = "netology-15-2-storage"
  description = "Object Storage service account for homework 15.2"
}

resource "yandex_resourcemanager_folder_iam_member" "storage_admin" {
  folder_id = var.folder_id
  role      = "storage.admin"
  member    = "serviceAccount:${yandex_iam_service_account.storage.id}"
}

resource "yandex_iam_service_account_static_access_key" "storage" {
  service_account_id = yandex_iam_service_account.storage.id
  description        = "Static key for the homework bucket"

  depends_on = [yandex_resourcemanager_folder_iam_member.storage_admin]
}

resource "yandex_storage_bucket" "images" {
  bucket     = var.bucket_name
  access_key = yandex_iam_service_account_static_access_key.storage.access_key
  secret_key = yandex_iam_service_account_static_access_key.storage.secret_key

  force_destroy = true

  anonymous_access_flags {
    read        = true
    list        = false
    config_read = false
  }
}

resource "yandex_storage_object" "image" {
  bucket       = yandex_storage_bucket.images.bucket
  key          = local.image_key
  source       = "${path.module}/assets/netology-cloud.svg"
  source_hash  = filemd5("${path.module}/assets/netology-cloud.svg")
  content_type = "image/svg+xml"
  acl          = "public-read"
  access_key   = yandex_iam_service_account_static_access_key.storage.access_key
  secret_key   = yandex_iam_service_account_static_access_key.storage.secret_key
}

resource "yandex_iam_service_account" "instance_group" {
  name        = "netology-15-2-ig"
  description = "Service account for the LAMP instance group"
}

resource "yandex_resourcemanager_folder_iam_member" "instance_group_compute_editor" {
  folder_id = var.folder_id
  role      = "compute.editor"
  member    = "serviceAccount:${yandex_iam_service_account.instance_group.id}"
}

resource "yandex_resourcemanager_folder_iam_member" "instance_group_load_balancer_editor" {
  folder_id = var.folder_id
  role      = "load-balancer.editor"
  member    = "serviceAccount:${yandex_iam_service_account.instance_group.id}"
}

resource "yandex_compute_instance_group" "lamp" {
  name               = "netology-15-2-lamp"
  service_account_id = yandex_iam_service_account.instance_group.id

  instance_template {
    name        = "lamp-{instance.index}"
    platform_id = "standard-v3"

    resources {
      cores         = 2
      memory        = 2
      core_fraction = 20
    }

    boot_disk {
      initialize_params {
        image_id = var.lamp_image_id
        size     = 10
        type     = "network-hdd"
      }
    }

    network_interface {
      network_id         = yandex_vpc_network.homework.id
      subnet_ids         = [yandex_vpc_subnet.public.id]
      nat                = true
      security_group_ids = [yandex_vpc_security_group.web.id]
    }

    metadata = {
      user-data = templatefile("${path.module}/cloud-init.yaml.tftpl", {
        image_url = local.image_url
      })
    }

    scheduling_policy {
      preemptible = true
    }
  }

  scale_policy {
    fixed_scale {
      size = 3
    }
  }

  allocation_policy {
    zones = [var.zone]
  }

  deploy_policy {
    max_unavailable = 1
    max_expansion   = 1
  }

  health_check {
    interval            = 10
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2

    http_options {
      port = 80
      path = "/"
    }
  }

  load_balancer {
    target_group_name = "netology-15-2-target-group"
  }

  depends_on = [
    yandex_resourcemanager_folder_iam_member.instance_group_compute_editor,
    yandex_resourcemanager_folder_iam_member.instance_group_load_balancer_editor,
    yandex_storage_object.image,
  ]
}

resource "yandex_lb_network_load_balancer" "web" {
  name = "netology-15-2-nlb"
  type = "external"

  listener {
    name        = "http"
    port        = 80
    target_port = 80
    protocol    = "tcp"

    external_address_spec {
      ip_version = "ipv4"
    }
  }

  attached_target_group {
    target_group_id = yandex_compute_instance_group.lamp.load_balancer[0].target_group_id

    healthcheck {
      name                = "http"
      interval            = 5
      timeout             = 3
      healthy_threshold   = 2
      unhealthy_threshold = 2

      http_options {
        port = 80
        path = "/"
      }
    }
  }
}
