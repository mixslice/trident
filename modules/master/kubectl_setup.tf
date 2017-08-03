resource "null_resource" "setup_kubectl" {
  depends_on = ["aws_instance.master"]
  provisioner "local-exec" {
    command = <<EOF
      ${path.root}/cfssl/generate_admin.sh
      echo export MASTER_HOST=${aws_instance.master.0.public_ip} > ${path.root}/secrets/setup_kubectl.sh
      echo export CA_CERT=${path.root}/secrets/ca.pem >> ${path.root}/secrets/setup_kubectl.sh
      echo export ADMIN_KEY=${path.root}/secrets/admin-key.pem >> ${path.root}/secrets/setup_kubectl.sh
      echo export ADMIN_CERT=${path.root}/secrets/admin.pem >> ${path.root}/secrets/setup_kubectl.sh
      . ${path.root}/secrets/setup_kubectl.sh
      kubectl config set-cluster default-cluster \
        --server=https://$MASTER_HOST --certificate-authority=$CA_CERT
      kubectl config set-credentials default-admin \
         --certificate-authority=$CA_CERT --client-key=$ADMIN_KEY --client-certificate=$ADMIN_CERT
      kubectl config set-context default-system --cluster=default-cluster --user=default-admin
      kubectl config use-context default-system
EOF
  }
}
