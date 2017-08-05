# Infrastructure

The infrastructure control repository for our AWS

Uses Terraform mainly to control.

---

## Set up your credentials
Put `access_key` and `secret_key` in `~/.aws/credentials`

Or you can put your credentials in `terraform.tfvars`.

## Prerequisite

Download [Terraform](https://www.terraform.io/)

> **Warning:** Terraform version (0.9.6 below) without [provider/aws: Revoke default ipv6 egress rule for aws_security_group](https://github.com/hashicorp/terraform/pull/15075) patch is required.

## Deploy
```
make
```

## Roadmap

- **TODO** Using AWS EC2 Container Registry
- **TODO** Ingress Controller for ALB
- **TODO** Security Group with minimal policies
- ✅ Essential addons
- **TODO** Monitoring with Prometheus
- **TODO** Logging with Fluentd and cloudwatch
- **TODO** Kubernetes upgrade mechanism
- **TODO** rkt as container runtime
