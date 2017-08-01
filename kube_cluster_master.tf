############################
# K8s Master Instances
############################

resource "aws_instance" "master" {
    count = "${var.master_count}"

    ami = "${lookup(var.amis, var.region)}"
    instance_type = "${var.master_instance_type}"

    root_block_device = {
        volume_type = "gp2"
        volume_size = "${var.master_volume_size}"
    }

    vpc_security_group_ids = ["${aws_security_group.k8s-master.id}"]
    subnet_id = "${aws_subnet.kubernetes.id}"
    associate_public_ip_address = true
    iam_instance_profile = "${aws_iam_instance_profile.master_profile.name}"
    user_data = "${data.template_file.master_yaml.rendered}"
    key_name = "${var.ssh_key_name}"

    connection {
       type = "ssh",
       user = "core",
       private_key = "${file(var.ssh_private_key_path)}"
    }

    # Generate k8s_master server certificate
    provisioner "local-exec" {
        command = <<EOF
            ${path.module}/cfssl/generate_server.sh k8s_master "${self.public_ip},${self.private_ip},10.3.0.1,kubernetes.default,kubernetes"
EOF
    }
    # Provision k8s_etcd server certificate
    provisioner "file" {
        source = "./secrets/ca.pem"
        destination = "/home/core/ca.pem"
    }
    provisioner "file" {
        source = "./secrets/k8s_master.pem"
        destination = "/home/core/apiserver.pem"
    }
    provisioner "file" {
        source = "./secrets/k8s_master-key.pem"
        destination = "/home/core/apiserver-key.pem"
    }

    # Generate k8s_master client certificate
    provisioner "local-exec" {
        command = <<EOF
            ${path.module}/cfssl/generate_client.sh k8s_master
EOF
    }

    # Provision k8s_master client certificate
    provisioner "file" {
        source = "./secrets/client-k8s_master.pem"
        destination = "/home/core/client.pem"
    }
    provisioner "file" {
        source = "./secrets/client-k8s_master-key.pem"
        destination = "/home/core/client-key.pem"
    }
    # Move certificate into kubernetes/ssl
    provisioner "remote-exec" {
        inline = [
            "sudo mkdir -p /etc/kubernetes/ssl",
            "sudo mv /home/core/{ca,apiserver,apiserver-key,client,client-key}.pem /etc/kubernetes/ssl/.",
        ]
    }

    tags {
      Name = "k8s-master-${count.index}"
    }
}

output "kubernetes_master_public_ip" {
    value = "${join(",", aws_instance.master.*.public_ip)}"
}

resource "null_resource" "ecr_credentials_gen" {
    provisioner "local-exec" {
        command = <<EOF
aws ecr get-login --no-include-email --region cn-north-1 > ./secrets/docker_login
EOF
    }
}

data "template_file" "master_yaml" {
  depends_on = ["null_resource.ecr_credentials_gen"]
  template = "${file("${path.module}/k8s/master.yaml")}"
  vars {
    DNS_SERVICE_IP = "10.3.0.10"
    ETCD_IP = "${aws_instance.etcd.private_ip}"
    POD_NETWORK = "10.2.0.0/16"
    SERVICE_IP_RANGE = "10.3.0.0/24"
    DOCKER_LOGIN_CMD = "${file("${path.module}/secrets/docker_login")}"
    S3_LOCATION = "${var.s3_location}"
    FLANNEL_VERSION = "${var.flannel_version}"
    PAUSE_VERSION = "${var.pause_version}"
    HYPERKUBE_ECR_LOCATION= "${var.ecr_location}"
    HYPERKUBE_IMAGE = "${var.kube_image}"
    HYPERKUBE_VERSION = "${var.kube_version}"
  }
}
