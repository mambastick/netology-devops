variable "cloud_id" {
  description = "Yandex Cloud ID"
  type        = string
}

variable "folder_id" {
  description = "Yandex Cloud folder ID"
  type        = string
}

variable "default_zone" {
  description = "Default availability zone"
  type        = string
  default     = "ru-central1-a"
}

variable "mysql_password" {
  description = "Password for the netology MySQL user"
  type        = string
  sensitive   = true
}

variable "kms_key_id" {
  description = "ID of the KMS key created in homework 15.3"
  type        = string
}
