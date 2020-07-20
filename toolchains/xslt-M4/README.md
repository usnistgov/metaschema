# XSLT-M4

An XSLT implementation of the metaschema toolchain for generating schemas, converters, and model documentation.

ENTRY POINTS

## Generate schemas

### Generate XML Schema (XSD)

source: metaschema (main module)

XSLT: `nist-metaschema-MAKE-XSD.xsl`

result: XSD (suffix `*.xsd`)

parameters: none

The output is an XSD (XML Schema Definition) that can be used to provide structural and datatype validation over XML data instances, testing conformance to models defined by the metaschema.

### Generate JSON Schema

source: metaschema (main module)

XSLT: `nist-metaschema-MAKE-JSON-SCHEMA.xsl`

result: JSON Schema (suffix `*.json`)

parameters: none

The output is a JSON Schema (v 7) that can be used to provide structural and lexical validation over JSON (and YAML) data instances, testing conformance to models defined by the metaschema.

## Generate converters

### XML to JSON converter

source: metaschema (main module)

XSLT: `nist-metaschema-MAKE-XML-TO-JSON-CONVERTER.xsl`

result: XSLT (suffix `*.xsl`)

### JSON to XML converter

source: metaschema (main module)

XSLT: `nist-metaschema-MAKE-JSON-TO-XML-CONVERTER.xsl`

result: XSLT (suffix `*.xsl`)

## Generate Metatron / Metaschema-based constraints validation

(Single Schematron for both XML and JSON, or separate?)
## Generate documentation

### XML docs

### XML model map

### JSON docs

### JSON model map

## Extras

### Compose metaschema

A composition step is provided internally by other processes, but it can also be run independently.

## XProc

Everything can also be done under XProc (`*.xpl` files) for debugging.
