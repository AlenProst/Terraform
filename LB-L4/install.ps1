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

$AdminKey = "HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\{A509B1A7-37EF-4b3f-8CFC-4F3A74704073}"

$UserKey = "HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\{A509B1A8-37EF-4b3f-8CFC-4F3A74704073}"

Set-ItemProperty -Path $AdminKey -Name "IsInstalled" -Value 0

Set-ItemProperty -Path $UserKey -Name "IsInstalled" -Value 0

Stop-Process -Name Explorer

Write-Host "IE Enhanced Security Configuration (ESC) has been disabled." -ForegroundColor Green

### Disable Firewall with PS ###
Set-NetFirewallProfile -Profile Domain,Public,Private -Enabled False
Set-MpPreference -DisableRealtimeMonitoring $true