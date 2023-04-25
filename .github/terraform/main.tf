terraform {
    required_providers {
        aws = {
            source = "hashicorp/aws"
            version = ">4.0.0"
        }
    }
    backend "s3" {
        key = "aws/ec2-deploy/terraform.tfstate"
    }
      
}

provider "aws" {
    region = var.region
}

resource "aws_instance" "server" {
    ami                 = "ami-007855ac798b5175e"
    instance_type       = "t2.micro"
    iam_instance_profile = aws_iam_instance_profile.ec2-profile.name
    key_name            = aws_key_pair.deployer.key_name
    vpc_security_group_ids = [aws_security_group.maingroup.id]
    connection {
        type            = "ssh"
        host            = "self.public_ip"
        user            = "ubuntu"
        private_key     = "var.private_key"
        timeout         = "4m"
      
    }
    tags = ({
        Name = "terraform-example"
    })
}

resource "aws_key_pair" "deployer" {
    key_name        = var.key_name
    public_key      = var.public_key
}

resource "aws_iam_instance_profile" "ec2-profile" {
    name = "ec2-profile"
    role = "Ec2-EcR-Role"
  
}

resource "aws_security_group" "maingroup" {
    egress = [
        {
           cidr_blocks                  = ["0.0.0.0/0"]
           description                  = "Allow all outbound traffic by default"
              from_port                 = 0
              ipv6_cidr_blocks          = []
                prefix_list_ids         = []
                protocol                = "-1"
                security_groups         = []
                self                    = false
                to_port                 = 0
                }
    ]
    ingress = [
        {
            cidr_blocks                 = ["0.0.0.0/0"]
            description                 = "Allow SSH inbound traffic"
            from_port                   = 22
            ipv6_cidr_blocks            = []
            prefix_list_ids             = []
            protocol                    = "tcp"
            security_groups             = []
            self                        = false
            to_port                     = 22
        },

        {
            cidr_blocks                 = ["0.0.0.0/0"]
            description                 = "Allow HTTP inbound traffic"
            from_port                   = 80
            ipv6_cidr_blocks            = []
            prefix_list_ids             = []
            protocol                    = "tcp"
            security_groups             = []
            self                        = false
            to_port                     = 80
        },
    ]
}

output "instance_public_ip" {
    value = aws_instance.server.public_ip
    sensitive = true
}
  
