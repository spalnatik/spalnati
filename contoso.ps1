Get-WindowsFeature -Name *rsat* | Install-WindowsFeature ; Install-windowsfeature AD-domain-services
$secpassword = ConvertTo-SecureString 'Pa$$w0rd12345' -AsPlainText -Force
Import-Module ADDSDeployment
Install-ADDSForest `
    -SafeModeAdministratorPassword $secpassword `
    -CreateDnsDelegation:$false `
    -DatabasePath "C:\windows\NTDS" `
    -DomainMode "WinThreshold" `
    -DomainName "Contoso.com" `
    -DomainNetbiosName "CONTOSO" `
    -ForestMode "WinThreshold" `
    -InstallDns:$true `
    -LogPath "C:\windows\NTDS" `
    -NoRebootOnCompletion:$false `
    -SysvolPath "C:\windows\SYSVOL" `
    -Force:$true