variable "zone" {
  description = "Yandex Cloud availability zone"
  type        = string
  default     = "ru-central1-a"
}

variable "ssh_public_key_path" {
  description = "Path to the public SSH key"
  type        = string
  default     = "~/.ssh/id_ed25519.pub"
}

variable "vm_user" {
  description = "Linux user created on the virtual machines"
  type        = string
  default     = "yc-user"
}

variable "nat_image_id" {
  description = "NAT instance image required by the assignment"
  type        = string
  default     = "fd80mrhj8fl2oe87o4e1"
}
