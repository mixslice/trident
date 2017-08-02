module "ecr_credentials" {
  source = "./modules/ecr_credentials"
}

module "vpc" {
  source = "./modules/vpc"

  vpc_cidr = "${var.vpc_cidr}"
}

module "sg" {
  source = "./modules/securitygroups"

  vpc_id = "${module.vpc.vpc_id}"
  vpc_cidr = "${var.vpc_cidr}"
  control_cidr = "${var.control_cidr}"
}

module "iam" {
  source = "./modules/iam"
}

# module "elb" {
#   source = "./modules/elb"
# }

module "etcd" {
  source = "./modules/etcd"

  etcd_count = "${var.etcd_count}"
  etcd_ami = "${lookup(var.amis, var.region)}"
  etcd_instance_type = "${var.etcd_instance_type}"
  etcd_volume_size = "${var.etcd_volume_size}"

  k8s_etcd_sg_id = "${module.sg.etcd_id}"
  k8s_subnet_id = "${module.vpc.subnet_id}"
  k8s_iam_profile_name = "${module.iam.etcd_profile_name}"

  ssh_key_name = "${var.ssh_key_name}"
  ssh_user_name = "core"
  ssh_private_key_path= "${var.ssh_private_key_path}"
}
#
# module "master" {
#   source = "./modules/master"
#
#   master_count = "${var.master_count}"
#   master_ami = "${lookup(var.amis, var.region)}"
#   master_instance_type = "${var.master_instance_type}"
#   master_volume_size = "${var.master_volume_size}"
#
#   k8s_master_sg_id = "${module.sg.master_id}"
#   k8s_subnet_id = "${module.vpc.subnet_id}"
#   k8s_iam_profile_name = "${module.iam.master_profile_name}"
#
#   ssh_key_name = "${var.ssh_key_name}"
#   ssh_user_name = "core"
#   ssh_private_key_path= "${var.ssh_private_key_path}"
#
#   dns_service_ip = "10.3.0.10"
#   etcd_private_ip = "${module.etcd.private_ips[0]}"
#   pod_network = "10.2.0.0/16"
#   service_ip_range = "10.3.0.0/24"
#   s3_location = "${var.s3_location}"
#   ecr_location = "${var.ecr_location}"
#   flannel_version = "${var.flannel_version}"
#   pause_version = "${var.pause_version}"
#   kube_image = "${var.kube_image}"
#   kube_version = "${var.kube_version}"
# }
#
# module "worker" {
#   source = "./modules/worker"
#
#   worker_count = "${var.worker_count}"
#   worker_ami = "${lookup(var.amis, var.region)}"
#   worker_instance_type = "${var.worker_instance_type}"
#   worker_volume_size = "${var.worker_volume_size}"
#
#   k8s_worker_sg_id = "${module.sg.worker_id}"
#   k8s_subnet_id = "${module.vpc.subnet_id}"
#   k8s_iam_profile_name = "${module.iam.worker_profile_name}"
#
#   ssh_key_name = "${var.ssh_key_name}"
#   ssh_user_name = "core"
#   ssh_private_key_path= "${var.ssh_private_key_path}"
#
#   dns_service_ip = "10.3.0.10"
#   etcd_private_ip = "${module.etcd.private_ips[0]}"
#   master_private_ip = "${module.master.private_ips[0]}"
#   pod_network = "10.2.0.0/16"
#   service_ip_range = "10.3.0.0/24"
#   s3_location = "${var.s3_location}"
#   ecr_location = "${var.ecr_location}"
#   flannel_version = "${var.flannel_version}"
#   pause_version = "${var.pause_version}"
#   kube_image = "${var.kube_image}"
#   kube_version = "${var.kube_version}"
# }
#
# module "kubectl_setup" {
#   source = "./modules/kubectl"
#
#   master_public_ip = "${module.master.public_ips[0]}"
# }
