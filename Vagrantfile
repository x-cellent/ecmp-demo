# Created by Topology-Converter v4.6.9
# Set the default provider to libvirt in the case they forget --provider=libvirt or if someone destroys a machine it reverts to virtualbox
ENV['VAGRANT_DEFAULT_PROVIDER'] = 'libvirt'

# Check required plugins
REQUIRED_PLUGINS_LIBVIRT = %w(vagrant-libvirt)
exit unless REQUIRED_PLUGINS_LIBVIRT.all? do |plugin|
  Vagrant.has_plugin?(plugin) || (
    puts "The #{plugin} plugin is required. Please install it with:"
    puts "$ vagrant plugin install #{plugin}"
    false
  )
end

Vagrant.require_version ">= 2.0.2"
Vagrant.configure("2") do |config|
  wbid = 1
  offset = wbid * 100
  device.vm.synced_folder ".", "/vagrant", disabled: true
  config.vm.provider :libvirt do |domain|
    domain.management_network_address = "10.255.#{wbid}.0/24"
    domain.management_network_name = "wbr#{wbid}"
    # increase nic adapter count to be greater than 8 for all VMs.
    domain.nic_adapter_count = 130
  end

  ##### DEFINE VM for leaf #####
  config.vm.define "leaf" do |device|
    device.vm.hostname = "leaf" 
    device.vm.box = "CumulusCommunity/cumulus-vx"
    device.vm.box_version = "3.7.2"
    device.vm.provider :libvirt do |v|
      v.memory = 768
    end

    # NETWORK INTERFACES
    # link for swp1 --> server01:eth1
    device.vm.network "private_network",
      :mac => "44:38:39:00:00:01",
      :libvirt__tunnel_type => 'udp',
      :libvirt__tunnel_local_ip => '127.0.0.1',
      :libvirt__tunnel_local_port => "#{ 9001 + offset }",
      :libvirt__tunnel_ip => '127.0.0.1',
      :libvirt__tunnel_port => "#{ 8001 + offset }",
      :libvirt__iface_name => 'swp1',
      auto_config: false
    
    # link for swp2 --> server02:eth1
    device.vm.network "private_network",
      :mac => "44:38:39:00:00:02",
      :libvirt__tunnel_type => 'udp',
      :libvirt__tunnel_local_ip => '127.0.0.1',
      :libvirt__tunnel_local_port => "#{ 9002 + offset }",
      :libvirt__tunnel_ip => '127.0.0.1',
      :libvirt__tunnel_port => "#{ 8002 + offset }",
      :libvirt__iface_name => 'swp2',
      auto_config: false

    # Fixes "stdin: is not a tty" and "mesg: ttyname failed : Inappropriate ioctl for device"  messages --> https://github.com/mitchellh/vagrant/issues/1673
    device.vm.provision :shell , inline: "(sudo grep -q 'mesg n' /root/.profile 2>/dev/null && sudo sed -i '/mesg n/d' /root/.profile  2>/dev/null) || true;", privileged: false
    device.vm.provision :shell , privileged: false, :inline => 'echo "$(whoami)" > /tmp/normal_user'
    device.vm.provision :shell , path: "./helper_scripts/config_switch.sh"
  end

  ##### DEFINE VM for server01 #####
  config.vm.define "server01" do |device|
    device.vm.hostname = "server01" 
    device.vm.box = "generic/ubuntu1804"
    device.vm.provider :libvirt do |v|
      v.nic_model_type = 'e1000' 
      v.memory = 512
    end
    # NETWORK INTERFACES
    # link for eth1 --> leaf01:swp1
    device.vm.network "private_network",
      :mac => "00:03:00:11:11:01",
      :libvirt__tunnel_type => 'udp',
      :libvirt__tunnel_local_ip => '127.0.0.1',
      :libvirt__tunnel_local_port => "#{ 8001 + offset }",
      :libvirt__tunnel_ip => '127.0.0.1',
      :libvirt__tunnel_port => "#{ 9001 + offset }",
      :libvirt__iface_name => 'eth1',
      auto_config: false

    # Fixes "stdin: is not a tty" and "mesg: ttyname failed : Inappropriate ioctl for device"  messages --> https://github.com/mitchellh/vagrant/issues/1673
    device.vm.provision :shell , inline: "(sudo grep -q 'mesg n' /root/.profile 2>/dev/null && sudo sed -i '/mesg n/d' /root/.profile  2>/dev/null) || true;", privileged: false
    device.vm.provision :shell , privileged: false, :inline => 'echo "$(whoami)" > /tmp/normal_user'
    device.vm.provision :shell , path: "./helper_scripts/config_server.sh",
    env: {
        "SERVER_ID" => "1"
    }
  end

  ##### DEFINE VM for server02 #####
  config.vm.define "server02" do |device|
    device.vm.hostname = "server02" 
    device.vm.box = "generic/ubuntu1804"
    device.vm.provider :libvirt do |v|
      v.nic_model_type = 'e1000' 
      v.memory = 512
    end
    # NETWORK INTERFACES
    # link for eth1 --> leaf01:swp2
    device.vm.network "private_network",
      :mac => "00:03:00:22:22:01",
      :libvirt__tunnel_type => 'udp',
      :libvirt__tunnel_local_ip => '127.0.0.1',
      :libvirt__tunnel_local_port => "#{ 8002 + offset }",
      :libvirt__tunnel_ip => '127.0.0.1',
      :libvirt__tunnel_port => "#{ 9002 + offset }",
      :libvirt__iface_name => 'eth1',
      auto_config: false

    # Fixes "stdin: is not a tty" and "mesg: ttyname failed : Inappropriate ioctl for device"  messages --> https://github.com/mitchellh/vagrant/issues/1673
    device.vm.provision :shell , inline: "(sudo grep -q 'mesg n' /root/.profile 2>/dev/null && sudo sed -i '/mesg n/d' /root/.profile  2>/dev/null) || true;", privileged: false
    device.vm.provision :shell , privileged: false, :inline => 'echo "$(whoami)" > /tmp/normal_user'
    device.vm.provision :shell , path: "./helper_scripts/config_server.sh",
    env: {
        "SERVER_ID" => "2"
    }
  end
end