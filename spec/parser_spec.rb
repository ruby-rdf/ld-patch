$:.unshift File.expand_path("../..", __FILE__)
require 'spec_helper'

describe LD::Patch::Parser do
  before(:each) {$stderr = StringIO.new}
  after(:each) {$stderr = STDERR}

  describe "#initialize" do
    it "accepts a string query" do |example|
      expect {
        described_class.new("foo") {
          raise "huh" unless input == "foo"
        }
      }.not_to raise_error
    end

    it "accepts a StringIO query" do |example|
      expect {
        described_class.new(StringIO.new("foo")) {
          raise "huh" unless input == "foo"
        }
      }.not_to raise_error
    end
  end

  describe "Empty" do
    it "renders an empty patch" do
      expect("").to generate("(patch)")
    end
  end

  describe "Add" do
    {
      "add-1triple" => {
        input: %(Add { <http://example.org/s2> <http://example.org/p2> <http://example.org/o2> } .),
        result: %((patch (add ((triple <http://example.org/s2> <http://example.org/p2> <http://example.org/o2>)))))
      },
      "add-abbr-1triple" => {
        input: %(A { <http://example.org/s2> <http://example.org/p2> <http://example.org/o2> } .),
        result: %((patch (add ((triple <http://example.org/s2> <http://example.org/p2> <http://example.org/o2>)))))
      },
      "addnew-1triple" => {
        input: %(AddNew { <http://example.org/s2> <http://example.org/p2> <http://example.org/o2> } .),
        result: %((patch (add ((triple <http://example.org/s2> <http://example.org/p2> <http://example.org/o2>)))))
      },
      "addnew-abbr-1triple" => {
        input: %(AN { <http://example.org/s2> <http://example.org/p2> <http://example.org/o2> } .),
        result: %((patch (add ((triple <http://example.org/s2> <http://example.org/p2> <http://example.org/o2>)))))
      },
    }.each do |name, params|
      it name do
        expect(params[:input]).to generate(params[:result])
      end
    end
  end

  describe "Bind" do
    {
      "bind" => {
        input: %(
          Bind ?x <http://example.org/s2> .

          Add { ?x <http://example.org/p2> <http://example.org/o2> } .
        ),
        result: %((patch
          (bind ?x <http://example.org/s2> (path))
          (add ((triple ?x <http://example.org/p2> <http://example.org/o2>)))
        ))
      },
      "bind-abbr" => {
        input: %(
          B ?x <http://example.org/s2> .

          Add { ?x <http://example.org/p2> <http://example.org/o2> } .
        ),
        result: %((patch
          (bind ?x <http://example.org/s2> (path))
          (add ((triple ?x <http://example.org/p2> <http://example.org/o2>)))
        ))
      },
      "bind-overridden" => {
        input: %(
          Bind ?x <http://example.org/s1> .
          Bind ?x <http://example.org/s2> .

          Add { ?x <http://example.org/p2> <http://example.org/o2> } .
        ),
        result: %((patch
          (bind ?x <http://example.org/s1> (path))
          (bind ?x <http://example.org/s2> (path))
          (add ((triple ?x <http://example.org/p2> <http://example.org/o2>)))
        ))
      },
      "path-at" => {
        input: %(
          Bind ?x <http://example.org/s> / 1 .

          Add { ?x a <http://example.org/Found> } .
        ),
        result: %((patch
          (bind ?x <http://example.org/s> (path (index 1)))
          (add ((triple ?x a <http://example.org/Found>)))
        ))
      },
      "path-backward" => {
        input: %(
          Bind ?x <http://example.org/s> / ^<http://example.org/p1> .

          Add {?x a <http://example.org/Found> .}.
        ),
        result: %((patch
          (bind ?x <http://example.org/s> (path (reverse <http://example.org/p1>)))
          (add ((triple ?x a <http://example.org/Found>)))
        ))
      },
      "path-filter-equal" => {
        input: %(
          Bind ?x <http://example.org/s> / <http://example.org/p2> [  / <http://example.org/l> = "b" ] .

          Add { ?x a <http://example.org/Found> } .
        ),
        result: %((patch
          (bind ?x <http://example.org/s> (path <http://example.org/p2> (constraint (path <http://example.org/l>) "b")))
          (add ((triple ?x a <http://example.org/Found>)))
        ))
      },
      "path-filter" => {
        input: %(
          Bind ?x <http://example.org/s> / <http://example.org/p2> [  / <http://example.org/p1> ] .

          Add { ?x a <http://example.org/Found> } .
        ),
        result: %((patch
          (bind ?x <http://example.org/s> (path <http://example.org/p2> (constraint (path <http://example.org/p1>))))
          (add ((triple ?x a <http://example.org/Found>)))
        ))
      },
      "path-starting-with-literal" => {
        input: %(
          Bind ?x "a" / ^<http://example.org/l> / ^<http://example.org/p2> .

          Add { ?x a <http://example.org/Found> } .
        ),
        result: %((patch
          (bind ?x "a" (path (reverse <http://example.org/l>) (reverse <http://example.org/p2>)))
          (add ((triple ?x a <http://example.org/Found>)))
        ))
      },
      "path-unicity" => {
        input: %(Bind ?x <http://example.org/s> / <http://example.org/p1> ! .),
        result: %((patch (bind ?x <http://example.org/s> (path <http://example.org/p1> (constraint unique)))))
      },
    }.each do |name, params|
      it name do
        expect(params[:input]).to generate(params[:result])
      end
    end
  end

  describe "Cut" do
    {
      "cut" => {
        input: %(
          Bind ?x <http://example.org/s> / <http://example.org/p2> [ / <http://example.org/l> = "a" ] .

          Cut ?x .
        ),
        result: %((patch
          (bind ?x <http://example.org/s> (path <http://example.org/p2> (constraint (path <http://example.org/l>) "a")))
          (cut ?x)
        ))
      },
      "cut-abbr" => {
        input: %(
          Bind ?x <http://example.org/s> / <http://example.org/p2> [ / <http://example.org/l> = "a" ] .

          C ?x .
        ),
        result: %((patch
          (bind ?x <http://example.org/s> (path <http://example.org/p2> (constraint (path <http://example.org/l>) "a")))
          (cut ?x)
        ))
      },
    }.each do |name, params|
      it name do
        expect(params[:input]).to generate(params[:result])
      end
    end
  end

  describe "Delete" do
    {
      "delete-1triple" => {
        input: %(Delete { <http://example.org/s2> <http://example.org/p2> <http://example.org/o2> } .),
        result: %((patch (delete ((triple <http://example.org/s2> <http://example.org/p2> <http://example.org/o2>)))))
      },
      "delete-abbr-1triple" => {
        input: %(D { <http://example.org/s2> <http://example.org/p2> <http://example.org/o2> } .),
        result: %((patch (delete ((triple <http://example.org/s2> <http://example.org/p2> <http://example.org/o2>)))))
      },
      "deleteexisting-1triple" => {
        input: %(DeleteExisting { <http://example.org/s2> <http://example.org/p2> <http://example.org/o2> } .),
        result: %((patch (delete ((triple <http://example.org/s2> <http://example.org/p2> <http://example.org/o2>)))))
      },
      "deleteexisting-abbr-1triple" => {
        input: %(DE { <http://example.org/s2> <http://example.org/p2> <http://example.org/o2> } .),
        result: %((patch (delete ((triple <http://example.org/s2> <http://example.org/p2> <http://example.org/o2>)))))
      },
    }.each do |name, params|
      it name do
        expect(params[:input]).to generate(params[:result])
      end
    end
  end

  describe "UpdateList" do
    {
      "updatelist" => {
        input: %(UpdateList <#> <http://example.org/vocab#preferredLanguages> 1..3 ( "IPSUM DOLOR" ) .),
        result: %((patch (updateList <#> <http://example.org/vocab#preferredLanguages> 1 3 ( "IPSUM DOLOR" ))))
      },
      "updatelist-abbr" => {
        input: %(UL <#> <http://example.org/vocab#preferredLanguages> 1..3 ( "IPSUM DOLOR" ) .),
        result: %((patch (updateList <#> <http://example.org/vocab#preferredLanguages> 1 3 ( "IPSUM DOLOR" ))))
      },
      "updatelist-nil" => {
        input: %(UpdateList <#> <http://example.org/vocab#preferredLanguages> .. ("fr" "en") .),
        result: %((patch (updateList <#> <http://example.org/vocab#preferredLanguages> http://www.w3.org/1999/02/22-rdf-syntax-ns#nil http://www.w3.org/1999/02/22-rdf-syntax-ns#nil ( "fr" "en" ))))
      },
      "updatelist-exceed-size-negative" => {
        input: %(UpdateList <#> <http://example.org/vocab#preferredLanguages> -6.. ( "LOREM" "IPSUM" ) .),
        result: %((patch (updateList <#> <http://example.org/vocab#preferredLanguages> -6 http://www.w3.org/1999/02/22-rdf-syntax-ns#nil ( "LOREM" "IPSUM" ))))
      },
    }.each do |name, params|
      it name do
        expect(params[:input]).to generate(params[:result])
      end
    end
  end

  describe "Syntax" do
    {
      "spec_example_24_positive" => {
        input: %(
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
          (prefix ((rdfs <http://www.w3.org/2000/01/rdf-schema#>) (schema <http://schema.org/>))
            (patch
              (bind ?b3 "W3C/MIT" (path (reverse schema:name)))
              (bind ?b2 ?b3 (path (reverse schema:workLocation)))
              (add ((triple ?b2 rdfs:label "b2") (triple ?b3 rdfs:label "b3")))
            )
          )
        )
      },
      "bnode-fresh.ldpatch" => {
        input: %(
          Add {
            <http://example.org/s2> <http://example.org/p2> _:genid1
          } .
        ),
        result: %(
          (patch (add ((triple <http://example.org/s2> <http://example.org/p2> _:genid1))))
        )
      },
      "blankNodePropertyList_as_object.ldpatch" => {
        input: %(
          Add {
            <http://a.example/s> <http://a.example/p> [ <http://a.example/p2> <http://a.example/o2> ] .
          } .
        ),
        result: %(
          (patch
            (add ((triple _:b0 <http://a.example/p2> <http://a.example/o2>)
                  (triple <http://a.example/s> <http://a.example/p> _:b0))))
        )
      },
    }.each do |name, params|
      it name do
        expect(params[:input]).to generate(params[:result])
      end
    end
  end

  def parse(input, options = {})
    production = options.fetch(:production, :ldpatch)
    @debug = options[:debug] || []
    described_class.new(input, {debug: @debug, resolve_iris: false}.merge(options)).parse(production)
  end
end
