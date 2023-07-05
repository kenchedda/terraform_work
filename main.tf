
# creating VPC
module "VPC" {
  source        = "./modules/vpc"
  REGION        = var.REGION
  PROJECT_NAME  = var.PROJECT_NAME
  vpc_cidr      = "10.0.0.0/16"
  pub_sub_count = 2
  pri_sub_count = 2
  nat_gtw_count = 2
  db_sub_count  = 2

}


# launching JUMP server or Bastion host 
module "SERVER" {
  source         = "./modules/bastion_host"
  JUMP_SG_ID     = module.vpc.JUMP_SG_ID
  PUB_SUB_ID_1 = module.vpc.PUB_SUB_ID_1
  KEY_NAME       = "tomcat"
  CPU            = "t2.micro"

}

module "ALB" {
  source       = "./modules/alb"
  PROJECT_NAME = var.PROJECT_NAME
  ALB_SG_ID    = module.vpc.ALB_SG_ID
  PUB_SUB_ID_1  = module.vpc.PUB_SUB_ID_1
  PUB_SUB_ID_2  = module.vpc.PUB_SUB_ID_2
  VPC_ID       = module.vpc.VPC_ID
 
}

# Crating Auto Scaling group
module "ASG" {
  source         = "./modules/asg"
  PROJECT_NAME   = var.PROJECT_NAME
  WEB_SG_ID    = module.vpc.WEB_SG_ID
  PRI_SUB_ID_1 = module.vpc.PRI_SUB_ID_1
  PRI_SUB_ID_2 = module.vpc.PRI_SUB_ID_2
  TG_ARN         = module.alb.TG_ARN

}


module "RDS" {
  source         = "./modules/rds"
  
  DB_SG_ID       = module.vpc.DB_SG_ID
  DB_SUB_ID_1 = module.vpc.DB_SUB_ID_1
  DB_SUB_ID_2 = module.vpc.DB_SUB_ID_2
  DB_USERNAME    = var.DB_USERNAME
  DB_PASSWORD    = var.DB_PASSWORD
  DB_NAME        = var.DB_NAME
  
}


# create cloudfront distribution 
module "CLOUDFRONT" {
  source = "./modules/cloudfront_route53"
  
  alb_dns_name = module.alb.alb_dns_name
  PROJECT_NAME =var.PROJECT_NAME

  
}