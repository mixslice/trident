# Output
output "k8s_etcd_ip" {
  value = "${module.etcd.public_ips}"
}
# output "k8s_master_ip" {
#   value = "${module.master.public_ips}"
# }
# output "k8s_worker_ip" {
#   value = "${module.worker.public_ips}"
# }

variable "access_key" {}
variable "secret_key" {}

variable "ssh_key_name" {}
variable "ssh_private_key_path" {}

variable "vpc_cidr" {}
variable "control_cidr" {}

variable "s3_location" {}
variable "ecr_location" {}

variable "region" {
  description = "The region to which you want to deploy"
  default = "cn-north-1"
}

variable "amis" {
  type = "map"
  default = {
    # coreOS
    cn-north-1 = "ami-ca5c8da7"
  }
}

variable "etcd_instance_type" {
  default = "m3.medium"
}

variable "master_instance_type" {
  default = "m3.medium"
}

variable "worker_instance_type" {
  default = "m3.medium"
}

variable "etcd_volume_size" {
  default = 25
}

variable "master_volume_size" {
  default = 25
}

variable "worker_volume_size" {
  default = 50
}

variable "kube_image" {
  default = "quay.io/coreos/hyperkube"
}

variable "kube_version" {
  default = "v1.7.1_coreos.0"
}

variable "pause_version" {
  default = "3.0"
}

variable "flannel_version" {
  default = "v0.7.1"
}

variable "etcd_count" {
  default = 1
}

variable "master_count" {
  default = 1
}

variable "worker_count" {
  default = 1
}
