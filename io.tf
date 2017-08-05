# Provider
provider "aws" {
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
  region = "${var.region}"
}

# Output
output "k8s_etcd_ip" {
  value = "${module.etcd.public_ips}"
}
output "k8s_master_ip" {
  value = "${module.master.public_ips}"
}
output "k8s_worker_ip" {
  value = "${module.worker.public_ips}"
}

# Variables
variable "access_key" {}
variable "secret_key" {}

variable "ssh_key_name" {}
variable "ssh_user_name" {
  default = "core"
}
variable "ssh_private_key_path" {}

variable "vpc_cidr" {
  default = "10.0.0.0/16"
}
variable "control_cidr" {
  default = "0.0.0.0/0"
}

variable "k8s_service_ip" {
  default = "10.3.0.1"
}
variable "dns_service_ip" {
  default = "10.3.0.10"
}
variable "pod_network" {
  default = "10.2.0.0/16"
}
variable "service_ip_range" {
  default = "10.3.0.0/24"
}

variable "cluster_domain" {
  default = "cluster.local"
}

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
  default = "v1.7.2_coreos.0"
}

variable "pod_infra_container_image" {
  default = "registry.aliyuncs.com/archon/pause-amd64:3.0"
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
