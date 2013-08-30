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

hadoop = "sudo -u #{hdfs_user} hadoop "

#TODO Isn't the resource redundant? 'execute "create /tmp/hadoop-yarn/staging/"' creates /tmp anyway.
execute "create /tmp/" do
  to_execute = [
      "fs -mkdir /tmp",
      "fs -chmod -R 1777 /tmp"
  ]
  command [hadoop, hadoop].zip(to_execute).map(&:join).join(' && ')
  user "root"
  action :run
  not_if { %x(#{hadoop} fs -test -e /tmp) and $?.success? }
end

execute "create /tmp/hadoop-yarn/staging/" do
  to_execute = [
    "fs -mkdir /tmp/hadoop-yarn/staging",
    "fs -chmod -R 1777 /tmp/hadoop-yarn/staging"
  ]
  command [hadoop, hadoop].zip(to_execute).map(&:join).join(' && ')
  user "root"
  action :run
  not_if { %x(#{hadoop} fs -test -e /tmp/hadoop-yarn/staging) and $?.success? }
end

execute "create /var/lib/hadoop-hdfs/cache/mapred/mapred/system/" do
  to_execute = [
    "fs -mkdir                  /var/lib/hadoop-hdfs/cache/mapred/mapred/system",
    "fs -chmod -R 1777          /var/lib/hadoop-hdfs/cache/mapred/mapred/system",
    "fs -chown -R mapred:mapred /var/lib/hadoop-hdfs/cache/mapred"
  ]
  command [hadoop, hadoop, hadoop].zip(to_execute).map(&:join).join(' && ')
  user "root"
  action :run
  not_if { %x(#{hadoop} fs -test -e /var/lib/hadoop-hdfs/cache/mapred/mapred/system) and $?.success? }
end

execute "create /tmp/hadoop-yarn/staging/history/done_intermediate/" do
  to_execute = [
    "fs -mkdir                  /tmp/hadoop-yarn/staging/history/done_intermediate",
    "fs -chmod -R 1777          /tmp/hadoop-yarn/staging/history/done_intermediate",
    "fs -chown -R mapred:mapred /tmp/hadoop-yarn/staging"
  ]
  command [hadoop, hadoop, hadoop].zip(to_execute).map(&:join).join(' && ')
  user "root"
  action :run
  not_if { %x(#{hadoop} fs -test -e /tmp/hadoop-yarn/staging/history/done_intermediate) and $?.success? }
end

execute "create /var/log/hadoop-yarn/" do
  to_execute = [
    "fs -mkdir /var/log/hadoop-yarn",
    "fs -chown yarn:mapred /var/log/hadoop-yarn"
  ]
  command [hadoop, hadoop].zip(to_execute).map(&:join).join(' && ')
  user "root"
  action :run
  not_if { %x(#{hadoop} fs -test -e /var/log/hadoop-yarn) and $?.success? }
end

%w(jobtracker tasktracker).each do |name|
  service "hadoop-0.20-mapreduce-#{name}" do
    action :start
  end
end
