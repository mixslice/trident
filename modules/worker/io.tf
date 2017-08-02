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

variable "dns_service_ip" {}
variable "etcd_private_ip" {}
variable "master_private_ip" {}
variable "pod_network" {}
variable "service_ip_range" {}
variable "s3_location" {}
variable "ecr_location" {}
variable "flannel_version" {}
variable "pause_version" {}
variable "kube_image" {}
variable "kube_version" {}

output "public_ips" {
  value = "${aws_instance.worker.*.public_ip}"
}
output "private_ip" {
  value = "${aws_instance.worker.*.private_ip}"
}
