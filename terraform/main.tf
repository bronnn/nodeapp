terraform {
    required_providers {
      aws = {
        source = "hashicorp/aws"
        version = "~>4.0"
      }
    }

    backend "s3" {
        key = "aws/ec2-deploy/terraform.tfstate"
    }
}

provider "aws"{
    region = var.region
}

resource "aws_instance" "name" {
    ami = "ami-0b9932f4918a00c4f"
    instance_type = "t2.micro"
    key_name = aws_key_pair.deployer.key_name
    vpc_security_group_ids = [aws_security_group.main_group.id]
    iam_instance_profile = aws_iam_instance_profile.ec2-profile
    connection {
        type = "ssh"
        host = self.public_ip
        user = "ubuntu"
        private_key = var.private_key
        timeout = "4m"
    }

    tags = {
        "name" = "deploy-vm"
    }

}

resource "aws_iam_instance_profile" "ec2-profile" {
    name = "ec2-profile"
    role = "EC2-ECRR-AUTH"

}

resource "aws_security_group" "main_group" {
    egress = [
        {
            cidr_blocks = ["0.0.0.0/0"]
            description = ""
            from_port = 0
            ipv6_cidr_blocks = []
            prefix_list_iids = []
            protocol = "-1"
            security_groups =[]
            self = false
            to_port = 0
        }
    ]
    ingress = [
        {
            cidr_blocks = ["0.0.0.0/0"]
            description = ""
            from_port = 22
            ipv6_cidr_blocks = []
            prefix_list_iids = []
            protocol = "tcp"
            security_groups =[]
            self = false
            to_port = 22
        },
        {
            cidr_blocks = ["0.0.0.0/0"]
            description = ""
            from_port = 80
            ipv6_cidr_blocks = []
            prefix_list_iids = []
            protocol = "tcp"
            security_groups =[]
            self = false
            to_port = 80
        }
    ]
}

resource "aws_key_pair" "deployer" {
    key_name = var.key_name
    public_key = var.public_key
}