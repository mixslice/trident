# aws credentials
access_key = ""
secret_key = ""
# This is ummm... manually created ssh-rsa
ssh_public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDe6dybFdihbTfJBYVINuYOeXKdvF7cuLuFkBFO4O56bgUIA+xA56Ipq2UjtOLbzClNRmAUoTPLmQoJCv6LZxLHtczbj2Fn9ckbY9hCjFCBDEQt4B0pzYVphgeMvMgCcn5dYzQJT/4yX9ib98TYxILjWt7wfuGmRXXxpx3rAq1C1puKIPSQ1U9UgSU0rfRX9Lbv4Cj+apmBXyvzYRdylR+QZLhD+VGRURK59WvlbErp3Vu2MYItwZRPHhccxqf0pFu3BFift0p82ZkadoMWMJrLvVB0jyS2t9cS7FQPDciZDaLud4jelE8JSPmzuaeaq29qoUwhySLl+/A20UhqKESX"

# Login
ssh_private_key_path = "~/.ssh/bensonz.pem"

# generate new discovery url: https://discovery.etcd.io/new?size=<master_count>
discovery_url = "https://discovery.etcd.io/78f373dd76f0bb756ccfb08bfe4e93ec"

# cidr
vpc_cidr = "10.0.0.0/16"
# This should be the address of your control machine
control_cidr = "0.0.0.0/0"
