
# launch the ec2 instance in pub-sub-1-a
resource "aws_instance" "jump_server" {
  ami                    = data.aws_ami.ami.id
  instance_type          = var.CPU
  subnet_id              = var.PUB_SUB_ID_1
  vpc_security_group_ids = [var.JUMP_SG_ID]
  key_name               = var.KEY_NAME

  tags = {
    Name = "jump_server"
  }
}

data "aws_ami" "ami" {
  most_recent = true
  owners      = ["self"]

  filter {
    name   = "Amazon Linux 2023 AMI"
    values = ["ami-06b09bfacae1453cb"]
  }
}

