module "vpc" {
  source          = "../../modules/vpc"
  name            = "dev"
  vpc_cidr        = "10.0.0.0/16"
  public_subnets  = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnets = ["10.0.11.0/24", "10.0.12.0/24"]
  azs             = ["us-east-1a", "us-east-1b"]
}

module "alb" {
  source         = "../../modules/alb"
  name           = "dev"
  vpc_id         = module.vpc.vpc_id
  public_subnets = module.vpc.public_subnets
}

module "ec2" {
  source           = "../../modules/ec2"
  name             = "dev"
  ami_id           = "ami-0abcdef1234567890"
  instance_type    = "t3.micro"
  vpc_id           = module.vpc.vpc_id
  public_subnets   = module.vpc.public_subnets
  target_group_arn = module.alb.target_group_arn
  alb_sg_id        = module.alb.alb_sg_id
  ssh_cidr_blocks  = ["0.0.0.0/0"]
}

# module "rds" {
#   source          = "../../modules/rds"
#   name            = "dev"
#   public_subnets  = module.vpc.public_subnets
#   db_user         = "appuser"
#   db_password     = "ChangeMe123!"
# }
