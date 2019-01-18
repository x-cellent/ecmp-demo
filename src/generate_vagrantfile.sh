#!/usr/bin/env bash

set -ex

sudo apt install python-pip
sudo pip install --upgrade pip
sudo pip install setuptools pydotplus jinja2 ipaddress

git clone https://github.com/CumulusNetworks/cldemo-vagrant
cp -R cldemo-vagrant/helper_scripts .

python topology_converter.py --provider=libvirt topology.dot
