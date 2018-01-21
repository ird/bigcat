provider "aws" {
    region = "eu-west-2"
}

resource "aws_instance" "vpn1" {
    ami = "ami-fcc4db98"
    instance_type = "t2.micro"
    key_name = "london1"
    connection {
        user = "ubuntu"
        private_key = "${file("~/.ssh/london1.pem")}"
        agent = "false"
    }
    # package the setup script and config files
    provisioner "local-exec" {
        command = "tar -czf setup_openvpn.tar.gz setup.sh configs"
    }
    # send the packaged files
    provisioner "file" {
        source = "setup_openvpn.tar.gz"
        destination = "/tmp/setup_openvpn.tar.gz"
    }
    # install dependencies and unpack setup script
    provisioner "remote-exec" {
        inline = [
            "sudo apt-get -q update",
            "sudo apt-get -q -y install openvpn easy-rsa",
            "mkdir /tmp/openvpn",
            "tar -xzf /tmp/setup_openvpn.tar.gz -C /tmp/openvpn",
            "chmod +x /tmp/openvpn/setup.sh"
        ]
    }
}
