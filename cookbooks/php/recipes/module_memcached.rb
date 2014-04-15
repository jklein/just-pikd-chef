#
# Author::  Scott Sandler (<scott.m.sandler@gmail.com>)
# Cookbook Name:: php
# Recipe:: module_memcached
#
# Copyright 2009-2011, Opscode, Inc.
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

configure_options = %w{ --disable-memcached-sasl }

version = node['php']['pecl-memcached']['version']

package 'libmemcached-dev' do
    action :install
  end

remote_file "#{Chef::Config[:file_cache_path]}/memcached-#{version}.tgz" do
  source "#{node['php']['pecl-url']}/memcached-#{version}.tgz"
  mode 0644
end

bash 'build pecl-memcached' do
  cwd Chef::Config[:file_cache_path]
  code <<-EOF
  tar -zxf memcached-#{version}.tgz
  (cd memcached-#{version} && phpize)
  (cd memcached-#{version} && ./configure --disable-memcached-sasl)
  (cd memcached-#{version} && make && make install)
  EOF
  not_if { ::File.exists?("/usr/local/lib/php/extensions/no-debug-non-zts-20121212/memcached.so") }
end

cookbook_file "#{node['php']['ext_conf_dir']}/memcached.ini" do
  source "memcached.ini"
  mode 0644
end
