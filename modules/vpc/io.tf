# vpc io.tf
variable "vpc_cidr" {}

output "vpc_id" {
  value = "${aws_vpc.kubernetes.id}"
}

output "subnet_id" {
  value = "${aws_subnet.kubernetes.id}"
}

output "subnet_az" {
  value = "${aws_subnet.kubernetes.availability_zone}"
}
