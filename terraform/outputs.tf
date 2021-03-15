output "server_private_ip" {
  value = aws_instance.test_instance.private_ip
}

output "server_id" {
  value = aws_instance.test_instance.id
}

output "vpc_id" {
  description = "ID of project VPC"
  value       = aws_vpc.test_vpc.id
}



