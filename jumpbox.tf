resource "azurerm_public_ip" "jumpbox_public_ip" {
  name                         = "${var.env_name}-jumpbox-public-ip"
  location                     = "${var.location}"
  resource_group_name          = "${azurerm_resource_group.pcf_resource_group.name}"
  public_ip_address_allocation = "static"
}

resource "azurerm_network_interface" "jumpbox_nic" {
  name                      = "${var.env_name}-jumpbox-nic"
  depends_on                = ["azurerm_public_ip.jumpbox_public_ip"]
  location                  = "${var.location}"
  resource_group_name       = "${azurerm_resource_group.pcf_resource_group.name}"
  network_security_group_id = "${azurerm_network_security_group.ops_manager_security_group.id}"

  ip_configuration {
    name                          = "${var.env_name}-jumpbox-ip-config"
    subnet_id                     = "${azurerm_subnet.control_plane_subnet.id}"
    private_ip_address_allocation = "static"
    private_ip_address            = "${var.jumpbox_private_ip}"
    public_ip_address_id          = "${azurerm_public_ip.jumpbox_public_ip.id}"
  }
}

resource "azurerm_virtual_machine" "jumpbox_vm" {
  name                          = "${var.env_name}-jumpbox-vm"
  depends_on                    = ["azurerm_network_interface.jumpbox_nic"]
  location                      = "${var.location}"
  resource_group_name           = "${azurerm_resource_group.pcf_resource_group.name}"
  network_interface_ids         = ["${azurerm_network_interface.jumpbox_nic.id}"]
  vm_size                       = "${var.jumpbox_vm_size}"
  delete_os_disk_on_termination = "true"

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }

  storage_os_disk {
    name              = "myosdisk1"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name  = "${var.env_name}-jumpbox"
    admin_username = "ubuntu"
    admin_password = "Ubuntu123"
  }

  os_profile_linux_config {
    disable_password_authentication = false

    ssh_keys {
      path     = "/home/ubuntu/.ssh/authorized_keys"
      key_data = "${tls_private_key.jumpbox.public_key_openssh}"
    }
  }
}


resource "tls_private_key" "jumpbox" {
  algorithm = "RSA"
  rsa_bits  = "4096"
}
