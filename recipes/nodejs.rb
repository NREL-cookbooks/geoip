#
# Cookbook Name:: geoip
# Recipe:: nodejs
#
# Copyright 2013, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

include_recipe "git"
include_recipe "nodejs"

user "geoip" do
  system true
  shell "/bin/false"
end

directory "/opt/geoip-lite" do
  recursive true
  owner "geoip"
  group "root"
  mode "0755"
  action :create
end

git "geoip-lite" do
  destination "/opt/geoip-lite"
  repository "https://github.com/GUI/node-geoip.git"
  user "geoip"
  notifies :run, "execute[geoip_lite_npm_install]"
  notifies :run, "execute[geoip_lite_updatedb]"
end

execute "geoip_lite_npm_install" do
  cwd "/opt/geoip-lite"
  command "#{node[:nodejs][:dir]}/bin/npm install"
  user "root"

  if File.exists?("/opt/geoip-lite/node_modules")
    action :nothing
  else
    action :run
  end
end

execute "geoip_lite_updatedb" do
  cwd "/opt/geoip-lite"
  command "#{node[:nodejs][:dir]}/bin/npm run-script updatedb"
  user "geoip"
  action :nothing
end

template "/etc/cron.d/geoip_lite_updatedb" do
  source "cron_updatedb.erb"
  mode "0644"
  owner "root"
  group "root"
end
