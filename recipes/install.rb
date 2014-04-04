#
# Author:: Nielsen Pierce
# Cookbook Name:: rackspace_wwpt
#
# Recipe:: install
#
# Copyright 2014, Rackspace UK, Inc.
#
# All rights reserved - Do Not Redistribute
#

if platform?('windows')

  windows_package node['rackspace_wwpt']['msi_package_name'] do
    source node['rackspace_wwpt']['url']
    checksum node['rackspace_wwpt']['checksum']
    installer_type :custom
    options '/q'
    action :install
  end

  batch 'configure_tentacle_agent' do
    cwd '#{node['rackspace_wwpt']['install_dir']}'
    code <<-EOH
       tentacle.exe create-instance --instance "Tentacle" --config "#{node['rackspace_wwpt']['home']}\\Tentacle\\Tentacle.config" --console
       tentacle.exe new-certificate --instance "Tentacle" --console
       tentacle.exe configure --instance "Tentacle" --home #{node['rackspace_wwpt']['home']} --console
       tentacle.exe configure --instance "Tentacle" --app #{node['rackspace_wwpt']['app']} --console
       tentacle.exe configure --instance "Tentacle" --port #{node['rackspace_wwpt']['port']} --console
       tentacle.exe register-with --instance "Tentacle" --server #{node['rackspace_wwpt']['server']} --environment #{node['rackspace_wwpt']['env']} --role #{node['rackspace_wwpt']['role']} --publicHostname=#{node['ipaddress']} --apikey=#{node['rackspace_wwpt']['apikey_value']} --comms-style #{node['rackspace_wwpt']['style']} --force --console
       tentacle.exe service --instance "Tentacle" --install --start --console
       tentacle.exe service --instance "Tentacle" --stop --console
       tentacle.exe service --instance "Tentacle" --start --console
     EOH
  end

else
  Chef::Log.warn('Octopus Deploy can only be installed on Windows using this cookbook.')
end
