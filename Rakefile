require "bundler/gem_tasks"
require "rake/testtask"

Bundler::GemHelper.install_tasks

task :default => :test
Rake::TestTask.new do |t|
  t.test_files = FileList['spec/lib/*_spec.rb']
  t.test_files = FileList['spec/*_spec.rb']
end
