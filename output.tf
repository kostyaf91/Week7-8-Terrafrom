output "vm_pass" {
  value     = module.vmss.password
  sensitive = true
}
output "postgres_pass" {
  value     = module.managed_postgres.postgres_password
  sensitive = true
}
output "ansible_pass" {
  value     = module.ansible_master_vm.password
  sensitive = true
}
output "lb_ip" {
  value = module.load_balancer.lb_ip
}
output "ansible_master_ip" {
  value = module.ansible_master_vm.ansible_ip
}
