#!/usr/bin/env rake

require "bundler/gem_tasks"
require "rake/testtask"
require 'rdoc/task'

desc 'Run tests'
Rake::TestTask.new(:test) do |t|
  t.libs << 'lib'
  t.libs << 'test'
  t.pattern = 'test/**/*_test.rb'
  t.verbose = true
end

task :default => :test

RDoc::Task.new do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.main     = 'README.md'
  rdoc.rdoc_files.include('README.md', 'lib/**/*.rb')
end
