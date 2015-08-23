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
          specify "#{t.name} - #{t.comment}#{'( negative)' if t.negative_test?}" do
            if %w(turtle-syntax-bad-struct-09 turtle-syntax-bad-struct-10).include?(t.name)
              pending "Multiple '.' allowed in this grammar"
            end
            t.debug = []
            begin
              operator = LD::Patch.parse(t.input,
                base_uri: t.base,
                validate: true,
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
                operator.execute(t.target_graph) if t.evaluate?
                fail("Should have raised a parser error")
              end
            rescue LD::Patch::ParseError
              unless t.syntax? && t.negative_test? || %w(turtle-eval-bad-01 turtle-eval-bad-02 turtle-eval-bad-03).include?(t.name)
                raise
              end
            rescue LD::Patch::Error => e
              # Special case
              if t.evaluate? && t.negative_test?
                expect(e.code).to eq t.statusCode.to_i
              else
                raise
              end
            end
          end
        end
      end
    end
  end
end unless ENV['CI']  # Skip for continuous integration