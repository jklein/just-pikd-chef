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


cookbook_file "/etc/monit/monitrc" do
  source "monitrc"
  mode 0700
end

cookbook_file "/etc/monit/conf.d/justpikd" do
  source "justpikd-services.conf"
  mode 0700
end