output "kms_key" {
  value = {
    id        = yandex_kms_symmetric_key.storage.id
    algorithm = yandex_kms_symmetric_key.storage.default_algorithm
  }
}

output "encrypted_bucket" {
  value = {
    name       = yandex_storage_bucket.encrypted.bucket
    object_url = "https://storage.yandexcloud.net/${yandex_storage_bucket.encrypted.bucket}/${yandex_storage_object.image.key}"
  }
}
