module LD::Patch::Algebra

  ##
  # The LD Patch `index` operator
  class Index < SPARQL::Algebra::Operator::Unary
    include SPARQL::Algebra::Query

    NAME = :index

    ##
    # Executes this upate on the given `writable` graph or repository.
    #
    # @param  [RDF::Queryable] queryable
    #   the graph or repository to write
    # @param  [Hash{Symbol => Object}] options
    #   any additional options
    # @option options [Boolean] :new
    #   Specifies that triples may not exist in the output graph
    # @return [RDF::Queryable]
    #   Returns queryable.
    # @raise [IOError]
    #   If no triples are identified, or the operand is an unbound variable
    # @see    http://www.w3.org/TR/sparql11-update/
    def execute(queryable, options = {})
      debug(options) {"Index"}

      queryable
    end
  end
end