############################
# K8s ETCD Instances
############################
resource "aws_instance" "etcd" {
  count                       = "${var.etcd_count}"

  ami                         = "${var.etcd_ami}"
  instance_type               = "${var.etcd_instance_type}"

  root_block_device = {
    volume_type = "gp2"
    volume_size               = "${var.etcd_volume_size}"
  }

  vpc_security_group_ids      = ["${var.k8s_etcd_sg_id}"]
  subnet_id                   = "${var.k8s_subnet_id}"
  associate_public_ip_address = true
  iam_instance_profile        = "${var.k8s_iam_profile_name}"
  user_data                   = "${file("${path.module}/etcd.yaml")}"
  key_name                    = "${var.ssh_key_name}"

  connection {
    type = "ssh",
    user                      = "${var.ssh_user_name}",
    private_key               = "${file(var.ssh_private_key_path)}"
  }

  # Generate the Certificate Authority
  provisioner "local-exec" {
    command = <<EOF
${path.root}/cfssl/generate_ca.sh
${path.root}/cfssl/generate_server.sh k8s_etcd ${self.private_ip}
EOF
  }

  #
  provisioner "file" {
    source = "${path.root}/secrets/ca.pem"
    destination = "/home/core/ca.pem"
  }

  provisioner "file" {
    source = "${path.root}/secrets/k8s_etcd.pem"
    destination = "/home/core/etcd.pem"
  }
  provisioner "file" {
    source = "${path.root}/secrets/k8s_etcd-key.pem"
    destination = "/home/core/etcd-key.pem"
  }
  # Move certificates & restart etcd2
  provisioner "remote-exec" {
    inline = [
      "sudo mkdir -p /etc/kubernetes/ssl",
      "sudo mv /home/core/{ca,etcd,etcd-key}.pem /etc/kubernetes/ssl/.",
      "sudo systemctl start etcd2",
      "sudo systemctl enable etcd2"
    ]
  }

  tags {
    Name = "k8s-etcd-${count.index}"
  }
}
