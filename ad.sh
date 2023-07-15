#!/bin/bash

echo 'append domain-search "contoso.com"' >> /etc/dhcp/dhclient.conf
sed -i '/^\[main\]/a dhcp = dhclient' /etc/NetworkManager/NetworkManager.conf

systemctl restart network

yum install -y adcli krb5-workstation nmap oddjob oddjob-mkhomedir realmd samba-common-tools sssd

realm discover contoso.com

realm join -U $username contoso.com
