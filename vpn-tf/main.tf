provider "aws" {
    region = "${var.region}"
}

resource "aws_key_pair" "deployment_key" {
    key_name = "${var.ssh_key_name}"
    public_key = "${file(var.ssh_public_key_path)}"
}

resource "aws_security_group" "vpn_traffic" {
    name = "vpn_traffic"
    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
        from_port = "${var.port}"
        to_port = "${var.port}"
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    egress {
        from_port       = 0
        to_port         = 0
        protocol        = "-1"
        cidr_blocks     = ["0.0.0.0/0"]
    }
    
}

resource "aws_instance" "openvpn_server" {
    ami = "${lookup(var.images, var.region)}"
    instance_type = "t2.micro"
    key_name = "${var.ssh_key_name}"
    security_groups = ["vpn_traffic"]
    connection {
        user = "ubuntu"
        private_key = "${file(var.ssh_private_key_path)}"
        agent = "false"
    }
    # package the setup script and config files
    provisioner "local-exec" {
        command = "tar -czf setup_openvpn.tar.gz setup.sh make-client-config.sh configs"
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
            "chmod +x /tmp/openvpn/setup.sh",
            "echo 'port ${var.port}' >> /tmp/openvpn/configs/server.conf",
            "echo 'remote ${aws_instance.openvpn_server.public_dns} ${var.port}' >> /tmp/openvpn/configs/base.conf",
            "mkdir -p /tmp/openvpn/client-configs/files",
            "chmod 700 /tmp/openvpn/client-configs/files",
            "mv /tmp/openvpn/configs/base.conf /tmp/openvpn/client-configs/base.conf",
            "/tmp/openvpn/setup.sh",
            "sudo systemctl start openvpn@server"
        ]
    }
    # retrieve the client key
    provisioner "local-exec" {
        command = "scp -o StrictHostKeyChecking=no -i ${var.ssh_private_key_path} ubuntu@${aws_instance.openvpn_server.public_dns}:/tmp/openvpn/client-configs/files/client.ovpn ${var.client_key_output_path}"
    }
}

output "region" {
    value = "${var.region}"
}

output "connect_string" {
    value = "ssh -i ${var.ssh_private_key_path} ubuntu@${aws_instance.openvpn_server.public_dns}"
}
