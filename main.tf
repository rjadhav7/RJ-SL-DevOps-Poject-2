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
  instance_type = "t2.micro"
  ami = "ami-00e87074e52e6c9f9"
  vpc_security_group_ids = [aws_security_group.jenkins-SG.id]
  key_name = "jenkins-key"
  tags = {
    Name = "Jenkins-Master"
}
##Bootstrap Master and Client for password letss authontications##
  provisioner "file" {
    source      = "/home/rjadhav155gmail/.ssh/id_rsa.pub"
    destination = "/home/centos/.ssh/id_rsa.pub"
  }
  provisioner "remote-exec" {
    inline = ["sudo cat /home/centos/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys"
]
  }

  provisioner "local-exec" {
    command = "echo ${aws_instance.JenkinsEC2.public_dns} > ./inventory.txt"
  }

  #Login to the centos user with the aws key.
  connection {
    type        = "ssh"
    user        = "centos"
    password    = ""
    private_key = "${file(var.ssh_key_private)}"
    host        = self.public_ip
  }
}

output "jenkins_endpoint" {

  value = formatlist("http://%s:%s/", aws_instance.JenkinsEC2.*.public_ip, "8080")
}
