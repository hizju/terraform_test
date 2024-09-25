

module "network" {
  source = "./network"
}

module "app" {
  source                = "./app"
  vpc_id                = module.network.vpc_id
  public_subnet         = [module.network.public_subnet_a, module.network.public_subnet_b]  # 두 개의 서브넷 지정
  web_security_group_id = module.network.web_security_group_id
  alb_security_group_id = module.network.alb_security_group_id
  private_subnet_a      = module.network.private_subnet_a
}

module "database" {
  source         = "./database"
  private_subnet = [module.network.private_subnet_a, module.network.private_subnet_b]
}

