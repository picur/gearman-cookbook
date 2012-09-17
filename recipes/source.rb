#
# Cookbook Name:: gearman
# Recipe:: source
#
# Copyright 2012, Botond Dani
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

packages = value_for_platform(
  %w{ debian ubuntu } => {
    :default => %w{ libboost-program-options-dev libboost-thread-dev libevent-dev libtokyocabinet8 uuid-dev libcloog-ppl0 }
  },
  %w{ centos redhat } => {
    :default => []
  }
)

remote_file "/tmp/gearmand-#{node['gearman']['source']['version']}.tar.gz" do
	source "#{node['gearman']['source']['remote_file']}"
	action :create_if_missing
	checksum "#{node['gearman']['source']['checksum']}"
end

packages.each do |pkg|
  package pkg
end

bash "install_gearmand" do
  user "root"
  cwd "/tmp"
  code <<-EOH
  tar xzf /tmp/gearmand-#{node['gearman']['source']['version']}.tar.gz
  cd /tmp/gearmand-#{node['gearman']['source']['version']}
  ./configure
  make
  make install
  EOH
  not_if "test -f /usr/local/sbin/gearmand"
end

user node['gearman']['server']['user'] do
  comment 'Gearman Job Server'
  home node['gearman']['server']['data_dir']
  shell '/bin/false'
  supports :manage_home => true
end

group node['gearman']['server']['group'] do
  members [node['gearman']['server']['user']]
end

directory node['gearman']['server']['log_dir'] do
  owner node['gearman']['server']['user']
  group node['gearman']['server']['group']
  mode '0775'
end

logrotate_app 'gearmand' do
  path "#{node['gearman']['server']['log_dir']}/*.log"
  frequency 'daily'
  rotate 4
  create "600 #{node['gearman']['server']['user']} #{node['gearman']['server']['group']}"
end

args = "--port=#{node['gearman']['server']['port']} --log-file #{node['gearman']['server']['log_dir']}/gearmand.log --verbose=#{node['gearman']['server']['log_level']}"

case node['platform']
when 'debian', 'ubuntu'
  template '/etc/init/gearmand.conf' do source 'gearmand.upstart.erb'
    owner 'root'
    group 'root'
    mode '0644'
    variables :args => args
    notifies :restart, 'service[gearmand]'
  end

  service 'gearmand' do
    provider Chef::Provider::Service::Upstart
    supports :restart => true, :status => true
    action [:enable, :start]
  end
when 'centos', 'redhat'
  include_recipe 'supervisor'
  supervisor_service 'gearmand' do
    start_command "/usr/sbin/gearmand #{args}"
    variables :user => node['gearman']['server']['user']
    supports :restart => true
    action [:enable, :start]
  end
end