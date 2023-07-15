#!/bin/bash

sudo echo 'append domain-search "contoso.com"' >> /etc/dhcp/dhclient.conf
sudo sed -i '/^\[main\]/a dhcp = dhclient' /etc/NetworkManager/NetworkManager.conf

sudo systemctl restart network

sudo yum install -y adcli krb5-workstation nmap oddjob oddjob-mkhomedir realmd samba-common-tools sssd

sudo realm discover contoso.com

sudo realm join -U $username contoso.com
