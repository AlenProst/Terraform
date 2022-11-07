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


#install chrome

$LocalTempDir = $env:TEMP; $ChromeInstaller = "ChromeInstaller.exe"; (new-object    System.Net.WebClient).DownloadFile('http://dl.google.com/chrome/install/375.126/chrome_installer.exe', "$LocalTempDir\$ChromeInstaller"); & "$LocalTempDir\$ChromeInstaller" /silent /install; $Process2Monitor =  "ChromeInstaller"; Do { $ProcessesFound = Get-Process | ?{$Process2Monitor -contains $_.Name} | Select-Object -ExpandProperty Name; If ($ProcessesFound) { "Still running: $($ProcessesFound -join ', ')" | Write-Host; Start-Sleep -Seconds 2 } else { rm "$LocalTempDir\$ChromeInstaller" -ErrorAction SilentlyContinue -Verbose } } Until (!$ProcessesFound)

### disable all security on the server ####

$AdminKey = "HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\{A509B1A7-37EF-4b3f-8CFC-4F3A74704073}"

$UserKey = "HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\{A509B1A8-37EF-4b3f-8CFC-4F3A74704073}"

Set-ItemProperty -Path $AdminKey -Name "IsInstalled" -Value 0

Set-ItemProperty -Path $UserKey -Name "IsInstalled" -Value 0

Stop-Process -Name Explorer

Write-Host "IE Enhanced Security Configuration (ESC) has been disabled." -ForegroundColor Green

### Disable Firewall with PS ###
Set-NetFirewallProfile -Profile Domain,Public,Private -Enabled False
Set-MpPreference -DisableRealtimeMonitoring $true


# Restart-Computer -Wait

# $username = "azureuser"
# $password = ConvertTo-SecureString "1" -AsPlainText -Force
# $psCred = New-Object System.Management.Automation.PSCredential -ArgumentList ($username, $password)

# Add-Computer -DomainName "contoso.local" -Credential $psCred -Restart -Force

#download Exchange
New-Item 'C:\EXCHANGE' -ItemType Directory

New-SMBShare -Name EXCHANGE -Path "C:\EXCHANGE" -FullAccess "Domain Admins" -ReadAccess "Users"
