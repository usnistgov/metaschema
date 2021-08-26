Transformations in this subdirectory support Metaschema composition, that is the canonical set of steps whereby a conceptual metaschema (expressed in a set of definitions allocated among modules) is translated into a concrete, complete and standalone metaschema instance, suitable for further processing.

Generally, metaschema composition will be a necessary preliminary to producing a schema, documentation or analysis of a single metaschema.

### Metaschema Composition

The following transformations executed in sequence provide for composition of Metaschema inputs into a standalone metaschema instance.

- `metaschema-collect.xsl`
- `metaschema-build-refs.xsl`
- `metaschema-trim-extra-modules.xsl`
- `metaschema-prune-unused-definitions.xsl` 
- `metaschema-resolve-use-names.xsl`
- `metaschema-resolve-sibling-names.xsl` 
- `metaschema-digest.xsl`
- `annotate-composition.xsl`

### Additional

The following are used in the documentation pipeline:

- `annotate-composition.xsl`
- `make-model-map.xsl`
- `unfold-model-map.xsl`
- `annotate-model-map.xsl`

### xpl

#### metaschema-compose.xpl

- XProc pipeline version 1.0 (10 steps)
- **Purpose:** Produce a standalone Metaschema instance representing a data model, suitable for further processing
- **Input:** A valid and correct OSCAL Metaschema instance linked to its modules (also valid and correct)
- **Output:** A completely standalone Metaschema instance fully resolving and disambiguating links among definitions, suitable for further processing.

- Runtime dependency: `annotate-composition.xsl`

- Runtime dependency: `metaschema-build-refs.xsl`

- Runtime dependency: `metaschema-collect.xsl`

- Runtime dependency: `metaschema-digest.xsl`

- Runtime dependency: `metaschema-prune-unused-definitions.xsl`

- Runtime dependency: `metaschema-resolve-sibling-names.xsl`

- Runtime dependency: `metaschema-resolve-use-names.xsl`

- Runtime dependency: `metaschema-trim-extra-modules.xsl`
