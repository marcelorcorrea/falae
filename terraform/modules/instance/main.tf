variable "ec2" {} 


resource "aws_key_pair" "deployer_falae_dev" {
  key_name   = "terraform_falae_dev"
  public_key = file("files/falae.pub")
}

resource "aws_instance" "instance" {

  ami                         = var.ubuntu_ami
  availability_zone           = var.ec2.availability_zone
  instance_type               = var.ec2.instance_type
  vpc_security_group_ids      = [var.security_group_id]
  key_name                    = aws_key_pair.deployer_falae_dev.id
  associate_public_ip_address = true

  root_block_device {
    delete_on_termination = true
    encrypted             = false
  }

  tags = {
    Name        = "FALAE"
    Environment = "DEV"
    OS          = "UBUNTU"
    Managed     = "IAC"
  }

  provisioner "file" {
    source      = var.env_source
    destination = var.env_destination

    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file("files/falae")
      host        = self.public_ip
    }

  }

  provisioner "file" {
    source      = var.ubuntu_source
    destination = var.ubuntu_destination


    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file("files/falae")
      host        = self.public_ip
    }

  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/ubuntu.sh",
      "/tmp/ubuntu.sh",
      "sleep 5"
    ]

    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file("files/falae")
      host        = self.public_ip
    }

  }
}