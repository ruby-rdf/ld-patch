require "bundler/setup"
require 'rspec/its'
require 'matchers'
require 'webmock/rspec'
require 'rdf/turtle'
require 'simplecov'
require 'coveralls'
SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter.new([
  SimpleCov::Formatter::HTMLFormatter,
  Coveralls::SimpleCov::Formatter
])
SimpleCov.start do
  add_filter "/spec/"
end

require 'ld/patch'

RSpec.configure do |config|
  config.filter_run focus: true
  config.run_all_when_everything_filtered = true
end
