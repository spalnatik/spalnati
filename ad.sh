echo 'append domain-search "contoso.com"' >> /etc/dhcp/dhclient.conf
sed -i '/^\[main\]/a dhcp = dhclient' /etc/NetworkManager/NetworkManager.conf

systemctl restart network

yum install realmd oddjob oddjob-mkhomedir sssd adcli krb5-workstation samba-common-tools nmap tcpdump

realm discover contoso.com

realm join -U $username contoso.com