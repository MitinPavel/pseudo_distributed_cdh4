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

namenode_dir =      "/var/lib/hadoop-hdfs/cache/hdfs/dfs/name"
namesecondary_dir = "/var/lib/hadoop-hdfs/cache/hdfs/dfs/namesecondary"
data_dir =          "/var/lib/hadoop-hdfs/cache/hdfs/dfs/data"
[namenode_dir, namesecondary_dir, data_dir].each do |dir|
  directory dir do
    owner "hdfs"
    group "hdfs"
    mode 0775
    recursive true
    action :create
  end
end

execute "format namenode" do
  command "hdfs namenode -format"
  user "hdfs"
  action :run
  only_if { ::Dir["#{namenode_dir}/*"].empty? }
end

%w(datanode namenode secondarynamenode).each do |node|
  execute "start hdfs #{node}" do
    command "service hadoop-hdfs-#{node} start"
    user "root"
    action :run
    #only_if { `pidof hadoop-hdfs-#{node}` == '' }
  end
end

