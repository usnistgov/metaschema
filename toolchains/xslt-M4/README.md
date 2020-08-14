# XSLT-M4

An XSLT implementation of the metaschema toolchain for generating schemas, converters, and model documentation.

Typically any of these operations will combine several lower-level operations in a defined sequence.

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

source: metaschema (main module)

XSLT: `nist-metaschema-MAKE-XML-METATRON.xsl`

result: Schematron (suffix `*.sch`)

tbd: Schematron that operates on JSON inputs (JSONatron)

## Generate documentation

### XML docs

source: metaschema (main module)

XSLT: `nist-metaschema-MAKE-XML-DOCS.xsl`

result: HTML file for Hugo (suffix `*.html`)

note: needs extension / integration / CSS work

### XML model map

source: metaschema (main module)

XSLT: `nist-metaschema-MAKE-XML-MAP.xsl`

result: HTML file for Hugo (suffix `*.html`)

note: needs integration / CSS work?

### JSON docs

source: metaschema (main module)

XSLT: `nist-metaschema-MAKE-JSON-DOCS.xsl`

result: HTML file for Hugo (suffix `*.html`)

note: needs extension / integration / CSS work

### JSON model map

source: metaschema (main module)

XSLT: `nist-metaschema-MAKE-JSON-MAP.xsl`

result: HTML file for Hugo (suffix `*.html`)

note: needs integration / CSS work?

## Extras

### Metaschema schemas

Any metaschema, metaschema module, or composed metaschema, should all be valid to the Metaschema XSD `validate/metaschema.xsd` and to the `validate/metaschema-check.sch` Schematron.

A composed metaschema is essentially what a metaschema will look like with all imports resolved (last appearing definition prevailing, imports read before main definitions); so a metaschema with no imports can be its own composed expression.

The Schematron currently runs the composition step irrespectively. We should perhaps factor out Schematron checks that are dependent on Metaschema composition, from those that should apply to any metaschema (composed, standalone) or module.

### Compose metaschema

Schema composition is essentially import resolution, wherein overriding imports are resolved. Since the last definition prevails, any definition in a main module overrides any imported definition of the same name; similarly, imports can cascade, any import overriding earlier imports. Metaschema composition does not guarantee a viable schema result: definitions must still be sensible.

source: metaschema (main module)

XSLT: `nist-metaschema-MAKE-JSON-MAP.xsl`

result: XML conformant to Metaschema XSD/Schematron

A composition step is provided internally by other processes, but it can also be run independently.

### XProc

Everything can also be done under XProc 1.0 (`*.xpl` files) for debugging.

Porting to XProc 3.0 and/or to other pipelining approaches is on the further horizon.
