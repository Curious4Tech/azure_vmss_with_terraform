# Configure the Azure provider
provider "azurerm" {
  features {}
  subscription_id = "740d2757-b717-42c4-be32-2c197135a7bd"
}

variable "admin_username" {
  description = "Username for the VM admin user"
  default     = "adminuser"
}

variable "admin_password" {
  description = "Password for the VM admin user"
  sensitive   = true  # Marks the value as sensitive to hide it in output
}

variable "resource_group_location" {
  description = "Location for all resources"
  default     = "East US"
}

variable "instance_count" {
  description = "Number of VM instances to initially deploy"
  default     = 2
}

# Create a resource group
resource "azurerm_resource_group" "vmss_rg" {
  name     = "vmss-resources"
  location = var.resource_group_location
}

# Create a virtual network
resource "azurerm_virtual_network" "vmss_vnet" {
  name                = "vmss-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.vmss_rg.location
  resource_group_name = azurerm_resource_group.vmss_rg.name
}

# Create a subnet
resource "azurerm_subnet" "vmss_subnet" {
  name                 = "vmss-subnet"
  resource_group_name  = azurerm_resource_group.vmss_rg.name
  virtual_network_name = azurerm_virtual_network.vmss_vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

# Create a public IP address
resource "azurerm_public_ip" "vmss_public_ip" {
  name                = "vmss-public-ip"
  location            = azurerm_resource_group.vmss_rg.location
  resource_group_name = azurerm_resource_group.vmss_rg.name
  allocation_method   = "Static"
  domain_name_label   = "vmss-dns-label"
}

# Create a load balancer
resource "azurerm_lb" "vmss_lb" {
  name                = "vmss-lb"
  location            = azurerm_resource_group.vmss_rg.location
  resource_group_name = azurerm_resource_group.vmss_rg.name

  frontend_ip_configuration {
    name                 = "PublicIPAddress"
    public_ip_address_id = azurerm_public_ip.vmss_public_ip.id
  }
}

# Create a backend address pool
resource "azurerm_lb_backend_address_pool" "vmss_backend_pool" {
  loadbalancer_id = azurerm_lb.vmss_lb.id
  name            = "BackEndAddressPool"
}

# Create a load balancer probe
resource "azurerm_lb_probe" "vmss_lb_probe" {
  loadbalancer_id = azurerm_lb.vmss_lb.id
  name            = "http-probe"
  port            = 80
}

# Create a load balancer rule
resource "azurerm_lb_rule" "vmss_lb_rule" {
  loadbalancer_id                = azurerm_lb.vmss_lb.id
  name                           = "http"
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 80
  frontend_ip_configuration_name = "PublicIPAddress"
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.vmss_backend_pool.id]
  probe_id                       = azurerm_lb_probe.vmss_lb_probe.id
}

# Create a virtual machine scale set with password authentication
resource "azurerm_linux_virtual_machine_scale_set" "vmss" {
  name                = "vmss"
  resource_group_name = azurerm_resource_group.vmss_rg.name
  location            = azurerm_resource_group.vmss_rg.location
  sku                 = "Standard_DS1_v2"
  instances           = var.instance_count
  admin_username      = var.admin_username
  
  # Password authentication using variable
  admin_password                  = var.admin_password
  disable_password_authentication = false

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  os_disk {
    storage_account_type = "Standard_LRS"
    caching              = "ReadWrite"
  }

  network_interface {
    name    = "vmss-nic"
    primary = true

    ip_configuration {
      name                                   = "internal"
      primary                                = true
      subnet_id                              = azurerm_subnet.vmss_subnet.id
      load_balancer_backend_address_pool_ids = [azurerm_lb_backend_address_pool.vmss_backend_pool.id]
    }
  }
}

# Create an autoscale setting
resource "azurerm_monitor_autoscale_setting" "vmss_autoscale" {
  name                = "autoscale-config"
  resource_group_name = azurerm_resource_group.vmss_rg.name
  location            = azurerm_resource_group.vmss_rg.location
  target_resource_id  = azurerm_linux_virtual_machine_scale_set.vmss.id

  profile {
    name = "defaultProfile"

    capacity {
      default = var.instance_count
      minimum = 1
      maximum = 5
    }

    rule {
      metric_trigger {
        metric_name        = "Percentage CPU"
        metric_resource_id = azurerm_linux_virtual_machine_scale_set.vmss.id
        time_grain         = "PT1M"
        statistic          = "Average"
        time_window        = "PT5M"
        time_aggregation   = "Average"
        operator           = "GreaterThan"
        threshold          = 75
      }

      scale_action {
        direction = "Increase"
        type      = "ChangeCount"
        value     = "1"
        cooldown  = "PT5M"
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
      }

      scale_action {
        direction = "Decrease"
        type      = "ChangeCount"
        value     = "1"
        cooldown  = "PT5M"
      }
    }
  }
}

# Output variables
output "vmss_id" {
  value = azurerm_linux_virtual_machine_scale_set.vmss.id
}

output "lb_public_ip_address" {
  value = azurerm_public_ip.vmss_public_ip.ip_address
}