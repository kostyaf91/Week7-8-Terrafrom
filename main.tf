locals {
  tag = "${terraform.workspace}-${var.tag}"
}

module "network" {
  source              = "./modules/network"
  private_subnet_name = "${local.tag}-private-subnet"
  public_subnet_name  = "${local.tag}-public-subnet"
  rg_name             = "${local.tag}-resource-group"
  nsg_name            = "${local.tag}-network-security-group"
  vnet_name           = "${local.tag}-virtual-network"
  location = var.location
}
module "ansible_master_vm" {
  source         = "./modules/linux_vm"
  rg             = module.network.resource_group
  ni_name        = "${local.tag}-ansible-ni"
  password       = random_password.ansible_password.result
  subnet         = module.network.public_subnet
  linux_vm_name  = "${local.tag}-ansible-master-vm"
  user_data_file = "./DataFile/${terraform.workspace}-ansible.sh"
}
module "load_balancer" {
  source  = "./modules/load_balancer"
  lb_name = "${local.tag}-lb"
  rg      = module.network.resource_group
  vnet    = module.network.vnet
}
module "vmss" {
  source          = "./modules/vmss"
  rg              = module.network.resource_group
  instance_count  = var.instance_count
  lb_backend_pool = module.load_balancer.lb_backend_pool
  password        = random_password.vm_password.result
  subnet          = module.network.public_subnet
  tag             = local.tag
}
module "managed_postgres" {
  source            = "./modules/managed_postgres"
  postgres_password = random_password.postgres_password.result
  private_subnet    = module.network.private_subnet
  rg                = module.network.resource_group
  vnet              = module.network.vnet
  tag               = local.tag
}

resource "local_file" "test" {
  filename = "./ansible/vars/${terraform.workspace}-vars.yaml"
  depends_on = [
  module.vmss,
  module.managed_postgres,
  module.load_balancer,
  module.ansible_master_vm
  ]
  content = <<-EOT
  ${terraform.workspace}_agent_ip=${module.ansible_master_vm.ansible_ip}
  ${terraform.workspace}_postgres_pass=${module.managed_postgres.postgres_password}
  ${terraform.workspace}_vm_pass=${module.vmss.password}
  ${terraform.workspace}_agent_pass=${module.ansible_master_vm.password}
  ${terraform.workspace}_lb_ip=${module.load_balancer.lb_ip}
EOT
}

