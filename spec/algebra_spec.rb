$:.unshift File.expand_path("../..", __FILE__)
require 'spec_helper'

describe LD::Patch::Algebra do
  before(:each) {$stderr = StringIO.new}
  after(:each) {$stderr = STDERR}

  PATHS_TTL = %(
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
  )
  EXAMPLE_4 = %(
    _:a <http://www.w3.org/1999/02/22-rdf-syntax-ns#first> "lorem" .
    _:a <http://www.w3.org/1999/02/22-rdf-syntax-ns#rest> _:b .
    _:b <http://www.w3.org/1999/02/22-rdf-syntax-ns#first> "ipsum" .
    _:b <http://www.w3.org/1999/02/22-rdf-syntax-ns#rest> _:c .
    _:c <http://www.w3.org/1999/02/22-rdf-syntax-ns#first> "dolor" .
    _:c <http://www.w3.org/1999/02/22-rdf-syntax-ns#rest> _:d .
    _:d <http://www.w3.org/1999/02/22-rdf-syntax-ns#first> "sit" .
    _:d <http://www.w3.org/1999/02/22-rdf-syntax-ns#rest> _:e .
    _:e <http://www.w3.org/1999/02/22-rdf-syntax-ns#first> "amet" .
    _:e <http://www.w3.org/1999/02/22-rdf-syntax-ns#rest> <http://www.w3.org/1999/02/22-rdf-syntax-ns#nil> .
    <http://example.org/#> <http://example.org/vocab#preferredLanguages> _:a .
  )

  describe "positive evaluation" do
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
        data: PATHS_TTL,
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
      "path-at" => {
        data: PATHS_TTL,
        patch: %(
          Bind ?x <http://example.org/s> / 1 .

          Add { ?x a <http://example.org/Found> } .
        ),
        result: %(
          <http://example.org/s> <http://example.org/p1> _:bs .
          <http://example.org/s> <http://example.org/p2> _:bsa .
          <http://example.org/s> <http://example.org/p2> _:bsb .
          <http://example.org/s> <http://www.w3.org/1999/02/22-rdf-syntax-ns#first> _:bi0 .
          _:g70188259035200 <http://www.w3.org/1999/02/22-rdf-syntax-ns#first> _:bi1 .
          _:g70188259035200 <http://www.w3.org/1999/02/22-rdf-syntax-ns#rest> _:g70188259036260 .
          _:g70188259036260 <http://www.w3.org/1999/02/22-rdf-syntax-ns#first> _:bi2 .
          _:g70188259036260 <http://www.w3.org/1999/02/22-rdf-syntax-ns#rest> <http://www.w3.org/1999/02/22-rdf-syntax-ns#nil> .
          <http://example.org/s> <http://www.w3.org/1999/02/22-rdf-syntax-ns#rest> _:g70188259035200 .
          _:bsa <http://example.org/l> "a" .
          _:bsa <http://example.org/p1> _:bsas .
          _:bsb <http://example.org/l> "b" .
          _:bp <http://example.org/p1> <http://example.org/s> .
          _:bpa <http://example.org/p2> <http://example.org/s> .
          _:bpb <http://example.org/p2> <http://example.org/s> .
          _:bpa <http://example.org/l> "a" .
          _:bpa <http://example.org/p1> _:bpas .
          _:bpb <http://example.org/l> "b" .
          _:bi1 <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://example.org/Found> .
        )
      },
      "updatelist" => {
        data: EXAMPLE_4,
        patch: %(
          UpdateList <http://example.org/#> <http://example.org/vocab#preferredLanguages> 1..3 ( "IPSUM DOLOR" ) .
        ),
        result: %(
          _:a <http://www.w3.org/1999/02/22-rdf-syntax-ns#first> "lorem" .
          _:a <http://www.w3.org/1999/02/22-rdf-syntax-ns#rest> _:b .
          _:b <http://www.w3.org/1999/02/22-rdf-syntax-ns#first> "IPSUM DOLOR" .
          _:b <http://www.w3.org/1999/02/22-rdf-syntax-ns#rest> _:c .
          _:c <http://www.w3.org/1999/02/22-rdf-syntax-ns#first> "sit" .
          _:c <http://www.w3.org/1999/02/22-rdf-syntax-ns#rest> _:d .
          _:d <http://www.w3.org/1999/02/22-rdf-syntax-ns#first> "amet" .
          _:d <http://www.w3.org/1999/02/22-rdf-syntax-ns#rest> <http://www.w3.org/1999/02/22-rdf-syntax-ns#nil> .
          <http://example.org/#> <http://example.org/vocab#preferredLanguages> _:a .
        )
      },
      "updatelist-var" => {
        data: EXAMPLE_4,
        patch: %(
          Bind ?var <http://example.org/#> .
          UpdateList ?var <http://example.org/vocab#preferredLanguages> 1..3 ( "IPSUM DOLOR" ) .
        ),
        result: %(
          _:a <http://www.w3.org/1999/02/22-rdf-syntax-ns#first> "lorem" .
          _:a <http://www.w3.org/1999/02/22-rdf-syntax-ns#rest> _:b .
          _:b <http://www.w3.org/1999/02/22-rdf-syntax-ns#first> "IPSUM DOLOR" .
          _:b <http://www.w3.org/1999/02/22-rdf-syntax-ns#rest> _:c .
          _:c <http://www.w3.org/1999/02/22-rdf-syntax-ns#first> "sit" .
          _:c <http://www.w3.org/1999/02/22-rdf-syntax-ns#rest> _:d .
          _:d <http://www.w3.org/1999/02/22-rdf-syntax-ns#first> "amet" .
          _:d <http://www.w3.org/1999/02/22-rdf-syntax-ns#rest> <http://www.w3.org/1999/02/22-rdf-syntax-ns#nil> .
          <http://example.org/#> <http://example.org/vocab#preferredLanguages> _:a .
        )
      },
      "updatelist-empty-slice" => {
        data: EXAMPLE_4,
        patch: %(
          UpdateList <http://example.org/#> <http://example.org/vocab#preferredLanguages> .. ( "IPSUM DOLOR" ) .
        ),
        result: %(
        _:a <http://www.w3.org/1999/02/22-rdf-syntax-ns#first> "lorem" .
        _:a <http://www.w3.org/1999/02/22-rdf-syntax-ns#rest> _:b .
        _:b <http://www.w3.org/1999/02/22-rdf-syntax-ns#first> "ipsum" .
        _:b <http://www.w3.org/1999/02/22-rdf-syntax-ns#rest> _:c .
        _:c <http://www.w3.org/1999/02/22-rdf-syntax-ns#first> "dolor" .
        _:c <http://www.w3.org/1999/02/22-rdf-syntax-ns#rest> _:d .
        _:d <http://www.w3.org/1999/02/22-rdf-syntax-ns#first> "sit" .
        _:d <http://www.w3.org/1999/02/22-rdf-syntax-ns#rest> _:e .
        _:e <http://www.w3.org/1999/02/22-rdf-syntax-ns#first> "amet" .
        _:e <http://www.w3.org/1999/02/22-rdf-syntax-ns#rest> _:f .
        _:f <http://www.w3.org/1999/02/22-rdf-syntax-ns#first> "IPSUM DOLOR" .
        _:f <http://www.w3.org/1999/02/22-rdf-syntax-ns#rest> <http://www.w3.org/1999/02/22-rdf-syntax-ns#nil> .
        <http://example.org/#> <http://example.org/vocab#preferredLanguages> _:a .
        )
      },
      "nested_collection" => {
        data: %(<http://example.org/something> <http://example.org/completely> <http://example.org/different> .),
        patch: %(Add {<http://a.example/s> <http://a.example/p> ((1)) .} .),
        result: %(
          <http://a.example/s> <http://a.example/p> _:outerEl1 .
          _:outerEl1 <http://www.w3.org/1999/02/22-rdf-syntax-ns#first> _:innerEl1 .
          _:innerEl1 <http://www.w3.org/1999/02/22-rdf-syntax-ns#first> "1"^^<http://www.w3.org/2001/XMLSchema#integer> .
          _:innerEl1 <http://www.w3.org/1999/02/22-rdf-syntax-ns#rest> <http://www.w3.org/1999/02/22-rdf-syntax-ns#nil> .
          _:outerEl1 <http://www.w3.org/1999/02/22-rdf-syntax-ns#rest> <http://www.w3.org/1999/02/22-rdf-syntax-ns#nil> .
          <http://example.org/something> <http://example.org/completely> <http://example.org/different> .
        )
      },
      "spec_examples-4-17-18" => {
        data: EXAMPLE_4,
        patch: %(UpdateList <http://example.org/#> <http://example.org/vocab#preferredLanguages> 0.. ( ) .),
        result: %(<http://example.org/#> <http://example.org/vocab#preferredLanguages> <http://www.w3.org/1999/02/22-rdf-syntax-ns#nil> .)
      }
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

  describe "negative evaluation" do
    {
      "path-unicity-fail" => {
        data: PATHS_TTL,
        patch: %(Bind ?x <http://example.org/s> / <http://example.org/p2> ! .)
      },
      "addnew-noop-fail" => {
        data: %(
          <http://example.org/s1> <http://example.org/p1> <http://example.org/o1> .
          <http://example.org/s2> <http://example.org/p2> <http://example.org/o2> .
        ),
        patch: %(AddNew { <http://example.org/s2> <http://example.org/p2> <http://example.org/o2> } .)
      },
      "deleteexisting-noop-fail" => {
        data: %(<http://example.org/s1> <http://example.org/p1> <http://example.org/o1> .),
        patch: %(DeleteExisting { <http://example.org/s2> <http://example.org/p2> <http://example.org/o2> } .)
      },
      "cut-fail" => {
        data: %(
          <http://example.org/s1> <http://example.org/p1> _:genid1 .
          <http://example.org/s2> <http://example.org/p2> _:genid2 .
        ),
        patch: %(
          Bind ?x <http://example.org/s2> / <http://example.org/p2> .

          Delete {
            <http://example.org/s2> <http://example.org/p2> ?x
          } .

          Cut ?x .
        )
      },
      "updatelist-exceed-size" => {
        data: EXAMPLE_4,
        patch: %(UpdateList <http://example.org/#> <http://example.org/vocab#preferredLanguages> 0..6 ( "LOREM" "IPSUM" ) .)
      },
      "updatelist-exceed-size-negative" => {
        data: EXAMPLE_4,
        patch: %(UpdateList <http://example.org/#> <http://example.org/vocab#preferredLanguages> -6.. ( "LOREM" "IPSUM" ) .)
      },
    }.each do |name, props|
      it name do
        graph = RDF::Graph.new << RDF::NTriples::Reader.new(props[:data])
        operator = LD::Patch::Parser.new(props[:patch]).parse
        expect {operator.execute(graph)}.to raise_error(LD::Patch::Error)
      end
    end
  end
end
