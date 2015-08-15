#!/usr/bin/env ruby
$:.unshift(File.expand_path(File.join(File.dirname(__FILE__), 'lib')))
require 'rubygems'
require 'yard'
require 'rspec/core/rake_task'

task default: :spec
task specs: :spec

namespace :gem do
  desc "Build the ld-patch-#{File.read('VERSION').chomp}.gem file"
  task :build do
    sh "gem build ld-patch.gemspec && mv ld-patch-#{File.read('VERSION').chomp}.gem pkg/"
  end

  desc "Release the ld-patch-#{File.read('VERSION').chomp}.gem file"
  task :release do
    sh "gem push pkg/ld-patch-#{File.read('VERSION').chomp}.gem"
  end
end

RSpec::Core::RakeTask.new(:spec)

desc "Run specs through RCov"
RSpec::Core::RakeTask.new("spec:rcov") do |spec|
  spec.rcov = true
  spec.rcov_opts =  %q[--exclude "spec"]
end

namespace :doc do
  YARD::Rake::YardocTask.new
end

desc 'Create versions of ebnf files in etc'
task etc: %w{etc/ld-patch.sxp etc/ld-patch.html etc/ld-patch.ll1.sxp}

desc 'Build first, follow and branch tables'
task meta: "lib/ld/patch/meta.rb"

file "lib/ld/patch/meta.rb" => "etc/ld-patch.ebnf" do |t|
  sh %{
    ebnf --ll1 ldpatch --format rb \
      --mod-name LD::Patch::Meta \
      --output lib/ld/patch/meta.rb \
      etc/ld-patch.ebnf
  }
end

file "etc/ld-patch.ll1.sxp" => "etc/ld-patch.ebnf" do |t|
  sh %{
    ebnf --ll1 ldpatch --format sxp \
      --output etc/ld-patch.ll1.sxp \
      etc/ld-patch.ebnf
  }
end

file "etc/ld-patch.sxp" => "etc/ld-patch.ebnf" do |t|
  sh %{
    ebnf --bnf --format sxp \
      --output etc/ld-patch.sxp \
      etc/ld-patch.ebnf
  }
end

file "etc/ld-patch.html" => "etc/ld-patch.ebnf" do |t|
  sh %{
    ebnf --format html \
      --output etc/ld-patch.html \
      etc/ld-patch.ebnf
  }
end
