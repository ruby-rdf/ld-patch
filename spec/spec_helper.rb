require "bundler/setup"
require 'rspec/its'
require 'matchers'
require 'webmock/rspec'
require 'rdf/turtle'

require 'ld/patch'

RSpec.configure do |config|
  config.filter_run focus: true
  config.run_all_when_everything_filtered = true
end
