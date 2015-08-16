module LD::Patch::Algebra

  ##
  # The LD Patch `delete` operator (incuding `deleteExisting`).
  #
  # The Add operation is used to delete triples from the target graph with or without checking to see if the exist already.
  #
  # @example
  #   (add ((<a> <b> <c>)))
  #
  class Delete < SPARQL::Algebra::Operator::Unary
    include SPARQL::Algebra::Update

    NAME = :delete

    ##
    # Executes this upate on the given `writable` graph or repository.
    #
    # @param  [RDF::Queryable] queryable
    #   the graph or repository to write
    # @param  [Hash{Symbol => Object}] options
    #   any additional options
    # @option options [Boolean] :existing
    #   Specifies that triples must already exist in the target graph
    # @return [RDF::Queryable]
    #   Returns queryable.
    # @raise [Error]
    #   If no triples are identified, or the operand is an unbound variable
    # @see    http://www.w3.org/TR/sparql11-update/
    def execute(queryable, options = {})
      debug(options) {"Delete"}
      bindings = options.fetch(:bindings)
      solution = bindings.first

      # Bind variables to triples
      triples = operand(0).dup.replace_vars! do |var|
        raise Error, "Operand uses unbound variable #{var.inspect}" unless solution.bound?(var)
        solution[var]
      end

      # If `:new` is specified, verify that no triple in triples exists in queryable
      if options[:existing]
        triples.each do |triple|
          raise Error, "Target graph does not contain triple #{triple.to_ntriples}" unless queryable.has_statement?(triple)
        end
      end

      queryable.delete(*triples)
    end
  end
end