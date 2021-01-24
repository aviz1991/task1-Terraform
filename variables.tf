variable "profile" {
  type    = string
  default = "default"
}


variable "my_region" {
  type    = string
  default = "us-east-1"
}


variable "cidr" {
  type    = string
  default = "192.168.100.0/24"
}


variable "activeport1" {
  type    = string
  default = "192.168.100.10"
}

variable "activeport1float" {
  type    = string
  default = "192.168.100.13"
}

variable "activeport2" {
  type    = string
  default = "192.168.100.74"
}

variable "license_type" {
  type    = string
  default = "payg"
}

variable "ami" {
  type    = string
  default = "ami-07a2b724815412830"
}

variable "keyname" {
  type    = string
  default = "ansible-keypair"
}


variable "passiveport1" {
  type    = string
  default = "192.168.100.11"
}


variable "passiveport2" {
  type    = string
  default = "192.168.100.75"
}
