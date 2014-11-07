# -*- mode: ruby -*-
# # vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.vm.box     = 'trusty64'
  config.vm.box_url = 'https://cloud-images.ubuntu.com/vagrant/trusty/current/trusty-server-cloudimg-amd64-vagrant-disk1.box'
  config.vm.provider "virtualbox" do |v|
    v.memory = 12288
    v.cpus   = 2
    v.name   = "JGI Docker Workshop VM"
  end
end
