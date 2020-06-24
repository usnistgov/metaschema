# Metaschema refactoring

xslt-M4


Multiple models: catalog, profile, ssp, components ... (RAR etc.)
Multiple formats: XML, JSON, YAML (herein nominally FFF or GGG)

Processes, *per model*

All of these should have "production" and "debug" modes: production for ordinary operation; debugging to expose intermediate results and activate messaging/logging.

Since one implementation will be pure (dynamic) XSLT gluing transformations in sequence, some processes e.g. schema validation must be done outside so they should happen at terminal points only.

## SOURCES

- Set of metaschema documents (modules) comprising a metaschema
  - definitions for assemblies, fields and flags
  - inline samples
  - out of line samples
  - test instances for validation

## PROCESSES

- Metaschema compilation
  - Integrating modules ('composition')
    - Providing defaults
    - Resolving overrides/enhancements
	- Rewriting global field and flag definitions to local
	- 'noisy' mode to show which definitions are acquired from which modules
	    and how they are rewritten by overrides
  - Validating and embedded Metaschema examples
    - Both inline and out of line
  - Producing Unified explicated abstract model (or: 'exploded metaschema')
    - This is a fully expanded and resolved schema with annotations per data formats
	  from which a schema of any of the target formats can be produced as a *filter- (downhill transformation)
  - Produce XSD for "exploded instance"?
	  
- Metaschema -> schema
  - Produce format schema (XSD or JSON Schema) from exploded metaschema
  - Validate normative/test samples against schema

- Metaschema -> convertor
  - convert to unified format
  - convert from unified format
    - unit test these?
  - (Crossing with a different model) validate conversion results against target schema

- Metaschema -> docs
  - producing YAML for Hugo ingest
  - integrating sample data
    - running through conversions when necessary
  - producing model maps
  
## RESULTS

### Final results

- For format FFF, a schema for validating instances in that format to the Metaschema constraint set
- XSLT UP - An XSLT for converting into (XML-based) unified format from instances
    Can include markdown-pseudoparse logic as XSLT package
- XSLT DOWN - An XSLT for converting from into unified format into FFF
  - By hooking an UP transformation for format FFF with a DOWN transformation for format GGG, we get an FFF->GGG transformation (plus the opposite)
- Documentation
  - YAML descriptions
  - Code samples
  - A model map

### Intermediate results / useful artifacts

- Per metaschema:
	- Composed metaschema
	- Exploded metaschema
	- Exploded Instance XSD (maybe)

- Per FFF->GGG and GGG->FFF conversion
	- Exploded (intermediate) instance data

## TESTING

- Unit tests for
  - Metaschema -> composed metaschema
  - composed metaschema -> exploded metaschema
  - Conversion from FFF into unified format
  - Conversion from unified format into FFF
  - Unit testing the docs or maps?

## Gap analysis

- Define exploded metaschema format
- Define Unified Instance format (very close to EM) - this presents a data set, not a schema, in a format neutral way with everything explicit for all formats (such that a transformation into FFF or GGG is easy)

##  Metaschema

Exercising everything

- Assemblies, fields and flags with cardinality variations
  - 0 or 1
  - 0 or more
  - 1 or more
  - n to n+m
  - along with any/all specialized XML and JSON behavior
    including JSON keys, JSON value keys, XML wrapping/unwrapping
Datatypes
