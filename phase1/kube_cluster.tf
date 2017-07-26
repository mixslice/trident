provider "aws" {
    access_key = "${var.access_key}"
    secret_key = "${var.secret_key}"
    region = "${var.region}"
}

resource "aws_key_pair" "ssh_key" {
    key_name = "ssh_key"
    public_key = "${var.ssh_public_key}"
}

resource "template_file" "cloud_init" {
    template = "${file("coreos/cloud_init.yaml.tpl")}"
    vars {
        discovery_url = "${var.discovery_url}"
    }
}

resource "null_resource" "addons" {
    depends_on = ["null_resource.worker"]

    provisioner "local-exec" {
        command = "until $(kubectl create -f addons/ > /dev/null); do sleep 10; done"
    }
}
