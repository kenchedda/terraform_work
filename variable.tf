variable "REGION" {
  default = "us-east-1"
}
variable "PROJECT_NAME" {
  default = "practice_project"
}

variable "DB_USERNAME" {
    sensitive = true
}
variable "DB_PASSWORD" {
   sensitive = true
}
variable "DB_NAME" {
    default = "databaseken"
}
