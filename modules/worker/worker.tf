############################################
# K8s Worker (aka Nodes, Minions) Instances
############################################

resource "aws_instance" "worker" {
  count = "${var.worker_count}"

  ami = "${var.worker_ami}"
  instance_type = "${var.worker_instance_type}"

  root_block_device = {
    volume_type = "gp2"
    volume_size = "${var.worker_volume_size}"
  }

  vpc_security_group_ids = ["${var.k8s_worker_sg_id}"]
  subnet_id = "${var.k8s_subnet_id}"
  associate_public_ip_address = true
  iam_instance_profile = "${var.k8s_iam_profile_name}"
  user_data = "${data.template_file.worker_yaml.rendered}"
  key_name = "${var.ssh_key_name}"

  connection {
    type = "ssh",
    user = "${var.ssh_user_name}",
    private_key = "${file(var.ssh_private_key_path)}"
  }

  # Generate k8s_worker client certificate
  provisioner "local-exec" {
    command = <<EOF
${path.root}/cfssl/generate_client.sh k8s_worker
EOF
  }

  # Provision k8s_master client certificate
  provisioner "file" {
    source = "${path.root}/secrets/ca.pem"
    destination = "/home/core/ca.pem"
  }
  provisioner "file" {
    source = "${path.root}/secrets/client-k8s_worker.pem"
    destination = "/home/core/worker.pem"
  }
  provisioner "file" {
    source = "${path.root}/secrets/client-k8s_worker-key.pem"
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


data "template_file" "worker_yaml" {

  template = "${file("${path.module}/worker.yaml")}"
  vars {
    CLUSTER_DOMAIN = "${var.cluster_domain}"
    DNS_SERVICE_IP = "${var.dns_service_ip}"
    ETCD_IP = "${var.etcd_private_ip}"
    POD_NETWORK = "${var.pod_network}"
    MASTER_HOST = "${var.master_private_ip}"
    DOCKER_LOGIN_CMD = "${file("${path.root}/secrets/docker_login")}"
    S3_LOCATION = "${var.s3_location}"
    FLANNEL_VERSION = "${var.flannel_version}"
    POD_INFRA_CONTAINER_IMAGE = "${var.pod_infra_container_image}"
    HYPERKUBE_ECR_LOCATION= "${var.ecr_location}"
    HYPERKUBE_IMAGE = "${var.kube_image}"
    HYPERKUBE_VERSION = "${var.kube_version}"
  }
}
