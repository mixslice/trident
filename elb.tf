############################################
# ELB creation
############################################
# resource "aws_elb" "kube_master" {
#   name = "kube-master"
#
#   instances = ["${aws_instance.master.*.id}"]
#   subnets = ["${aws_instance.master.*.subnet_id}"]
#   security_groups = ["${aws_security_group.k8s-master.id}"]
#   cross_zone_load_balancing = false
#
#   listener {
#     lb_port = "${var.k8s_api_port}"
#     instance_port = "${var.k8s_api_port}"
#     lb_protocol = "TCP"
#     instance_protocol = "TCP"
#   }
#
#   health_check {
#     healthy_threshold = 2
#     unhealthy_threshold = 2
#     timeout = 15
#     target = "HTTP:8000/healthz"
#     interval = 30
#   }
#
#   listener {
#     instance_port = 80
#     instance_protocol = "tcp"
#     lb_port = 80
#     lb_protocol = "tcp"
#   }
#
#   listener {
#     instance_port = 8080
#     instance_protocol = "tcp"
#     lb_port = 8080
#     lb_protocol = "tcp"
#   }
#
# }
