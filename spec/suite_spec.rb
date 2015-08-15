$:.unshift "."
require 'spec_helper'
require 'fileutils'

WebMock.allow_net_connect!(net_http_connect_on_start: true)
describe LD::Patch do
  require 'suite_helper'

  before(:all) {WebMock.allow_net_connect!(net_http_connect_on_start: true)}
  after(:all) {WebMock.allow_net_connect!(net_http_connect_on_start: false)}

  %w(manifest.ttl manifest-syntax.ttl turtle/manifest-ldpatch.ttl).each do |variant|
    #next unless variant == 'turtle/manifest-ldpatch.ttl'
    manifest = Fixtures::SuiteTest::BASE + variant

    Fixtures::SuiteTest::Manifest.open(manifest) do |m|
      describe m.comment do
        m.entries.each do |t|
          next if t.approval =~ /Rejected/
          specify "#{t.id.split("/").last}: #{t.name} - #{t.comment}" do
            t.debug = []
            begin
              LD::Patch.parse(t.input,
                base_uri: t.base,
                debug:    t.debug
              ) do |parser|
                if positive_test?
                  if evaluate?
                    pending "positive evaluation tests"
                  end
                else
                  if evaluate?
                    pending "negative evaluation tests"
                  end
                end
              end
            rescue LD::Patch::Error
              # Special case
              unless t.syntax? && t.negative_test?
                raise
              end
            end
          end
        end
      end
    end
  end
end unless ENV['CI']  # Skip for continuous integration