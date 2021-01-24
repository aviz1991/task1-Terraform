output "FGT_primary_FW_IP" {
  value = aws_eip.ClusterPublicIP.public_ip
}

output "FGT_secondary_FW_IP" {
  value = aws_eip.PassivePublicIP.public_ip
}
