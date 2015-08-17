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
    "cut" => {
      data: %(
        <http://example.org/s> <http://example.org/p1> _:bs .
        <http://example.org/s> <http://example.org/p2> _:bsa .
        <http://example.org/s> <http://example.org/p2> _:bsb .
        <http://example.org/s> <http://www.w3.org/1999/02/22-rdf-syntax-ns#first> _:bi0 .
        _:g70171436004340 <http://www.w3.org/1999/02/22-rdf-syntax-ns#first> _:bi1 .
        _:g70171436004340 <http://www.w3.org/1999/02/22-rdf-syntax-ns#rest> _:g70171436006660 .
        _:g70171436006660 <http://www.w3.org/1999/02/22-rdf-syntax-ns#first> _:bi2 .
        _:g70171436006660 <http://www.w3.org/1999/02/22-rdf-syntax-ns#rest> <http://www.w3.org/1999/02/22-rdf-syntax-ns#nil> .
        <http://example.org/s> <http://www.w3.org/1999/02/22-rdf-syntax-ns#rest> _:g70171436004340 .
        _:bsa <http://example.org/l> "a" .
        _:bsa <http://example.org/p1> _:bsas .
        _:bsb <http://example.org/l> "b" .
        _:bp <http://example.org/p1> <http://example.org/s> .
        _:bpa <http://example.org/p2> <http://example.org/s> .
        _:bpb <http://example.org/p2> <http://example.org/s> .
        _:bpa <http://example.org/l> "a" .
        _:bpa <http://example.org/p1> _:bpas .
        _:bpb <http://example.org/l> "b" .
      ),
      patch: %(
        Bind ?x <http://example.org/s> / <http://example.org/p2> [ / <http://example.org/l> = "a" ] .

        Cut ?x .
      ),
      result: %(
        <http://example.org/s> <http://example.org/p1> _:bs .
        <http://example.org/s> <http://example.org/p2> _:bsb .
        <http://example.org/s> <http://www.w3.org/1999/02/22-rdf-syntax-ns#first> _:bi0 .
        _:g70192880088320 <http://www.w3.org/1999/02/22-rdf-syntax-ns#first> _:bi1 .
        _:g70192880088320 <http://www.w3.org/1999/02/22-rdf-syntax-ns#rest> _:g70192880090180 .
        _:g70192880090180 <http://www.w3.org/1999/02/22-rdf-syntax-ns#first> _:bi2 .
        _:g70192880090180 <http://www.w3.org/1999/02/22-rdf-syntax-ns#rest> <http://www.w3.org/1999/02/22-rdf-syntax-ns#nil> .
        <http://example.org/s> <http://www.w3.org/1999/02/22-rdf-syntax-ns#rest> _:g70192880088320 .
        _:bsb <http://example.org/l> "b" .
        _:bp <http://example.org/p1> <http://example.org/s> .
        _:bpa <http://example.org/p2> <http://example.org/s> .
        _:bpb <http://example.org/p2> <http://example.org/s> .
        _:bpa <http://example.org/l> "a" .
        _:bpa <http://example.org/p1> _:bpas .
        _:bpb <http://example.org/l> "b" .
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
