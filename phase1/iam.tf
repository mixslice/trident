############################################
# IAM roles creation
############################################
resource "aws_iam_role" "master_role" {
    name = "k8s-master"
    assume_role_policy = "${file("iam/kubernetes-master-role.json")}"
}

resource "aws_iam_role_policy" "master_policy" {
    name = "master_policy"
    role = "${aws_iam_role.master_role.id}"
    policy = "${file("iam/kubernetes-master-policy.json")}"
}

resource "aws_iam_instance_profile" "master_profile" {
    name = "master_profile"
    role = "${aws_iam_role.master_role.name}"
}

resource "aws_iam_role" "worker_role" {
    name = "k8s-worker"
    assume_role_policy = "${file("iam/kubernetes-worker-role.json")}"
}

resource "aws_iam_role_policy" "worker_policy" {
    name = "worker_policy"
    role = "${aws_iam_role.worker_role.id}"
    policy = "${file("iam/kubernetes-worker-policy.json")}"
}

resource "aws_iam_instance_profile" "worker_profile" {
    name = "worker_profile"
    role = "${aws_iam_role.worker_role.name}"
}
