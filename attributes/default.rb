#
# Cookbook Name:: gearman
# Attributes:: default
#
# Copyright 2012, Cramer Development
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

default['gearman']['server']['user'] = 'gearman'
default['gearman']['server']['group'] = 'gearman'
default['gearman']['server']['port'] = 4730
default['gearman']['server']['log_dir'] = '/var/log/gearmand'
default['gearman']['server']['log_level'] = 'INFO'
default['gearman']['server']['data_dir'] = '/var/lib/gearman'

default['gearman']['source']['version'] = "1.1.0"
default['gearman']['source']['remote_file'] = "https://launchpad.net/gearmand/1.2/#{node['gearman']['source']['version']}/+download/gearmand-#{node['gearman']['source']['version']}.tar.gz"
default['gearman']['source']['checksum'] = "c2e04042181242a95dab47c88b96eef1"

default['gearman']['php']['version'] = "1.0.3"