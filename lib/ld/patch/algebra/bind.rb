module LD::Patch::Algebra

  ##
  # The LD Patch `bind` operator.
  #
  # The Bind operation is used to bind a single term to a variable.
  #
  # @example simple value to variable binding
  #   Bind ?x <http://example.org/s> . #=>
  #   SELECT ?x WHERE { ?x ?_0 ?_1 FILTER (?x = <http://example.org/s>)}
  #   (project (?x)
  #     (filter (= ?x <http://example.org/s>) (bgp (triple ?x ?_0 ?_1)))))
  #
  # @example constant path (filter-forward.ldpatch)
  #   Bind ?x <http://example.org/s> / <http://example.org/p1> . #=>
  #   SELECT ?x WHERE { <http://example.org/s> <http://example.org/p1> ?x)}
  #   (project (?x)
  #     (bgp (triple <http://example.org/s> <http://example.org/p1> ?x)))
  #
  # @example list index (path-at.ldpatch)
  #   Bind ?x <http://example.org/s> / 1 . #=>
  #   (bind ?x ??0
  #     ((index 1 <http://example.org/s> ??0)))
  #
  # @example reverse (path-backward.ldpath)
  #   Bind ?x <http://example.org/s> / ^<http://example.org/p1> . #=>
  #   SELECT ?x WHERE { <http://example.org/s> ^<http://example.org/p1> ?x
  #   (project (?x)
  #     (path <http://example.org/s> (reverse <http://example.org/p1>) ?x))
  #
  # @example constraint (path-filter-equal.ldpatch)
  #   Bind ?x <http://example.org/s> / <http://example.org/p2> [  / <http://example.org/l> = "b" ] . #=>
  #   SELECT ?x
  #   WHERE {
  #     <http://example.org/s> <http://example.org/p2> ?x .
  #     ?x <http://example.org/l> "b"
  #   }
  #   (project (?x)
  #     (bgp
  #       (triple <http://example.org/s> <http://example.org/p2> ?x)
  #       (triple ?x <http://example.org/l> "b")) )
  #
  # @example constraint (path-filter.ldpatch)
  #   Bind ?x <http://example.org/s> / <http://example.org/p2> [  / <http://example.org/p1> ] . #=>
  #   SELECT ?x
  #   WHERE {
  #     <http://example.org/s> <http://example.org/p2> ?x .
  #     ?x <http://example.org/l> ?_0
  #   }
  #   (project (?x)
  #     (bgp
  #       (triple <http://example.org/s> <http://example.org/p2> ?x)
  #       (triple ?x <http://example.org/l> ?_0)) )
  #
  # @example starting with a literal
  #   Bind ?x "a" / ^<http://example.org/l> / ^<http://example.org/p2> . #=>
  #   SELECT ?x WHERE { "a"  ^<http://example.org/p1> / ^<http://example.org/p2> ?x}
  #   (project (?x)
  #     (path "a"
  #       (seq
  #         (reverse <http://example.org/l>)
  #         (reverse <http://example.org/p2>)) ?x))
  #
  # @example unicity (path-unicity.ldpath)
  #   Bind ?x <http://example.org/s> / <http://example.org/p1> ! . #=>
  #   SELECT ?x
  #   WHERE {<http//example.org/s> <http://example.org/p1> ?x}
  #   GROUP BY ?x
  #   HAVING COUNT(?x) = 1
  #   (bind ?x ?0
  #     ((pattern <http://example.org/s> <http://example.org/p1> ??0)
  #      (unique ??0)))
  class Bind < SPARQL::Algebra::Operator::Ternary
    include SPARQL::Algebra::Query

    NAME = :bind

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
      debug(options) {"Bind"}
      var, value, path = operands

      if path
        results = path.execute(queryable)
        raise Error, "Bind path bound to #{results.length} terms, expected just one" unless results.length == 1
        bindings[var] = results.first[var]
      else
        bindings[var] = value
      end
      bindings
    end
  end
end