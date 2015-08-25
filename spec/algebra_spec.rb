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
  EXAMPLE_1 = %(
    <http://example.org/#> <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://schema.org/Person> .
    <http://example.org/#> <http://schema.org/alternateName> "TimBL" .
    <http://example.org/#> <http://ogp.me/ns/profile#first_name> "Tim" .
    <http://example.org/#> <http://ogp.me/ns/profile#last_name> "Berners-Lee" .
    _:g70241628916320 <http://schema.org/name> "W3C/MIT" .
    <http://example.org/#> <http://schema.org/workLocation> _:g70241628916320 .
    <http://example.org/#> <http://schema.org/performerIn> _:b1 .
    <http://example.org/#> <http://schema.org/performerIn> _:b2 .
    _:g70241628160100 <http://www.w3.org/1999/02/22-rdf-syntax-ns#first> "en" .
    _:g70241628160100 <http://www.w3.org/1999/02/22-rdf-syntax-ns#rest> _:g70241628162580 .
    _:g70241628162580 <http://www.w3.org/1999/02/22-rdf-syntax-ns#first> "fr" .
    _:g70241628162580 <http://www.w3.org/1999/02/22-rdf-syntax-ns#rest> <http://www.w3.org/1999/02/22-rdf-syntax-ns#nil> .
    <http://example.org/#> <http://example.org/vocab#preferredLanguages> _:g70241628160100 .
    _:b1 <http://schema.org/name> "F2F5 - Linked Data Platform" .
    _:b1 <http://schema.org/url> <https://www.w3.org/2012/ldp/wiki/F2F5> .
    _:b2 <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://schema.org/Event> .
    _:b2 <http://schema.org/name> "TED 2009" .
    _:b2 <http://schema.org/startDate> "2009-02-04" .
    _:b2 <http://schema.org/url> <http://conferences.ted.com/TED2009/> .
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
  EXAMPLE_24 = %(
    <http://example.org/#> <http://xmlns.com/foaf/0.1/name> "Alice" .
    <http://example.org/#> <http://xmlns.com/foaf/0.1/knows> _:b1 .
    <http://example.org/#> <http://xmlns.com/foaf/0.1/knows> _:b2 .
    _:b1 <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://xmlns.com/foaf/0.1/Person> .
    _:b2 <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://xmlns.com/foaf/0.1/Person> .
    _:b2 <http://schema.org/workLocation> _:b3 .
    _:b3 <http://schema.org/name> "W3C/MIT" .
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
      "spec_examples-1-2-3" => {
        data: EXAMPLE_1,
        patch: %(
          @prefix rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#> .
          @prefix schema: <http://schema.org/> .
          @prefix profile: <http://ogp.me/ns/profile#> .
          @prefix ex: <http://example.org/vocab#> .

          Delete { <http://example.org/#> profile:first_name "Tim" } .
          Add {
            <http://example.org/#> profile:first_name "Timothy" ;
              profile:image <https://example.org/timbl.jpg> .
          } .

          Bind ?workLocation <http://example.org/#> / schema:workLocation .
          Cut ?workLocation .

          UpdateList <http://example.org/#> ex:preferredLanguages 1..2 ( "fr-CH" ) .

          Bind ?event <http://example.org/#> / schema:performerIn [ / schema:url = <https://www.w3.org/2012/ldp/wiki/F2F5> ]  .
          Add { ?event rdf:type schema:Event } .

          Bind ?ted <http://conferences.ted.com/TED2009/> / ^schema:url ! .
          Delete { ?ted schema:startDate "2009-02-04" } .
          Add {
            ?ted schema:location [
              schema:name "Long Beach, California" ;
              schema:geo [
                schema:latitude "33.7817" ;
                schema:longitude "-118.2054"
              ]
            ]
          } .
        ),
        result: %(
          <http://example.org/#> <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://schema.org/Person> .
          <http://example.org/#> <http://schema.org/alternateName> "TimBL" .
          <http://example.org/#> <http://ogp.me/ns/profile#first_name> "Timothy" .
          <http://example.org/#> <http://ogp.me/ns/profile#last_name> "Berners-Lee" .
          <http://example.org/#> <http://ogp.me/ns/profile#image> <https://example.org/timbl.jpg> .
          <http://example.org/#> <http://schema.org/performerIn> _:b1 .
          <http://example.org/#> <http://schema.org/performerIn> _:b2 .
          _:g70201382063060 <http://www.w3.org/1999/02/22-rdf-syntax-ns#first> "en" .
          _:g70201382063060 <http://www.w3.org/1999/02/22-rdf-syntax-ns#rest> _:g70201382065840 .
          _:g70201382065840 <http://www.w3.org/1999/02/22-rdf-syntax-ns#first> "fr-CH" .
          _:g70201382065840 <http://www.w3.org/1999/02/22-rdf-syntax-ns#rest> <http://www.w3.org/1999/02/22-rdf-syntax-ns#nil> .
          <http://example.org/#> <http://example.org/vocab#preferredLanguages> _:g70201382063060 .
          _:b1 <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://schema.org/Event> .
          _:b1 <http://schema.org/name> "F2F5 - Linked Data Platform" .
          _:b1 <http://schema.org/url> <https://www.w3.org/2012/ldp/wiki/F2F5> .
          _:b2 <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://schema.org/Event> .
          _:b2 <http://schema.org/name> "TED 2009" .
          _:b2 <http://schema.org/url> <http://conferences.ted.com/TED2009/> .
          _:g70201381047840 <http://schema.org/name> "Long Beach, California" .
          _:g70201380929840 <http://schema.org/latitude> "33.7817" .
          _:g70201380929840 <http://schema.org/longitude> "-118.2054" .
          _:g70201381047840 <http://schema.org/geo> _:g70201380929840 .
          _:b2 <http://schema.org/location> _:g70201381047840 .
        )
      },
      "spec_examples-4-5-6" => {
        data: EXAMPLE_4,
        patch: %(UpdateList <http://example.org/#> <http://example.org/vocab#preferredLanguages> 1..2 ( "fr" ) .),
        result: %(
          _:g70355537922820 <http://www.w3.org/1999/02/22-rdf-syntax-ns#first> "lorem" .
          _:g70355537922820 <http://www.w3.org/1999/02/22-rdf-syntax-ns#rest> _:g70355537924860 .
          _:g70355537924860 <http://www.w3.org/1999/02/22-rdf-syntax-ns#first> "fr" .
          _:g70355537924860 <http://www.w3.org/1999/02/22-rdf-syntax-ns#rest> _:g70355537927900 .
          _:g70355537927900 <http://www.w3.org/1999/02/22-rdf-syntax-ns#first> "dolor" .
          _:g70355537927900 <http://www.w3.org/1999/02/22-rdf-syntax-ns#rest> _:g70355538003480 .
          _:g70355538003480 <http://www.w3.org/1999/02/22-rdf-syntax-ns#first> "sit" .
          _:g70355538003480 <http://www.w3.org/1999/02/22-rdf-syntax-ns#rest> _:g70355538007220 .
          _:g70355538007220 <http://www.w3.org/1999/02/22-rdf-syntax-ns#first> "amet" .
          _:g70355538007220 <http://www.w3.org/1999/02/22-rdf-syntax-ns#rest> <http://www.w3.org/1999/02/22-rdf-syntax-ns#nil> .
          <http://example.org/#> <http://example.org/vocab#preferredLanguages> _:g70355537922820 .
        )
      },
      "spec_examples-4-7-8" => {
        data: EXAMPLE_4,
        patch: %(UpdateList <http://example.org/#> <http://example.org/vocab#preferredLanguages> 2..2 ( "en" "fr" ) .),
        result: %(
          _:g70103492264460 <http://www.w3.org/1999/02/22-rdf-syntax-ns#first> "lorem" .
          _:g70103492264460 <http://www.w3.org/1999/02/22-rdf-syntax-ns#rest> _:g70103492266260 .
          _:g70103492266260 <http://www.w3.org/1999/02/22-rdf-syntax-ns#first> "ipsum" .
          _:g70103492266260 <http://www.w3.org/1999/02/22-rdf-syntax-ns#rest> _:g70103492268360 .
          _:g70103492268360 <http://www.w3.org/1999/02/22-rdf-syntax-ns#first> "en" .
          _:g70103492268360 <http://www.w3.org/1999/02/22-rdf-syntax-ns#rest> _:g70103492270100 .
          _:g70103492270100 <http://www.w3.org/1999/02/22-rdf-syntax-ns#first> "fr" .
          _:g70103492270100 <http://www.w3.org/1999/02/22-rdf-syntax-ns#rest> _:g70103492282080 .
          _:g70103492282080 <http://www.w3.org/1999/02/22-rdf-syntax-ns#first> "dolor" .
          _:g70103492282080 <http://www.w3.org/1999/02/22-rdf-syntax-ns#rest> _:g70103492284900 .
          _:g70103492284900 <http://www.w3.org/1999/02/22-rdf-syntax-ns#first> "sit" .
          _:g70103492284900 <http://www.w3.org/1999/02/22-rdf-syntax-ns#rest> _:g70103492297500 .
          _:g70103492297500 <http://www.w3.org/1999/02/22-rdf-syntax-ns#first> "amet" .
          _:g70103492297500 <http://www.w3.org/1999/02/22-rdf-syntax-ns#rest> <http://www.w3.org/1999/02/22-rdf-syntax-ns#nil> .
          <http://example.org/#> <http://example.org/vocab#preferredLanguages> _:g70103492264460 .
        )
      },
      "spec_examples-4-9-10" => {
        data: EXAMPLE_4,
        patch: %(UpdateList <http://example.org/#> <http://example.org/vocab#preferredLanguages> .. ( "en" "fr" ) .),
        result: %(
          _:g70243947791520 <http://www.w3.org/1999/02/22-rdf-syntax-ns#first> "lorem" .
          _:g70243947791520 <http://www.w3.org/1999/02/22-rdf-syntax-ns#rest> _:g70243947793380 .
          _:g70243947793380 <http://www.w3.org/1999/02/22-rdf-syntax-ns#first> "ipsum" .
          _:g70243947793380 <http://www.w3.org/1999/02/22-rdf-syntax-ns#rest> _:g70243947795500 .
          _:g70243947795500 <http://www.w3.org/1999/02/22-rdf-syntax-ns#first> "dolor" .
          _:g70243947795500 <http://www.w3.org/1999/02/22-rdf-syntax-ns#rest> _:g70243947797260 .
          _:g70243947797260 <http://www.w3.org/1999/02/22-rdf-syntax-ns#first> "sit" .
          _:g70243947797260 <http://www.w3.org/1999/02/22-rdf-syntax-ns#rest> _:g70243947809080 .
          _:g70243947809080 <http://www.w3.org/1999/02/22-rdf-syntax-ns#first> "amet" .
          _:g70243947809080 <http://www.w3.org/1999/02/22-rdf-syntax-ns#rest> _:g70243947812000 .
          _:g70243947812000 <http://www.w3.org/1999/02/22-rdf-syntax-ns#first> "en" .
          _:g70243947812000 <http://www.w3.org/1999/02/22-rdf-syntax-ns#rest> _:g70243947856740 .
          _:g70243947856740 <http://www.w3.org/1999/02/22-rdf-syntax-ns#first> "fr" .
          _:g70243947856740 <http://www.w3.org/1999/02/22-rdf-syntax-ns#rest> <http://www.w3.org/1999/02/22-rdf-syntax-ns#nil> .
          <http://example.org/#> <http://example.org/vocab#preferredLanguages> _:g70243947791520 .
        )
      },
      "spec_examples-4-11-12" => {
        data: EXAMPLE_4,
        patch: %(UpdateList <http://example.org/#> <http://example.org/vocab#preferredLanguages> 2.. ( "en" "fr" ) .),
        result: %(
          _:g70272918507700 <http://www.w3.org/1999/02/22-rdf-syntax-ns#first> "lorem" .
          _:g70272918507700 <http://www.w3.org/1999/02/22-rdf-syntax-ns#rest> _:g70272918507320 .
          _:g70272918507320 <http://www.w3.org/1999/02/22-rdf-syntax-ns#first> "ipsum" .
          _:g70272918507320 <http://www.w3.org/1999/02/22-rdf-syntax-ns#rest> _:g70272918552980 .
          _:g70272918552980 <http://www.w3.org/1999/02/22-rdf-syntax-ns#first> "en" .
          _:g70272918552980 <http://www.w3.org/1999/02/22-rdf-syntax-ns#rest> _:g70272918557500 .
          _:g70272918557500 <http://www.w3.org/1999/02/22-rdf-syntax-ns#first> "fr" .
          _:g70272918557500 <http://www.w3.org/1999/02/22-rdf-syntax-ns#rest> <http://www.w3.org/1999/02/22-rdf-syntax-ns#nil> .
          <http://example.org/#> <http://example.org/vocab#preferredLanguages> _:g70272918507700 .
        )
      },
      "spec_examples-4-13-14" => {
        data: EXAMPLE_4,
        patch: %(UpdateList <http://example.org/#> <http://example.org/vocab#preferredLanguages> -3.. ( "en" "fr" ) .),
        result: %(
          _:g70165773774620 <http://www.w3.org/1999/02/22-rdf-syntax-ns#first> "lorem" .
          _:g70165773774620 <http://www.w3.org/1999/02/22-rdf-syntax-ns#rest> _:g70165773777100 .
          _:g70165773777100 <http://www.w3.org/1999/02/22-rdf-syntax-ns#first> "ipsum" .
          _:g70165773777100 <http://www.w3.org/1999/02/22-rdf-syntax-ns#rest> _:g70165773844780 .
          _:g70165773844780 <http://www.w3.org/1999/02/22-rdf-syntax-ns#first> "en" .
          _:g70165773844780 <http://www.w3.org/1999/02/22-rdf-syntax-ns#rest> _:g70165773847640 .
          _:g70165773847640 <http://www.w3.org/1999/02/22-rdf-syntax-ns#first> "fr" .
          _:g70165773847640 <http://www.w3.org/1999/02/22-rdf-syntax-ns#rest> <http://www.w3.org/1999/02/22-rdf-syntax-ns#nil> .
          <http://example.org/#> <http://example.org/vocab#preferredLanguages> _:g70165773774620 .
        )
      },
      "spec_examples-4-15-16" => {
        data: EXAMPLE_4,
        patch: %(UpdateList <http://example.org/#> <http://example.org/vocab#preferredLanguages> 1..3 ( ) .),
        result: %(
          _:g70106772858120 <http://www.w3.org/1999/02/22-rdf-syntax-ns#first> "lorem" .
          _:g70106772858120 <http://www.w3.org/1999/02/22-rdf-syntax-ns#rest> _:g70106772862780 .
          _:g70106772862780 <http://www.w3.org/1999/02/22-rdf-syntax-ns#first> "sit" .
          _:g70106772862780 <http://www.w3.org/1999/02/22-rdf-syntax-ns#rest> _:g70106767753500 .
          _:g70106767753500 <http://www.w3.org/1999/02/22-rdf-syntax-ns#first> "amet" .
          _:g70106767753500 <http://www.w3.org/1999/02/22-rdf-syntax-ns#rest> <http://www.w3.org/1999/02/22-rdf-syntax-ns#nil> .
          <http://example.org/#> <http://example.org/vocab#preferredLanguages> _:g70106772858120 .
        )
      },
      "spec_examples-4-17-18" => {
        data: EXAMPLE_4,
        patch: %(UpdateList <http://example.org/#> <http://example.org/vocab#preferredLanguages> 0.. ( ) .),
        result: %(<http://example.org/#> <http://example.org/vocab#preferredLanguages> <http://www.w3.org/1999/02/22-rdf-syntax-ns#nil> .)
      },
      "spec_example24_positive" => {
        data: EXAMPLE_24,
        patch: %(
          @prefix rdfs: <http://www.w3.org/2000/01/rdf-schema#> .
          @prefix schema: <http://schema.org/> .

          Bind ?b3 "W3C/MIT" / ^schema:name .
          Bind ?b2 ?b3 / ^schema:workLocation .

          Add {
              ?b2 rdfs:label "b2" .
              ?b3 rdfs:label "b3" .
          } .
        ),
        result: %(
          <http://example.org/#> <http://xmlns.com/foaf/0.1/name> "Alice" .
          <http://example.org/#> <http://xmlns.com/foaf/0.1/knows> _:b1 .
          <http://example.org/#> <http://xmlns.com/foaf/0.1/knows> _:b2 .
          _:b1 <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://xmlns.com/foaf/0.1/Person> .
          _:b2 <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://xmlns.com/foaf/0.1/Person> .
          _:b2 <http://schema.org/workLocation> _:b3 .
          _:b2 <http://www.w3.org/2000/01/rdf-schema#label> "b2" .
          _:b3 <http://schema.org/name> "W3C/MIT" .
          _:b3 <http://www.w3.org/2000/01/rdf-schema#label> "b3" .
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
