module LD::Patch::Algebra

  ##
  # The LD Patch `add` operator.
  #
  # The Add operation is used to add triples to the target graph with or without allowing duplicates.
  #
  # @example
  #   (add ((<a> <b> <c>)))
  #
  class Add < SPARQL::Algebra::Operator::Unary
    include SPARQL::Algebra::Update

    NAME = :add

    ##
    # Executes this upate on the given `writable` graph or repository.
    #
    # @param  [RDF::Queryable] queryable
    #   the graph or repository to write
    # @param  [Hash{Symbol => Object}] options
    #   any additional options
    # @option options [Boolean] :new
    #   Specifies that triples may not already exist in the target graph
    # @return [RDF::Queryable]
    #   Returns queryable.
    # @raise [Error]
    #   If the :new option is specified and any triples already exist in queryable
    # @see    http://www.w3.org/TR/sparql11-update/
    def execute(queryable, options = {})
      debug(options) {"Add"}
      bindings = options.fetch(:bindings)
      solution = bindings.first

      # Bind variables to triples
      triples = operand(0).dup.replace_vars! do |var|
        raise Error, "Operand uses unbound variable #{var.inspect}" unless solution.bound?(var)
        solution[var]
      end

      # If `:new` is specified, verify that no triple in triples exists in queryable
      if options[:new]
        triples.each do |triple|
          raise Error, "Target graph contains added triple #{triple.to_ntriples}" if queryable.has_statement?(triple)
        end
      end

      queryable.insert(*triples)
    end
  end
end