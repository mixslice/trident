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

    vpc_security_group_ids = ["${aws_security_group.kubernetes_api.id}"]
    subnet_id = "${aws_subnet.kubernetes.id}"
    associate_public_ip_address = true
    iam_instance_profile = "${aws_iam_instance_profile.master_profile.name}"
    user_data = "${template_file.cloud_init.rendered}"
    key_name = "${aws_key_pair.ssh_key.key_name}"

    tags {
      Name = "Master"
    }
}

output "kubernetes_master_public_ip" {
    value = "${join(",", aws_instance.master.*.public_ip)}"
}

resource "null_resource" "master" {
    count = "${var.master_count}"

    depends_on = ["aws_elb.kube_master"]

    triggers {
        etcd_endpoints = "${join(",", formatlist("http://%s:2379", aws_instance.master.*.private_ip))}"
        etcd_server = "${format("http://%s:2379", aws_instance.master.0.private_ip)}"
    }
    # Tell terraform how to connect to these instances
    connection {
        host = "${element(aws_instance.master.*.public_ip, count.index)}"
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
        source = "master/"
        destination = "/tmp"
    }

    provisioner "remote-exec" {
        inline = [
            "sudo mkdir -p /etc/kubernetes/ssl",
            "sudo mv /tmp/certs/ca.pem /etc/kubernetes/ssl/ca.pem",
            "sudo mv /tmp/certs/apiserver.pem /etc/kubernetes/ssl/apiserver.pem",
            "sudo mv /tmp/certs/apiserver-key.pem /etc/kubernetes/ssl/apiserver-key.pem",
            "rm -R /tmp/certs",
            "sudo chmod 600 /etc/kubernetes/ssl/*-key.pem",
            "sudo chown root:root /etc/kubernetes/ssl/*-key.pem",
            "sudo mkdir -p /opt/bin",
            "sudo curl -L -o /opt/bin/kubelet https://s3.cn-north-1.amazonaws.com.cn/kubernetes-bin/kubelet",
            "sudo chmod +x /opt/bin/kubelet",
            "K8S_VER=${var.kube_version}",
            "ETCD_ENDPOINTS=${self.triggers.etcd_endpoints}",
            "ETCD_SERVER=${self.triggers.etcd_server}",
            "ADVERTISE_IP=${element(aws_instance.master.*.private_ip, count.index)}",
            "ADVERTISE_DNS=${element(aws_instance.master.*.private_dns, count.index)}",
            "sed -i \"s|<ADVERTISE_IP>|$ADVERTISE_IP|g\" /tmp/options.env",
            "sed -i \"s|<ETCD_ENDPOINTS>|$ETCD_ENDPOINTS|g\" /tmp/options.env",
            "sudo mkdir -p /etc/systemd/system/etcd2.service.d",
            "sudo mv /tmp/40-listen-address.conf /etc/systemd/system/etcd2.service.d/40-listen-address.conf",
            "sudo systemctl daemon-reload",
            "sudo systemctl start etcd2",
            "sudo systemctl enable etcd2",
            "sudo mkdir -p /etc/flannel",
            "sudo mv /tmp/options.env /etc/flannel/options.env",
            "sudo mkdir -p /etc/systemd/system/flanneld.service.d",
            "sudo mv /tmp/40-ExecStartPre-symlink.conf /etc/systemd/system/flanneld.service.d/40-ExecStartPre-symlink.conf",
            "sudo mkdir -p /etc/systemd/system/docker.service.d",
            "sudo mv /tmp/40-flannel.conf /etc/systemd/system/docker.service.d/40-flannel.conf",
            "sed -i \"s|<ADVERTISE_DNS>|$ADVERTISE_DNS|g\" /tmp/kubelet.service",
            "sudo mv /tmp/kubelet.service /etc/systemd/system/kubelet.service",
            "sed -i 's|<KUBE_VERSION>|${var.kube_version}|g' /tmp/kube-apiserver.yaml",
            "sed -i \"s|<ETCD_ENDPOINTS>|$ETCD_ENDPOINTS|g\" /tmp/kube-apiserver.yaml",
            "sed -i \"s|<ADVERTISE_IP>|$ADVERTISE_IP|g\" /tmp/kube-apiserver.yaml",
            "sudo mkdir -p /etc/kubernetes/manifests",
            "sudo mv /tmp/kube-apiserver.yaml /etc/kubernetes/manifests/kube-apiserver.yaml",
            "sed -i 's|<KUBE_VERSION>|${var.kube_version}|g' /tmp/kube-proxy.yaml",
            "sudo mv /tmp/kube-proxy.yaml /etc/kubernetes/manifests/kube-proxy.yaml",
            "sed -i \"s|<ETCD_ENDPOINTS>|$ETCD_ENDPOINTS|g\" /tmp/kube-podmaster.yaml",
            "sed -i \"s|<ADVERTISE_IP>|$ADVERTISE_IP|g\" /tmp/kube-podmaster.yaml",
            "sudo mv /tmp/kube-podmaster.yaml /etc/kubernetes/manifests/kube-podmaster.yaml",
            "sudo mkdir -p /srv/kubernetes/manifests",
            "sed -i 's|<KUBE_VERSION>|${var.kube_version}|g' /tmp/kube-controller-manager.yaml",
            "sudo mv /tmp/kube-controller-manager.yaml /srv/kubernetes/manifests/kube-controller-manager.yaml",
            "sed -i 's|<KUBE_VERSION>|${var.kube_version}|g' /tmp/kube-scheduler.yaml",
            "sudo mv /tmp/kube-scheduler.yaml /srv/kubernetes/manifests/kube-scheduler.yaml",
            "sudo systemctl daemon-reload",
            "curl -X PUT -d 'value={\"Network\":\"10.2.0.0/16\",\"Backend\":{\"Type\":\"vxlan\"}}' \"$ETCD_SERVER/v2/keys/coreos.com/network/config\"",
            "sudo systemctl start kubelet",
            "sudo systemctl enable kubelet",
            "until $(curl -o /dev/null -sf http://127.0.0.1:8080/version); do printf 'curl not responding...'; sleep 5; done",
            "curl -X POST -d '{\"apiVersion\":\"v1\",\"kind\":\"Namespace\",\"metadata\":{\"name\":\"kube-system\"}}' \"http://127.0.0.1:8080/api/v1/namespaces\""
        ]
    }
}
