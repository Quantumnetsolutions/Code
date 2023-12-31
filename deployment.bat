# Script Name:                          deployment.bat
# Author Name:                          Tianna Farrow
# Date of latest revision:              12/21/2023
# Purpose:                              A script that automates the deployment of a Windows Server (Virutal Machine). 
# Execution:                            add it as a .ps1 file on the server or copy code into powershell as 
# Additional Resources:                 https://pypi.org/project/pywinrm/; https://www.phillipsj.net/posts/executing-powershell-from-python/;  https://docs.microsoft.com/en-us/powershell/module/servermanager/uninstall-windowsfeature; https://docs.microsoft.com/en-us/powershell/module/netadapter/disable-netadapter; https://docs.microsoft.com/en-us/powershell/module/dnsclient/clear-dnsclientserveraddress;https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.management/rename-computer; https://docs.microsoft.com/en-us/powershell/module/addsadministration/remove-adorganizationalunit; https://docs.microsoft.com/en-us/powershell/module/addsadministration/remove-aduser;  https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.management/rename-computer?view=powershell-7.4; https://learn.microsoft.com/en-us/powershell/module/nettcpip/new-netipaddress?view=windowsserver2022-ps; https://learn.microsoft.com/en-us/powershell/module/dnsclient/set-dnsclientserveraddress?view=windowsserver2022-ps; https://learn.microsoft.com/en-us/powershell/module/servermanager/install-windowsfeature?view=windowsserver2022-ps; https://learn.microsoft.com/en-us/powershell/module/addsdeployment/install-addsforest?view=windowsserver2022-ps; https://learn.microsoft.com/en-us/powershell/module/activedirectory/new-adorganizationalunit?view=windowsserver2022-ps; https://learn.microsoft.com/en-us/powershell/module/activedirectory/new-aduser?view=windowsserver2022-ps; https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.management/get-wmiobject?view=powershell-5.1;   


# Clear Existing Configurations
Write-Host "Clearing existing configurations..."

# Backup important data if needed

# Remove Roles and Features
Get-WindowsFeature | Where-Object { $_.Installed } | Uninstall-WindowsFeature -Remove

# Remove AD Domain Services
Uninstall-WindowsFeature -Name AD-Domain-Services -IncludeManagementTools

# Remove DNS Server Role
Uninstall-WindowsFeature -Name DNS -IncludeManagementTools

# Clear Network Configuration
Write-Host "Clearing network configuration..."
Get-NetAdapter | Disable-NetAdapter
Get-NetAdapter | Clear-DnsClientServerAddress

# Reset Computer Name
Write-Host "Resetting computer name..."
Rename-Computer -NewName "TEMP" -Restart

# Remove Organizational Units (OUs) and Users
Write-Host "Removing OUs and users..."
Get-ADOrganizationalUnit -Filter { Name -eq "Executive Team" } | Remove-ADOrganizationalUnit -Recursive
Get-ADUser -Filter * | Remove-ADUser -Confirm:$false

# Reset DNS Configuration
Write-Host "Resetting DNS configuration..."
Set-DnsClientServerAddress -InterfaceAlias Ethernet -ResetServerAddresses

# Rename Windows Server VM 
Rename-Computer -NewName "TarantinoTechServer" -Restart 

# Assign a Static IPv4 Address and DNS 
# Variables 

$IPAddress = "10.0.2.101"
$SubnetMask = "255.255.255.0"
$Gateway = "10.0.2.1"
$DNS = "10.0.2.1"

New-NetIPAddress -InterfaceAlias Ethernet -IPAddress $IPAddress -PrefixLength 24 -DefaultGateway $Gateway
Set-DnsClientServerAddress -InterfaceAlias Ethernet -ServerAddresses $DNS

# AD Domain Services 
Install-WindowsFeature -Name AD-Domain-Services -IncludeManagementTools

# Domain Controller 
# Variable 

$DomainName = "tarantinotech.com"
$NetBiosDomainName = "TARANTINOTECH"
$SafeModeAdministratorPassword = ConvertTo-SecureString -String "PulpFiction" -AsPlainText -Force

Install-ADDSForest -DomainName $DomainName -SafeModeAdministratorPassword $SafeModeAdministratorPassword -Force:$true -InstallDns:$true -DomainNetbiosName "TARANTINOTECH"

# Organization Units (OUs)
New-ADOrganizationalUnit -Name "Executive Team" -Path "DC=tarantinotech,DC=com"
New-ADOrganizationalUnit -Name "Development Department" -Path "DC=tarantinotech,DC=com"
New-ADOrganizationalUnit -Name "Product Department" -Path "DC=tarantinotech,DC=com"
New-ADOrganizationalUnit -Name "Operations Department" -Path "DC=tarantinotech,DC=com"
New-ADOrganizationalUnit -Name "Human Resources" -Path "DC=tarantinotech,DC=com"

# Users 
New-ADUser -SamAccountName "WinstonWolfe" -UserPrincipalName "WinstonWolfe@tarantinotech.com" -Name "Winston Wolfe" -GivenName "Winston" -Surname "Wolfe" -Title "CEO" -Department "Executive Team"
New-ADUser -SamAccountName "AldoRaine" -UserPrincipalName "AldoRaine@tarantinotech.com" -Name "Aldo Raine" -GivenName "Aldo" -Surname "Raine" -Title "CTO" -Department "Executive Team"
New-ADUser -SamAccountName "JulesWinnfield" -UserPrincipalName "JulesWinnfield@tarantinotech.com" -Name "Jules Winnfield" -GivenName "Jules" -Surname "Winnfield" -Title "COO" -Department "Executive Team"
New-ADUser -SamAccountName "MiaWallace" -UserPrincipalName "MiaWallace@tarantinotech.com" -Name "Mia Wallace" -GivenName "Mia" -Surname "Wallace" -Title "CFO" -Department "Executive Team"
New-ADUser -SamAccountName "VincentVega" -UserPrincipalName "VincentVega@tarantinotech.com" -Name "Vincent Vega" -GivenName "Vincent" -Surname "Vega" -Title "Lead Software Engineer" -Department "Development Department"
New-ADUser -SamAccountName "KingSchultz" -UserPrincipalName "KingSchultz@tarantinotech.com" -Name "King Schultz" -GivenName "King" -Surname "Schultz" -Title "Senior Frontend Developer" -Department "Development Department"
New-ADUser -SamAccountName "BridgetVonHammersmark" -UserPrincipalName "BridgetVonHammersmark@tarantinotech.com" -Name "Bridget Von Hammersmark" -GivenName "Bridget" -Surname "Von Hammersmark" -Title "Backend Developer" -Department "Development Department"
New-ADUser -SamAccountName "DjangoFreeman" -UserPrincipalName "DjangoFreeman@tarantinotech.com" -Name "Django Freeman" -GivenName "Django" -Surname "Freeman" -Title "QA Engineer" -Department "Development Department"
New-AdUser -SamAccountName "ArchieHicox" -UserPrincipalName "ArchieHicox@tarantinotech.com" -Name "Archie Hicox" -GivenName "Archie" -Surname "Hicox" -Title "Product Manager" -Department "Product Department"
New-AdUser -SamAccountName "ShosannaDreyfus" -UserPrincipalName "ShosannaDreyfus@tarantinotech.com" -Name "Shosanna Dreyfus" -GivenName "Shosanna" -Surname "Dreyfus" -Title "UX/UI Designer" -Department "Product Department"
New-AdUser -SamAccountName "CalvinCandie" -UserPrincipalName "CalvinCandie@tarantinotech.com" -Name "Calvin Candie" -GivenName "Calvin" -Surname "Candie" -Title "Data Analyst" -Department "Product Department"
New-AdUser -SamAccountName "HansLanda" -UserPrincipalName "HansLanda@tarantinotech.com" -Name "Hans Landa" -GivenName "Hans" -Surname "Landa" -Title "Scrum Master" -Department "Product Department"
New-AdUser -SamAccountName "JackieBrown" -UserPrincipalName "JackieBrown@tarantinotech.com" -Name "Jackie Brown" -GivenName "Jackie" -Surname "Brown" -Title "Operations Director/VP of Operations" -Department "Operations Department"
New-AdUser -SamAccountName "Butch Coolidge" -UserPrincipalName "ButchCoolidge@tarantinotech.com" -Name "Butch Coolidge" -GivenName "Butch" -Surname "Coolidge" -Title "Supply Chain Manager" -Department "Operations Department"
New-ADUser -SamAccountName "Ordell Robbie" -UserPrincipalName "OrdellRobbie@tarantinotech.com" -Name "Ordell Robbie" -GivenName "Ordell" -Surname "Robbie" -Title "Facilties Manager" -Department "Operations Department"
New-AdUser -SamAccountName "Elle Driver" -UserPrincipalName "ElleDriver@tarantinotech.com" -Name "Elle Driver" -GivenName "Elle" -Surname "Driver" -Title "Security Officer" -Department "Opeartions Department"
New-AdUser -SamAccountName "Hugo Stiglitz" -UserPrincipalName "HugoStiglitz@tarantinotech.com" -Name "Hugo Stiglitz" -GivenName "Hugo" -Surname "Stiglitz" -Title "HR Director" -Department "Human Resources"
New-AdUser -SamAccountName "Beatrix Kiddo" -UserPrincipalName "BeatrixKiddo@tarantinotech.com" -Name "Beatrix Kiddo" -GivenName "Beatrix" -Surname "Kiddo" -Title "Talent Acquisition Specialist" -Department "Human Resources"
New-AdUser -SamAccountName "Daisy Domergue" -UserPrincipalName "DaisyDomergue@tarantinotech.com" -Name "Daisy Domergue" -GivenName "Daisy" -Surname "Domergue" -Title "Employee Relations Manager" -Department "Human Resources"
New-AdUser -SamAccountName "GogoYubari" -UserPrincipalName "GogoYubari@tarantinotech.com" -Name "Gogo Yubari" -GivenName "Gogo" -Surname "Yubari" -Title "Training and Development Coordinator" -Department "Human Resources"

# DNS Server 
$DnsServer = Get-WmiObject Win32_NetworkAdapterConfiguration | Where-Object { $_.DNSServerSearchOrder -eq $null }
$DnsServer.SetDNSServerSearchOrder(@($DNS))

# End Script 
Write-Host "Script complete!"

# Notes to self 
# Can set using Set-ExecutionPolicy Unrestricted -Force. 
# There are some python resources