# Infrastructure

The infrastructure control repository for our AWS

Currently we uses Terraform to bootstrap everything.

We are switching to Terraform + Ansible! For a rather stable version go to release v0.1

---

## Set up your credentials
Put `access_key` and `secret_key` in `~/.aws/credentials`

Or you can put your credentials in `terraform.tfvars`.

## Prerequisite

Download [Terraform](https://www.terraform.io/)

> **Warning:** Terraform version (0.9.6 below) without [provider/aws: Revoke default ipv6 egress rule for aws_security_group](https://github.com/hashicorp/terraform/pull/15075) patch is required.

## Deploy
```
make build
```
## Remote setup
```
make remote_kubecfg
```

## Roadmap
- [x] VPC and internet gateway
- [x] IAM role
- [x] Security groups (master, worker and etc)
- [x] kubernetes machines setup (with coreOS_v1407) (master, worker, and etcd)
- [x] certificates generate (With CFSSL)
- [x] kubernetes setup: remote (hyperkube and etc)
- [x] kubernetes setup: local (kubectl)
- [x] Essential addons:
  - [x] dashboard : using cluster role as clusterAdmin
  - [x] DNS + DNS Autoscale
  - [x] heapster (Metrics)
- [x] Using AWS EC2 Container Registry
  - [x] token auto refresh
- [x] Traefik Ingress Controller
  - [x] EIP association for edge-router
  - [ ] Let's Encrypt Support
- [x] Security Group with minimal policies
- [ ] Monitoring with Prometheus
- [ ] Logging with Fluentd and cloudwatch
- [ ] Kubernetes upgrade mechanism
- [ ] Ansible or kubespray

# Some other requirements
If you are on a brand new machine and want to use this code to bootstrap your AWS + Kubernetes cluster, here are some other Prerequisites that may present a challenge.

1.
