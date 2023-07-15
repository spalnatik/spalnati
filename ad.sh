#!/bin/bash

sudo echo 'append domain-search "contoso.com"' >> /etc/dhcp/dhclient.conf
sudo sed -i '/^\[main\]/a dhcp = dhclient' /etc/NetworkManager/NetworkManager.conf

sudo systemctl restart network




