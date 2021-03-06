# Encoding: utf-8
#
# Cookbook Name:: docker_registry
# Recipe:: install
#
# Copyright 2014, Paul Czarkowski
#

include_recipe 'docker::default'

docker_registry_instance 'registry' do
  version 'latest'
  docker_image 'registry'
end

docker_registry_config 'registry' do
  version 'latest'
end

docker_registry_service 'registry' do
  version 'latest'
  subscribes :restart, 'docker_registry_config[registry]', :delayed
  action [:enable, :start]
end
