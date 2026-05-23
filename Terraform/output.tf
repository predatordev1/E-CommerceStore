output "vpc_id" {
  description = "VPC_ARN of created VPC for E-Commerce App"
  value       = aws_vpc.e-commerce-vpc.arn
}

output "EC2_Public_IP" {
  description = "Public IP of EC2 Server"
  value       = aws_instance.e-commerce-webserver.public_ip
}