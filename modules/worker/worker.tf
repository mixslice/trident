############################################
# K8s Worker (aka Nodes, Minions) Instances
############################################

resource "aws_instance" "worker" {
  count = "${var.count}"

  ami = "${var.ami}"
  instance_type = "${var.instance_type}"

  root_block_device = {
    volume_type = "gp2"
    volume_size = "${var.volume_size}"
  }

  vpc_security_group_ids = ["${var.sg_id}"]
  subnet_id = "${var.subnet_id}"
  associate_public_ip_address = true
  iam_instance_profile = "${var.iam_profile_name}"
  user_data = "${data.template_file.worker_yaml.rendered}"
  key_name = "${var.ssh_key_name}"

  connection {
    type = "ssh",
    user = "${var.ssh_user_name}",
    private_key = "${file(var.ssh_private_key_path)}"
  }

  # Generate worker client certificate
  provisioner "local-exec" {
    command = <<EOF
${path.root}/cfssl/generate.sh client kube-worker
${path.root}/cfssl/generate.sh client kube-proxy
EOF
  }

  # Provision k8s certificates
  provisioner "file" {
    source = "${path.root}/secrets/ca.pem"
    destination = "/home/core/ca.pem"
  }
  provisioner "file" {
    source = "${path.root}/secrets/kube-worker.pem"
    destination = "/home/core/kube-worker.pem"
  }
  provisioner "file" {
    source = "${path.root}/secrets/kube-worker-key.pem"
    destination = "/home/core/kube-worker-key.pem"
  }
  provisioner "file" {
    source = "${path.root}/secrets/kube-proxy.pem"
    destination = "/home/core/kube-proxy.pem"
  }
  provisioner "file" {
    source = "${path.root}/secrets/kube-proxy-key.pem"
    destination = "/home/core/kube-proxy-key.pem"
  }
  provisioner "file" {
    source = "${path.root}/secrets/etcd.pem"
    destination = "/home/core/etcd.pem"
  }
  provisioner "file" {
    source = "${path.root}/secrets/etcd-key.pem"
    destination = "/home/core/etcd-key.pem"
  }

  # TODO: permissions on these keys
  provisioner "remote-exec" {
    inline = [
      "sudo mkdir -p /etc/kubernetes/ssl",
      "sudo mv /home/core/{ca,etcd,etcd-key,kube-worker,kube-worker-key,kube-proxy,kube-proxy-key}.pem /etc/kubernetes/ssl/."
    ]
  }


  tags {
    Name = "k8s-${var.type}-${count.index}"
    ansibleFilter = "${var.ansibleFilter}"
    ansibleNodeType = "${var.ansibleNodeType}"
    ansibleNodeName = "${var.ansibleNodeType}-${count.index}"
  }
}


data "template_file" "worker_yaml" {

  template = "${file("${path.module}/worker.yml")}"
  vars {
    CLUSTER_DOMAIN = "${var.cluster_domain}"
    DNS_SERVICE_IP = "${var.dns_service_ip}"
    NODE_LABELS = "${var.node_labels}"
    ETCD_IP = "${var.etcd_private_ip}"
    POD_NETWORK = "${var.pod_network}"
    MASTER_HOST = "${var.master_private_ip}"
    S3_LOCATION = "${var.s3_location}"
    FLANNEL_VERSION = "${var.flannel_version}"
    POD_INFRA_CONTAINER_IMAGE = "${var.pod_infra_container_image}"
    HYPERKUBE_ECR_LOCATION= "${var.ecr_location}"
    HYPERKUBE_IMAGE = "${var.kube_image}"
    HYPERKUBE_VERSION = "${var.kube_version}"
  }
}
