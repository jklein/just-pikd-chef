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

cookbook_file "/root/postgres_product.sql" do
  source "postgres_product.sql"
  mode 0600
end

execute 'set up postgres' do
  command 'export PGPASSWORD="justpikd"; psql -h localhost -U postgres -f /root/postgres_setup.sql'
  user 'root'
end

execute 'postgres product' do
  command 'export PGPASSWORD="justpikd"; psql -h localhost -U postgres -d product -f /root/postgres_product.sql'
  user 'root'
end