############################################
# IAM roles creation
############################################
resource "aws_iam_role" "etcd_role" {
  name = "k8s-etcd"
  assume_role_policy = "${file("${path.module}/k8s-etcd-role.json")}"
}

resource "aws_iam_role_policy" "etcd_policy" {
  name = "etcd_policy"
  role = "${aws_iam_role.etcd_role.id}"
  policy = "${file("${path.module}/k8s-etcd-policy.json")}"
}

resource "aws_iam_instance_profile" "etcd_profile" {
  name = "etcd_profile"
  role = "${aws_iam_role.etcd_role.name}"
}

resource "aws_iam_role" "master_role" {
  name = "k8s-master"
  assume_role_policy = "${file("${path.module}/k8s-master-role.json")}"
}

resource "aws_iam_role_policy" "master_policy" {
  name = "master_policy"
  role = "${aws_iam_role.master_role.id}"
  policy = "${file("${path.module}/k8s-master-policy.json")}"
}

resource "aws_iam_instance_profile" "master_profile" {
  name = "master_profile"
  role = "${aws_iam_role.master_role.name}"
}

resource "aws_iam_role" "worker_role" {
  name = "k8s-worker"
  assume_role_policy = "${file("${path.module}/k8s-worker-role.json")}"
}

resource "aws_iam_role_policy" "worker_policy" {
  name = "worker_policy"
  role = "${aws_iam_role.worker_role.id}"
  policy = "${file("${path.module}/k8s-worker-policy.json")}"
}

resource "aws_iam_instance_profile" "worker_profile" {
  name = "worker_profile"
  role = "${aws_iam_role.worker_role.name}"
}
