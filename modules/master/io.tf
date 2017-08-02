variable "master_count" {}
variable "master_ami" {}
variable "master_instance_type" {}
variable "master_volume_size" {}

variable "k8s_master_sg_id" {}
variable "k8s_subnet_id" {}
variable "k8s_iam_profile_name" {}

variable "dns_service_ip" {}
variable "etcd_private_ip" {}
variable "pod_network" {}
variable "service_ip_range" {}
variable "s3_location" {}
variable "ecr_location" {}
variable "flannel_version" {}
variable "pause_version" {}
variable "kube_image" {}
variable "kube_version" {}

variable "ssh_key_name" {}
variable "ssh_user_name" {}
variable "ssh_private_key_path"{}

output "public_ips" {
  value = "${aws_instance.master.*.public_ip}"
}
output "private_ips" {
  value = "${aws_instance.master.*.private_ip}"
}
