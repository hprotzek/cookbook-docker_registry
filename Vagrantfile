# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure('2') do |config|
  config.vm.hostname = "dockerregistry"
  config.vm.box = "chef/ubuntu-14.04"
  config.omnibus.chef_version = 'latest'
  config.berkshelf.enabled = true

  config.vm.provision :chef_solo do |chef|
    chef.json = {
    }

    chef.run_list = [
        'recipe[docker_registry::install]',
        'recipe[docker_registry::webui]'
    ]
  end
end
