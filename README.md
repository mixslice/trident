# Infrastructure
The infrastructure control repository for our AWS

Uses Terraform mainly to control.

---

### Set up your credentials
> Put access_key and secret_key in ~/.aws/credentials

> Or you can put your credentials in variable.tf but DO NOT push it.

### Prerequisite:
- Download Terraform

### Deploy :
```
terraform plan

terraform apply
```

### Finally:
Upload your **terraform.tfstate** file!!! This is very important! Otherwise Terraform will not run planning correctly.
