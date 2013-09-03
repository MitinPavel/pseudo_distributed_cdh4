action :create do
  hadoop = "sudo -u #{new_resource.hadoop_user} hadoop "

  to_execute = ["fs -mkdir #{new_resource.dir_name}"]
  to_execute << "fs -chmod -R #{new_resource.chmod} #{new_resource.dir_name}" unless new_resource.chmod.nil?
  to_execute << "fs -chown #{new_resource.chown} #{new_resource.dir_name}" unless new_resource.chown.nil?
  to_execute_str = Array.new(to_execute.size, hadoop).zip(to_execute).map(&:join).join(' && ')

  execute "create #{new_resource.dir_name} dir" do
    command to_execute_str
    user "root"
    action :run
    not_if { %x(#{hadoop} fs -test -e #{new_resource.dir_name}) and $?.success? }
  end
end
