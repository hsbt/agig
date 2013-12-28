#!/usr/bin/env rake
require 'rspec/core/rake_task'
require "bundler/gem_tasks"

RSpec::Core::RakeTask.new do |t|
  t.pattern = 'spec/**/*_spec.rb'
end

task :default => [:spec]
