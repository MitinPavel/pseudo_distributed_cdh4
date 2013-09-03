actions :create

default_action :create

attribute :dir_name, :kind_of => String
attribute :hadoop_user, :kind_of => String
attribute :chmod, :kind_of => String, :regex => /\A[01]*[0-7]{3}\z/
attribute :chown, :kind_of => String, :regex => /\A[^:]+\:[^:]+\z/
