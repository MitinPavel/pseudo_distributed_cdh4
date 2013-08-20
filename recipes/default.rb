bash "test_bash" do
  user "vagrant"
  cwd "/home/vagrant"
  code <<-CODE
    touch blah 
  CODE
end
