#!/bin/bash

set -ex

FRR_VERSION=6.0
FRR_DOWNLOAD=https://github.com/FRRouting/frr/releases/download

# Install FRR
curl -fLsO ${FRR_DOWNLOAD}/frr-${FRR_VERSION}/frr_${FRR_VERSION}-1.ubuntu18.04+1_amd64.deb
apt install -y ./frr_${FRR_VERSION}-1.ubuntu18.04+1_amd64.deb

# Enable BGP and Zebra daemons of FRR
cat << EOT > /etc/frr/daemons
bgpd=yes
zebra=yes
EOT

cat << EOT > /etc/frr/vtysh.conf
service integrated-vtysh-config
username cumulus nopassword
EOT

cat << EOT > /etc/frr/frr.conf
frr version 5.0
frr defaults traditional
log syslog debugging
service integrated-vtysh-config
!
router bgp 65001
  bgp router-id 10.0.0.${SERVER_ID}
  neighbor TOR peer-group
  neighbor TOR remote-as external
  neighbor eth1 interface peer-group TOR
  address-family ipv4 unicast
    neighbor TOR activate
    redistribute connected
  exit-address-family
!
EOT

# Interfaces-Configuration
cat << EOT > /etc/network/interfaces
auto lo
iface lo inet static
  address 10.0.0.${SERVER_ID}/32
  address 10.0.0.50/32

auto eth0
iface eth0 inet dhcp

auto eth1
iface eth1 inet6 auto
  ipv6 nd ra-interval 6

EOT
apt install -y ifupdown
ip addr add 10.0.0.${SERVER_ID}/32 dev lo
ip addr add 10.0.0.50/32 dev lo
ifup eth1

# Sysctl-Settings recommended for FRR
cat << EOT > /etc/sysctl.d/99-frr.conf
# /etc/sysctl.d/99frr_defaults.conf
# Place this file at the location above and reload the device.
# or run the sysctl -p /etc/sysctl.d/99frr_defaults.conf

# Enables IPv4/IPv6 Routing
net.ipv4.ip_forward = 1
net.ipv6.conf.all.forwarding=1

# Routing
net.ipv6.route.max_size=131072
net.ipv4.conf.all.ignore_routes_with_linkdown=1
net.ipv6.conf.all.ignore_routes_with_linkdown=1

# Best Settings for Peering w/ BGP Unnumbered
#    and OSPF Neighbors
net.ipv4.conf.all.rp_filter = 0
net.ipv4.conf.default.rp_filter = 0
net.ipv4.conf.lo.rp_filter = 0
net.ipv4.conf.all.forwarding = 1
net.ipv4.conf.default.forwarding = 1
net.ipv4.conf.default.arp_announce = 2
net.ipv4.conf.default.arp_notify = 1
net.ipv4.conf.default.arp_ignore=1
net.ipv4.conf.all.arp_announce = 2
net.ipv4.conf.all.arp_notify = 1
net.ipv4.conf.all.arp_ignore=1
net.ipv4.icmp_errors_use_inbound_ifaddr=1

# Miscellaneous Settings
#   Keep ipv6 permanent addresses on an admin down
net.ipv6.conf.all.keep_addr_on_down=1

# igmp
net.ipv4.igmp_max_memberships=1000
net.ipv4.neigh.default.mcast_solicit = 10

# MLD
net.ipv6.mld_max_msf=512

# Garbage Collection Settings for ARP and Neighbors
net.ipv4.neigh.default.gc_thresh2=7168
net.ipv4.neigh.default.gc_thresh3=8192
net.ipv4.neigh.default.base_reachable_time_ms=14400000
net.ipv6.neigh.default.gc_thresh2=3584
net.ipv6.neigh.default.gc_thresh3=4096
net.ipv6.neigh.default.base_reachable_time_ms=14400000

# Use neigh information on selection of nexthop for multipath hops
net.ipv4.fib_multipath_use_neigh=1

# Allows Apps to Work with VRF
net.ipv4.tcp_l3mdev_accept=1
EOT

sysctl -p /etc/sysctl.d/99-frr.conf
systemctl start frr

# Fix to have a IPv6 Link-Local-Address at eth1
sysctl -w net.ipv6.conf.eth1.disable_ipv6=0

apt update
apt install -y docker.io
docker pull nginx

echo "${SERVER_ID}" > index.html
docker run -d -p 8080:80 -v $PWD/index.html:/usr/share/nginx/html/index.html nginx                                                       

# delete default route to vagrant bridge
sudo ip route del default via 10.255.1.1 dev eth0
