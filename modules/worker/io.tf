variable "worker_count" {}
variable "worker_ami" {}
variable "worker_instance_type" {}
variable "worker_volume_size" {}

variable "k8s_worker_sg_id" {}
variable "k8s_subnet_id" {}
variable "k8s_iam_profile_name" {}

variable "ssh_key_name" {}
variable "ssh_user_name" {}
variable "ssh_private_key_path" {}

variable "cluster_domain" {}
variable "dns_service_ip" {}
variable "etcd_private_ip" {}
variable "master_private_ip" {}
variable "pod_network" {}
variable "service_ip_range" {}
variable "s3_location" {}
variable "ecr_location" {}
variable "flannel_version" {}
variable "pod_infra_container_image" {}
variable "kube_image" {}
variable "kube_version" {}

output "public_ips" {
  value = "${aws_instance.worker.*.public_ip}"
}
output "private_ips" {
  value = "${aws_instance.worker.*.private_ip}"
}
output "instance_ids" {
  value = "${aws_instance.worker.*.id}"
}
output "private_dnss" {
  value = "${aws_instance.worker.*.private_dns}"
}
