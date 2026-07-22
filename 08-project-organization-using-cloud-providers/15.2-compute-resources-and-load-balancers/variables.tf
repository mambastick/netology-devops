variable "folder_id" {
  description = "Yandex Cloud folder ID"
  type        = string
  default     = "b1go0ejd095nvn796sns"
}

variable "cloud_id" {
  description = "Yandex Cloud ID"
  type        = string
  default     = "b1g7iol3qfndu08g0o15"
}

variable "zone" {
  description = "Yandex Cloud availability zone"
  type        = string
  default     = "ru-central1-a"
}

variable "bucket_name" {
  description = "Globally unique Object Storage bucket name"
  type        = string
  default     = "netology-mambastick-20260722"
}

variable "lamp_image_id" {
  description = "LAMP image required by the assignment"
  type        = string
  default     = "fd827b91d99psvq5fjit"
}
