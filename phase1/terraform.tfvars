/*
   DO NOT EDIT terraform.tfvars.example! Copy it instead to
   terraform.tfvars and edit that file.
*/

/* Required variables */
default_keypair_public_key = "terraform"
/* TODO: In theory this should be your control machine's IP */
control_cidr = "0.0.0.0/0"

/* Optional. Set as desired */
region = "cn-north-1"
zone = "cn-north-1a"

/*
   If your chosen region above doesn't have a corresponding ami
   in the "amis" variable (found in variables.tf), you can
   override the default below.
*/

amis = { cn-north-1 = "ami-0220b23b" }
