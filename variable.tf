variable "access_key"  {
    default = ""
}

variable "secret_key"  {
    default = ""
}

variable "region" {
    default = "cn-north-1"
}

# This ami is a ecs optimized machine
variable "ami-code" {
    default = "ami-0de63760"
}
