resource "azurerm_public_ip" "vpn_pip" {
  name                = "${var.prefix}-vpn-pip"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_network_interface" "vpn_nic" {
  name                  = "${var.prefix}-vpn-nic"
  location              = var.location
  resource_group_name   = var.resource_group_name
  ip_forwarding_enabled = true

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Static"
    private_ip_address            = "10.1.5.4"
    public_ip_address_id          = azurerm_public_ip.vpn_pip.id
  }
}

resource "azurerm_linux_virtual_machine" "vpn_router" {
  name                            = "${var.prefix}-vpn-router"
  location                        = var.location
  resource_group_name             = var.resource_group_name
  size                            = "Standard_DS1_v2"
  admin_username                  = "deploy"
  disable_password_authentication = true

  network_interface_ids = [
    azurerm_network_interface.vpn_nic.id
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "ubuntu-24_04-lts"
    sku       = "server"
    version   = "latest"
  }

  admin_ssh_key {
    username   = "deploy"
    public_key = file(var.ssh_public_key_path)
  }

  custom_data = base64encode(templatefile("${path.module}/cloud-init-vpn.yaml", {
    skylab_public_ip = var.skylab_public_ip
    azure_tunnel_ip  = "192.168.100.1"
    skylab_tunnel_ip = "192.168.100.2"
    vnet_cidr        = "10.1.0.0/16"
    azure_bgp_as     = "65002"
    skylab_bgp_as    = "65001"
    ipsec_psk        = var.ipsec_psk
  }))
}

resource "local_file" "vpn_inventory" {
  content  = <<-EOT
    [vpn]
    vpn-router ansible_host=${azurerm_public_ip.vpn_pip.ip_address} ansible_user=deploy ansible_ssh_private_key_file=~/.ssh/id_azure

    [vpn:vars]
    ansible_ssh_common_args='-o StrictHostKeyChecking=no'
  EOT
  filename = "${path.root}/ansible/inventory-vpn.ini"
}

resource "null_resource" "ssh_keyscan_vpn" {
  depends_on = [azurerm_linux_virtual_machine.vpn_router]

  triggers = {
    vm_id = azurerm_linux_virtual_machine.vpn_router.id
  }

  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    command     = "sleep 30 && ssh-keyscan -H ${azurerm_public_ip.vpn_pip.ip_address} >> ~/.ssh/known_hosts"
  }
}