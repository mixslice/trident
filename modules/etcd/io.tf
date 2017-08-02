variable "etcd_count" {}
variable "etcd_ami" {}
variable "etcd_instance_type" {}
variable "etcd_volume_size" {}

variable "k8s_etcd_sg_id" {}
variable "k8s_subnet_id" {}
variable "k8s_iam_profile_name" {}

variable "ssh_key_name" {}
variable "ssh_user_name" {}
variable "ssh_private_key_path"{}

output "public_ips" {
  value = "${aws_instance.etcd.*.public_ip}"
}
output "private_ips" {
  value = "${aws_instance.etcd.*.private_ip}"
}
