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
  source = "./modules/ec2"
  type = "master"
  count = "${var.master_count}"
  ami = "${lookup(var.amis, var.region)}"
  instance_type = "${var.master_instance_type}"
  volume_size = "${var.master_volume_size}"

  sg_id = "${module.sg.master_id}"
  subnet_id = "${module.vpc.subnet_id}"
  iam_profile_name = "${module.iam.master_profile_name}"
  user_data = "${module.master_user_data.rendered_data}"
  ssh_key_name = "${var.ssh_key_name}"

  ansibleFilter = "${var.ansibleFilter}"
  ansibleNodeType = "${var.master_ansibleNodeType}"
}

module "worker" {
  source = "./modules/ec2"
  type = "worker"
  count = "${var.worker_count}"
  ami = "${lookup(var.amis, var.region)}"
  instance_type = "${var.worker_instance_type}"
  volume_size = "${var.worker_volume_size}"

  sg_id = "${module.sg.worker_id}"
  subnet_id = "${module.vpc.subnet_id}"
  iam_profile_name = "${module.iam.worker_profile_name}"
  user_data = "${module.worker_user_data.rendered_data}"
  ssh_key_name = "${var.ssh_key_name}"

  ansibleFilter = "${var.ansibleFilter}"
  ansibleNodeType = "${var.worker_ansibleNodeType}"
}

module "edge"{
  source = "./modules/ec2"
  type = "edge"
  count = "${var.edge_count}"
  ami = "${lookup(var.amis, var.region)}"
  instance_type = "${var.worker_instance_type}"
  volume_size = "${var.worker_volume_size}"

  sg_id = "${module.sg.edge_node_id}"
  subnet_id = "${module.vpc.subnet_id}"
  iam_profile_name = "${module.iam.worker_profile_name}"
  user_data = "${module.worker_user_data.rendered_data}"
  ssh_key_name = "${var.ssh_key_name}"

  ansibleFilter = "${var.ansibleFilter}"
  ansibleNodeType = "${var.edge_ansibleNodeType}"
}

module "cert" {
  source = "./modules/cert"

  master_public_ips = "${join(",", module.master.public_ips)}"
  master_private_ips = "${join(",", module.master.private_ips)}"
  service_ip = "${var.k8s_service_ip}"
}

module "master_user_data"{
  source = "./modules/user_data/master"

  pod_network = "${var.pod_network}"
}

module "worker_user_data"{
  source = "./modules/user_data/worker"

  pod_network = "${var.pod_network}"
  etcd_ip = "${join(",", module.master.private_ips)}"
}
