# For detailed certificates generation, refer to README.md in /cfssl
resource "null_resource" "certificates_gen" {
    provisioner "local-exec" {
      command = <<EOF
      ${path.root}/cfssl/generate_ca.sh
      ${path.root}/cfssl/generate.sh client-server etcd "${var.master_private_ips},127.0.0.1"
      ${path.root}/cfssl/generate.sh client kube-master
      ${path.root}/cfssl/generate.sh server kube-apiserver "${var.master_public_ips},${var.master_private_ips},${var.service_ip},kubernetes.default,kubernetes"
      ${path.root}/cfssl/generate.sh client kube-worker
      ${path.root}/cfssl/generate.sh client kube-proxy
EOF
    }
}
