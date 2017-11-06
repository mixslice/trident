[![Kubernetes version](https://img.shields.io/badge/kubernetes-1.7.3-brightgreen.svg)](https://github.com/mixslice/trident)
[![Terraform version](https://img.shields.io/badge/terraform-0.10.5-brightgreen.svg)](https://github.com/mixslice/trident)
[![Ansible version](https://img.shields.io/badge/ansible-2.3.2.0-brightgreen.svg)](https://github.com/mixslice/trident)

# Trident 🔱

Trident is a project for bootstrapping a kubernetes cluster in China.

Currently we only support setup on AWS, but that's only the terraform part. Ansible part can boostrap any type of machine.

---

# Asciinema recording of the whole build
Link: https://asciinema.org/a/146104

## Setting up credentials
Put your `access_key` and `secret_key` in local directory `~/.aws/credentials`

Alternatively you can put your credentials in `terraform.tfvars`.

## Prerequisite

Download [Terraform](https://www.terraform.io/)

> **Warning:** Terraform version (0.9.6 below) without [provider/aws: Revoke default ipv6 egress rule for aws_security_group](https://github.com/hashicorp/terraform/pull/15075) patch is required.

## Deploy
```
make build
```
## Remote kubectl setup
(You probably want to look into MAKEFILE to see how this works)
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
- [x] Ansible or kubespray

# CI/CD
This is a work in progress. We are still deciding whether to deploy jenkins as an addon of kubernetes or as coreOS service.

# <span style="color:#b60205"> Other requirements </span>
If you are on a new machine and want to use this code to bootstrap your AWS + Kubernetes cluster, here are some other prerequisites that may present a challenge.

#### 1. GFW
Obviously the greatest challenge of bootstrapping a kubernetes cluster in China is the GFW, which blocks almost a lot of the image sources. Our solution contains a public and private part. We have a public bucker in amazon S3: https://s3.cn-north-1.amazonaws.com.cn/kubernetes-bin which you can use to pull rkt images. In the bucket there are:
- flannel_v0.7.1.aci
- hyperkube_v1.7.3_coreos.0.aci

However for the private part, the docker images are store in ECR (also an amazon service.) Some required images are:
- hyperkube_v1.7.3_coreos.0

and then there are some images for addons.(Not required, but without them your build with create_all_addons will fail.)

#### 2. Docker token refresh
There are 2 docker token generates.
One is used to pull hyperkube from ecr, which is at the container level. We provide a public image awscli at daocloud.io/mixslice/awscli that we use in the ansible part.

Another is used to allow kubernetes to pull all other addons images from ecr. We also provide a public image ecr-dockercfg-refresh at daocloud.io/mixslice/ecr-dockercfg-refresh which is applied as an addon.

#### 3. Others
We do not support linking to existing machines at the terraform part. But if you are confident in your physical machine set up you can skip the terraform part and use the ansible part with
```
ansible-playbook site.yml
```
**Warning**
Put your hosts in hosts, put your ssh credentials in ansible.cfg.
