variable "ubuntu_ami" {
  description = "Ubuntu AMI ID"
  type        = string
}

variable "ec2" {
  description = "The attribute of EC2 information"
  type = object({
    name              = string
    os_type           = string
    instance_type     = string
    availability_zone = string
  })
}

variable "region" {
  description = "AWS region"
  type        = string
}