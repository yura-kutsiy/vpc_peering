output "VPC_main_region" {
  value = data.aws_region.vpc_region_main.description
}

output "public_server_ip" {
  description = "List of public IP addresses assigned to the instances, if applicable"
  value       = aws_instance.server_main.public_ip
}

output "VPC_secondary_region" {
  value = data.aws_region.vpc_region_secondary.description
}

output "private_server_ip" {
  description = "List of private IP addresses assigned to the instances"
  value       = aws_instance.server_sec.private_ip
}
