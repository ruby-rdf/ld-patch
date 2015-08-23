# Spira class for manipulating test-manifest style test suites.
# Used for Turtle tests
require 'rdf/turtle'
require 'json/ld'

# For now, override RDF::Utils::File.open_file to look for the file locally before attempting to retrieve it
module RDF::Util
  module File
    REMOTE_PATH = "https://raw.githubusercontent.com/pchampin/ld-patch-testsuite/master/"
    LOCAL_PATH = ::File.expand_path("../testsuite", __FILE__) + '/'

    ##
    # Override to use Patron for http and https, Kernel.open otherwise.
    #
    # @param [String] filename_or_url to open
    # @param  [Hash{Symbol => Object}] options
    # @option options [Array, String] :headers
    #   HTTP Request headers.
    # @return [IO] File stream
    # @yield [IO] File stream
    def self.open_file(filename_or_url, options = {}, &block)
      case filename_or_url.to_s
      when /^file:/
        path = filename_or_url[5..-1]
        Kernel.open(path.to_s, options, &block)
      when /^#{REMOTE_PATH}/
        begin
          #puts "attempt to open #{filename_or_url} locally"
          local_filename = filename_or_url.to_s.sub(REMOTE_PATH, LOCAL_PATH)
          if ::File.exist?(local_filename)
            response = ::File.open(local_filename)
            #puts "use #{filename_or_url} locally"
            case filename_or_url.to_s
            when /\.ttl$/
              def response.content_type; 'text/turtle'; end
            when /\.ldpatch$/
              def response.content_type; 'text/ldpatch'; end
            end

            if block_given?
              begin
                yield response
              ensure
                response.close
              end
            else
              response
            end
          else
            Kernel.open(filename_or_url.to_s, options.fetch(:headers, {}), &block)
          end
        rescue Errno::ENOENT #, OpenURI::HTTPError
          # Not there, don't run tests
          StringIO.new("")
        end
      else
        Kernel.open(filename_or_url.to_s, options.fetch(:headers, {}), &block)
      end
    end
  end
end

module Fixtures
  module SuiteTest
    BASE = "https://raw.githubusercontent.com/pchampin/ld-patch-testsuite/master/"
    FRAME = JSON.parse(%q({
      "@context": {
        "xsd": "http://www.w3.org/2001/XMLSchema#",
        "rdfs": "http://www.w3.org/2000/01/rdf-schema#",
        "mf": "http://www.w3.org/2001/sw/DataAccess/tests/test-manifest#",
        "mq": "http://www.w3.org/2001/sw/DataAccess/tests/test-query#",
        "ldp": "https://raw.githubusercontent.com/pchampin/ld-patch-testsuite/master/manifest.ttl#",

        "comment": "rdfs:comment",
        "entries": {"@id": "mf:entries", "@container": "@list"},
        "name": "mf:name",
        "action": {"@id": "mf:action", "@type": "@id"},
        "result": {"@id": "mf:result", "@type": "@id"},
        "data": {"@id": "ldp:data", "@type": "@id"},
        "base": {"@id": "ldp:base", "@type": "@id"},
        "patch": {"@id": "ldp:patch", "@type": "@id"},
        "statusCode": {"@id": "ldp:statusCode", "@type": "xsd:integer"}
      },
      "@type": "mf:Manifest",
      "entries": {
        "mf:action": {}
      }
    }))

    class Manifest < JSON::LD::Resource
      def self.open(file)
        #puts "open: #{file}"
        prefixes = {}
        g = RDF::Repository.load(file, format:  :ttl)
        JSON::LD::API.fromRDF(g) do |expanded|
          JSON::LD::API.frame(expanded, FRAME) do |framed|
            yield Manifest.new(framed['@graph'].first)
          end
        end
      end

      # @param [Hash] json framed JSON-LD
      # @return [Array<Manifest>]
      def self.from_jsonld(json)
        json['@graph'].map {|e| Manifest.new(e)}
      end

      def entries
        # Map entries to resources
        attributes['entries'].map {|e| Entry.new(e, base: file)}
      end
    end

    class Entry < JSON::LD::Resource
      attr_accessor :debug

      def base
        action.is_a?(Hash) ? action.fetch("base", action["data"]) : action
      end

      # Alias data and query
      def input
        url = case action
        when Hash then action['patch']
        else action
        end
        @input ||= RDF::Util::File.open_file(URI.decode(url)) {|f| f.read}
      end

      def data
        action.is_a?(Hash) && action["data"]
      end

      def target_graph
        @graph ||= RDF::Graph.load(URI.decode(data), base_uri: base)
      end

      def expected
        @expected ||= RDF::Util::File.open_file(URI.decode(result)) {|f| f.read}
      end

      def expected_graph
        @expected_graph ||= RDF::Graph.load(URI.decode(result), base_uri: base)
      end

      def evaluate?
        Array(attributes['@type']).join(" ").match(/Eval/)
      end

      def syntax?
        Array(attributes['@type']).join(" ").match(/Syntax/)
      end

      def positive_test?
        !Array(attributes['@type']).join(" ").match(/Negative/)
      end

      def negative_test?
        !positive_test?
      end

      def inspect
        super.sub('>', "\n" +
        "  syntax?: #{syntax?.inspect}\n" +
        "  positive?: #{positive_test?.inspect}\n" +
        "  evaluate?: #{evaluate?.inspect}\n" +
        ">"
      )
      end
    end
  end
end