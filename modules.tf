# #####################
# All modules ( main terraform entry point )
# #####################
module "vpc" {
  source = "./modules/vpc"
  # Input
  vpc_cidr = "${var.vpc_cidr}"
  # Output
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

module "edge_eip" {
  source = "./modules/eip"
  # Input
  allocation_id = "${var.edge_eip_allocation_id}"
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

  ssh_key_name = "${var.ssh_key_name}"
  ssh_user_name = "${var.ssh_user_name}"
  ssh_private_key_path = "${var.ssh_private_key_path}"

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

  ssh_key_name = "${var.ssh_key_name}"
  ssh_user_name = "${var.ssh_user_name}"
  ssh_private_key_path = "${var.ssh_private_key_path}"

}
# Basically an edge node is no different than a worker node,
# except that edge nodes has a wider security rule set and
# different tag.
module "edge"{
  source = "./modules/ec2"
  type = "edge"
  count = "${var.edge_count}"
  ami = "${lookup(var.amis, var.region)}"
  instance_type = "${var.worker_instance_type}"
  volume_size = "${var.worker_volume_size}"
  #Edge node has its own security rules
  sg_id = "${module.sg.edge_node_id}"
  subnet_id = "${module.vpc.subnet_id}"
  iam_profile_name = "${module.iam.worker_profile_name}"

  ssh_key_name = "${var.ssh_key_name}"
  ssh_user_name = "${var.ssh_user_name}"
  ssh_private_key_path = "${var.ssh_private_key_path}"

}

# TODO: Move this out of terraform
module "cert" {
  source = "./modules/cert"

  master_public_ips = "${join(",", module.master.public_ips)}"
  master_private_ips = "${join(",", module.master.private_ips)}"
  service_ip = "${var.k8s_service_ip}"
}
