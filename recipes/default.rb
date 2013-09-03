hdfs_user = "hdfs"
mapred_user = "mapred"

deb_file_name = "cdh4-repository_1.0_all.deb"

remote_file "/tmp/#{deb_file_name}" do
  source "http://archive.cloudera.com/cdh4/one-click-install/precise/amd64/#{deb_file_name}"
  action :create_if_missing
end

dpkg_package 'cdh4-repository' do
  source "/tmp/#{deb_file_name}"
  action :install
end

execute "apt-get update" do
  command "apt-get update"
end

package "hadoop-0.20-conf-pseudo"

user hdfs_user do
  supports :manage_home => true
  gid hdfs_user
end

user mapred_user do
  supports :manage_home => true
  gid mapred_user
end

namenode_dir =      "/var/lib/hadoop-hdfs/cache/hdfs/dfs/name"
namesecondary_dir = "/var/lib/hadoop-hdfs/cache/hdfs/dfs/namesecondary"
data_dir =          "/var/lib/hadoop-hdfs/cache/hdfs/dfs/data"
[namenode_dir, namesecondary_dir, data_dir].each do |dir|
  directory dir do
    owner hdfs_user
    group "hdfs"
    mode 0775
    recursive true
    action :create
  end
end

execute "format namenode" do
  command "hdfs namenode -format"
  user hdfs_user
  action :run
  only_if { ::Dir["#{namenode_dir}/*"].empty? }
end

%w(datanode namenode secondarynamenode).each do |name|
  service "hadoop-hdfs-#{name}" do
    action :start
  end
end

%w(/tmp/hadoop-yarn/staging
   /var/lib/hadoop-hdfs/cache/mapred/mapred/system
   /tmp/hadoop-yarn/staging/history/done_intermediate
   /var/log/hadoop-yarn).each do |dir|
  pseudo_distributed_cdh4_hdfs_dir "create #{dir}" do
    dir_name dir
    hadoop_user hdfs_user
    chmod "1777"
  end
end

[
  ["mapred:mapred", "/var/lib/hadoop-hdfs/cache/mapred/mapred/system/"],
  ["mapred:mapred", "/tmp/hadoop-yarn/staging/"],
  ["yarn:mapred",   "/var/log/hadoop-yarn/"]
].each do |user_and_group, dir|
  execute "chown #{dir}" do
    command "sudo -u #{hdfs_user} hadoop fs -chown -R #{user_and_group} #{dir}"
    user "root"
    action :run
  end
end

%w(jobtracker tasktracker).each do |name|
  service "hadoop-0.20-mapreduce-#{name}" do
    action :start
  end
end
