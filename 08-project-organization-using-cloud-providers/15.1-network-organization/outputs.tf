output "network" {
  value = {
    id   = yandex_vpc_network.homework.id
    name = yandex_vpc_network.homework.name
    subnets = {
      public  = local.public_cidr
      private = local.private_cidr
    }
  }
}

output "nat_instance" {
  value = {
    private_ip = yandex_compute_instance.nat.network_interface[0].ip_address
    public_ip  = yandex_compute_instance.nat.network_interface[0].nat_ip_address
  }
}

output "public_vm" {
  value = {
    private_ip = yandex_compute_instance.public.network_interface[0].ip_address
    public_ip  = yandex_compute_instance.public.network_interface[0].nat_ip_address
  }
}

output "private_vm" {
  value = {
    private_ip = yandex_compute_instance.private.network_interface[0].ip_address
  }
}

output "ssh_commands" {
  value = {
    public_vm  = "ssh -p 443 ${var.vm_user}@${yandex_compute_instance.public.network_interface[0].nat_ip_address}"
    private_vm = "ssh -p 443 -J ${var.vm_user}@${yandex_compute_instance.public.network_interface[0].nat_ip_address}:443 ${var.vm_user}@${yandex_compute_instance.private.network_interface[0].ip_address}"
  }
}
