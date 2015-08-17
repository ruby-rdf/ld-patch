$:.unshift File.expand_path("../..", __FILE__)
require 'spec_helper'

describe LD::Patch::Algebra do
  before(:each) {$stderr = StringIO.new}
  after(:each) {$stderr = STDERR}

  {
    "add-1triple" => {
      data: %(<http://example.org/s1> <http://example.org/p1> <http://example.org/o1> .),
      patch: %(Add { <http://example.org/s2> <http://example.org/p2> <http://example.org/o2> } .),
      result: %(
        <http://example.org/s1> <http://example.org/p1> <http://example.org/o1> .
        <http://example.org/s2> <http://example.org/p2> <http://example.org/o2> .
      )
    },
    "bind" => {
      data: %(<http://example.org/s1> <http://example.org/p1> <http://example.org/o1> .),
      patch: %(
        Bind ?x <http://example.org/s2> .

        Add { ?x <http://example.org/p2> <http://example.org/o2> } .
      ),
      result: %(
        <http://example.org/s1> <http://example.org/p1> <http://example.org/o1> .
        <http://example.org/s2> <http://example.org/p2> <http://example.org/o2> .
      )
    },
    "delete-1triple" => {
      data: %(
        <http://example.org/s1> <http://example.org/p1> <http://example.org/o1> .
        <http://example.org/s2> <http://example.org/p2> <http://example.org/o2> .
      ),
      patch: %(Delete { <http://example.org/s2> <http://example.org/p2> <http://example.org/o2> } .),
      result: %(
        <http://example.org/s1> <http://example.org/p1> <http://example.org/o1> .
      )
    },
  }.each do |name, props|
    it name do
      graph = RDF::Graph.new << RDF::NTriples::Reader.new(props[:data])
      operator = LD::Patch::Parser.new(props[:patch]).parse
      result = RDF::Graph.new << RDF::NTriples::Reader.new(props[:result])
      operator.execute(graph)
      expect(graph).to be_equivalent_graph(result)
    end
  end
end
