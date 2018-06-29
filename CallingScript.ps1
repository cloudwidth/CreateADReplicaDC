#Break in case the script is run from a command line.  All these commands should be run individually as needed (i.e. from Powershell ISE)
break

# Shout out to @goateepfe for laying the groundwork fror some of this.

#Install Chocolatey, then use it to install Terraform
Set-ExecutionPolicy Bypass -Scope Process -Force; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
choco install terraform --version 0.11.7

#Download the Terraform script
Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/texmx/CreateADReplicaDC/master/main.tf' -OutFile '.\main.tf'

# Install the Azure Resource Manager modules from PowerShell Gallery
# Takes a while to install 28 modules
Install-Module AzureRM -Force -Verbose
Install-AzureRM

# Install the Azure Service Management module from PowerShell Gallery
Install-Module Azure -Force -Verbose

# Import AzureRM modules for the given version manifest in the AzureRM module
Import-AzureRM -Verbose

# Import Azure Service Management module
Import-Module Azure -Verbose

# Authenticate to your Azure account
Login-AzureRmAccount

#Azure Provider Login for Terraform.  If you don't have a Service Principal created to use to authenticate, you can follow
#the instructions at https://www.terraform.io/docs/providers/azurerm/authenticating_via_service_principal.html to get them.

$SubscriptionID = "00000000-0000-0000-0000-000000000000"
$ClientID       = "00000000-0000-0000-0000-000000000000"
$ClientSecret   = "00000000-0000-0000-0000-000000000000"
$TenantID       = "00000000-0000-0000-0000-000000000000"

#Environment Variables for your new domain controllers
$Location = "East US"       #Set the location where you want to deploy
$NewDCRG  = "yournamerg"    #Set the name of the new resource group where you want to deploy
$TargetVNET = "adVNET"      #The name of the existing vnet where you want to deploy
$TargetSubnet = "adSubnet"  #The name of the subnet in $TargetVNET where you want to deploy
$TargetVNETRG = "vnetrg"    #The name of the ResourceGroup containing the target vnet
$VMNamePrefix = "AZ-ADDS"    #The vm name prefix you want to use for your domain controllers.  Each will be named like AZ-ADDS1, AZ-ADDS2, etc.
$Count = 2                  #The number of new domain controllers you want to deploy - all of them will be part of a new Availability Group
$ADDomain = "contoso.com"   #The FQDN of the existing AD Domain you want to join
$ADSiteName = "Default-First-Site-Name"    #The name of an existing AD Site you want these domain controllers to associate with.
$AdminUser = "adadministrator"  #The username of a domain admin in your existing AD
$AdminPassword = "P@ssw0rd!!"   #The password for $AdminUser
$SafeModePassword = "P@ssw0rd!!"    #The AD SafeMode restore password to be used
$VMSize = "Standard_D2_v2"  #The size of VM you want to deploy for each domain controller

terraform apply -var "subscriptioni_id=${SubscriptionID}" -var "client_id=${ClientID}" -var "client_secret=${ClientSecret}" -var "tenant_id=${TenantID}" -var "location=${Location}" -var "new_dc_resourcegroup=${NewDCRG}" -var "target_vnet=${TargetVNET}" -var "target_subnet=${TargetSubnet}" -var "target_vnet_resourcegroup=${TargetVNETRG}" -var "vmname_prefix=${VMNamePrefix}" -var "count=${Count}" -var "addomain=${ADDomain}" -var "adsitename=${ADSiteName}" -var "admin_username=${AdminUser}" -var "admin_password=${AdminPassword}" -var "safemode_password=${SafeModePassword}" -var "vm_size=${VMSize}"
# This takes ~30 minutes

# Delete the entire resource group when finished
terraform destroy