deb_file_name = "cdh4-repository_1.0_all.deb"

execute 'download CDH4 package' do
  command "wget http://archive.cloudera.com/cdh4/one-click-install/precise/amd64/#{deb_file_name}"
  cwd "/tmp"
  action :run
  not_if { ::File.exists?("/tmp/#{deb_file_name}")}
end

dpkg_package 'cdh4-repository' do
  source "/tmp/#{deb_file_name}"
  action :install
end

execute "apt-get update" do
  command "apt-get update"
end

package "hadoop-0.20-conf-pseudo"

user "hdfs" do
  supports :manage_home => true
  gid "hdfs"
end

directory "/var/lib/hadoop-hdfs/cache/hdfs/dfs/name" do
  owner "hdfs"
  group "hdfs"
  mode 0775
  recursive true
  action :create
end

execute "format namenode" do
  command "hdfs namenode -format"
  user "hdfs"
  action :run
end
