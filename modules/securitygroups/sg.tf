########################
# Security groups
########################

resource "aws_security_group" "k8s-etcd" {
  vpc_id = "${var.vpc_id}"
  name = "k8s-etcd"

  # TODO: actually make this accept only ssh
  ingress {
    from_port = 0
    to_port = 0
    protocol = -1
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow all outbound traffic
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "k8s-master" {
  vpc_id = "${var.vpc_id}"
  name = "k8s-master"

  # TODO: actually make this accept only ssh
  ingress {
    from_port = 0
    to_port = 0
    protocol = -1
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow all outbound traffic
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "k8s-worker" {
  vpc_id = "${var.vpc_id}"
  name = "k8s-worker"

  # Allow all outbound
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow all internal
  ingress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["${var.vpc_cidr}"]
  }

  # Allow all traffic from the API ELB
  # ingress {
  #   from_port = 0
  #   to_port = 0
  #   protocol = "-1"
  #   security_groups = ["${aws_security_group.k8s-master.id}"]
  # }

  # Allow all traffic from control host IP
  ingress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["${var.control_cidr}"]
  }

}
