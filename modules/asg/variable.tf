variable "PROJECT_NAME"{}
variable "AMI" {
    default = "ami-06b09bfacae1453cb"
}
variable "CPU" {
    default = "t2.micro"
}
variable "KEY_NAME" {
    default = "tomcat"
}
variable "WEB_SG_ID" {}
variable "MAX_SIZE" {
    default = 6
}
variable "MIN_SIZE" {
    default = 2
}
variable "DESIRED_CAP" {
    default = 3
}
variable "asg_health_check_type" {
    default = "ELB"
}
variable "PRI_SUB_ID_1" {}
variable "PRI_SUB_ID_2" {}
variable "TG_ARN" {}