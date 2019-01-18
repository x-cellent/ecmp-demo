#!/usr/bin/env bash

sudo apt install python-pip
sudo pip install --upgrade pip
sudo pip install setuptools
sudo pip install pydotplus
sudo pip install jinja2
sudo pip install ipaddress

wget https://raw.githubusercontent.com/CumulusNetworks/topology_converter/master/topology_converter.py
mkdir ./templates/
wget -O ./templates/Vagrantfile.j2 https://raw.githubusercontent.com/CumulusNetworks/topology_converter/master/templates/Vagrantfile.j2
wget https://github.com/CumulusNetworks/cldemo-vagrant/blob/master/topology.dot

# Anpassungen dot file

git clone https://github.com/CumulusNetworks/cldemo-vagrant
cp -R cldemo-vagrant/helper_scripts .

python topology_converter.py --provider=libvirt topology.dot


server01
wget https://github.com/osrg/gobgp/releases/download/v2.0.0/gobgp_2.0.0_linux_amd64.tar.gz
tar xzvf wget gobgp_2.0.0_linux_amd64.tar.gz

/etc/init.d/networking restart
./gobgpd -d -f config.toml
