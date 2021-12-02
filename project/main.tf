provider "aws" {
}

terraform {
  backend "s3" {
    encrypt = true
    bucket = "moodle-tf-state-stage-v2"
    dynamodb_table = "moodle-tfstatelock-stage-v2"
    key = "moodle/terraform.tfstate"
  }
}

module "key-pair" {
  source = "../modules/keys"
  key_name        = var.key_name
# create_key_pair = false
}

module "vpc" {
  source   = "../modules/networks"
  env      = var.env
  vpc_cidr = var.vpc_cidr
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
}

module "redis" {
  source                  = "../modules/redis"
  env                     = var.env
  node_type               = var.redis_node_type
  subnet_ids              = [module.vpc.db_subnet_ids[0], module.vpc.db_subnet_ids[1]]
  redis_security_group_id = module.vpc.redis_security_group_id
}

module "database" {
  source                    = "../modules/database"
  env                       = var.env
  instance_class            = var.db_instance_class
  subnet_ids                = [module.vpc.db_subnet_ids[0], module.vpc.db_subnet_ids[1]]
  mariadb_security_group_id = module.vpc.mariadb_security_group_id
  availability_zone         = module.vpc.aws_availability_zones
}

module "glusterfs" {
  source                    = "../modules/glusterfs"
  instance_type             = var.gluster_instance_type
  key_name                  = var.key_name
  ebs_volume_size           = 1
  gluster_security_group_id = module.vpc.gluster_security_group_id
  private_subnet_ids        = module.vpc.private_subnet_ids[*]
  availability_zones        = module.vpc.aws_availability_zones
}

module "bastion" {
  source                    = "../modules/bastion"
  key_name                  = var.key_name
  tls_private_key           = module.key-pair.tls_private_key
  bastion_security_group_id = module.vpc.bastion_security_group_id
  public_subnet_id          = module.vpc.public_subnet_ids[0]
  db_password               = module.database.db_password
  db_host                   = module.database.db_dns_name
  ip_node01                 = module.glusterfs.ip_node01
  ip_node02                 = module.glusterfs.ip_node02
  depends_on                = [module.database, module.glusterfs]

}

module "alb_vpl" {
  source = "../modules/lb/alb_vpl"
  env                       = var.env
  key_name                  = var.key_name
  instance_type             = var.vpl_instance_type
  ami_name                  = var.vpl_ami_name
  public_subnet_ids         = [module.vpc.public_subnet_ids[0], module.vpc.public_subnet_ids[1]]
  private_subnet_ids        = [module.vpc.private_subnet_ids[0], module.vpc.private_subnet_ids[1]]
  vpc_id                    = module.vpc.vpc_id
  alb_vpl_security_group_id = module.vpc.alb_vpl_security_group_id

}

module "alb_ext" {
  source                    = "../modules/lb/alb_ext"
  env                       = var.env
  key_name                  = var.key_name
  instance_type             = var.instance_type
  ami_name                  = var.moodle_ami_name
  public_subnet_ids         = [module.vpc.public_subnet_ids[0], module.vpc.public_subnet_ids[1]]
  private_subnet_ids        = [module.vpc.private_subnet_ids[0], module.vpc.private_subnet_ids[1]]
  vpc_id                    = module.vpc.vpc_id
  bastion_security_group_id = module.vpc.bastion_security_group_id
  alb_security_group_id     = module.vpc.alb_security_group_id
  ip_node01                 = module.glusterfs.ip_node01
  ip_node02                 = module.glusterfs.ip_node02
  db_host                   = module.database.db_dns_name
  db_password               = module.database.db_password
  redis                     = module.redis.elasticache_host
  depends_on                = [module.database, module.glusterfs]
}
