########################
# Security groups
########################
resource "aws_security_group" "k8s-master" {
    vpc_id = "${aws_vpc.kubernetes.id}"
    name = "k8s-master"

    # Allow inbound traffic to the port used by Kubernetes API HTTPS
    ingress {
        from_port = "${var.k8s_api_port}"
        to_port = "${var.k8s_api_port}"
        protocol = "TCP"
        cidr_blocks = ["0.0.0.0/0"]
    }
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
    vpc_id = "${aws_vpc.kubernetes.id}"
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
    ingress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        security_groups = ["${aws_security_group.k8s-master.id}"]
    }

    # Allow all traffic from control host IP
    ingress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["${var.control_cidr}"]
    }

    # Allow ICMP from control host IP
    # ingress {
    #     from_port = 8
    #     to_port = 0
    #     protocol = "icmp"
    #     cidr_blocks = ["${var.control_cidr}"]
    # }

}
