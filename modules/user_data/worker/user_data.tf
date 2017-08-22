data "template_file" "worker_yml" {
  template = "${file("${path.module}/worker.yml")}"
  vars {
      ETCD_IP = "${var.etcd_ip}"
      POD_NETWORK = "${var.pod_network}"
  }
}
