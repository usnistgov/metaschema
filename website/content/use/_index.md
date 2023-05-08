---
title: "Using the Metaschema Framework"
menu:
  primary:
    name: Using
    weight: 10
---

Currently, a Metaschema [module](/specification/glossary/#metaschema-module) is defined using an [XML-based format](https://github.com/usnistgov/metaschema/blob/develop/schema/xml/metaschema.xsd). Alternate formats (e.g., JSON, YAML) are currently being considered.

An [ISO Schematron](https://schematron.com/) ruleset is also [provided](https://github.com/usnistgov/metaschema/blob/master/toolchains/xslt-M4/validate/metaschema-composition-check.sch) to enforce some of the rules described in the Metaschema [specification](/specification/).

A [tutorial](/tutorials/1-getting-started/) covering basic concepts is provided that will walk you through an example of creating a new Metaschema module.

## Schema Generation

A Metaschema module can be used to generate a schema, expressed as an XML or JSON Schema, for the corresponding [*data model*](/specification/glossary/#data-model) in a format-specific, serializable form (e.g., XML, JSON, YAML). These generated schemas can be used to *validate* that data to be processed by the system is well-formed and consistent with the requirements of the data model.

## Other Generative Use Cases

Metaschema modules are used to generate other model-related artifacts based on the metaschema description. These artifacts include:

- Conversion utilities that can convert content instances between the XML and JSON formats derived from a given metaschema definition, ensuring the resulting content is schema-valid and model-identical to its input (the conversion is lossless).
- XML and JSON model documentation for use on a website (e.g., the [OSCAL website](https://pages.nist.gov/OSCAL/documentation/schema/)).
- Programming language APIs used for parsing data conformant to a given data model into a set of language-specific objects, and also writing data in language-specific objects out to one of the supported data model formats.
