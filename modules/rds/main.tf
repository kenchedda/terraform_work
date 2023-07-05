resource "aws_db_subnet_group" "db_sub_group" {
  name       = "db_sub_group"
  subnet_ids = [var.DB_SUB_ID_1, var.DB_SUB_ID_2]
  
}





resource "aws_db_instance" "book-db" {
  identifier              = "book-db"
  engine                  = "mysql"
  engine_version          = "5.7"
  instance_class          = "db.t2.micro"
  allocated_storage       = 20
  username                = var.DB_USERNAME
  password                = var.DB_PASSWORD
  db_name                 = var.DB_NAME
  multi_az                = true
  storage_type            = "gp2"
  storage_encrypted       = false
  publicly_accessible     = false
  skip_final_snapshot     = true
  backup_retention_period = 0

  vpc_security_group_ids = [var.DB_SG_ID] # Replace with your desired security group ID

  db_subnet_group_name = aws_db_subnet_group.db_sub_group.name

  tags = {
    Name = "db_sub_group"
  }
}