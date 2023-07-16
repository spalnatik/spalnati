#!/bin/bash
netplan apply

# Create the file and write the content
cat << EOF > /etc/netplan/99-dns.yaml
network:
  ethernets:
    eth0:
      nameservers:
        search: [ contoso.com ]
EOF
netplan apply
systemd-resolve --status
