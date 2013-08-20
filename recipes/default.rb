# http://archive.cloudera.com/cdh4/one-click-install/precise/amd64/cdh4-repository_1.0_all.deb

execute 'download CDH4 package' do
  command 'wget http://archive.cloudera.com/cdh4/one-click-install/precise/amd64/cdh4-repository_1.0_all.deb'
  cwd '/tmp'
  action :run
end

dpkg_package 'cdh4-repository' do
  source '/tmp/cdh4-repository_1.0_all.deb'
  action :install
end

