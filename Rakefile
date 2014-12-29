require 'bundler/gem_tasks'
begin
  require 'rspec/core/rake_task'
  RSpec::Core::RakeTask.new(:spec)
  task :default => :spec
rescue LoadError
  puts "Couldn't find RSpec, please install bundle:\n  $ bundle\n\n"
end

