#!/bin/bash

echo "#################################"
echo "  Running Switch Post Config (config_switch.sh)"
echo "#################################"
sudo su


## Convenience code. This is normally done in ZTP.

# Make DHCP occur without delays
echo "retry 1;" >> /etc/dhcp/dhclient.conf

cat << EOT > /etc/network/interfaces
auto lo
iface lo inet static
  address 10.0.0.99/32

auto eth0
iface eth0 inet dhcp

auto swp1
iface swp1

auto swp2
iface swp2
EOT
ifreload -a

cat << EOT > /etc/frr/daemons
zebra=yes
bgpd=yes
EOT

cat << EOT > /etc/frr/frr.conf
frr version 4.0+cl3u8
frr defaults datacenter
hostname leaf01
username cumulus nopassword
!
service integrated-vtysh-config
!
log syslog informational
!
router bgp 65099
 bgp router-id 10.0.0.99
 neighbor FABRIC peer-group
 neighbor FABRIC remote-as external
 neighbor swp1 interface peer-group FABRIC
 neighbor swp2 interface peer-group FABRIC
 !
 address-family ipv4 unicast
  neighbor FABRIC activate
  redistribute connected
 exit-address-family
!
line vty
!
EOT
systemctl start frr

echo "#################################"
echo "   Finished"
echo "#################################"


