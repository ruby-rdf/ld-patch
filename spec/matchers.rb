# coding: utf-8
require 'json'
JSON_STATE = JSON::State.new(
   indent:        "  ",
   space:         " ",
   space_before:  "",
   object_nl:     "\n",
   array_nl:      "\n"
 )

RSpec::Matchers.define :generate do |expected, **options|
  def parser(options = {})
    Proc.new do |input|
      parser = LD::Patch::Parser.new(input, resolve_iris: false, **options)
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
    @input = input
    case
    when expected == LD::Patch::ParseError
      expect {parser(**options).call(input)}.to raise_error(expected)
    when expected.is_a?(Regexp)
      @actual = parser(**options).call(input)
      expect(normalize(@actual.to_sxp)).to match(expected)
    when expected.is_a?(String)
      @actual = parser(**options).call(input)
      expect(normalize(@actual.to_sxp)).to eq normalize(expected)
    else
      @actual = parser(**options).call(input)
      expect(@actual).to eq expected
    end
  end
  
  failure_message do |input|
    "Input        : #{@input}\n" +
    case expected
    when String
      "Expected     : #{normalize(expected)}\n"
    else
      "Expected     : #{expected.to_sxp}\n" +
      "Expected(raw): #{expected.inspect}\n"
    end +
    "Actual       : #{actual.to_sxp}\n" +
    "Actual(raw)  : #{actual.inspect}\n" +
    "Processing results:\n#{options[:logger]}"
  end
end
