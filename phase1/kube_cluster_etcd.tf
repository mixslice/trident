############################
# K8s ETCD Instances
############################
resource "aws_instance" "etcd" {
    count = "${var.etcd_count}"

    ami = "${lookup(var.amis, var.region)}"
    instance_type = "${var.etcd_instance_type}"

    root_block_device = {
        volume_type = "gp2"
        volume_size = "${var.etcd_volumn_size}"
    }

    vpc_security_group_ids = ["${aws_security_group.k8s-master.id}"]
    subnet_id = "${aws_subnet.kubernetes.id}"
    associate_public_ip_address = true
    iam_instance_profile = "${aws_iam_instance_profile.master_profile.name}"
    user_data = "${file("${path.module}/k8s/etcd.yaml")}"
    key_name = "${var.ssh_key_name}"

    connection {
        type = "ssh",
        user = "core",
        private_key = "${file(var.ssh_private_key_path)}"
    }

    # Generate the Certificate Authority
    provisioner "local-exec" {
        command = <<EOF
            ${path.module}/cfssl/generate_ca.sh
EOF
    }
    # Generate k8s-etcd server certificate
    provisioner "local-exec" {
        command = <<EOF
            ${path.module}/cfssl/generate_server.sh k8s_etcd ${self.private_ip}
EOF
    }
    #
    provisioner "file" {
        source = "./secrets/ca.pem"
        destination = "/home/core/ca.pem"
    }

    provisioner "file" {
        source = "./secrets/k8s_etcd.pem"
        destination = "/home/core/etcd.pem"
    }
    provisioner "file" {
        source = "./secrets/k8s_etcd-key.pem"
        destination = "/home/core/etcd-key.pem"
    }
    provisioner "remote-exec" {
        inline = [
            "sudo mkdir -p /etc/kubernetes/ssl",
            "sudo mv /home/core/{ca,etcd,etcd-key}.pem /etc/kubernetes/ssl/."
        ]
    }

    # Start etcd2
    provisioner "remote-exec" {
        inline = [
            "sudo systemctl start etcd2",
            "sudo systemctl enable etcd2",
        ]
    }

    tags {
        Name = "k8s-etcd"
    }
}

output "kubernetes_etcd_public_ips" {
    value = "${join(",", aws_instance.etcd.*.public_ip)}"
}
