configuration CreateADReplicaDC
{

    param
    (
        [Parameter(Mandatory)][String]$DomainName,
        [Parameter(Mandatory)][System.Management.Automation.PSCredential]$Admin_credentials,
        [Parameter(Mandatory)][System.Management.Automation.PSCredential]$SafeMode_credentials,
        [Parameter(Mandatory)][String]$ADSiteName
        #[Parameter(Mandatory)][String]$AdminUser,
        #[Parameter(Mandatory)][String]$AdminPassword,
        #[Parameter(Mandatory)][String]$SafeModeUser,
        #[Parameter(Mandatory)][String]$SafeModePassword
    )

    Import-DscResource -ModuleName PSDesiredStateConfiguration -ModuleVersion 1.1
    Import-DscResource -ModuleName StorageDSC -ModuleVersion 4.4.0.0
    Import-DscResource -ModuleName xActiveDirectory -ModuleVersion 2.19.0.0

    #$secadminpasswd = ConvertTo-SecureString $AdminPassword -AsPlainText -Force
    #$secsafemodepasswd = ConvertTo-SecureString $SafeModePassword -AsPlainText -Force
    [System.Management.Automation.PSCredential]$DomainCreds = New-Object System.Management.Automation.PSCredential ($DomainName.Split('.')[0] + "\" + $admin_credentials.UserName), $Admin_credentials.Password
    [System.Management.Automation.PSCredential]$SafeModeCreds = New-Object System.Management.Automation.PSCredential ($DomainName.Split('.')[0] + "\" + $SafeMode_credentials.UserName), $SafeMode_credentials.Password

    Node $AllNodes.NodeName
    {
       LocalConfigurationManager
        {
            ActionAfterReboot = 'ContinueConfiguration'
            ConfigurationMode = 'ApplyOnly'
            RebootNodeIfNeeded = $true
            AllowModuleOverwrite = $true
        }

       WindowsFeature ADDS
        {
            Ensure = 'Present'
            Name = 'AD-Domain-Services'
        }

       WindowsFeature RSATADTools
        {
           Ensure = "Present"
           Name = "RSAT-AD-Tools"
        }

        WindowsFeature RSATADAdminCenter
        {
           Ensure = "Present"
           Name = "RSAT-AD-AdminCenter"
        }

       WaitForDisk Disk2
       {
          DiskID = '2'
          RetryIntervalSec = $RetryIntervalSec
          RetryCount = $RetryCount
       }

       Disk ADDataDisk 
       {
          DiskID = '2'
          DriveLetter = 'F'
          FSFormat = 'NTFS'
          FSLabel = 'AD-DS'
          DependsOn = "[WaitForDisk]Disk2"
       }

        xADDomainController ReplicaDC 
        { 
          DomainName = $DomainName 
          DomainAdministratorCredential = $DomainCreds 
          SafemodeAdministratorPassword = $SafeModeCreds
          DatabasePath = "F:\NTDS"
          LogPath = "F:\NTDS"
          SysvolPath = "F:\SYSVOL"
          DependsOn = "[Disk]ADDataDisk", "[WindowsFeature]ADDS"
          SiteName = $ADSiteName
        }

    }
}
