module LD::Patch::Algebra

  ##
  # The LD Patch `slice` operator.
  #
  class Slice < SPARQL::Algebra::Operator::Ternary
    include SPARQL::Algebra::Update

    NAME = :slice

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
      debug(options) {"Slice"}

      queryable
    end
  end
end