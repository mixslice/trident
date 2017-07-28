provider "aws" {
    access_key = "${var.access_key}"
    secret_key = "${var.secret_key}"
    region = "${var.region}"
}

# resource "aws_key_pair" "ssh_key" {
#     key_name = "k8s"
#     public_key = "${var.ssh_public_key}"
# }
