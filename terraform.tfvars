# aws credentials
access_key = ""
secret_key = ""
# This is ummm... manually created ssh-rsa
ssh_public_key = ""

# Login
ssh_key_name = "k8s"
ssh_private_key_path = "~/.ssh/k8s.pem"

# generate new discovery url: https://discovery.etcd.io/new?size=<master_count>
discovery_url = "https://discovery.etcd.io/78f373dd76f0bb756ccfb08bfe4e93ec"

s3_location = "https://s3.cn-north-1.amazonaws.com.cn/kubernetes-bin"
ecr_location = "493490470276.dkr.ecr.cn-north-1.amazonaws.com.cn"

# cidr
vpc_cidr = "10.0.0.0/16"
# This should be the address of your control machine
control_cidr = "0.0.0.0/0"

kube_version = "v1.7.1_coreos.0"

etcd_count = 1
master_count = 1
worker_count = 0
