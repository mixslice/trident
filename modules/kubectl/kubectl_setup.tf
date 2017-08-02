resource "null_resource" "make_admin_key" {
  # TODO: should depends on master
  provisioner "local-exec" {
    command = <<EOF
${path.root}/cfssl/generate_admin.sh
EOF
  }
}

resource "null_resource" "setup_kubectl" {
  depends_on = ["null_resource.make_admin_key"]
  provisioner "local-exec" {
    command = <<EOF
      echo export MASTER_HOST=${var.master_public_ip} > ${path.root}/secrets/setup_kubectl.sh
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

# resource "null_resource" "deploy_dns_addon" {
#   depends_on = ["null_resource.setup_kubectl"]
#   provisioner "local-exec" {
#     command = <<EOF
#       until kubectl get pods 2>/dev/null; do printf '.'; sleep 5; done
#       kubectl create -f ${path.root}/k8s/dns-addon.yaml
# EOF
#   }
# }
