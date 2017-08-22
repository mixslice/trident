data "template_file" "master_yml" {
  template = "${file("${path.module}/master.yml")}"

  vars {
      POD_NETWORK = "${var.pod_network}"
  }
}
