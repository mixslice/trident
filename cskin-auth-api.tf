resource "aws_instance" "cskin-auth-api" {
    ami = "${var.ami-code}"
    instance_type   = "t2.micro"
    
}
