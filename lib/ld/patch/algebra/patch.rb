module LD::Patch::Algebra

  ##
  # The LD Patch `patch` operator.
  #
  # Transactionally iterates over all operands building bindings along the way
  class Patch < SPARQL::Algebra::Operator
    include SPARQL::Algebra::Update

    NAME = :patch

    ##
    # Executes this upate on the given `writable` graph or repository.
    #
    # @param  [RDF::Queryable] queryable
    #   the graph or repository to write
    # @param  [Hash{Symbol => Object}] options
    #   any additional options
    # @return [RDF::Queryable]
    #   Returns queryable.
    # @raise [Error]
    #   If any error is caught along the way, and rolls back the transaction
    def execute(queryable, options = {})
      debug(options) {"Delete"}

      # FIXME: due to insufficient transaction support, this is implemented by running through operands twice: the first using a clone of the graph, and the second acting on the graph directly
      graph = RDF::Graph.new << queryable
      loop do
        operands.inject(RDF::Query::Solutions.new([RDF::Query::Solution.new])) do |bindings, op|
          # Invoke operand using bindings from prvious operation
          op.execute(graph, options.merge(bindings: bindings))
        end

        break if graph.equal?(queryable)
        graph = queryable
      end
    end
  end
end