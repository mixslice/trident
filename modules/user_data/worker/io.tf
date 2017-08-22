variable "etcd_ip" {}
variable "pod_network" {}

output "rendered_data"{
  value = "${data.template_file.worker_yml.rendered}"
}
