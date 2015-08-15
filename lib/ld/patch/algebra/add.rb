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
    #   Specifies that triples may not exist in the output graph
    # @return [RDF::Queryable]
    #   Returns queryable.
    # @raise [IOError]
    #   If the :new option is specified and any triples already exist in queryable
    # @see    http://www.w3.org/TR/sparql11-update/
    def execute(queryable, options = {})
      debug(options) {"Add"}

      queryable
    end
  end # Add
end