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

#install dependency since dpkg won't do it for us
package 'libmemcached10' do
    action :install
end

cookbook_file "/var/chef/pecl-memcached_2.2.0-1_amd64.deb" do
  source "pecl-memcached_2.2.0-1_amd64.deb"
  owner "root"
  group "root"
  mode "0444"
end

package 'pecl-memcached_2.2.0-1_amd64.deb' do
  provider Chef::Provider::Package::Dpkg
  source "/var/chef/pecl-memcached_2.2.0-1_amd64.deb"
  action :install
end
