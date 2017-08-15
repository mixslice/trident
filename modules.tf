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
  # master_id : aws_security_group.k8s-master.id
  # worker_id : aws_security_group.k8s-worker.id
}

module "iam" {
  source = "./modules/iam"
  # Input

  # Output
  # wroker_profile_id : aws_iam_role.worker_role.id
  # worker_profile_name : aws_iam_instance_profile.worker_profile.name
  # master_profile_id : aws_iam_role.master_role.id
  # master_profile_name : aws_iam_instance_profile.master_profile.name
}

module "eip" {
  source = "./modules/eip"
  # Input
  allocation_id = "${var.eip_allocation_id}"
  instance_id = "${module.edge.instance_ids[0]}"
}

module "master" {
  source = "./modules/master"
  type = "master"
  count = "${var.master_count}"
  ami = "${lookup(var.amis, var.region)}"
  instance_type = "${var.master_instance_type}"
  volume_size = "${var.master_volume_size}"

  sg_id = "${module.sg.master_id}"
  subnet_id = "${module.vpc.subnet_id}"
  iam_profile_name = "${module.iam.master_profile_name}"

  ssh_key_name = "${var.ssh_key_name}"
  ssh_user_name = "${var.ssh_user_name}"
  ssh_private_key_path= "${var.ssh_private_key_path}"

  cluster_domain = "${var.cluster_domain}"
  dns_service_ip = "${var.dns_service_ip}"
  ecr_location = "${var.ecr_location}"
  etcd_private_ip = "127.0.0.1"
  flannel_version = "${var.flannel_version}"
  kube_image = "${var.kube_image}"
  kube_version = "${var.kube_version}"
  node_labels = "${var.master_node_labels}"
  pod_infra_container_image = "${var.pod_infra_container_image}"
  pod_network = "${var.pod_network}"
  s3_location = "${var.s3_location}"
  service_ip = "${var.k8s_service_ip}"
  service_ip_range = "${var.service_ip_range}"

  ansibleFilter = "${var.ansibleFilter}"
  ansibleNodeType = "${var.master_ansibleNodeType}"
}

module "worker" {
  source = "./modules/worker"
  type = "worker"
  count = "${var.worker_count}"
  ami = "${lookup(var.amis, var.region)}"
  instance_type = "${var.worker_instance_type}"
  volume_size = "${var.worker_volume_size}"

  sg_id = "${module.sg.worker_id}"
  subnet_id = "${module.vpc.subnet_id}"
  iam_profile_name = "${module.iam.worker_profile_name}"

  ssh_key_name = "${var.ssh_key_name}"
  ssh_user_name = "${var.ssh_user_name}"
  ssh_private_key_path= "${var.ssh_private_key_path}"

  cluster_domain = "${var.cluster_domain}"
  dns_service_ip = "${var.dns_service_ip}"
  ecr_location = "${var.ecr_location}"
  etcd_private_ip = "${module.master.private_ips[0]}"
  flannel_version = "${var.flannel_version}"
  kube_image = "${var.kube_image}"
  kube_version = "${var.kube_version}"
  master_private_ip = "${module.master.private_ips[0]}"
  node_labels = "${var.worker_node_labels}"
  pod_infra_container_image = "${var.pod_infra_container_image}"
  pod_network = "${var.pod_network}"
  s3_location = "${var.s3_location}"
  service_ip_range = "${var.service_ip_range}"

  ansibleFilter = "${var.ansibleFilter}"
  ansibleNodeType = "${var.worker_ansibleNodeType}"
}

module "edge"{
  source = "./modules/worker"
  type = "edge"
  count = "${var.edge_count}"
  ami = "${lookup(var.amis, var.region)}"
  instance_type = "${var.worker_instance_type}"
  volume_size = "${var.worker_volume_size}"

  sg_id = "${module.sg.edge_node_id}"
  subnet_id = "${module.vpc.subnet_id}"
  iam_profile_name = "${module.iam.worker_profile_name}"

  ssh_key_name = "${var.ssh_key_name}"
  ssh_user_name = "${var.ssh_user_name}"
  ssh_private_key_path= "${var.ssh_private_key_path}"

  cluster_domain = "${var.cluster_domain}"
  dns_service_ip = "${var.dns_service_ip}"
  ecr_location = "${var.ecr_location}"
  etcd_private_ip = "${module.master.private_ips[0]}"
  flannel_version = "${var.flannel_version}"
  kube_image = "${var.kube_image}"
  kube_version = "${var.kube_version}"
  master_private_ip = "${module.master.private_ips[0]}"
  node_labels = "${var.edge_node_labels}"
  pod_infra_container_image = "${var.pod_infra_container_image}"
  pod_network = "${var.pod_network}"
  s3_location = "${var.s3_location}"
  service_ip_range = "${var.service_ip_range}"

  ansibleFilter = "${var.ansibleFilter}"
  ansibleNodeType = "${var.edge_ansibleNodeType}"
}
