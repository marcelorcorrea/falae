variable "ubuntu_ami" {
  description = "Ubuntu AMI ID"
  type        = string
}

variable "availability_zone" {
  description = "Availability Zone"
  type        = string
}

variable "instance_type" {
  description = "Instance Type"
  type        = string
}

variable "security_group_id" {
  description = "ID Security Group"
  type        = string
}

variable "env_source" {
  description = "Source path for .env file"
  type        = string
}

variable "env_destination" {
  description = "Destination path for .env file"
  type        = string
}

variable "ubuntu_source" {
  description = "Source path for the ubuntu.sh script"
  type        = string
}

variable "ubuntu_destination" {
  description = "Destination path for the ubuntu.sh script"
  type        = string
}
