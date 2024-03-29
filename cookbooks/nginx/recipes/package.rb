#
# Cookbook Name:: nginx
# Recipe:: package
# Author:: AJ Christensen <aj@junglist.gen.nz>
#
# Copyright 2008-2013, Opscode, Inc.
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

include_recipe 'nginx::ohai_plugin'

#install dependencies manually, since dpkg doesn't have a good way to do this for you
pkgs = %w{
  libc6
  libpcre3
  libssl1.0.0
  zlib1g
  lsb-base
  adduser
}

pkgs.each do |pkg|
  package pkg do
    action :install
  end
end

deb_name = "nginx_#{node['nginx']['version']}-1~trusty_amd64.deb"

# This is the hash from the "direct" url in Box.net
box_hash = "orleu5l1m756zib2w0pr67ff11qgfuut"

bash "Download and move the nginx deb so we can install it" do
  code <<-EOH
    cd /tmp
    wget https://g2gmarketinc.box.com/shared/static/#{box_hash}.deb
    cp /tmp/#{box_hash}.deb /var/chef/#{deb_name}
  EOH
  not_if { ::File.exists?("/tmp/#{box_hash}.deb") }
end

package "#{deb_name}" do
  provider Chef::Provider::Package::Dpkg
  source "/var/chef/#{deb_name}"
  action :install
  notifies :reload, 'ohai[reload_nginx]', :immediately
end

#delete default.conf if it exists
file '/etc/nginx/conf.d/default.conf' do
  action :delete
end

service 'nginx' do
  supports :status => true, :restart => true, :reload => true
  action   :enable
end

include_recipe 'nginx::commons'
