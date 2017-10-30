# eip io.tf
variable "instance_id" {}
variable "allocation_id" {}

output "ip"{
  value = "${aws_eip_association.eip_assoc.public_ip}"
}
