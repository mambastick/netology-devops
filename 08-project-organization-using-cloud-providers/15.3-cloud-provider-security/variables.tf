variable "cloud_id" {
  description = "Yandex Cloud ID"
  type        = string
  default     = "b1g7iol3qfndu08g0o15"
}

variable "folder_id" {
  description = "Yandex Cloud folder ID"
  type        = string
  default     = "b1go0ejd095nvn796sns"
}

variable "zone" {
  description = "Yandex Cloud availability zone"
  type        = string
  default     = "ru-central1-a"
}

variable "bucket_name" {
  description = "Object Storage bucket created in homework 15.2"
  type        = string
  default     = "netology-mambastick-20260722"
}
