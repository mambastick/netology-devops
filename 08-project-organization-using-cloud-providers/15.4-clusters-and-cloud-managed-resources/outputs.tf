output "mysql_cluster_id" {
  value = yandex_mdb_mysql_cluster.netology.id
}

output "mysql_hosts" {
  value = yandex_mdb_mysql_cluster.netology.host[*].fqdn
}

output "kubernetes_cluster_id" {
  value = yandex_kubernetes_cluster.regional.id
}

output "kubernetes_node_group_id" {
  value = yandex_kubernetes_node_group.workers.id
}

output "get_credentials_command" {
  value = "yc managed-kubernetes cluster get-credentials ${yandex_kubernetes_cluster.regional.id} --external --force"
}
