Transformations in this subdirectory support Metaschema composition, that is the canonical set of steps whereby a conceptual metaschema (expressed in a set of definitions allocated among modules) is translated into a concrete, complete and standalone metaschema instance, suitable for further processing.

Generally, metaschema composition will be a necessary preliminary to producing a schema, documentation or analysis of a single metaschema.


### Implicit in many pipelines

The composition process is implicit in many (most) end-to-end metaschema processes including both schema and docs generation.

For testing, entry points are also isolated for standalone metaschema composition.

(TBD: a consistent way to unify these and keep them aligned)

### XSLT for end-to-end

Single metaschema input, with its imports available, produces single compose metaschema results.

* `../nist-metaschema-COMPOSE.xsl`
* With that XSLT as context, executing path `/*/*[@name='transformation-sequence']/*/('1. &#96;' || replace(.,'.*/','') || '&#96;') => string-join('&#xA;')` we get (in Markdown):

(NB: keeping this up to date enables us to track deltas in the documentation so please do edit/amend as this pipeline changes)

1. `metaschema-collect.xsl`
1. `metaschema-build-refs.xsl`
1. `metaschema-trim-extra-modules.xsl`
1. `metaschema-prune-unused-definitions.xsl`
1. `metaschema-resolve-use-names.xsl`
1. `metaschema-resolve-sibling-names.xsl`
1. `metaschema-digest.xsl`
1. `annotate-composition.xsl`

### Additional processes

The following are used in the documentation pipeline:

- `annotate-composition.xsl`
- `make-model-map.xsl`
- `unfold-model-map.xsl`
- `annotate-model-map.xsl`

### XProc for debugging (with more transparency as to step results)

Single metaschema input, with its imports available, run in an XPrc pipeline with configurable results (write any or none) giving greater transparency over intermediate steps.

* `metaschema-compose.xpl`
* With the XProc as context, execute
`/*/*:xslt/*:input/*:document/@href/('1. &#96;' || . || '&#96;') => string-join('&#xA;')`

(NB: as above, please help keep this listing up to date)

1. `metaschema-collect.xsl`
1. `metaschema-build-refs.xsl`
1. `metaschema-trim-extra-modules.xsl`
1. `metaschema-prune-unused-definitions-a9.xsl`
1. `metaschema-resolve-use-names.xsl`
1. `metaschema-resolve-sibling-names.xsl`
1. `metaschema-digest.xsl`
1. `annotate-composition.xsl`
