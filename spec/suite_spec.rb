$:.unshift "."
require 'spec_helper'
require 'fileutils'

WebMock.allow_net_connect!(net_http_connect_on_start: true)
describe LD::Patch do
  require 'suite_helper'

  before(:all) {WebMock.allow_net_connect!(net_http_connect_on_start: true)}
  after(:all) {WebMock.allow_net_connect!(net_http_connect_on_start: false)}

  %w(manifest.ttl manifest-syntax.ttl turtle/manifest-ldpatch.ttl).each do |variant|
    manifest = Fixtures::SuiteTest::BASE + variant

    Fixtures::SuiteTest::Manifest.open(manifest) do |m|
      describe m.comment do
        m.entries.each do |t|
          next if t.approval =~ /Rejected/
          specify "#{t.id.split("/").last}: #{t.name} - #{t.comment}#{'( negative)' if t.negative_test?}" do
            if %w(turtle-syntax-bad-struct-09 turtle-syntax-bad-struct-10).include?(t.name)
              pending "Multiple '.' allowed in this grammar"
            end
            t.debug = []
            begin
              operator = LD::Patch.parse(t.input,
                base_uri: t.base,
                debug:    t.debug
              )
              if t.positive_test?
                if t.evaluate?
                  ug = operator.execute(t.target_graph)
                  expect(t.target_graph).to be_equivalent_graph(t.expected_graph, t)
                else
                  expect(operator).to be_a(SPARQL::Algebra::Operator)
                end
              else
                if t.evaluate?
                  pending "negative evaluation tests"
                  operator.execute(t.target_graph)
                  expect(t.target_graph).not_to be_equivalent_graph(t.expected_graph, t)
                  fail
                else
                  fail("Should have raised a parser error")
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