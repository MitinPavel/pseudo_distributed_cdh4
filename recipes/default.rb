hdfs_user = "hdfs"
mapred_user = "mapred"

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

%w(datanode namenode secondarynamenode).each do |node|
  execute "start hdfs #{node}" do
    command "service hadoop-hdfs-#{node} start"
    user "root"
    action :run
    not_if { `sudo jps`.match(/#{node}/i) }
  end
end

hadoop = "sudo -u #{hdfs_user} hadoop "

execute "create tmp dir" do
  to_execute = [
      "fs -mkdir /tmp",
      "fs -chmod -R 1777 /tmp"
  ]
  command [hadoop, hadoop].zip(to_execute).map(&:join).join(' && ')
  user "root"
  action :run
  only_if { `#{hadoop} fs -ls /tmp` == '' }
end

execute "create staging dir" do
  to_execute = [
    "fs -mkdir /tmp/hadoop-yarn/staging",
    "fs -chmod -R 1777 /tmp/hadoop-yarn/staging"
  ]
  command [hadoop, hadoop].zip(to_execute).map(&:join).join(' && ')
  user "root"
  action :run
  only_if { `#{hadoop} fs -ls /tmp/hadoop-yarn` == '' &&  `#{hadoop} fs -ls /tmp/hadoop-yarn/staging` == '' }
end

execute "create done_intermediate dir" do
  to_execute = [
      "fs -mkdir                  /tmp/hadoop-yarn/staging/history/done_intermediate",
      "fs -chmod -R 1777          /tmp/hadoop-yarn/staging/history/done_intermediate",
      "fs -chown -R mapred:mapred /tmp/hadoop-yarn/staging"
  ]
  command [hadoop, hadoop, hadoop].zip(to_execute).map(&:join).join(' && ')
  user "root"
  action :run
  only_if do
    `#{hadoop} fs -ls /tmp/hadoop-yarn/staging/history` == '' &&
    `#{hadoop} fs -ls /tmp/hadoop-yarn/staging/history/done_intermediate` == ''
  end
end

execute "create /var/log/hadoop-yarn dir" do
  to_execute = [
      "fs -mkdir /var/log/hadoop-yarn",
      "fs -chown yarn:mapred /var/log/hadoop-yarn"
  ]
  command [hadoop, hadoop].zip(to_execute).map(&:join).join(' && ')
  user "root"
  action :run
  only_if { `#{hadoop} fs -ls /var/log/hadoop-yarn` == '' }
end
