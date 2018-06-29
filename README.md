# CreateADReplicaDC
Creates a number of domain controller replicas from an existing AD domain in Azure.

If you have an existing AD in a lab, download just the CallingScript.ps1 file from github and follow the instructions within.

It should:

1.	Install Chocolatey so you can install Terraform
2.	Install Terraform
3.	Download the 3 required terraform files.
4.	Instruct you on how to create the service principal in Azure to be used to authenticate
5.	Instruct you on how to edit the variables used for the environment in other files.
6.	Initialize the Terraform environment
7.	Test the scripts with a Terraform plan command
8.	Execute the scripts with terraform apply command

