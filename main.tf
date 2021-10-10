resource "aws_security_group" "jenkins-SG" { 
  name = "jenkins-SG" 

  ingress { 

    from_port   = 8080 
    to_port     = 8080 
    protocol    = "tcp" 
    cidr_blocks = ["0.0.0.0/0"] 

  } 


  ingress { 

    from_port   = 22 
    to_port     = 22 
    protocol    = "tcp" 
    cidr_blocks = ["0.0.0.0/0"] 

  } 


  egress { 

    from_port   = 0 
    to_port     = 0 
    protocol    = "-1" 
    cidr_blocks = ["0.0.0.0/0"] 

  } 

} 

resource "aws_instance" "JenkinsEC2" { 

  instance_type          = "t2.micro" 

  ami                    = "ami-00e87074e52e6c9f9" 

  vpc_security_group_ids = [aws_security_group.jenkins-SG.id] 

  key_name               = "rj-key" 

  tags = { 

    Name = "Jenkins-Master" 

  } 
 
provisioner "file" {
    source      = "/home/project/script.sh"
    destination = "/tmp/script.sh"
  }
  # Change permissions on bash script and execute from ec2-user.
  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/script.sh",
      "sh /tmp/script.sh",
    ]
  }
  
  # Login to the ec2-user with the aws key.
  connection {
    type        = "ssh"
    user        = "centos"
    password    = ""
    private_key = file("/home/project/rj-key.pem")
    host        = self.public_ip
  }

}

output "jenkins_endpoint" { 

  value = "${formatlist("http://%s:%s/", aws_instance.JenkinsEC2.*.public_ip, "8080")}" 

  }
