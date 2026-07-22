output "bucket" {
  value = {
    name      = yandex_storage_bucket.images.bucket
    image_url = local.image_url
  }
}

output "instance_group" {
  value = {
    id        = yandex_compute_instance_group.lamp.id
    size      = length(yandex_compute_instance_group.lamp.instances)
    instances = [for instance in yandex_compute_instance_group.lamp.instances : instance.name]
  }
}

output "load_balancer" {
  value = {
    id         = yandex_lb_network_load_balancer.web.id
    public_ip  = one(one(yandex_lb_network_load_balancer.web.listener).external_address_spec).address
    public_url = "http://${one(one(yandex_lb_network_load_balancer.web.listener).external_address_spec).address}"
  }
}
