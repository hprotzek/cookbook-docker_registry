# Encoding: utf-8
# Cookbook Name:: docker_registry
# Provider:: config
# Copyright 2014, Paul Czarkowski
# License:: Apache 2.0

require 'chef/mixin/shell_out'
require 'chef/mixin/language'
include Chef::Mixin::ShellOut

def load_current_resource
  new_resource.clone
end

action :remove do
  dr = registry_resources
  %w(config.yml config.env).each do |file|
    dr_dir = file "#{dr[:path]}/#{file}" do
      action :delete
    end
    new_resource.updated_by_last_action(dr_dir.updated_by_last_action?)
  end
end

action :create do
  dr = registry_resources
  Chef::Log.info("creating config files at #{dr[:path]}")

  dir = directory "#{dr[:path]}/config" do
    owner dr[:user]
    group dr[:group]
    recursive true
    mode '0755'
    action :create
  end
  new_resource.updated_by_last_action(dir.updated_by_last_action?)

  case dr[:install_type]
  when 'pip'
    tpl = template "#{dr[:path]}/config/config.yml" do
      source "#{dr[:storage_driver]}_config.yml.erb"
      cookbook dr[:template_cookbook]
      group dr[:group]
      owner dr[:user]
      mode '0600'
      variables registry: dr
      action :create
    end
    new_resource.updated_by_last_action(tpl.updated_by_last_action?)

    tpl = template "#{dr[:path]}/config/config.env" do
      source 'config.env.erb'
      cookbook dr[:template_cookbook]
      group dr[:group]
      owner dr[:user]
      mode '0700'
      variables registry: dr, config: "#{dr[:path]}/config/config.yml"
      action :create
    end
    new_resource.updated_by_last_action(tpl.updated_by_last_action?)
  when 'docker'
    tpl = template "#{dr[:path]}/config/#{dr[:name]}.env" do
      source 'config_docker.env.erb'
      cookbook dr[:template_cookbook]
      group dr[:group]
      owner dr[:user]
      mode '0700'
      variables registry: dr
      action :create
    end
    new_resource.updated_by_last_action(tpl.updated_by_last_action?)
  end
end

private

def registry_resources
  storage_driver_options = new_resource.storage_driver_options || node[:docker_registry]["#{new_resource.storage_driver}_options"]
  registry = {
    path: new_resource.path,
    name: new_resource.name,
    user: new_resource.user,
    group: new_resource.group,
    listen_ip: new_resource.listen_ip,
    listen_port: new_resource.listen_port,
    template_cookbook: new_resource.template_cookbook,
    storage_driver: new_resource.storage_driver,
    install_type: new_resource.install_type,
    storage_driver_options: storage_driver_options
  }
  registry
end
