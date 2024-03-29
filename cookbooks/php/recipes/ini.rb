#
# Author::  Christo De Lange (<opscode@dldinternet.com>)
# Cookbook Name:: php
# Recipe:: ini
#
# Copyright 2011, Opscode, Inc.
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

directory '/etc/php5' do
    owner 'root'
    group 'root'
    mode '0755'
end

directory '/etc/php5/cli' do
    owner 'root'
    group 'root'
    mode '0755'
end

directory '/etc/php5/conf.d' do
    owner 'root'
    group 'root'
    mode '0755'
end

template "#{node['php']['conf_dir']}/php.ini" do
	source node['php']['ini']['template']
	cookbook node['php']['ini']['cookbook']
	unless platform?('windows')
		owner 'root'
		group 'root'
		mode '0644'
	end
	variables(:directives => node['php']['directives'])
end

cookbook_file '/etc/php5/conf.d/php-fpm.conf' do
  source 'php-fpm.conf'
  mode 0644
end

cookbook_file '/etc/init.d/php-fpm' do
  source 'php-fpm'
  mode 0755
end
