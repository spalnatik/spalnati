#!/bin/bash

sudo echo 'append domain-search "intl.contoso.com"' >> /etc/dhcp/dhclient.conf
sudo sed -i '/^\[main\]/a dhcp = dhclient' /etc/NetworkManager/NetworkManager.conf
#echo "nameserver 10.0.0.15" | sudo tee /etc/resolv.conf
sudo systemctl restart NetworkManager




