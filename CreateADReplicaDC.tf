/* Connect to Azure */
provider "azurerm" {}

resource "azurerm_resource_group" "newdcrg" {
  name     = "${var.new_dc_resourcegroup}"
  location = "${var.location}"

  /* Optional Tags
  tags = {
    Environment = "Development"
    DeployDate  = "${replace(timestamp(), "/T.*$/", "")}"
  }
*/
}

resource "azurerm_availability_set" "newdcas" {
  name                = "${var.vmname_prefix}-as"
  location            = "${var.location}"
  resource_group_name = "${azurerm_resource_group.newdcrg.name}"
  managed             = true

  /* Optional Tags
  tags = {
    Environment = "Development"
    DeployDate  = "${replace(timestamp(), "/T.*$/", "")}"
  }
*/
}

data "azurerm_subnet" "newdc-subnet" {
  name                 = "${var.target_subnet}"
  virtual_network_name = "${var.target_vnet}"
  resource_group_name  = "${var.target_vnet_resourcegroup}"
}

resource "azurerm_network_interface" "newdcnic" {
  name                    = "${var.vmname_prefix}${count.index + 1}-nic"
  location                = "${var.location}"
  resource_group_name     = "${azurerm_resource_group.newdcrg.name}"
  count                   = "${var.count}"
  internal_dns_name_label = "dc-${count.index + 1}"
  #dns_servers             = ["${cidrhost(data.azurerm_subnet.newdc-subnet.address_prefix, 4)}"]

  ip_configuration {
    name                          = "${var.vmname_prefix}${count.index + 1}-ip_config"
    subnet_id                     = "${data.azurerm_subnet.newdc-subnet.id}"
    private_ip_address_allocation = "Static"
    private_ip_address            = "${cidrhost(data.azurerm_subnet.newdc-subnet.address_prefix, "${count.index + 100}")}"
  }

  /*
  Optional Tags
  tags = {
    Environment = "Development"
    DeployDate  = "${replace(timestamp(), "/T.*$/", "")}"
  }
*/
}

resource "azurerm_virtual_machine" "dc" {
  name                             = "${var.vmname_prefix}${count.index + 1}"
  location                         = "${var.location}"
  resource_group_name              = "${azurerm_resource_group.newdcrg.name}"
  network_interface_ids            = ["${element(azurerm_network_interface.newdcnic.*.id, count.index)}"]
  vm_size                          = "${var.vm_size}"
  delete_os_disk_on_termination    = true
  delete_data_disks_on_termination = true
  availability_set_id              = "${azurerm_availability_set.newdcas.id}"
  count                            = "${var.count}"

  /* Optional Tags
  tags = {
    Environment = "Development"
    DeployDate  = "${replace(timestamp(), "/T.*$/", "")}"
  }
*/

  lifecycle {
    ignore_changes = ["admin_password"]
  }
  storage_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2012-R2-Datacenter"
    version   = "latest"
  }
  storage_os_disk {
    name              = "${var.vmname_prefix}${count.index + 1}-osdisk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
  storage_data_disk {
    name              = "${var.vmname_prefix}${count.index + 1}-datadisk"
    caching           = "None"
    managed_disk_type = "Standard_LRS"
    create_option     = "Empty"
    lun               = 1
    disk_size_gb      = "1023"
  }
  os_profile {
    computer_name  = "${var.vmname_prefix}${count.index + 1}"
    admin_username = "${var.admin_username}"
    admin_password = "${var.admin_password}"
  }
  os_profile_windows_config {
    provision_vm_agent        = true
    enable_automatic_upgrades = true
  }
  depends_on = ["azurerm_availability_set.newdcas"]
}

resource "azurerm_virtual_machine_extension" "CreateADReplicaDC" {
  name                 = "DSC-DCPromo"
  location             = "${var.location}"
  resource_group_name  = "${azurerm_resource_group.newdcrg.name}"
  virtual_machine_name = "${var.vmname_prefix}${count.index + 1}"
  publisher            = "Microsoft.Powershell"
  type                 = "DSC"
  type_handler_version = "2.76"
  depends_on           = ["azurerm_virtual_machine.dc"]
  count                = "${var.count}"

  settings = <<SETTINGS
    {
        "wmfVersion": "latest",
        "configuration": {
            "url": "https://raw.githubusercontent.com/cloudwidth/CreateADReplicaDC/master/CreateADReplicaDC.zip",
            "script": "CreateADReplicaDC.ps1",
            "function": "CreateADReplicaDC"
        },
        "configurationArguments": {
          "domainname": "${var.addomain}",
          "ADSiteName": "${var.adsitename}"
        },
        "privacy": {
            "dataCollection": "enable"
        }
    }
    SETTINGS

  protected_settings = <<PROTECTED_SETTINGS
    {
        "configurationArguments": {
          "admin_credentials": {
              "userName": "${var.admin_username}",
              "password": "${var.admin_password}"
          },
          "safemode_credentials": {
              "userName": "none",
              "password": "${var.safemode_password}"
          }
        }
    }
    PROTECTED_SETTINGS
}
