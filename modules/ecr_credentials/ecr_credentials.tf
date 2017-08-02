resource "null_resource" "ecr_credentials_gen" {
  provisioner "local-exec" {
    command = <<EOF
rm -rf ${path.module}/../../secrets/docker_login
aws ecr get-login --no-include-email --region cn-north-1 | sed "s/^/\/usr\/bin\//" > ${path.module}/../../secrets/docker_login
EOF
  }
}
