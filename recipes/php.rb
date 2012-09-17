#
# Cookbook Name:: gearman
# Recipe:: php
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

include_recipe 'apache2'
include_recipe 'php'

execute "install-php-gearman" do
	command "pecl install channel://pecl.php.net/gearman-#{node['gearman']['php']['version']}"
	action :run
	not_if "test -f #{node['php']['ext_conf_dir']}/gearman.ini"
end

template "#{node['php']['ext_conf_dir']}/gearman.ini" do
	source "gearman.ini.erb"
	notifies :restart, "service[apache2]", :immediately
end