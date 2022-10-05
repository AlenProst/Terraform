Install-WindowsFeature -Name Web-Server -IncludeAllSubFeature -IncludeManagementTools

New-Item -Path 'C:\inetpub\wwwroot' -Name 'iisstart.htm' -ItemType 'file' -Value '<h1>Test from IIS</h1>' -force

### Removes Complexity Locally ###
secedit /export /cfg c:\secpol.cfg
(gc C:\secpol.cfg).replace("PasswordComplexity = 1", "PasswordComplexity = 0") | Out-File C:\secpol.cfg
secedit /configure /db c:\windows\security\local.sdb /cfg c:\secpol.cfg /areas SECURITYPOLICY
rm -force c:\secpol.cfg -confirm:$false

gpupdate /force

$Password = ConvertTo-SecureString "1" -AsPlainText -Force
$UserAccount = Get-LocalUser -Name "azureuser"
$UserAccount | Set-LocalUser -Password $Password

### Set-TimeZone ###

Set-TimeZone -Id "FLE Standard Time"