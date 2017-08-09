# All printed outputs
output "k8s_etcd_ip" {
  value = "${module.etcd.public_ips}"
}
output "k8s_etcd_private_ip" {
  value = "${module.etcd.private_ips}"
}
output "k8s_master_ip" {
  value = "${module.master.public_ips}"
}
output "k8s_master_private_ip" {
  value = "${module.master.private_ips}"
}
output "k8s_worker_ip" {
  value = "${module.worker.public_ips}"
}
output "k8s_worker_private_ip" {
  value = "${module.worker.private_ips}"
}
