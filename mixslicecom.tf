resource "aws_instance" "mixslicecom" {
    ami = "${var.ami-code}"
    instance_type   = "t2.micro"

}
