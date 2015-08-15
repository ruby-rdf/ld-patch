module LD::Patch::Algebra

  ##
  # The LD Patch `constraint` operator.
  class Constraint < SPARQL::Algebra::Operator
    include SPARQL::Algebra::Query

    NAME = :constraint

    ##
    # If a path is given, constructs a SPARQL Algebra path operator to bind the variable to the end of the path, otherwise, binds value to variable.
    #
    # @param  [RDF::Queryable] queryable
    #   the graph or repository to write
    # @param  [Hash{Symbol => Object}] options
    #   any additional options
    # @return [RDF::Query::Solution] A solution including passed bindings with `var` bound to the solution.
    # @raise [Error]
    #   If path does not evaluate to a single term
    # @see    http://www.w3.org/TR/sparql11-update/
    def execute(queryable, options = {})
      debug(options) {"Constraint"}
    end
  end
end