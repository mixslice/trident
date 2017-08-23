# All printed outputs
# If you change the names of these outputs you must also change names in ansible/load.py
# Masters
output "k8s_master_ip" {
  value = "${module.master.public_ips}"
}
output "k8s_master_private_ip" {
  value = "${module.master.private_ips}"
}
# Workers
output "k8s_worker_ip" {
  value = "${module.worker.public_ips}"
}
output "k8s_worker_private_ip" {
  value = "${module.worker.private_ips}"
}
# EDGE workers
output "k8s_edge_ip" {
  value = "${list(module.eip.ip)}"
}
output "k8s_edge_private_ip" {
  value = "${module.edge.private_ips}"
}
