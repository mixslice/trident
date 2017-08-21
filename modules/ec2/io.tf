# ec2 io.tf
variable "type" {}
variable "count" {}
variable "ami" {}
variable "instance_type" {}
variable "volume_size" {}
variable "ssh_key_name" {}

variable "sg_id" {}
variable "subnet_id" {}
variable "iam_profile_name" {}
variable "user_data" {}

variable "ansibleFilter" {}
variable "ansibleNodeType" {}

output "public_ips" {
  value = "${aws_instance.ec2.*.public_ip}"
}
output "private_ips" {
  value = "${aws_instance.ec2.*.private_ip}"
}
output "instance_ids" {
  value = "${aws_instance.ec2.*.id}"
}
output "private_dnss" {
  value = "${aws_instance.ec2.*.private_dns}"
}
