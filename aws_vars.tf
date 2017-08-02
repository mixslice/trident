variable "access_key" {}
variable "secret_key" {}

variable "ssh_key_name" {}
variable "ssh_public_key" {}
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
  default = "t2.micro"
}

variable "master_instance_type" {
  default = "m3.medium"
}

variable "worker_instance_type" {
  default = "m3.medium"
}

variable "etcd_volumn_size" {
  default = 25
}

variable "master_volume_size" {
  default = 25
}

variable "worker_volume_size" {
  default = 50
}
