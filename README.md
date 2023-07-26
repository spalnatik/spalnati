# spalnati

I have written a script to automate the process of integrating a server with Active Directory. This script is designed to assist with troubleshooting AD replication issues, which are commonly encountered.

Here is the link to download the script:

spalnati/intlinuxad.sh at main · spalnatik/spalnati (github.com)

The script performs the steps outlined in the provided documentation:
----------------------------------------------------------------------------------------
Integrating with Active Directory - Overview (visualstudio.com)
Create, change, or delete an Azure virtual network | Microsoft Learn
How To Use Custom DNS In Linux VM - Overview (visualstudio.com)

Usage:
The script will do the below:
•	Please prompt the user to provide their username and password, which will be used for accessing the Windows and Linux VMs as local users.
•	Create resource group, VNET and 2 VMs.
•	1 VM is windows_2019 and another one is centos7_9.
•	By default, it will create centos VM, but you can use -i and image urn to specify another image.
Ex:
./intlinuxad.sh -i "suse:sles-15-sp2:gen2:latest" 
Or
./intlinuxad.sh -i "Canonical:0001-com-ubuntu-server-focal:20_04-lts:latest"
Or
./intlinuxad.sh -i "redhat:rhel:7-lvm:latest"

•	Changing the DNS server of VNET (providing windows VM as DNS server).
•	Starting a custom script extension to configure:
o	PowerShell script (contoso.ps1) will be used to install AD domain services and configuring domain name (contoso.com) on windows VM.
o	Shell script (ad.sh,suse.sh and ubuntu.sh) will be used to configure custom DNS in Linux VM and also to install required rpms (realmd ,sssd etc).
•	Updating NSGs with public IP and allowing ssh and rdp access. 
•	Run command is used to pass the domain join script ( realm join ).
________________________________________
Tools required to run it:
•	WSL (windows subsystem for Linux) or any Linux system.
•	Azure CLI installed on the machine and already logged in.
________________________________________
limitations:
•	The current script requires approximately 20 minutes to complete the deployment process, with the majority of the time being dedicated to the installation of AD domain services and the configuration of the domain name (contoso.com) on the Windows VM.
•	You can modify the VM name and Resource group name by directly editing the variables in the script.
