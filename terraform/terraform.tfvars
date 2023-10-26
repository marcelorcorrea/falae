ubuntu_ami = "ami-0fc5d935ebf8bc3bc"

ec2 = {
  name              = "falae"
  os_type           = "ubuntu"
  instance_type     = "t2.micro"
  availability_zone = "us-east-1a"
}

region = "us-east-1"

env_source = "./scripts/.env"

env_destination = "/tmp/.env"

ubuntu_source = "./scripts/ubuntu.sh"

ubuntu_destination = "/tmp/ubuntu.sh"