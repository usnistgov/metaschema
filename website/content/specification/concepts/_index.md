---
title: "Metaschema Concepts"
Description: "Discussion of the core Metaschema concepts"
weight: 10
---

An instance of a Metaschema, called a [*metaschema definition*](terminology/#metaschema-definition), defines an [*information model*](terminology/#information-model) for an aspect of given [*domain*](terminology/#domain) in a format-neutral form. A metaschema definition contains a collection of definitions for [*managed objects*](terminology/#managed-object) consisting of semanticly well-defined data structures. Metaschema definitions contain documentation about the meaning (semantics) and use of a given managed object.

A metaschema can be used to generate a schema for a corresponding [*data model*](terminology/#data-model), which is a representation of an *information model* in a format specific serializable form (e.g., XML, JSON, YAML) expressed as XSD and JSON Schema. These generated schema can be used to validate that data is conformant to the asscoiated format, and thus conformant to the information model defined by the Metaschema.

Metaschemas are used to generate other model-related artifacts based on the metaschema description. These artifacts include:

- Conversion utilities that can convert content instances between the XML and JSON formats derived from a given metaschema defintion, ensuring the resulting content is schema valid; 
- XML and JSON model documentation for use on a website (i.e. the [OSCAL website](https://pages.nist.gov/OSCAL/documentation/schema/).
- Programing language APIs used for parsing data conformat to a given data model into a set of language-specific objects, and also writing data in language-specific objects out to one of the supported data model formats.

Use of metaschema definitions provides a sustainable means to maintain seamless and consistent support for multiple models and multiple associated formats for each model by avoiding the need to maintain each format individually. Content can also be kept up-to-date in multiple formats using generated content converters, and can be validated using generated schema. Adding support for new formats (e.g., YAML) can accomplished by extending the Metaschema tooling to produce schema and converters for other formats.

## Metaschema Architecture

The following illustrates the Metaschema architecture:

{{<mermaid>}}
graph TB
  ms1[metaschema moduleA] -- include --> ms
  ms2[metaschema moduleB] -- include --> ms
  xmp1[example1] -- cite --> ms
  xmp2[example2] -- cite --> ms
  ms[main Metaschema] -- compile metaschema --> cms
  cms -- extract documentation --> xmldocsh[XML docs / HTML]
  cms((Compiled metaschema)) -- translate --> sch(XML Schema)
  cms -- xdm::object map --> xj{xml to json XSLT}
  cms -- object::xdm map --> jx{json to xml XSLT}
  cms -- translate --> jsch(JSON Schema)
  cms -- extract documentation --> jsondocsh[JSON docs / HTML]

classDef metasch fill:skyblue,stroke:blue,stroke-width:12px,stroke-opacity:0.2
classDef xml fill:gold,stroke:#333,stroke-width:2px;
classDef json fill:pink,stroke:#333,stroke-width:2px
classDef html fill:lightgreen,stroke-width:2px
classDef md fill:lightgreen,stroke-width:4px,stroke-dasharray:2,2

class cms,ms,ms1,ms2,xmp1,xmp2 metasch
class sch,xj xml
class jsch,jx json
class xmldocsh,jsondocsh html
class xmldocmd,jsondocmd md
{{</mermaid>}}

The diagram above was [generated](architecture-mermaid) using [Mermaid](https://mermaidjs.github.io/).

