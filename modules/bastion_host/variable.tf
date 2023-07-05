variable "CPU" {}
variable "ami_name" {
    default = "Amazon Linux 2023 AMI"
}
variable "JUMP_SG_ID" {
    type = string
}
variable "KEY_NAME" {
    default = "tomcat"
}

variable "PUB_SUB_ID_1" {}

