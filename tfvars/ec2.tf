resource "aws_instance" "expense" {
  for_each = var.instances
  ami                    = "ami-0220d79f3f480ecf5"
  instance_type          = each.value
  vpc_security_group_ids = [aws_security_group.allow_ssh_terraform.id]

  connection {
    type     = "ssh"
    user     = "ec2-user"
    password = "DevOps321"
    host     = self.public_ip
  }

  # Frontend setup
  provisioner "remote-exec" {
    when   = create
    inline = each.key == "frontend-prod" ? [
      "sudo dnf install -y ansible",
      "sudo dnf install -y nginx",
      "sudo systemctl enable nginx",
      "sudo systemctl start nginx"
    ] : []
    on_failure = continue
  }
  provisioner "remote-exec" {
    when   = destroy
    inline = each.key == "frontend-prod" ? [
      "sudo systemctl stop nginx || true"
    ] : []
    on_failure = continue
  }

  # Backend setup with Tomcat 9.0.100
provisioner "remote-exec" {
  when   = create
  inline = each.key == "backend-prod" ? [
    "sudo dnf install -y java-17-openjdk",
    "wget https://archive.apache.org/dist/tomcat/tomcat-9/v9.0.100/bin/apache-tomcat-9.0.100.tar.gz",
    "sudo mkdir -p /opt/tomcat",
    "sudo tar xvf apache-tomcat-9.0.100.tar.gz -C /opt/tomcat --strip-components=1",
    "sudo /opt/tomcat/bin/startup.sh"
  ] : []
  on_failure = continue
}


  provisioner "remote-exec" {
    when   = destroy
    inline = each.key == "backend-prod" ? [
      "sudo systemctl stop tomcat || true"
    ] : []
    on_failure = continue
  }

  # MySQL setup
  provisioner "remote-exec" {
    when   = create
    inline = each.key == "mysql-prod" ? [
      "sudo dnf install -y mariadb-server",
      "sudo systemctl enable mariadb",
      "sudo systemctl start mariadb",
      "sudo mysql -e \"CREATE DATABASE IF NOT EXISTS expense;\" || true"
    ] : []
    on_failure = continue
  }
  provisioner "remote-exec" {
    when   = destroy
    inline = each.key == "mysql-prod" ? [
      "sudo systemctl stop mariadb || true"
    ] : []
    on_failure = continue
  }

  tags = merge(
    var.common_tags,
    var.tags,
    {
      Name = each.key
    }
  )
}

resource "aws_security_group" "allow_ssh_terraform" {
  name        = "allow_ssh-${var.environment}"
  description = "Allow port number 22 ,80, 8080, 3306 for access"

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    
  }

  ingress {
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    
  }

  ingress {
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    
  }

  ingress {
    from_port        = 8080
    to_port          = 8080
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  
  }

  ingress {
    from_port        = 3306
    to_port          = 3306
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    
  }

  tags = merge(
    var.common_tags,
    var.tags,
    {
      Name = "allow_ssh_sg_${var.environment}"
    }
  )
}



# resource "aws_instance" "expense" {
#   for_each = var.instances
#   ami                    = "ami-0220d79f3f480ecf5"
#   instance_type          = each.value
#   vpc_security_group_ids = [aws_security_group.allow_ssh_terraform.id]

#   connection {
#     type     = "ssh"
#     user     = "ec2-user"
#     password = "DevOps321"
#     host     = self.public_ip
#   }

#   # Frontend setup
#   provisioner "remote-exec" {
#     when   = create
#     inline = [
#       "sudo dnf install -y ansible",
#       "sudo dnf install -y nginx",
#       "sudo systemctl enable nginx",
#       "sudo systemctl start nginx"
#     ]
#     # Only run if this is frontend
#     on_failure = continue
#   }
#   provisioner "remote-exec" {
#     when   = destroy
#     inline = [
#       "sudo systemctl stop nginx"
#     ]
#     on_failure = continue
#   }

#   # Backend setup
#   # Backend setup with Tomcat 9.0.100
# provisioner "remote-exec" {
#   when   = create
#   inline = [
#     # Install Java
#     "sudo dnf install -y java-17-openjdk",

#     # Download Tomcat 9.0.100
#     "wget https://downloads.apache.org/tomcat/tomcat-9/v9.0.100/bin/apache-tomcat-9.0.100.tar.gz",

#     # Extract into /opt/tomcat
#     "sudo mkdir -p /opt/tomcat",
#     "sudo tar xvf apache-tomcat-9.0.100.tar.gz -C /opt/tomcat --strip-components=1",

#     # Create a systemd unit file for Tomcat
#     "sudo bash -c 'cat > /etc/systemd/system/tomcat.service <<EOF\n[Unit]\nDescription=Apache Tomcat Web Application Container\nAfter=network.target\n\n[Service]\nType=forking\nExecStart=/opt/tomcat/bin/startup.sh\nExecStop=/opt/tomcat/bin/shutdown.sh\nUser=ec2-user\nGroup=ec2-user\nRestart=always\n\n[Install]\nWantedBy=multi-user.target\nEOF'",

#     # Reload systemd and enable/start Tomcat
#     "sudo systemctl daemon-reload",
#     "sudo systemctl enable tomcat || true",
#     "sudo systemctl start tomcat || true"
#   ]
#   on_failure = continue
# }

# # Graceful shutdown on destroy
# provisioner "remote-exec" {
#   when   = destroy
#   inline = [
#     "sudo systemctl stop tomcat || true"
#   ]
#   on_failure = continue
# }


#   # MySQL setup
#   provisioner "remote-exec" {
#   when   = create
#   inline = [
#     # Install and start MariaDB
#     "sudo dnf install -y mariadb-server",
#     "sudo systemctl enable mariadb",
#     "sudo systemctl start mariadb",

#     # Create database as root via sudo
#     "sudo mysql -e \"CREATE DATABASE IF NOT EXISTS expense;\" || true"
#   ]
#   on_failure = continue
# }

# provisioner "remote-exec" {
#   when   = destroy
#   inline = [
#     "sudo systemctl stop mariadb || true"
#   ]
#   on_failure = continue
# }

#   tags = merge(
#     var.common_tags,
#     var.tags,
#     {
#       Name = each.key
#     }
#   )
# }

# resource "aws_security_group" "allow_ssh_terraform" {
#   name        = "allow_ssh-${var.environment}"
#   description = "Allow port number 22 for SSH access"

#   egress {
#     from_port        = 0
#     to_port          = 0
#     protocol         = "-1"
#     cidr_blocks      = ["0.0.0.0/0"]
#     ipv6_cidr_blocks = ["::/0"]
#   }

#   ingress {
#     from_port        = 22
#     to_port          = 22
#     protocol         = "tcp"
#     cidr_blocks      = ["0.0.0.0/0"]
#     ipv6_cidr_blocks = ["::/0"]
#   }

#   ingress {
#     from_port        = 80
#     to_port          = 80
#     protocol         = "tcp"
#     cidr_blocks      = ["0.0.0.0/0"]
#     ipv6_cidr_blocks = ["::/0"]
#   }

#   ingress {
#     from_port        = 8080
#     to_port          = 8080
#     protocol         = "tcp"
#     cidr_blocks      = ["0.0.0.0/0"]
#     ipv6_cidr_blocks = ["::/0"]
#   }

#   ingress {
#     from_port        = 3306
#     to_port          = 3306
#     protocol         = "tcp"
#     cidr_blocks      = ["0.0.0.0/0"]
#     ipv6_cidr_blocks = ["::/0"]
#   }

#   tags = merge(
#     var.common_tags,
#     var.tags,
#     {
#       Name = "allow_ssh_sg_${var.environment}"
#     }
#   )
# }

