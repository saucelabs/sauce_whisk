require 'rspec/core/rake_task'

Bundler::GemHelper.install_tasks

begin
  RSpec::Core::RakeTask.new(:spec)

  # If these are nil then the tests will fail
  ENV['SAUCE_USERNAME']   ||= 'test_user'
  ENV['SAUCE_ACCESS_KEY'] ||= 'test_key'

  task :default => :spec
rescue LoadError
  # No Rspec here
end