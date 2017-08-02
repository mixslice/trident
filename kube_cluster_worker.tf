############################################
# K8s Worker (aka Nodes, Minions) Instances
############################################

resource "aws_instance" "worker" {
  count = "${var.worker_count}"

  ami = "${lookup(var.amis, var.region)}"
  instance_type = "${var.worker_instance_type}"

  root_block_device = {
    volume_type = "gp2"
    volume_size = "${var.worker_volume_size}"
  }

  vpc_security_group_ids = ["${aws_security_group.k8s-worker.id}"]
  subnet_id = "${aws_subnet.kubernetes.id}"
  associate_public_ip_address = true
  iam_instance_profile = "${aws_iam_instance_profile.worker_profile.name}"
  user_data = "${data.template_file.worker_yaml.rendered}"
  key_name = "${var.ssh_key_name}"

  connection {
    type = "ssh",
    user = "core",
    private_key = "${file(var.ssh_private_key_path)}"
  }

  # Generate k8s_worker client certificate
  provisioner "local-exec" {
    command = <<EOF
      ${path.module}/cfssl/generate_client.sh k8s_worker
EOF
  }

  # Provision k8s_master client certificate
  provisioner "file" {
    source = "./secrets/ca.pem"
    destination = "/home/core/ca.pem"
  }
  provisioner "file" {
    source = "./secrets/client-k8s_worker.pem"
    destination = "/home/core/worker.pem"
  }
  provisioner "file" {
    source = "./secrets/client-k8s_worker-key.pem"
    destination = "/home/core/worker-key.pem"
  }

  # TODO: permissions on these keys
  provisioner "remote-exec" {
    inline = [
      "sudo mkdir -p /etc/kubernetes/ssl",
      "sudo cp /home/core/{ca,worker,worker-key}.pem /etc/kubernetes/ssl/.",
      "sudo mkdir -p /etc/ssl/etcd/",
      "sudo mv /home/core/{ca,worker,worker-key}.pem /etc/ssl/etcd/."
    ]
  }


  tags {
    Name = "k8s-worker-${count.index}"
  }
}

output "kubernetes_workers_public_ip" {
  value = "${join(",", aws_instance.worker.*.public_ip)}"
}

data "template_file" "worker_yaml" {
  depends_on = ["null_resource.ecr_credentials_gen"]
  template = "${file("${path.module}/k8s/worker.yaml")}"
  vars {
    DNS_SERVICE_IP = "10.3.0.10"
    ETCD_IP = "${aws_instance.etcd.private_ip}"
    MASTER_HOST = "${aws_instance.master.private_ip}"
    DOCKER_LOGIN_CMD = "${file("${path.module}/secrets/docker_login")}"
    S3_LOCATION = "${var.s3_location}"
    FLANNEL_VERSION = "${var.flannel_version}"
    PAUSE_VERSION = "${var.pause_version}"
    HYPERKUBE_ECR_LOCATION= "${var.ecr_location}"
    HYPERKUBE_IMAGE = "${var.kube_image}"
    HYPERKUBE_VERSION = "${var.kube_version}"
  }
}
