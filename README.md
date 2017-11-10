[![Kubernetes version](https://img.shields.io/badge/kubernetes-1.7.3-brightgreen.svg)](https://github.com/mixslice/trident)
[![Terraform version](https://img.shields.io/badge/terraform-0.9.6-brightgreen.svg)](https://github.com/mixslice/trident)
[![Ansible version](https://img.shields.io/badge/ansible-2.3.2.0-brightgreen.svg)](https://github.com/mixslice/trident)

# Trident 🔱

Trident is an open source project for bootstrapping a production ready [Kubernetes] cluster on China AWS.

We use [Terraform] to bring up raw machines and related network configurations. Then we use [Ansible] to deploy the kubernetes cluster onto those machines.

# Asciinema recording of the whole build
[![demo](https://asciinema.org/a/r15Q5nbKunvhZ3BkUhNfWtBYP.png)](https://asciinema.org/a/r15Q5nbKunvhZ3BkUhNfWtBYP?autoplay=1)

## Main Features
Terraform
- [x] VPC and internet gateway
- [x] IAM role
- [x] Security Group with minimal policies (master, worker and etc)
- [x] certificates generate (With CFSSL)
- [x] Elastic IP bind to Edge worker
- [x] Raw machine setup (with CoreOS_v1407)

Ansible
- [x] kubernetes setup: machines (hyperkube)
- [ ] Scalability
  - [ ] multiple master
  - [x] multiple worker
- [x] Essential addons:
  - [x] dashboard : using cluster role as clusterAdmin
  - [x] DNS + DNS Autoscale
- [x] Using AWS EC2 Container Registry
  - [x] token auto refresh
- [x] Traefik Ingress Controller
  - [x] EIP association for edge-router
- [ ] Kubernetes upgrade mechanism

Others
- [x] kubernetes setup: local/remote (kubectl)

---

# Asciinema recording of the whole build
Link: https://asciinema.org/a/146104

## Setting up credentials
Put your `access_key` and `secret_key` in local directory `~/.aws/credentials`

Alternatively you can put your credentials in `terraform.tfvars`.

## Prerequisite

Download
[Terraform] v0.9.6 , [Ansible] v2.3.2.0 and [CFSSL]

> **Warning:** Terraform version (0.9.6 below) without [provider/aws: Revoke default ipv6 egress rule for aws_security_group](https://github.com/hashicorp/terraform/pull/15075) patch is required.
---

# Set up guide

## Deploy
```
$ make build
```
## Remote kubectl setup
```
$ make remote_kubecfg
```

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

[Ansible]:(https://www.ansible.com/)
[CFSSL]:(https://cfssl.org/)
[Kubernetes]:(http://kubernetes.io/)
[Terraform]:(https://www.terraform.io/)
