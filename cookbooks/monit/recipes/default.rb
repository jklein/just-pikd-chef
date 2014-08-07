#
# Cookbook Name:: monit
# Recipe:: default
#
# Copyright 2014, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#


package 'monit' do
    action :install
end

# Get the global configuration
cookbook_file "/etc/monit/monitrc" do
  source "monitrc"
  mode 0700
end

# Get our services config
cookbook_file "/etc/monit/conf.d/justpikd-services.conf" do
  source "justpikd-services.conf"
  mode 0700
end

# Start the monit service
service "monit" do
  supports restart: true, start: true, reload: true
  action [:enable, :start]

  start_command   "service monit start"
  restart_command "service monit restart"
  reload_command  "service monit reload"
end