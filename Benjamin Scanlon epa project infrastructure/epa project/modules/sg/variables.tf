variable "security_group_name" {
  description = "Name for the security group"
}
variable "vpc_id" {
  description = "vpc for the security group"
}

variable "vpn_ip" {
  description = "ip to limit access to instances to company ip/vpn"
}
