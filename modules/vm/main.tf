locals {
  zone_map = { for z in var.zones : z => z }
}

resource "azurerm_public_ip" "vm_pip" {
  for_each            = local.zone_map
  name                = "${var.prefix}-gameserver-0${each.key}-pip"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
  zones               = [each.value]
}

resource "azurerm_network_interface" "vm_nic" {
  for_each            = local.zone_map
  name                = "${var.prefix}-gameserver-0${each.key}-nic"
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.vm_pip[each.key].id
  }
}

resource "azurerm_linux_virtual_machine" "gameserver" {
  for_each                        = local.zone_map
  name                            = "${var.prefix}-gameserver-0${each.key}"
  resource_group_name             = var.resource_group_name
  location                        = var.location
  size                            = "Standard_DS1_v2"
  admin_username                  = "deploy"
  disable_password_authentication = true
  zone                            = each.value

  network_interface_ids = [
    azurerm_network_interface.vm_nic[each.key].id
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

  custom_data = base64encode(templatefile("${path.root}/cloud-init.yaml", {
    ssh_public_key = file(var.ssh_public_key_path)
  }))
}

resource "azurerm_managed_disk" "gameserver_data" {
  for_each             = local.zone_map
  name                 = "${var.prefix}-gameserver-0${each.key}-datadisk"
  location             = var.location
  resource_group_name  = var.resource_group_name
  storage_account_type = "Standard_LRS"
  create_option        = "Empty"
  disk_size_gb         = 32
  zone                 = each.value
}

resource "azurerm_virtual_machine_data_disk_attachment" "gameserver_data_attach" {
  for_each           = local.zone_map
  managed_disk_id    = azurerm_managed_disk.gameserver_data[each.key].id
  virtual_machine_id = azurerm_linux_virtual_machine.gameserver[each.key].id
  lun                = 10
  caching            = "ReadWrite"
}

resource "local_file" "ansible_inventory" {
  content = join("\n", concat(
    ["[gameservers]"],
    [for zone, ip in azurerm_public_ip.vm_pip :
      "gameserver-${zone} ansible_host=${ip.ip_address} ansible_user=deploy ansible_ssh_private_key_file=~/.ssh/id_azure"
    ],
    [""],
    ["[gameservers:vars]"],
    ["ansible_python_interpreter=/usr/bin/python3"],
    ["ansible_ssh_common_args='-o StrictHostKeyChecking=no'"]
  ))
  filename = "${path.root}/ansible/inventory-gameservers.ini"
}