module "network" {
  source             = "./modules/network"
  vpc_cidr           = var.vpc_cidr
  public_subnet_cidr = var.public_subnet_cidr
}

module "security" {
  source = "./modules/security"
  vpc_id = module.network.vpc_id
}

module "jenkins" {
  source            = "./modules/compute-jenkins"
  ami               = data.aws_ami.ubuntu.id
  instance_type     = "m7i-flex.large"
  subnet_id         = module.network.subnet_id
  security_group_id = module.security.jenkins_sg
  key_name          = var.key_name
  name              = "jenkins"
}

module "sonarqube" {
  source            = "./modules/compute-sonarqube"
  ami               = data.aws_ami.ubuntu.id
  instance_type     = "m7i-flex.large"
  subnet_id         = module.network.subnet_id
  security_group_id = module.security.sonarqube_sg
  key_name          = var.key_name
  name              = "sonarqube"
}

module "nexus" {
  source            = "./modules/compute-nexus"
  ami               = data.aws_ami.ubuntu.id
  instance_type     = "m7i-flex.large"
  subnet_id         = module.network.subnet_id
  security_group_id = module.security.nexus_sg
  key_name          = var.key_name
  name              = "nexus"
}

module "docker" {
  source            = "./modules/compute-docker"
  ami               = data.aws_ami.ubuntu.id
  instance_type     = "m7i-flex.large"
  subnet_id         = module.network.subnet_id
  security_group_id = module.security.docker_sg
  key_name          = var.key_name
  name              = "docker-host"
}
module "ansible" {
  source            = "./modules/compute-ansible"
  ami               = data.aws_ami.ubuntu.id
  instance_type     = "t3.micro"
  subnet_id         = module.network.subnet_id
  security_group_id = module.security.ansible_sg
  key_name          = var.key_name
  name              = "ansible-control"
}
