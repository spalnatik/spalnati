#!/bin/bash

# Update the NETCONFIG_DNS_STATIC_SEARCHLIST value in the config file
sed -i 's/NETCONFIG_DNS_STATIC_SEARCHLIST=.*/NETCONFIG_DNS_STATIC_SEARCHLIST="contoso.com"/' /etc/sysconfig/network/config

# Restart the network service
systemctl restart network

# Verify the changes
echo "DNS static search list updated:"
cat /etc/sysconfig/network/config | grep NETCONFIG_DNS_STATIC_SEARCHLIST
