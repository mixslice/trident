variable "vpc_id" {}
variable "vpc_cidr" {}
variable "control_cidr" {}

output "etcd_id" {
  value = "${aws_security_group.k8s-etcd.id}"
}
output "master_id" {
  value = "${aws_security_group.k8s-master.id}"
}
output "worker_id" {
  value = "${aws_security_group.k8s-worker.id}"
}
