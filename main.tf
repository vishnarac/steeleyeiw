provider "aws" {
region = "ap-south-1"
}

resource "aws_security_group" "web" {
  name = "web"
  ingress {
      from_port = 22
      to_port = 22
      protocol = "TCP"
      cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
      from_port = 80
      to_port = 80
      protocol = "TCP"
      cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
      from_port = 0
      to_port = 0
      protocol = "-1"
      cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "app" {
  name = "app"
  depends_on = [aws_security_group.web]
  ingress {
      from_port = 22
      to_port = 22
      protocol = "TCP"
      cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
      from_port = 8484
      to_port = 8484
      protocol = "TCP"
      security_groups = [aws_security_group.web.id]
  }

  egress {
      from_port = 0
      to_port = 0
      protocol = "-1"
      cidr_blocks = ["0.0.0.0/0"]
  }
}


resource "aws_instance" "app1" {
  ami           = "ami-0470e33cd681b2476"
  instance_type = "t2.micro"
  security_groups = [ "app" ]
  key_name = "vishnuc"
  user_data = file("appuserdata.sh")
  depends_on = [aws_security_group.app]
  provisioner "local-exec" {
  command = "cat /dev/null > ./public_dns_list.txt && echo ${aws_instance.app1.public_dns} >> ./public_dns_list.txt"
  }
}

resource "aws_instance" "app2" {
  ami           = "ami-0470e33cd681b2476"
  instance_type = "t2.micro"
  security_groups = [ "app" ]
  key_name = "vishnuc"
  user_data = file("appuserdata.sh")
  depends_on = [aws_instance.app1]
  provisioner "local-exec" {
  command = "echo ${aws_instance.app2.public_dns} >> ./public_dns_list.txt"
  }

}

resource "aws_instance" "web-lb" {
  depends_on = [aws_instance.app2]
  ami           = "ami-0470e33cd681b2476"
  instance_type = "t2.micro"
  security_groups = [ "web" ]
  key_name = "vishnuc"
  connection {
    host     = aws_instance.web-lb.public_dns
    type     = "ssh"
    agent    = false
    user     = "ec2-user"
    password = ""
    private_key = file("~/Downloads/vishnuc.pem")
    }
  provisioner "file" {
  source      = "./public_dns_list.txt"
  destination = "/tmp/public_dns_list.txt"
  }
  user_data = file("webuserdata.sh")
}

