#Break in case the script is run from a command line.  All these commands should be run individually as needed (i.e. from Powershell ISE)
break

# Shout out to @goateepfe for laying the groundwork fror some of this.

#Install Chocolatey, then use it to install Terraform
Set-ExecutionPolicy Bypass -Scope Process -Force; Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
#May have to restart the PowerShell session before the next line
choco install terraform

#Download the Terraform script files
Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/texmx/CreateADReplicaDC/master/CreateADReplicaDC.tf' -OutFile '.\CreateADReplicaDC.tf'
Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/texmx/CreateADReplicaDC/master/CreateADReplicaDC_vars.tf' -OutFile '.\CreateADReplicaDC_vars.tf'
Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/texmx/CreateADReplicaDC/master/CreateADReplicaDC.tfvars' -OutFile '.\CreateADReplicaDC.tfvars'

#Use Azure CLI to Create a Service Principal in the Azure subscription to be used to log in with terraform
az login
az account list  #make note of the value returned for "id"
<#            [
              {
                "cloudName": "AzureCloud",
                "id": "00000000-0000-0000-0000-000000000000",      <--------Make note of this value and replace for SUBSCRIPTION_ID below
                "isDefault": true,
                "name": "PAYG Subscription",
                "state": "Enabled",
                "tenantId": "00000000-0000-0000-0000-000000000000",
                "user": {
                  "name": "user@example.com",
                  "type": "user"
                }
              }
            ]#>
az account set --subscription="SUBSCRIPTION_ID"
az ad sp create-for-rbac --role="Contributor" --scopes="/subscription/SUBSCRIPTION_ID"
<#          {
              "appId": "00000000-0000-0000-0000-000000000000",     <---------this value is client_id
              "displayName": "azure-cli-2017-06-05-10-41-15",
              "name": "http://azure-cli-2017-06-05-10-41-15",
              "password": "0000-0000-0000-0000-000000000000",      <---------this value is client_secret
              "tenant": "00000000-0000-0000-0000-000000000000"     <---------this value is tenant_id
            }#>

<#Edit the CreateADReplicaDC.tfvars file and fill in the values for:
    azure_subscription_id = SUBSCRIPTION_ID
    azure_client_id       = client_id
    azure_client_secret   = client_secret
    azure_tenant_id       = tenant_id

    location = "eastus"                         #Azure Location to deploy to
    new_dc_resourcegroup = "NewDCRG"            #New Resource Group to contain your new domain controllers
    target_vnet_resourcegroup = "ExistingDCRG"  #Existing Resource Group containing the vnet where the domain controllers should be deployed
    target_vnet = "adVNET"                      #Existing vnet where the domain controllers should be deployed
    target_subnet = "adSubnet"                  #Existing subnet in the existing vnet where the domain controllers should be deployed
    vmname_prefix = "AZ-ADDS"                   #VM name prefix.  (i.e. AZ-ADDS1, AZ-ADDS2, etc)
    addomain = "contoso.com"                    #FQDN of the existing Active Directory domain to which the new machines sould be joined.
    admin_username = "adadministrator"          #Domain Administrator of the domain to join
    admin_password = "P@ssw0rd!!"               #Password for the Domain Administrator
    safemode_password = "P@ssw0rd!!"            #Password for SafeMode
    adsitename = "Default-First-Site-Name"      #Name of the existing Active Directory Site to associate with the new domain controllers
#>

terraform init -no-color -var-file="CreateADReplicaDC.tfvars"
terraform plan -no-color -var-file="CreateADReplicaDC.tfvars"
terraform apply -no-color -var-file="CreateADReplicaDC.tfvars"
# This takes ~30 minutes

# Delete the entire resource group when finished
terraform destroy -no-color -var-file="CreateADReplicaDC.tfvars"
