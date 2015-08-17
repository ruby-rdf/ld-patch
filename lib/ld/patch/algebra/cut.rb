module LD::Patch::Algebra

  ##
  # The LD Patch `cut` operator.
  #
  # The Cut operation is recursively remove triples from some starting node.
  #
  # @example
  #   (cut ?a)
  #
  class Cut < SPARQL::Algebra::Operator::Unary
    include SPARQL::Algebra::Update
    include SPARQL::Algebra::Evaluatable

    NAME = :cut

    ##
    # Executes this upate on the given `writable` graph or repository.
    #
    # @param  [RDF::Queryable] queryable
    #   the graph or repository to write
    # @param  [Hash{Symbol => Object}] options
    #   any additional options
    # @return [RDF::Queryable]
    #   Returns queryable.
    # @raise [IOError]
    #   If no triples are identified, or the operand is an unbound variable
    # @see    http://www.w3.org/TR/sparql11-update/
    def execute(queryable, options = {})
      debug(options) {"Cut"}
      bindings = options.fetch(:bindings)
      solution = bindings.first
      var = operand(0)

      # Bind variable
      raise LD::Patch::Error, "Operand uses unbound variable #{var.inspect}" unless solution.bound?(var)
      var = solution[var]

      # Get triples to delete using consice bounded description
      queryable.concise_bounded_description(var) do |statement|
        queryable.delete(statement)
      end

      # Also delete triples having var in the object position
      queryable.query(object: var).each do |statement|
        queryable.delete(statement)
      end
      queryable
    end
  end
end