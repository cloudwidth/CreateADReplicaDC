#Break in case the script is run from a command line.  All these commands should be run individually as needed (i.e. from Powershell ISE)
break

# Shout out to @goateepfe for laying the groundwork fror some of this.

#Install Chocolatey, then use it to install Terraform
Set-ExecutionPolicy Bypass -Scope Process -Force; Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
#May have to restart the PowerShell session before the next line
choco install terraform

#Download the Terraform script files
Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/cloudwidth/CreateADReplicaDC/master/CreateADReplicaDC.tf' -OutFile '.\CreateADReplicaDC.tf'
Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/cloudwidth/CreateADReplicaDC/master/CreateADReplicaDC_vars.tf' -OutFile '.\CreateADReplicaDC_vars.tf'
Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/cloudwidth/CreateADReplicaDC/master/CreateADReplicaDC.tfvars' -OutFile '.\CreateADReplicaDC.tfvars'

#Use Azure CLI to log in with terraform
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

terraform init -no-color -var-file="CreateADReplicaDC.tfvars"   # Initialize your workspace
terraform plan -no-color -var-file="CreateADReplicaDC.tfvars"   # Pre-Validate the configuration 
terraform apply -no-color -var-file="CreateADReplicaDC.tfvars"  # Deploy the configuration
# This takes ~30 minutes

# Delete the entire resource group when finished
terraform destroy -no-color -var-file="CreateADReplicaDC.tfvars"
