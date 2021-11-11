variable "keyid" {
  type = string
}

variable "seckey" {
  type = string
}

variable "region" {
  type = string
}

variable "clustername" {
  type    = string
  default = "mycluster"
}

variable "public_subnets" {
  type = list(string)
}

variable "private_subnets" {
  type = list(string)
}
