output "pm_security_group_ids" {
  value = [aws_security_group.pm-sg.id]
}

output "public_subnet1_id" {
  value = module.pm-vpc.public_subnets[0]
}

output "public_subnet2_id" {
  value = module.pm-vpc.public_subnets[1]
}

output "merged_public_subnet_ids" {
  value = concat(
    [module.pm-vpc.public_subnets[0]],
    [module.pm-vpc.public_subnets[1]]
  )
}

output "vpc_id" {
  value = module.pm-vpc.vpc_id
}