#!/usr/bin/env rake
require "bundler/gem_helper"
require 'rake/testtask'

namespace 'dotenv' do
  Bundler::GemHelper.install_tasks :name => 'env_bang'
end

namespace 'dotenv-rails' do
  Bundler::GemHelper.install_tasks :name => 'env_bang-rails'
end

desc 'Run all tests'
Rake::TestTask.new do |t|
  t.test_files = FileList['test/*_test.rb']
  t.verbose = true
end

task :default => :test
