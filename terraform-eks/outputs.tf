output "cluster_name" {
  value = module.eks.cluster_name
}

output "cluster_endpoint" {
  value = module.eks.cluster_endpoint
}
output "bastion_public_ip" {
  value = aws_instance.bastion.public_ip
}
