# Master io.tf
variable "type" {}
variable "count" {}
variable "ami" {}
variable "instance_type" {}
variable "volume_size" {}

variable "sg_id" {}
variable "subnet_id" {}
variable "iam_profile_name" {}
variable "service_ip" {}

variable "ssh_key_name" {}
variable "ssh_user_name" {}
variable "ssh_private_key_path"{}

variable "cluster_domain" {}
variable "dns_service_ip" {}
variable "etcd_private_ip" {}
variable "pod_network" {}
variable "service_ip_range" {}
variable "s3_location" {}
variable "ecr_location" {}
variable "flannel_version" {}
variable "pod_infra_container_image" {}
variable "kube_image" {}
variable "kube_version" {}
variable "node_labels" {}

variable "ansibleFilter" {}
variable "ansibleNodeType" {}

output "public_ips" {
  value = "${aws_instance.master.*.public_ip}"
}
output "private_ips" {
  value = "${aws_instance.master.*.private_ip}"
}
