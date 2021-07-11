variable "pair_main" {
  default = ""
}

variable "region_main" {
  description = "region for main vpc"
  default     = "eu-central-1"
}

variable "region_sec" {
  description = "region for secondary vpc"
  default     = "eu-west-2"
}

variable "instance_type" {
  default = "t2.micro"
}

variable "ports" {
  description = "List of open ports"
  default     = ["80", "443", "22"]
  type        = list(any)
}
