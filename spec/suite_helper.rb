# Spira class for manipulating test-manifest style test suites.
# Used for Turtle tests
require 'rdf/turtle'
require 'json/ld'
require 'rdf/normalize'

# For now, override RDF::Utils::File.open_file to look for the file locally before attempting to retrieve it
module RDF::Util
  module File
    REMOTE_PATH = "https://raw.githubusercontent.com/pchampin/ld-patch-testsuite/master/"
    LOCAL_PATH = ::File.expand_path("../testsuite", __FILE__) + '/'

    class << self
      alias_method :original_open_file, :open_file
    end

    ##
    # Override to use Patron for http and https, Kernel.open otherwise.
    #
    # @param [String] filename_or_url to open
    # @param  [Hash{Symbol => Object}] options
    # @option options [Array, String] :headers
    #   HTTP Request headers.
    # @return [IO] File stream
    # @yield [IO] File stream
    def self.open_file(filename_or_url, **options, &block)
      case
      when filename_or_url.to_s =~ /^file:/
        path = filename_or_url[5..-1]
        Kernel.open(path.to_s, **options, &block)
      when (filename_or_url.to_s =~ %r{^#{REMOTE_PATH}} && Dir.exist?(LOCAL_PATH))
        localpath = RDF::URI(filename_or_url).dup
        localpath.query = nil
        localpath = localpath.to_s.sub(REMOTE_PATH, LOCAL_PATH)
        response = begin
          ::File.open(localpath)
        rescue Errno::ENOENT => e
          raise IOError, e.message
        end
        document_options = {
          base_uri:     RDF::URI(filename_or_url),
          charset:      Encoding::UTF_8,
          code:         200,
          headers:      {}
        }
        #puts "use #{filename_or_url} locally"
        document_options[:headers][:content_type] = case filename_or_url.to_s
        when /\.nt$/      then 'application/n-triples'
        when /\.ttl$/     then 'text/turtle'
        when /\.ldpatch$/ then 'text/ldpatch'
        else                  'unknown'
        end

        document_options[:headers][:content_type] = response.content_type if response.respond_to?(:content_type)
        # For overriding content type from test data
        document_options[:headers][:content_type] = options[:contentType] if options[:contentType]

        remote_document = RDF::Util::File::RemoteDocument.new(response.read, **document_options)
        if block_given?
          yield remote_document
        else
          remote_document
        end
      else
        original_open_file(filename_or_url, **options) do |rd|
          # Override content_type
          if options[:contentType]
            rd.headers[:content_type] = options[:contentType]
            rd.instance_variable_set(:@content_type, options[:contentType].split(';').first)
          end

          if block_given?
            yield rd
          else
            rd
          end
        end
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
        g = RDF::Repository.load(file, format:  :ttl)
        JSON::LD::API.fromRDF(g) do |expanded|
          JSON::LD::API.frame(expanded, FRAME) do |framed|
            yield Manifest.new(framed)
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
      def format; :normalize; end # for debug output

      def base
        action.is_a?(Hash) ? action.fetch("base", action["data"]) : action
      end

      # Alias data and query
      def input
        url = case action
        when Hash then action['patch']
        else action
        end
        @input ||= RDF::Util::File.open_file(CGI.unescape(url)) {|f| f.read}
      end

      def data
        @data ||= RDF::Util::File.open_file(CGI.unescape(action["data"])) {|f| f.read} if action["data"]
      end

      def target_graph
        @graph ||= RDF::Graph.new do |g|
          g << RDF::Reader.open(CGI.unescape(action["data"]), base_uri: base) if action["data"]
        end
      end

      def expected
        @expected ||= RDF::Util::File.open_file(CGI.unescape(result)) {|f| f.read} if result
      end

      def expected_graph
        @expected_graph ||= RDF::Graph.new do |g|
          g << RDF::Reader.open(CGI.unescape(result), base_uri: base) if result
        end
      end

      def evaluate?
        Array(attributes['@type']).join(" ").match?(/Eval/)
      end

      def syntax?
        Array(attributes['@type']).join(" ").match?(/Syntax/)
      end

      def positive_test?
        !Array(attributes['@type']).join(" ").match?(/Negative/)
      end

      def negative_test?
        !positive_test?
      end

      # Create a logger initialized with the content of `debug`
      def logger
        @logger ||= begin
          l = RDF::Spec.logger
          debug.each {|d| l.debug(d)}
          l
        end
      end

      def inspect
        "<Entry id\n" +
        "  id: #{self.id}\n" +
        "  type: #{self.type}\n" +
        "  name: #{self.name}\n" +
        (self.action.is_a?(Hash) ?
          "  action.base: #{self.action['base']}\n" +
          "  action.data: #{self.action['data']}\n" +
          "  action.patch: #{self.action['patch']}\n"
        : "  action: #{self.action}"
        ) +
        "  result: #{self.result}\n" +
        "  syntax?: #{syntax?.inspect}\n" +
        "  positive?: #{positive_test?.inspect}\n" +
        "  evaluate?: #{evaluate?.inspect}\n" +
        ">"
      end
    end
  end
end