# #####################
# All modules ( main terraform entry point )
# #####################
module "vpc" {
  source = "./modules/vpc"
  # Input
  vpc_cidr = "${var.vpc_cidr}"
  # Outpu
  # vpc_id : aws_vpc.kubernetes.id
  # subnet_id : aws_subnet.kubernetes.id
}

module "sg" {
  source = "./modules/securitygroups"
  # Input
  vpc_id = "${module.vpc.vpc_id}"
  vpc_cidr = "${var.vpc_cidr}"
  control_cidr = "${var.control_cidr}"
  # Output
  # etcd_id   : aws_security_group.k8s-etcd.id
  # master_id : aws_security_group.k8s-master.id
  # worker_id : aws_security_group.k8s-worker.id
}

module "iam" {
  source = "./modules/iam"
  # Input

  # Output
  # etcd_profile_id : aws_iam_role.etcd_role.id
  # etcd_profile_name : aws_iam_instance_profile.etcd_profile.name
  # wroker_profile_id : aws_iam_role.worker_role.id
  # worker_profile_name : aws_iam_instance_profile.worker_profile.name
  # master_profile_id : aws_iam_role.master_role.id
  # master_profile_name : aws_iam_instance_profile.master_profile.name
}

# module "elb" {
#   source = "./modules/elb"
# }

# module "alb" {
#   source = "./modules/alb"
#
#   subnet_ids = "1"
#   security_group_ids = "2"
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
  ssh_user_name = "${var.ssh_user_name}"
  ssh_private_key_path= "${var.ssh_private_key_path}"
}

module "master" {
  source = "./modules/master"

  master_count = "${var.master_count}"
  master_ami = "${lookup(var.amis, var.region)}"
  master_instance_type = "${var.master_instance_type}"
  master_volume_size = "${var.master_volume_size}"

  k8s_master_sg_id = "${module.sg.master_id}"
  k8s_subnet_id = "${module.vpc.subnet_id}"
  k8s_iam_profile_name = "${module.iam.master_profile_name}"

  ssh_key_name = "${var.ssh_key_name}"
  ssh_user_name = "${var.ssh_user_name}"
  ssh_private_key_path= "${var.ssh_private_key_path}"

  cluster_domain = "${var.cluster_domain}"
  k8s_service_ip = "${var.k8s_service_ip}"
  dns_service_ip = "${var.dns_service_ip}"
  etcd_private_ip = "${module.etcd.private_ips[0]}"
  pod_network = "${var.pod_network}"
  service_ip_range = "${var.service_ip_range}"
  s3_location = "${var.s3_location}"
  ecr_location = "${var.ecr_location}"
  flannel_version = "${var.flannel_version}"
  pod_infra_container_image = "${var.pod_infra_container_image}"
  kube_image = "${var.kube_image}"
  kube_version = "${var.kube_version}"
}

module "worker" {
  source = "./modules/worker"

  worker_count = "${var.worker_count}"
  worker_ami = "${lookup(var.amis, var.region)}"
  worker_instance_type = "${var.worker_instance_type}"
  worker_volume_size = "${var.worker_volume_size}"

  k8s_worker_sg_id = "${module.sg.worker_id}"
  k8s_subnet_id = "${module.vpc.subnet_id}"
  k8s_iam_profile_name = "${module.iam.worker_profile_name}"

  ssh_key_name = "${var.ssh_key_name}"
  ssh_user_name = "${var.ssh_user_name}"
  ssh_private_key_path= "${var.ssh_private_key_path}"

  cluster_domain = "${var.cluster_domain}"
  dns_service_ip = "${var.dns_service_ip}"
  etcd_private_ip = "${module.etcd.private_ips[0]}"
  master_private_ip = "${module.master.private_ips[0]}"
  pod_network = "${var.pod_network}"
  service_ip_range = "${var.service_ip_range}"
  s3_location = "${var.s3_location}"
  ecr_location = "${var.ecr_location}"
  flannel_version = "${var.flannel_version}"
  pod_infra_container_image = "${var.pod_infra_container_image}"
  kube_image = "${var.kube_image}"
  kube_version = "${var.kube_version}"
}

# module "kubectl_setup" {
#   source = "./modules/kubectl"

#   master_public_ip = "${module.master.public_ips[0]}"
# }
