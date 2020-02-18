# Worked Example / Development Punchlist

- Resource Registry Schema (Worked example)
  - see metaschema/test-suite/worked-example
  - [x] Metaschema
  - [x] XProc for XSD
  - [ ] Refactor XSD to new design
  - [ ] Abstract Model Map
  - [ ] JSON Schema
  - [ ] XProc for docs production
      - [ ] main docs including in- and out-of-line samples
      - [ ] model maps
  - [ ] Once things are stable, orchestrate via XSLT/scripting (remove XProc dependency) 
  - [ ] Data sets for testing

- Data
    - XML
    - JSON
      - exercise json-key, json-value-key features
      - test: json-key constraints on assemblies at the root? (xslt mode 'uniqueness-constraint')

- Feature list
  - survey Metaschema XSD, Schematron
  
## Pipelines

### Metaschema Compose

- rewrites a modular metaschema in fully-resolved standalone form
- global declarations only for assemblies
- samples are included
- outputs are still valid to Metaschema XSD

### Metaschema Schematron?
  
separate Schematrons for pre- and post-composition metaschema?

### Explode data map

runs over composed metaschema to produce a generalized expanded data map

this version comprehends both XML and JSON expressions in a single map

### Produce model maps

runs over exploded data supermodel map to produce JSON- and XML-oriented model maps

### Produce schemas

Produce each of

- XSD
- JSON Schema
- XSD for 'exploded' form?

### Produce transformers

convert to and from XML or JSON into supermodel XML