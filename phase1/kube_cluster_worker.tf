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

    vpc_security_group_ids = ["${aws_security_group.kubernetes.id}"]
    subnet_id = "${aws_subnet.kubernetes.id}"
    associate_public_ip_address = true
    iam_instance_profile = "${aws_iam_instance_profile.worker_profile.name}"

    key_name = "${aws_key_pair.ssh_key.key_name}"

    tags {
      Name = "k8s-worker-${count.index}"
    }
}

output "kubernetes_workers_public_ip" {
    value = "${join(",", aws_instance.worker.*.public_ip)}"
}

resource "null_resource" "worker" {
    count = "${var.worker_count}"

    depends_on = ["null_resource.master"]

    triggers {
        etcd_endpoints = "${join(",", formatlist("http://%s:2379", aws_instance.master.*.private_ip))}"
    }
    # Tell terraform how to connect to these instances
    connection {
        host = "${element(aws_instance.worker.*.public_ip, count.index)}"
        type = "ssh"
        user = "core"
        private_key = "${file(var.ssh_private_key_path)}"
    }

    # Move local files to machines
    provisioner "file" {
        source = "openssl/certs"
        destination = "/tmp"
    }

    provisioner "file" {
        source = "shared/"
        destination = "/tmp"
    }

    provisioner "file" {
        source = "worker/"
        destination = "/tmp"
    }

    # Set up worker node
    provisioner "remote-exec" {
        inline = [
            "sudo mkdir -p /etc/kubernetes/ssl",
            "sudo mv /tmp/certs/ca.pem /etc/kubernetes/ssl/ca.pem",
            "sudo mv /tmp/certs/worker.pem /etc/kubernetes/ssl/worker.pem",
            "sudo mv /tmp/certs/worker-key.pem /etc/kubernetes/ssl/worker-key.pem",
            "rm -R /tmp/certs",
            "sudo chmod 600 /etc/kubernetes/ssl/*-key.pem",
            "sudo chown root:root /etc/kubernetes/ssl/*-key.pem",

            "MASTER_HOST=${aws_elb.kube_master.dns_name}",
            "ETCD_ENDPOINTS=${self.triggers.etcd_endpoints}",
            "ADVERTISE_IP=${element(aws_instance.worker.*.private_ip, count.index)}",
            "ADVERTISE_DNS=${element(aws_instance.worker.*.private_dns, count.index)}",
            "sed -i \"s|<ADVERTISE_IP>|$ADVERTISE_IP|g\" /tmp/options.env",
            "sed -i \"s|<ETCD_ENDPOINTS>|$ETCD_ENDPOINTS|g\" /tmp/options.env",
            "sudo mkdir -p /etc/flannel",
            "sudo mv /tmp/options.env /etc/flannel/options.env",
            "sudo mkdir -p /etc/systemd/system/flanneld.service.d",
            "sudo mv /tmp/40-ExecStartPre-symlink.conf /etc/systemd/system/flanneld.service.d/40-ExecStartPre-symlink.conf",
            "sudo mkdir -p /etc/systemd/system/docker.service.d",
            "sudo mv /tmp/40-flannel.conf /etc/systemd/system/docker.service.d/40-flannel.conf",
            "sed -i \"s|<MASTER_HOST>|$MASTER_HOST|g\" /tmp/kubelet.service",
            "sed -i \"s|<ADVERTISE_DNS>|$ADVERTISE_DNS|g\" /tmp/kubelet.service",
            "sudo mv /tmp/kubelet.service /etc/systemd/system/kubelet.service",
            "sed -i 's|<KUBE_VERSION>|${var.kube_version}|g' /tmp/kube-proxy.yaml",
            "sed -i \"s|<MASTER_HOST>|$MASTER_HOST|g\" /tmp/kube-proxy.yaml",
            "sudo mkdir -p /etc/kubernetes/manifests",
            "sudo mv /tmp/kube-proxy.yaml /etc/kubernetes/manifests/kube-proxy.yaml",
            "sudo mv /tmp/worker-kubeconfig.yaml /etc/kubernetes/worker-kubeconfig.yaml",
            "sudo systemctl daemon-reload",
            "sudo systemctl start kubelet",
            "sudo systemctl enable kubelet"
        ]
    }
}
