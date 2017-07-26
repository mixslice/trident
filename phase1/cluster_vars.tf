variable "discovery_url" {}

variable "kube_version" {
    default = "v1.7.1"
}

variable "k8s_api_port" {
  default = "6443"
}

variable "master_count" {
    default = 1
}

variable "worker_count" {
    default = 1
}
