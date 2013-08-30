require 'rubygems'

require 'bundler'
Bundler.setup

require 'rake'
require 'rspec/core/rake_task'

task :default => [:spec]

RSpec::Core::RakeTask.new(:spec) do |t|
  t.pattern = "./specs{,/*/**}/*_spec.rb"
end
