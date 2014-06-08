#
# Cookbook Name:: jp_app
# Recipe:: default
#
# Copyright 2014, Just Pikd
#
# All rights reserved - Do Not Redistribute
#

cookbook_file "/root/postgres_setup.php" do
  source "postgres_setup.php"
  mode 0600
end

execute 'set up postgres' do
  command 'php -f /root/postgres_setup.php'
  user 'root'
end

# Create a log file
file "/var/log/testlog.log" do
  owner "root"
  group "root"
  mode "0777"
  action :create
end