locals {
  image_key    = "netology-cloud.svg"
  image_source = "${path.module}/../15.2-compute-resources-and-load-balancers/assets/netology-cloud.svg"
}

resource "yandex_iam_service_account" "storage" {
  name        = "netology-15-3-storage"
  description = "Service account for the encrypted bucket"
}

resource "yandex_resourcemanager_folder_iam_member" "storage_admin" {
  folder_id = var.folder_id
  role      = "storage.admin"
  member    = "serviceAccount:${yandex_iam_service_account.storage.id}"
}

resource "yandex_iam_service_account_static_access_key" "storage" {
  service_account_id = yandex_iam_service_account.storage.id
  description        = "Static key for the encrypted bucket"

  depends_on = [yandex_resourcemanager_folder_iam_member.storage_admin]
}

resource "yandex_kms_symmetric_key" "storage" {
  name              = "netology-15-3-kms"
  description       = "KMS key for Object Storage encryption"
  default_algorithm = "AES_256"
  rotation_period   = "24h"
}

resource "yandex_resourcemanager_folder_iam_member" "kms_encrypter_decrypter" {
  folder_id = var.folder_id
  role      = "kms.keys.encrypterDecrypter"
  member    = "serviceAccount:${yandex_iam_service_account.storage.id}"
}

resource "yandex_storage_bucket" "encrypted" {
  bucket     = var.bucket_name
  access_key = yandex_iam_service_account_static_access_key.storage.access_key
  secret_key = yandex_iam_service_account_static_access_key.storage.secret_key

  force_destroy = true

  anonymous_access_flags {
    read        = true
    list        = false
    config_read = false
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        kms_master_key_id = yandex_kms_symmetric_key.storage.id
        sse_algorithm     = "aws:kms"
      }
    }
  }

  depends_on = [yandex_resourcemanager_folder_iam_member.kms_encrypter_decrypter]
}

resource "yandex_storage_object" "image" {
  bucket       = yandex_storage_bucket.encrypted.bucket
  key          = local.image_key
  source       = local.image_source
  source_hash  = filemd5(local.image_source)
  content_type = "image/svg+xml"
  acl          = "public-read"
  access_key   = yandex_iam_service_account_static_access_key.storage.access_key
  secret_key   = yandex_iam_service_account_static_access_key.storage.secret_key
}
