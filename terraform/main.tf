variable "env_source" {}
variable "env_destination" {}
variable "ubuntu_source" {}
variable "ubuntu_destination" {}

module "security_group" {
  source = "./modules/security_group"
}

module "ec2_instance" {
  source = "./modules/instance"

  ubuntu_ami         = var.ubuntu_ami
  ec2                = var.ec2
  availability_zone  = var.ec2.availability_zone
  instance_type      = var.ec2.instance_type
  security_group_id  = module.security_group.sg_id
  env_source         = var.env_source
  env_destination    = var.env_destination
  ubuntu_source      = var.ubuntu_source
  ubuntu_destination = var.ubuntu_destination
}


