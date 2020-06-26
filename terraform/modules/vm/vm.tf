

resource "azurerm_network_interface" "nic" {
  name                = "${var.application_type}-${var.resource_type}"
  location            = "${var.location}"
  resource_group_name = "${var.resource_group}"

  ip_configuration {
    name                          = "internal"
    subnet_id                     = "${var.subnet_id}"
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = "${var.public_ip_address_id}"
  }
}


#Generate an ID
resource "random_id" "randomId" {
    keepers = {
        # Generate a new ID when a new resource group is defined
        resource_group = "${var.resource_group}"
    }
    
    byte_length = 8
}

#An account to store the system diagnose
resource "azurerm_storage_account" "SA" {
    name                        = "diagnose${random_id.randomId.hex}"
    resource_group_name         = "${var.resource_group}"
    location                    = "${var.location}"
    account_replication_type    = "LRS"
    account_tier                = "Standard"

    tags = {
        environment = "Terraform"
    }
}

#Generating a key
resource "tls_private_key" "pkey" {
  algorithm = "RSA"
  rsa_bits = 4096
}

output "tls_private_key" { value = "tls_private_key.pkey.private_key_pem" }

resource "azurerm_linux_virtual_machine" "lvm" {
  name                = "${var.application_type}-${var.resource_type}-lvm"
  location            = "${var.location}"
  resource_group_name = "${var.resource_group}"
  size                = "Standard_B1s"
  admin_username      = "testuser"
  disable_password_authentication = true
  network_interface_ids = [azurerm_network_interface.nic.id]
  admin_ssh_key {
    username   = "testuser"
    public_key = tls_private_key.pkey.public_key_openssh
  }
  os_disk {
    caching           = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
  boot_diagnostics {
        storage_account_uri = azurerm_storage_account.SA.primary_blob_endpoint
    }
  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }
}
