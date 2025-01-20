variable "region" {
  default = "us-east-1"
  type    = string
}
variable "ami" {
  default = "ami-080e1f13689e07408"
  type    = string
}
variable "instance_type" {
  default = "t2.micro"
  type    = string
}

variable "app-branch" {
  default = "feat/alerts" //"dev"
  type    = string
}

variable "app-repo" {
  default = "https://github.com/BenjaminS04/epa-project-app.git"
  type    = string
}

variable "environment" {
  description = "Environment to deploy workload"
  default     = "dev"
  type        = string
  nullable    = false
}

variable "vpn_ip" {
  description = "ip to limit access to instances to company ip/vpn"
  default     = " 195.50.119.196"
  type        = string
}


variable "sns_subscriptions" {
  description = "sets the emails that recieve alerts"
  type        = list(string)
  default     = ["benjamin.scanlon@jdplc.com", "benscanloncerts@gmail.com"]
}




