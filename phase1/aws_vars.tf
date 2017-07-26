variable "access_key" {}
variable "secret_key" {}

variable "ssh_public_key" {}
variable "ssh_private_key_path" {}

variable "vpc_cidr" {}
variable "control_cidr" {}

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

variable "master_instance_type" {
    default = "t2.micro"
}

variable "worker_instance_type" {
    default = "t2.small"
}

variable "master_volume_size" {
    default = 25
}

variable "worker_volume_size" {
    default = 50
}
