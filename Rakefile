require 'open3'

require 'bundler'
require 'bundler/gem_tasks'

begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts 'Run `bundle install` to install missing gems'
  exit e.status_code
end

require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec) do |spec|
  spec.pattern = FileList['spec/**/*_spec.rb']
end

desc 'Run RSpec with code coverage'
task :coverage do
  ENV['COVERAGE'] = 'true'
  Rake::Task['spec'].execute

  sh('codeclimate-test-reporter') if ENV['CI']
end

desc 'Run RuboCop over this gem'
task :internal_investigation do
  sh('bundle exec rubocop --require rubocop-rspec')
end

desc 'Build config/default.yml'
task :build_config do
  sh('bin/build_config')
end

desc 'Confirm config/default.yml is up to date'
task confirm_config: :build_config do
  _, stdout, _, process =
    Open3.popen3('git diff --exit-code config/default.yml')

  unless process.value.success?
    raise "default.yml is out of sync:\n\n#{stdout.read}\nRun bin/build_config"
  end
end

task default: %i[build_config coverage internal_investigation confirm_config]
