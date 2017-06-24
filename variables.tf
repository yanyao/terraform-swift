variable "image" {
  default = "Ubuntu 16.04"
}

variable "flavor" {
  default = "m1.medium"
}

variable "ssh_key_file" {
  default = "~/.ssh/id_rsa.terraform"
}

variable "ssh_user_name" {
  default = "ubuntu"
}

variable "external_gateway" {
  default = "27d3f2ea-b6a4-48b5-9299-9e42e8aa2da3"
}

variable "pool" {
  default = "Public"
}
