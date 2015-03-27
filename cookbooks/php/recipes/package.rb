#
# Author::  Seth Chisamore (<schisamo@opscode.com>)
# Author::  Lucas Hansen (<lucash@opscode.com>)
# Cookbook Name:: php
# Recipe:: package
#
# Copyright 2013, Opscode, Inc.
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

#install dependencies manually, since dpkg doesn't have a good way to do this for you
pkgs = %w{
  libcurl3-gnutls
  libcurl3
  libfreetype6
  libgmp10
  libmcrypt4
  libmhash2
  openssl
  bzip2
  libjpeg8
  libpcre3
  tzdata
  libqdbm14
  libonig2
  libc6
  libc-client2007e
  libt1-5
}

pkgs.each do |pkg|
  package pkg do
    action :install
  end
end

deb_name = "php5_#{node['php']['version']}_all.deb"

# This is the hash from the "direct" url in Box.net
box_hash = "26q13gra5thbtmvbf59ss1eu6lssi5hp"

bash "Download and move the PHP deb so we can install it" do
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
end

include_recipe "php::ini"
