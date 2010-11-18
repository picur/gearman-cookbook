#
# Author:: Joshua Timberman (<joshua@opscode.com>)
# Cookbook Name:: database
# Recipe:: master
#
# Copyright 2009-2010, Opscode, Inc.
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
# This is potentially destructive to the nodes mysql password attributes, since
# we iterate over all the app databags. If this database server provides
# databases for multiple applications, the last app found in the databags
# will win out, so make sure the databags have the same passwords set for
# the root, repl, and debian-sys-maint users.
#

include_recipe "mysql::server"

db_info = Hash.new
root_pw = String.new

search(:apps) do |app|
  (app['database_master_role'] & node.run_list.roles).each do |dbm_role|
    app['databases'].each do |env,db|
      db_info[env] = db
    end
  end
end


grants_path = value_for_platform(
  ["centos", "redhat", "suse", "fedora" ] => {
    "default" => "/etc/mysql_app_grants.sql"
  },
  "default" => "/etc/mysql/app_grants.sql"
)

template "/etc/mysql/app_grants.sql" do
  path grants_path
  source "app_grants.sql.erb"
  cookbook 
  owner "root"
  group "root"
  mode "0600"
  action :create
  variables :db_info => db_info
end

execute "mysql-install-application-privileges" do
  command "/usr/bin/mysql -u root #{node[:mysql][:server_root_password].empty? ? '' : '-p' }#{node[:mysql][:server_root_password]} < #{grants_path}"
  action :nothing
  subscribes :run, resources(:template => "/etc/mysql/app_grants.sql"), :immediately
end

Gem.clear_paths
require 'mysql'

search(:apps) do |app|
  (app['database_master_role'] & node.run_list.roles).each do |dbm_role|
    app['databases'].each do |env,db|
      if env =~ /#{node[:app_environment]}/
        root_pw = node["mysql"]["server_root_password"]
        mysql_database "create #{db['database']}" do
          host "localhost"
          username "root"
          password root_pw
          database db['database']
          action [:create_db]
        end
      end
    end
  end
end