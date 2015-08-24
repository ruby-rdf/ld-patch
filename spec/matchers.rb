# coding: utf-8
require 'rdf/isomorphic'
require 'json'
JSON_STATE = JSON::State.new(
   indent:        "  ",
   space:         " ",
   space_before:  "",
   object_nl:     "\n",
   array_nl:      "\n"
 )

def normalize(graph)
  case graph
  when RDF::Queryable then graph
  when IO, StringIO
    RDF::Graph.new.load(graph, base_uri:  @info.about)
  else
    # Figure out which parser to use
    g = RDF::Repository.new
    reader_class = detect_format(graph)
    reader_class.new(graph, base_uri:  @info.about).each {|s| g << s}
    g
  end
end

Info = Struct.new(:about, :coment, :trace, :input, :result, :action, :expected)

RSpec::Matchers.define :be_equivalent_graph do |expected, info|
  match do |actual|
    @info = if info.respond_to?(:input)
      info
    elsif info.is_a?(Hash)
      identifier = info[:identifier] || expected.is_a?(RDF::Enumerable) ? expected.context : info[:about]
      trace = info[:trace]
      if trace.is_a?(Array)
        trace = trace.map {|s| s.dup.force_encoding(Encoding::UTF_8)}.join("\n")
      end
      Info.new(identifier, info[:comment] || "", trace)
    else
      Info.new(expected.is_a?(RDF::Enumerable) ? expected.context : info, info.to_s)
    end
    @expected = normalize(expected)
    @actual = normalize(actual)
    @actual.isomorphic_with?(@expected) rescue false
  end

  failure_message do |actual|
    info = @info.respond_to?(:comment) ? @info.comment : @info.inspect
    if @expected.is_a?(RDF::Graph) && @actual.size != @expected.size
      "Graph entry count differs:\nexpected: #{@expected.size}\nactual:   #{@actual.size}"
    elsif @expected.is_a?(Array) && @actual.size != @expected.length
      "Graph entry count differs:\nexpected: #{@expected.length}\nactual:   #{@actual.size}"
    else
      "Graph differs"
    end +
    "\n#{info + "\n" unless info.empty?}" +
    (@info.action ? "Input file: #{@info.action}\n" : "") +
    (@info.result ? "Result file: #{@info.result}\n" : "") +
    "Unsorted Expected:\n#{@expected.dump(:ttl, standard_prefixes:  true)}" +
    "Unsorted Results:\n#{@actual.dump(:ttl, standard_prefixes:  true)}" +
    (@info.trace ? "\nDebug:\n#{@info.trace}" : "")
  end  
end

RSpec::Matchers.define :generate do |expected, options = {}|
  def parser(options = {})
    @debug = options[:progress] ? 2 : []
    Proc.new do |input|
      parser = LD::Patch::Parser.new(input, {debug: @debug, resolve_iris: false}.merge(options))
      options[:production] ? parser.parse(options[:production]) : parser.parse
    end
  end

  def normalize(obj)
    if obj.is_a?(String)
      obj.gsub(/\s+/m, ' ').
        gsub(/\s+\)/m, ')').
        gsub(/\(\s+/m, '(').
        strip
    else
      obj
    end
  end

  match do |input|
    case
    when expected == LD::Patch::ParseError
      expect {parser(options).call(input)}.to raise_error(expected)
    when expected.is_a?(String)
      @actual = parser(options).call(input)
      expect(normalize(@actual.to_sxp)).to eq normalize(expected)
    else
      @actual = parser(options).call(input)
      expect(@actual).to eq expected
    end
  end
  
  failure_message do |input|
    "Input        : #{input}\n"
    case expected
    when String
      "Expected     : #{expected}\n"
    else
      "Expected     : #{expected.inspect}\n" +
      "Expected(sse): #{expected.to_sxp}\n"
    end +
    "Actual       : #{actual.inspect}\n" +
    "Actual(sse)  : #{actual.to_sxp}\n" +
    "Processing results:\n#{@debug.is_a?(Array) ? @debug.join("\n") : ''}"
  end
end
