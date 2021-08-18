

### xsl

#### configure-namespaces.xsl

- XSLT stylesheet version 2.0 (7 templates)
- Runtime parameter `$debug` with default ''no''

#### make-json-schema-metamap.xsl

- XSLT stylesheet version 3.0 (63 templates)
- **Purpose:** Produce an XPath-JSON document representing JSON Schema declarations from Metaschema source data. The results are conformant to the rules for the XPath 3.1 definition of an XML format capable of being cast (using the xml-to-json() function) into JSON.
- **Note:** this XSLT will only be used on its own for development and debugging. It is however imported by `produce-json-converter.xsl` and possibly other stylesheets.

#### make-metaschema-metatron.xsl

- XSLT stylesheet version 3.0 (34 templates)
- **Purpose:** Produce an Schematron representing constraints declared in a metaschema
- **Input:** A Metaschema
- **Output:** An XSD, with embedded documentation
- Runtime parameter `$produce-warnings` as xs:string
- Runtime parameter `$noisy` as xs:string
- Runtime parameter `$debug` with default ''no''

- Compile-time dependency (xsl:import) `../metapath/parse-metapath.xsl`
- Compile-time dependency (xsl:import) `metatron-datatype-functions.xsl`

#### make-metaschema-xsd.xsl

- XSLT stylesheet version 3.0 (41 templates)
- **Purpose:** Produce an XSD Schema representing constraints declared in a metaschema
- **Input:** A Metaschema
- **Output:** An XSD, with embedded documentation
- Runtime parameter `$debug` with default ''no''

#### metatron-datatype-functions.xsl

- XSLT stylesheet version 3.0 (7 templates)
- Can be run standalone, but also serves as a utility XSLT to `make-metaschema-metatron.xsl`

### xpl

#### test-make-metaschema-xsd.xpl

- XProc pipeline version 1.0 (5 steps)
- Runtime dependency: `configure-namespaces.xsl`
- Runtime dependency: `make-metaschema-xsd.xsl`

### xsd

#### oscal-datatypes.xsd

Includes type definitions to be called into generated schemas.

This file drives JSON as well as XSD processes and supports processes throughout the library - test when editing!

#### oscal-prose-module.xsd

Similarly, this file provides boilerplate declarations supporting markup-line and markup-multiline data structures in any metaschema-defined model using these datatypes.
