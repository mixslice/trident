variable "discovery_url" {}

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
