output "ec2_vpc1_private_ip" {
  value = aws_instance.ec2_vpc1.private_ip
}

output "ec2_vpc2_private_ip" {
  value = aws_instance.ec2_vpc2.private_ip
}