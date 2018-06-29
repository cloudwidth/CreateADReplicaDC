[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$TerraformFolder = New-Item -ItemType Directory -Force -Path ($env:PROGRAMFILES + "\Terraform2")
Invoke-WebRequest -Uri 'https://releases.hashicorp.com/terraform/0.11.7/terraform_0.11.7_windows_amd64.zip' -OutFile $TerraformFolder
