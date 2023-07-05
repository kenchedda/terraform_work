output "REGION" {
  value = var.REGION
}

output "PROJECT_NAME" {
  value = var.PROJECT_NAME
}

output "VPC_ID" {
  value = aws_vpc.vpc.id
}

output "PUB_SUB_ID_1" {
  value = aws_subnet.pub-sub[0].id
}

output "PUB_SUB_ID_2" {
  value = aws_subnet.pub-sub[1].id
}
output "PRI_SUB_ID_1" {
  value = aws_subnet.pri-sub[0].id
}
output "PRI_SUB_ID_2" {
  value = aws_subnet.pri-sub[1].id
}

output "DB_SUB_ID_1" {
  value = aws_subnet.db-sub[0].id
}
output "DB_SUB_ID_2" {
  value = aws_subnet.db-sub[1].id
}
output "IGW_ID" {
  value = aws_internet_gateway.internet_gateway.id
}

output "ALB_SG_ID" {
  value = aws_security_group.alb_sg.id
}

output "WEB_SG_ID" {
  value = aws_security_group.web_sg.id
}

output "DB_SG_ID" {
  value = aws_security_group.db_sg.id
}
output "JUMP_SG_ID" {
  value = aws_security_group.jump_sg.id
}
