#########################
## Generate certificates
#########################

# Generate Certificates
data "template_file" "certificates" {
    template = "${file("${path.module}/template/kubernetes-csr.json")}"
    depends_on = ["aws_elb.kubernetes_api","aws_instance.controller","aws_instance.worker"]
    vars {
      kubernetes_api_elb_dns_name = "${aws_elb.kubernetes_api.dns_name}"
      kubernetes_cluster_dns = "${var.kubernetes_cluster_dns}"

      # Unfortunately, variables must be primitives, neither lists nor maps
      controller0_ip = "${aws_instance.controller.0.private_ip}"
      worker0_ip = "${aws_instance.worker.0.private_ip}"

      controller0_dns = "${aws_instance.controller.0.private_dns}"
      worker0_dns = "${aws_instance.worker.0.private_dns}"
    }
}
resource "null_resource" "certificates" {
  triggers {
    template_rendered = "${ data.template_file.certificates.rendered }"
  }
  provisioner "local-exec" {
    command = "echo '${ data.template_file.certificates.rendered }' > ../cert/kubernetes-csr.json"
  }
  provisioner "local-exec" {
    command = "cd ../cert; cfssl gencert -initca ca-csr.json | cfssljson -bare ca; cfssl gencert -ca=ca.pem -ca-key=ca-key.pem -config=ca-config.json -profile=kubernetes kubernetes-csr.json | cfssljson -bare kubernetes"
  }
}
