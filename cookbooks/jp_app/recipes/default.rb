#
# Cookbook Name:: jp_app
# Recipe:: default
#
# Copyright 2014, Just Pikd
#
# All rights reserved - Do Not Redistribute
#

cookbook_file "/root/postgres_setup.sql" do
  source "postgres_setup.sql"
  mode 0600
end

# Run apt-get update to create the stamp file
execute 'set up postgres' do
  command 'export PGPASSWORD="justpikd"; psql -h localhost -U postgres -f /root/postgres_setup.sql'
  user 'root'
end