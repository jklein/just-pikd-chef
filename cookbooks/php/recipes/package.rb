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

php_version = "5.6.5-1"

cookbook_file "/var/chef/php5_#{php_version}_all.deb" do
  source "php5_#{php_version}_all.deb"
  owner "root"
  group "root"
  mode "0444"
end

package "php5_#{php_version}_all.deb" do
  provider Chef::Provider::Package::Dpkg
  source "/var/chef/php5_#{php_version}_all.deb"
  action :install
end

include_recipe "php::ini"
