module LD::Patch::Algebra

  ##
  # The LD Patch `reverse` operator
  #
  # Finds all the terms which are the subject of triples where the `operand` is the predicate and input terms are objects.
  #
  # @example
  #     (reverse :p)
  #
  #   Queries `queryable` for subjects where input terms are objects and the predicate is `:p`, by executing the `reverse` operand using input terms to get a set of output terms.
  class Reverse < SPARQL::Algebra::Operator::Unary
    include SPARQL::Algebra::Query

    NAME = :reverse

    ##
    # Executes this upate on the given `writable` graph or repository.
    #
    # @param  [RDF::Queryable] queryable
    #   the graph or repository to write
    # @param  [Hash{Symbol => Object}] options
    #   any additional options
    # @option options [Array<RDF::Term>] starting terms
    # @return [RDF::Query::Solutions] solutions with `:term` mapping
    def execute(queryable, options = {})
      debug(options) {"Reverse"}
      terms = Array(options.fetch(:terms))

      RDF::Query::Solutions.new terms.map do |object|
        queryable.query(subject: subject, predicate: op, &:object)
      end.flatten.map do |term|
        RDF::Query::Solution.new(path: term)
      end
    end
  end
end