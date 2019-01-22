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
  neighbor swp1 default-originate
  neighbor swp2 default-originate
  redistribute connected
 exit-address-family
!
line vty
!
EOT
systemctl start frr

# Use L4 information for Multipath-Hashing
sysctl -w net.ipv4.fib_multipath_hash_policy=1

# SNAT packets to servers at swp1 and swp2
iptables -t nat -A POSTROUTING -o swp2 -s 10.255.1.1/24  -j SNAT --to 10.0.0.99
iptables -t nat -A POSTROUTING -o swp1 -s 10.255.1.1/24  -j SNAT --to 10.0.0.99

echo "#################################"
echo "   Finished"
echo "#################################"
