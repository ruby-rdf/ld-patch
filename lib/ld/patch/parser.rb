require 'ebnf'
require 'ebnf/ll1/parser'
require 'ld/patch/meta'

module LD::Patch
  ##
  # A parser for the LD Patch grammar.
  #
  # @see http://www.w3.org/TR/ldpatch/#concrete-syntax
  # @see http://en.wikipedia.org/wiki/LR_parser
  class Parser
    include LD::Patch::Meta
    include LD::Patch::Terminals
    include EBNF::PEG::Parser
    include RDF::Util::Logger

    ##
    # Any additional options for the parser.
    #
    # @return [Hash]
    attr_reader   :options

    ##
    # The current input string being processed.
    #
    # @return [String]
    attr_accessor :input

    ##
    # The internal representation of the result
    # @return [Array]
    attr_accessor :result

    # Terminals passed to lexer. Order matters!
    terminal(:ANON,                 ANON) do |value|
      bnode
    end
    terminal(:BLANK_NODE_LABEL,     BLANK_NODE_LABEL) do |value|
      bnode(value[2..-1])
    end
    terminal(:IRIREF,               IRIREF, unescape: true) do |value|
      begin
        iri(value[1..-2])
      rescue ArgumentError => e
        raise ParseError, e.message
      end
    end
    terminal(:DOUBLE,               DOUBLE) do |value|
      # Note that a Turtle Double may begin with a '.[eE]', so tack on a leading
      # zero if necessary
      value = value.sub(/\.([eE])/, '.0\1')
      input[:literal] = literal(value, datatype: RDF::XSD.double)
    end
    terminal(:DECIMAL,              DECIMAL) do |value|
      # Note that a Turtle Decimal may begin with a '.', so tack on a leading
      # zero if necessary
      value = "0#{token.value}" if token.value[0,1] == "."
      literal(value, datatype: RDF::XSD.decimal)
    end
    terminal(:INTEGER,              INTEGER) do |value|
      literal(value, datatype: RDF::XSD.integer)
    end
    terminal(:PNAME_LN,             PNAME_LN, unescape: true) do |value|
      prefix, suffix = value.split(":", 2)
      ns(prefix, suffix)
    end
    terminal(:PNAME_NS,             PNAME_NS) do |value, prod|
      prefix = value[0..-2]

      # Two contexts, one when prefix is being defined, the other when being used
      prod == :prefixId ? prefix : ns(prefix, nil)
    end
    terminal(:STRING_LITERAL_LONG_SINGLE_QUOTE, STRING_LITERAL_LONG_SINGLE_QUOTE, unescape: true) do |value|
      value[3..-4]
    end
    terminal(:STRING_LITERAL_LONG_QUOTE, STRING_LITERAL_LONG_QUOTE, unescape: true) do |value|
      input[:string] = value[3..-4]
    end
    terminal(:STRING_LITERAL_QUOTE, STRING_LITERAL_QUOTE, unescape: true) do |value|
      value[1..-2]
    end
    terminal(:STRING_LITERAL_SINGLE_QUOTE, STRING_LITERAL_SINGLE_QUOTE, unescape: true) do |value|
      value[1..-2]
    end
    terminal(:VAR1, VAR1) do |value|
      variable(value[1..-1])
    end

    # Keyword terminals
    #terminal(nil, STR_EXPR) do |prod, token, input|
    #  case token.value
    #  when '^'             then input[:reverse] = token.value
    #  when '/'             then input[:slash] = token.value
    #  when '!'             then input[:not] = token.value
    #  when 'a'             then input[:predicate] = (a = RDF.type.dup; a.lexical = 'a'; a)
    #  when /true|false/    then input[:literal] = RDF::Literal::Boolean.new(token.value)
    #  when '@prefix'       then input[:prefix] = token.value
    #  when %r{
    #      AddNew|Add|A|
    #      Bind|B|
    #      Cut|C|
    #      DeleteExisting|Delete|DE|D|
    #      UpdateList|UL|
    #      @prefix
    #    }x
    #    input[token.value.to_sym] = token.value
    #  else
    #    #add_prod_datum(:string, token.value)
    #  end
    #end

    terminal(:LANGTAG,              LANGTAG) do |value|
      value[1..-1]
    end

    # [1]	ldpatch	::=	prologue statement*
    start_production(:ldpatch, as_hash: true)
    production(:ldpatch) do |value|
      patch = Algebra::Patch.new(*value[:_ldpatch_1])
      prefixes.empty? ? patch : Algebra::Prefix.new(prefixes.to_a, patch)
    end

    # [4]	bind	::=	("Bind" | "B") VAR1 value path? "."
    start_production(:bind, as_hash: true)
    production(:bind) do |value|
      path = Algebra::Path.new(*Array(value[:_bind_2]))
      Algebra::Bind.new(value[:VAR1], value[:value], path)
    end

    # [5]	add	::=	("Add" | "A") "{" graph "}" "."
    start_production(:add, as_hash: true)
    production(:add) do |value|
      Algebra::Add.new(value[:graph], new: false)
    end

    # [6]	addNew	::=	("AddNew" | "AN") "{" graph "}" "."
    start_production(:addNew, as_hash: true)
    production(:addNew) do |value|
      Algebra::Add.new(value[:graph], new: true)
    end

    # [7]	delete ::=	("Delete" | "D") "{" graph "}" "."
    start_production(:delete, as_hash: true)
    production(:delete) do |value|
      Algebra::Delete.new(value[:graph], existing: false)
    end

    # [8]	deleteExisting	::=	("DeleteExisting" | "DE") "{" graph "}" "."
    start_production(:deleteExisting, as_hash: true)
    production(:deleteExisting) do |value|
      Algebra::Delete.new(value[:graph], existing: true)
    end

    # [9]	cut	::=	("Cut" | "C") VAR1 "."
    start_production(:cut, as_hash: true)
    production(:cut) do |value|
      Algebra::Cut.new(value[:VAR1])
    end

    # [10] updateList ::= ("UpdateList" | "UL") varOrIRI predicate slice collection "."
    start_production(:updateList, as_hash: true)
    production(:updateList) do |value|
      var_or_iri = value[:varOrIRI]
      Algebra::UpdateList.new(var_or_iri, value[:predicate], value[:slice][:slice1], value[:slice][:slice2], value[:collection][:collection].to_a)
    end

    # [11t]   predicate       ::=     iri
    production(:predicate) {|value| value.first[:iri]}

    # [13]    path            ::=     ( '/' step | constraint )*
    production(:_path_2) {|value| value.last[:step]}

    # [14]    step            ::=     '^' iri | iri | INTEGER
    production(:step) do |value|
      case value
      when RDF::URI     then value
      when RDF::Literal then Algebra::Index.new(value)
      else                   Algebra::Reverse.new(value.last[:iri])
      end
    end

    # [15] constraint ::= '[' path ( '=' value )? ']' | '!'
    production(:constraint) do |value|
      case value
      when "!" then Algebra::Constraint.new(:unique)
      else value
      end
    end

    start_production(:_constraint_1, as_hash: true)
    production(:_constraint_1) do |value|
      path = Algebra::Path.new(*Array(value[:path]))
      if value[:_constraint_2]
        Algebra::Constraint.new(path, value[:_constraint_2].last[:value])
      else
        Algebra::Constraint.new(path)
      end
    end

    # [16] slice ::= INDEX? '..' INDEX?
    start_production(:slice, as_hash: true)
    production(:slice) do |value|
      {slice1: value[:_slice_1], slice2: value[:_slice_2]}
    end

    # [4t]    prefixID        ::=     "@prefix" PNAME_NS IRIREF "."
    start_production(:prefixID, as_hash: true)
    production(:prefixID) do |value|
      prefix = value[:PNAME_NS]
      iri = value[:IRIREF]
      log_debug("prefixID") {"Defined prefix #{prefix.inspect} mapping to #{iri.inspect}"}
      prefix(prefix, iri)
    end

    # [18] graph ::= triples ( '.' triples )* '.'?
    start_production(:graph, as_hash: true)
    production(:graph) do |value|
      Array(value[:triples]).concat(Array(value[:_graph_1]))
    end
    production(:_graph_2) {|value| value.last[:_graph_3]}

    # [6t]    triples         ::=     subject predicateObjectList | blankNodePropertyList predicateObjectList?
    production(:_triples_1) do |value|
      value.last[:predicateObjectList]
    end
    production(:_triples_2) do |value|
      value.last[:predicateObjectList]
    end

    # [10t*] subject ::= iri | BlankNode | collection | VAR1
    production(:subject) do |value, data|
      res = {}
      res[:subject] = case value
      when RDF::URI, RDF::Node, RDF::Query::Variable then value
      else
        # Collection
        list = value[:collection]
          # Add collection patterns
          list.each_statement do |statement|
            (res[:triples] ||= []) << RDF::Query::Pattern.from(statement)
          end

        list.subject
      end
      prod_data[:subject] = res[:subject]
      res
    end

    # [12t*] object ::= iri | BlankNode | collection | blankNodePropertyList | literal | VAR1
    production(:object) do |value, data|
      res = {}
      res[:object] = case value
      when RDF::Term then value
      else
        if list = value[:collection]
          # Add collection patterns
          list.each_statement do |statement|
            (res[:triples] ||= []) << RDF::Query::Pattern.from(statement)
          end

          list.subject
        elsif bpl = value[:blankNodePropertyList]
          res[:triples] = bpl[:triples]
          bpl[:subject]
        end
      end
      res[:object]
      res
    end

    # [14t] blankNodePropertyList ::= "[" predicateObjectList "]"
    start_production(:blankNodePropertyList, as_hash: true) {|data| data[:subject] = self.bnode}
    production(:blankNodePropertyList) {|value| value[:predicateObjectList]}

    # [7t]    predicateObjectList     ::=     verb objectList (';' (verb objectList)?)*
    # Returns triples
    start_production(:predicateObjectList, as_hash: true) {|data| data[:subject] = prod_data[:subject]}
    production(:predicateObjectList) do |value, data|
      triples = Array(value[:triples])
      verb = value[:verb] == 'a' ?
        (a = RDF.type.dup; a.lexical = 'a'; a) :
        value[:verb]
      Array(value[:objectList][:objects]).each do |object|
        triples << RDF::Query::Pattern.new(data[:subject], verb, object)
      end
      triples + Array(value[:objectList][:triples])
    end

    # [8t]    objectList      ::=     object (',' object)*
    start_production(:objectList, as_hash: true)
    production(:objectList) do |value|
      objects = Array(value[:object][:object])
      triples = Array(value[:object][:triples])
      value[:_objectList_1].each do |object_list|
        objects << object_list[:object]
        triples.concat(object_list[:triples])
      end
      {objects: objects, triples: triples}
    end
    production(:_objectList_1) do |value|
      value
    end
    production(:_objectList_2) {|value| value.last.values.first}

    # [15t] collection ::= "(" object* ")"
    start_production(:collection, as_hash: true)
    production(:collection) do |value|
      objects = value[:_collection_1].map {|item| item[:object]}
      {collection: RDF::List[*objects], triples: value[:triples]}
    end

    # [129s]   RDFLiteral   ::=   String ( LANGTAG | ( '^^' iri ) )?
    start_production(:RDFLiteral, as_hash: true)
    production(:RDFLiteral) do |value|
      RDF::Literal(value[:String], datatype: value[:datatype], language: value[:language])
    end
    production(:_RDFLiteral_2) do |value|
      value[:LANGTAG] ?
        {language: value[:LANGTAG].to_s.downcase.to_sym} :
        {datatype: value[:_RDFLiteral_3]}
    end
    production(:_RDFLiteral_3) {|value| value.last[:iri]}

    ##
    # Initializes a new parser instance.
    #
    # @param  [String, IO, StringIO, #to_s] input
    # @param  [Hash{Symbol => Object}] options
    # @option options [#to_s]    :base_uri     (nil)
    #   the base URI to use when resolving relative URIs
    # @option options [#to_s]    :anon_base     ("b0")
    #   Basis for generating anonymous Nodes
    # @option options [Boolean] :resolve_iris (false)
    #   Resolve prefix and relative IRIs, otherwise, when serializing the parsed SSE as S-Expressions, use the original prefixed and relative URIs along with `base` and `prefix` definitions.
    # @option options [Boolean]  :validate (false)
    #   whether to validate the parsed statements and values
    # @option options [Logger, #write, #<<] :logger
    #   Record error/info/debug output
    # @yield  [parser] `self`
    # @yieldparam  [LD::Patch::Parser] parser
    # @return [LD::Patch::Parser] The parser instance, or result returned from block
    def initialize(input = nil, **options, &block)
      @input = case input
      when IO, StringIO then input.read
      else input.to_s.dup
      end
      @input.encode!(Encoding::UTF_8) if @input.respond_to?(:encode!)
      @options = {anon_base: "b0", validate: true}.merge(options)
      @errors = @options[:errors]
      @options[:debug] ||= case
      when options[:progress] then 2
      when options[:validate] then (@errors ? nil : 1)
      end

      log_debug("base IRI") {base_uri.inspect}
      log_debug("validate") {validate?.inspect}

      @vars = {}

      if block_given?
        case block.arity
          when 0 then instance_eval(&block)
          else block.call(self)
        end
      end
    end

    ##
    # Accumulated errors found during processing
    # @return [Array<String>]
    attr_reader :errors

    alias_method :peg_parse, :parse
    # Parse patch
    #
    # The result is an S-List. Productions return an array such as the following:
    #
    #   (prefix ((: <http://example/>))
    #
    # @param [Symbol, #to_s] prod The starting production for the parser.
    #   It may be a URI from the grammar, or a symbol representing the local_name portion of the grammar URI.
    # @return [SPARQL::Algebra::Operator, Object]
    # @raise [ParseError] when illegal grammar detected.
    def parse(prod = :ldpatch)
      @result = peg_parse(@input,
        prod,
        LD::Patch::Meta::RULES,
        whitespace: WS,
        **@options
      )

      # Validate resulting expression
      @result.validate! if @result && validate?
      @result
    rescue EBNF::PEG::Parser::Error =>  e
      raise LD::Patch::ParseError.new(e.message, lineno: e.lineno)
    end

    ##
    # Returns the Base URI defined for the parser,
    # as specified or when parsing a BASE prologue element.
    #
    # @example
    #   base  #=> RDF::URI('http://example.com/')
    #
    # @return [HRDF::URI]
    def base_uri
      RDF::URI(@options[:base_uri])
    end

    ##
    # Set the Base URI to use for this parser.
    #
    # @param  [RDF::URI, #to_s] iri
    #
    # @example
    #   base_uri = RDF::URI('http://purl.org/dc/terms/')
    #
    # @return [RDF::URI]
    def base_uri=(iri)
      @options[:base_uri] = RDF::URI(iri)
    end

    ##
    # Returns the URI prefixes currently defined for this parser.
    #
    # @example
    #   prefixes[:dc]  #=> RDF::URI('http://purl.org/dc/terms/')
    #
    # @return [Hash{Symbol => RDF::URI}]
    # @since  0.3.0
    def prefixes
      @options[:prefixes] ||= {}
    end

    ##
    # Defines the given named URI prefix for this parser.
    #
    # @example Defining a URI prefix
    #   prefix :dc, RDF::URI('http://purl.org/dc/terms/')
    #
    # @example Returning a URI prefix
    #   prefix(:dc)    #=> RDF::URI('http://purl.org/dc/terms/')
    #
    # @overload prefix(name, uri)
    #   @param  [Symbol, #to_s]   name
    #   @param  [RDF::URI, #to_s] uri
    #
    # @overload prefix(name)
    #   @param  [Symbol, #to_s]   name
    #
    # @return [RDF::URI]
    def prefix(name = nil, iri = nil)
      name = name.to_s.empty? ? nil : (name.respond_to?(:to_sym) ? name.to_sym : name.to_s.to_sym)
      iri.nil? ? prefixes[name] : prefixes[name] = iri
    end

    private
    ##
    # Returns `true` if parsed statements and values should be validated.
    #
    # @return [Boolean] `true` or `false`
    # @since  0.3.0
    def resolve_iris?
      @options[:resolve_iris]
    end

    ##
    # Returns `true` when resolving IRIs, otherwise BASE and PREFIX are retained in the output algebra.
    #
    # @return [Boolean] `true` or `false`
    # @since  1.0.3
    def validate?
      @options[:validate]
    end

    ##
    # Return variable allocated to an ID.
    # If no ID is provided, a new variable
    # is allocated. Otherwise, any previous assignment will be used.
    # @return [RDF::Query::Variable]
    def variable(id, distinguished = true)
      @vars[id] ||= begin
        v = RDF::Query::Variable.new(id)
        v.distinguished = distinguished
        v
      end
    end

    # Generate a BNode identifier
    def bnode(id = nil)
      unless id
        id = @options[:anon_base]
        @options[:anon_base] = @options[:anon_base].succ
      end
      # Don't use provided ID to avoid aliasing issues when re-serializing the graph, when the bnode identifiers are re-used
      (@bnode_cache ||= {})[id.to_s] ||= begin
        new_bnode = RDF::Node.new
        new_bnode.lexical = "_:#{id}"
        new_bnode
      end
    end

    # Create URIs
    def iri(value)
      # If we have a base URI, use that when constructing a new URI
      iri = if base_uri
        u = base_uri.join(value.to_s)
        u.lexical = "<#{value}>" unless u.to_s == value.to_s || resolve_iris?
        u
      else
        RDF::URI(value)
      end

      iri.validate! if validate? && iri.respond_to?(:validate)
      #iri = RDF::URI.intern(iri) if intern?
      iri
    end

    def ns(prefix, suffix)
      error("pname", "undefined prefix #{prefix.inspect}") unless prefix(prefix)
      base = prefix(prefix).to_s
      suffix = suffix.to_s.sub(/^\#/, "") if base.index("#")
      log_debug {"ns(#{prefix.inspect}): base: '#{base}', suffix: '#{suffix}'"}
      iri = iri(base + suffix.to_s)
      # Cause URI to be serialized as a lexical
      iri.lexical = "#{prefix}:#{suffix}" unless resolve_iris?
      iri
    end

    # Create a literal
    def literal(value, **options)
      options = options.dup
      # Internal representation is to not use xsd:string, although it could arguably go the other way.
      options.delete(:datatype) if options[:datatype] == RDF::XSD.string
      log_debug("literal") do
        "value: #{value.inspect}, " +
        "options: #{options.inspect}, " +
        "validate: #{validate?.inspect}, "
      end
      RDF::Literal.new(value, validate: validate?, **options)
    end
  end
end


# Update RDF::Node to set lexical representation of BNode
##
# Extensions for RDF::URI
class RDF::Node
  # Original lexical value of this URI to allow for round-trip serialization.
  def lexical=(value); @lexical = value; end
  def lexical; @lexical; end
end
