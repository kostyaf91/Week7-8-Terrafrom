# VM scale set creation
resource "azurerm_linux_virtual_machine_scale_set" "vmss" {
  name                = "${var.tag}-vmss"
  admin_username      = "ubuntu"
  admin_password      = var.password
  instances           = var.instance_count
  location            = var.rg.location
  resource_group_name = var.rg.name
  sku                 = "Standard_B2s"
  disable_password_authentication = false
  overprovision = false
  single_placement_group = false

  network_interface {
    name                      = "${var.tag}-vmss-ni"
    primary                   = true

    ip_configuration {
      name                                   = "${var.tag}-vmss-ip-config"
      load_balancer_backend_address_pool_ids = [var.lb_backend_pool.id]
      subnet_id                              = var.subnet.id
      primary                                = true
      #public_ip_address {
      #  name = "${var.tag}-vmss-ip"
      #}
    }
  }
  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "StandardSSD_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts-gen2"
    version   = "latest"
  }
}

resource "azurerm_monitor_autoscale_setting" "vm-autoscale" {
  location            = var.rg.location
  name                = "vm-autoscale"
  resource_group_name = var.rg.name
  target_resource_id  = azurerm_linux_virtual_machine_scale_set.vmss.id

  profile {
    name = "AutoScale"
    capacity {
      default = var.instance_count
      maximum = 10
      minimum = var.instance_count
    }

    rule {
      metric_trigger {
        metric_name        = "Percentage CPU"
        metric_resource_id = azurerm_linux_virtual_machine_scale_set.vmss.id
        operator           = "GreaterThan"
        statistic          = "Average"
        threshold          = 75
        time_aggregation   = "Average"
        time_grain         = "PT1M"
        time_window        = "PT5M"
        metric_namespace   = "microsoft.compute/virtualmachinescalesets"

        /*
        dimensions {
          name     = "AppName"
          operator = "Equals"
          values   = ["App1"]
        }
        */
      }
      scale_action {
        cooldown  = "PT1M"
        direction = "Increase"
        type      = "ChangeCount"
        value     = 1
      }
    }
    rule {
      metric_trigger {
        metric_name        = "Percentage CPU"
        metric_resource_id = azurerm_linux_virtual_machine_scale_set.vmss.id
        time_grain         = "PT1M"
        statistic          = "Average"
        time_window        = "PT5M"
        time_aggregation   = "Average"
        operator           = "LessThan"
        threshold          = 25
        metric_namespace   = "microsoft.compute/virtualmachinescalesets"
      }

      scale_action {
        direction = "Decrease"
        type      = "ChangeCount"
        value     = "1"
        cooldown  = "PT1M"
      }
    }
  }
}