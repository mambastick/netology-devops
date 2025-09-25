# Задание 4

Создал файл `outputs.tf` и записал в него следующий конфиг:
```terraform
output "instances" {
  description = "Instance name, external IP and FQDN for each VM"
  value = {
    for inst in [
      yandex_compute_instance.platform,
      yandex_compute_instance.db
    ] :
    inst.name => {
      instance_name = inst.name
      external_ip   = try(inst.network_interface[0].nat_ip_address, null)
      fqdn          = inst.fqdn
    }
  }
}

```

Сделал `terraform validate`, а затем `terraform apply`:
![img.png](img.png)