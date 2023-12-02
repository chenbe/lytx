output "public_ip_instance1" {
  value = aws_instance.instance1.public_ip
  description = "The public IP address of the EC2 instance1"
}

output "instance1_private_ip" {
  value = aws_instance.instance1.private_ip
  description = "The private IP address of the EC2 instance1"
}

output "public_ip_instance2" {
  value = aws_instance.instance2.public_ip
  description = "The public IP address of the EC2 instance2"
}

output "instance2_private_ip" {
  value = aws_instance.instance2.private_ip
  description = "The private IP address of the EC2 instance2"
}