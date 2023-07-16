#!/bin/bash

timestamp=$(date +"%Y-%m-%d %H:%M:%S")

echo "Script execution started at: $timestamp"

#set -x

vmname1="win2019adserver"
vmname2="linuxad"
rgname="Lab_Azure_AD"
offer="MicrosoftWindowsServer:WindowsServer:2019-datacenter-smalldisk:latest"
offer1="OpenLogic:CentOS:7_9:latest"
loc="eastus"
sku_size="Standard_D2s_v3"
vnetname="AD-vnet"
subnetname="ADsubnet"
logfile="deploy.log"

# Parse command line arguments
while getopts "i:" opt; do
  case $opt in
    i) offer1=$OPTARG ;;
    *) ;;
  esac
done

echo "Offer1: $offer1"


if [ -f "./username.txt" ]; then
    username=$(cat username.txt)
else
    read -p "Please enter the username: " username
fi

if [ -f "./password.txt" ]; then
    password=$(cat password.txt)
else
    read -s -p "Please enter the password: " password
fi

echo ""
date >> "$logfile"
echo "Creating RG $rgname.."
az group create --name "$rgname" --location "$loc" >> "$logfile"

echo "Creating VNET .."
az network vnet create --name "$vnetname" -g "$rgname" --address-prefixes 10.0.0.0/24 --subnet-name "$subnetname" --subnet-prefixes 10.0.0.0/24 >> "$logfile"

echo "Creating windows AD Domain server"
az vm create -g "$rgname" -n "$vmname1" --admin-username "$username" --admin-password "$password" --image "$offer" --vnet-name "$vnetname" --subnet "$subnetname" --public-ip-sku Standard --private-ip-address "10.0.0.15" --no-wait >> "$logfile"

echo "Creating Linux AD integrating server"
az vm create -g "$rgname" -n "$vmname2" --admin-username "$username" --admin-password "$password" --image $offer1 --vnet-name "$vnetname" --subnet "$subnetname" --public-ip-sku Standard --private-ip-address "10.0.0.6" >> "$logfile"

## Update the virtual network with IP address of the DNS server. ##
az network vnet update --resource-group "$rgname" --name "$vnetname" --dns-servers 10.0.0.15

echo 'configuring domain name and installing ad domain services'

az vm extension set \
    --resource-group "$rgname" \
    --vm-name "$vmname1" \
    --name CustomScriptExtension \
    --publisher Microsoft.Compute \
    --settings '{"fileUris": ["https://raw.githubusercontent.com/spalnatik/spalnati/main/contoso.ps1"],"commandToExecute": "powershell.exe -ExecutionPolicy Unrestricted -File contoso.ps1"}' >> "$logfile"

#!/bin/bash

if [[ $offer1 == *"Canonical"* ]]; then
    echo 'installing sssd and other packages'

az vm extension set \
    --resource-group "$rgname" \
    --vm-name "$vmname2" \
    --name customScript \
    --publisher Microsoft.Azure.Extensions \
    --protected-settings '{
        "fileUris": ["https://raw.githubusercontent.com/spalnatik/spalnati/main/ubuntu.sh"],
        "commandToExecute": "apt update && apt install realmd oddjob oddjob-mkhomedir sssd sssd-tools sssd-ad adcli packagekit samba-common -y  && chmod +x ubuntu.sh && ./ubuntu.sh"    }' >> "$logfile"

elif [[ $offer1 == *"suse"* ]]; then
    echo 'installing sssd and other packages'

az vm extension set \
    --resource-group "$rgname" \
    --vm-name "$vmname2" \
    --name customScript \
    --publisher Microsoft.Azure.Extensions \
    --protected-settings '{
        "fileUris": ["https://raw.githubusercontent.com/spalnatik/spalnati/main/suse.sh"],
        "commandToExecute": "zypper -n install realmd sssd sssd-tools adcli krb5-client samba-client openldap2-client sssd-ad && chmod +x suse.sh && ./suse.sh"    }' >> "$logfile"

#elif [[ "$offer1" == *"rhel"* || "$offer1" == *"CentOS"* ]]; then
elif [[ $offer1 == *"OpenLogic"* || $offer1 == *"redhat"* ]]; then
     echo 'installing sssd and other packages'

az vm extension set \
    --resource-group "$rgname" \
    --vm-name "$vmname2" \
    --name customScript \
    --publisher Microsoft.Azure.Extensions \
    --protected-settings '{
        "fileUris": ["https://raw.githubusercontent.com/spalnatik/spalnati/main/ad.sh"],
        "commandToExecute": "yum install -y adcli krb5-workstation nmap oddjob oddjob-mkhomedir realmd samba-common-tools sssd && chmod +x ad.sh && ./ad.sh"    }' >> "$logfile"

else
    # Invalid offer1 value
    echo "Invalid offer1 value. No script to execute."

fi


echo 'Updating NSGs with public IP and allowing ssh access(linux vm) and rdp (windows VM) from that IP'

my_pip=`curl ifconfig.io`
nsg_list=`az network nsg list -g $rgname  --query [].name -o tsv`
for i in $nsg_list
    do
	az network nsg rule create -g $rgname --nsg-name $i -n buildInfraRule --priority 100 --source-address-prefixes $my_pip  --destination-port-ranges 3389 --access Allow --protocol Tcp >> $logfile

	az network nsg rule create -g $rgname --nsg-name $i -n buildInfraRule --priority 101 --source-address-prefixes $my_pip  --destination-port-ranges 22 --access Allow --protocol Tcp >> $logfile
done

echo 'sleep for 2 mins until windows server is up'

sleep 120


echo 'adding server to the domain'
az vm run-command invoke   --resource-group $rgname   --name $vmname2   --command-id RunShellScript   --scripts "echo $password | realm join -U $username contoso.com" >> $logfile


end_time=$(date +"%Y-%m-%d %H:%M:%S")

echo "Script execution completed at: $end_time"
