############################
# K8s Master Instances (ETCD included)
############################
resource "aws_instance" "master" {
  count                       = "${var.count}"

  ami                         = "${var.ami}"
  instance_type               = "${var.instance_type}"

  root_block_device = {
    volume_type = "gp2"
    volume_size               = "${var.volume_size }"
  }

  vpc_security_group_ids      = ["${var.sg_id}"]
  subnet_id                   = "${var.subnet_id}"
  associate_public_ip_address = true
  iam_instance_profile        = "${var.iam_profile_name}"
  user_data                   = "${data.template_file.master_yaml.rendered}"
  key_name                    = "${var.ssh_key_name}"

  connection {
     type = "ssh",
     user                     = "${var.ssh_user_name}",
     private_key              = "${file(var.ssh_private_key_path)}"
  }

  # Generate k8s_master server certificate
  provisioner "local-exec" {
    command = <<EOF
    ${path.root}/cfssl/generate_ca.sh
    ${path.root}/cfssl/generate.sh client-server etcd "${self.private_ip},127.0.0.1"
    ${path.root}/cfssl/generate.sh client kube-master
    ${path.root}/cfssl/generate.sh server kube-apiserver "${self.public_ip},${self.private_ip},${var.service_ip},kubernetes.default,kubernetes"

EOF
  }
  # Provision certificate
  provisioner "file" {
    source = "${path.root}/secrets/ca.pem"
    destination = "/home/core/ca.pem"
  }
  provisioner "file" {
    source = "${path.root}/secrets/etcd.pem"
    destination = "/home/core/etcd.pem"
  }
  provisioner "file" {
    source = "${path.root}/secrets/etcd-key.pem"
    destination = "/home/core/etcd-key.pem"
  }
  provisioner "file" {
    source = "${path.root}/secrets/kube-master.pem"
    destination = "/home/core/kube-master.pem"
  }
  provisioner "file" {
    source = "${path.root}/secrets/kube-master-key.pem"
    destination = "/home/core/kube-master-key.pem"
  }
  provisioner "file" {
    source = "${path.root}/secrets/kube-apiserver.pem"
    destination = "/home/core/kube-apiserver.pem"
  }
  provisioner "file" {
    source = "${path.root}/secrets/kube-apiserver-key.pem"
    destination = "/home/core/kube-apiserver-key.pem"
  }
  # Move certificate into kubernetes/ssl
  provisioner "remote-exec" {
    inline = [
      "sudo mkdir -p /etc/kubernetes/ssl",
      "sudo mv /home/core/{ca,etcd,etcd-key,kube-master,kube-master-key,kube-apiserver,kube-apiserver-key}.pem /etc/kubernetes/ssl/",
      "rm -rf /home/core/secrets",
      "sudo systemctl start etcd2",
      "sudo systemctl enable etcd2"
    ]
  }

  tags {
    Name = "k8s-${var.type}-${count.index}"
    ansibleFilter = "${var.ansibleFilter}"
    ansibleNodeType = "${var.ansibleNodeType}"
    ansibleNodeName = "${var.ansibleNodeType}-${count.index}"
  }
}

data "template_file" "master_yaml" {
  template = "${file("${path.module}/master.yml")}"
  vars {
    CLUSTER_DOMAIN = "${var.cluster_domain}"
    DNS_SERVICE_IP = "${var.dns_service_ip}"
    ETCD_IP = ""
    POD_NETWORK = "${var.pod_network}"
    SERVICE_IP_RANGE = "${var.service_ip_range}"
    S3_LOCATION = "${var.s3_location}"
    NODE_LABELS = "${var.node_labels}"
    FLANNEL_VERSION = "${var.flannel_version}"
    POD_INFRA_CONTAINER_IMAGE = "${var.pod_infra_container_image}"
    HYPERKUBE_ECR_LOCATION= "${var.ecr_location}"
    HYPERKUBE_IMAGE = "${var.kube_image}"
    HYPERKUBE_VERSION = "${var.kube_version}"
  }
}
