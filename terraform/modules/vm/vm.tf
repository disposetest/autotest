

resource "azurerm_network_interface" "nic" {
  name                = "${var.application_type}-${var.resource_type}"
  location            = var.location
  resource_group_name = var.resource_group

  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = var.public_ip_address_id
  }
}


#Generate an ID
resource "random_id" "randomId" {
    keepers = {
        # Generate a new ID when a new resource group is defined
        resource_group = var.resource_group
    }
    
    byte_length = 8
}

#An account to store the system diagnose
resource "azurerm_storage_account" "SA" {
    name                        = "diagnose${random_id.randomId.hex}"
    resource_group_name         = var.resource_group
    location                    = var.location
    account_replication_type    = "LRS"
    account_tier                = "Standard"

    tags = {
        environment = "LinuxVMEnv"
    }
}


resource "azurerm_linux_virtual_machine" "lvm" {
  name                = "${var.application_type}-${var.resource_type}-lvm"
  location            = var.location
  resource_group_name = var.resource_group
  size                = "Standard_B1s"
  admin_username      = "testuser"
  disable_password_authentication = true
  network_interface_ids = [azurerm_network_interface.nic.id]
  admin_ssh_key {
    username   = "testuser"
    public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQD2DdxPjYlEW96uIweui4EyRDLh6zP52Mu5eLAuWyQlxgzph2Zw9Im/TpVfemw1NZGLQYL5rd+kMALPM7DglLjW/XINJ/GG+XP778SgnDXBtm9FCQP/GIgRuMYTPSEvtHt16WwL1TWIHbcBO17frd5aZ300GUCSviLw4q7i6EhHMcuNlAMTuTfNrwxW48TuH2C+11qItDJZdzHyBhu9ncFweRa7af2NqFLTVNuIQtTRz/7hnuTGXf96o61TYDJY/YSqCWT7oEYCAkjvXfLgJ9Egdy19m3RBs0OGLYk3loRn7WBfUoyN/Uuq8NIwvg+cbouRrnWXBLf0DykfZqMs3IOAnd0NFyftbVxiQtO4lVXTYuIJtKpDL+mHVnPvIjKykXQxPGTYAbsKqU96aLW0AUTWvtfnwstKtOkmuw3QNK/i0HSuAoup/gEgFmxsm24BUcyYRPQxemNmxlQbm9iUQUIX8fLdaBI+AGTeBUyuRepyhOR/l8ssFU2rexFAfTvKXiFzbu/dZ0dBBLFKPSH7nsSgHQsovx/gWxqfzVllFyS945cWKNWa0wjmLFO0zQx5mOly82KXKJXIxo6VSbTsc7sKbSbYwApETCNT0edi8kgSVjj4p5H1uiUn6EcBBVMX6ELadIh4y3AgZ6bYm/jNtdnV4pJ00PrxGJ21x5uokziC7w== cjordan@cjordan-Aspire-VX5-591G"
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
