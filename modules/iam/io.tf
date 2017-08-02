# Input

# Output
# ETCD
output "etcd_profile_id"{
  value = "${ aws_iam_role.etcd_role.id }"
}
output "etcd_profile_name"{
  value = "${ aws_iam_instance_profile.etcd_profile.name }"
}

# Master
output "master_profile_id" {
  value = "${ aws_iam_role.master_role.id }"
}
output "master_profile_name"{
  value = "${ aws_iam_instance_profile.master_profile.name }"
}

# Worker
output "worker_profile_id" {
  value = "${ aws_iam_role.worker_role.id }"
}
output "worker_profile_name"{
  value = "${ aws_iam_instance_profile.worker_profile.name }"
}
