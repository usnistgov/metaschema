# OSCAL Metaschema

This subtree of the repository contains the original XSLT-based implementation of the Mwtaschema framework's schema, converter, and documentation generation capabilities.

This Metaschema implementation supports:

- XSD and JSON Schema production, coordinated from a unified source
- Documentation (embedded and [web-based](https://pages.nist.gov/OSCAL/docs/schemas/))
- Automated conversion scripts (XSLT transformations) for converting between XML and JSON format(s) conformant to the given metaschema

The [lib](lib) subdirectory contains the libraries and transformation specifications (stylesheets) providing for these data transformations.

For the most part these transformations require a conformant XSLT 3.0 processor such as [SaxonHE](http://saxon.sourceforge.net/#F9.9HE), as the script shows. Occasionally an XSLT has been written in version 1.0 to provide for greater availability: they should work in web browsers (with suitable configurations) as well as in any conformant XSLT 1.0 processor.

## Operations

Listed here are operations currently supported with the top-level XSLTs for each operation, to be applied to a valid metaschema source document (such as the catalog Metaschema):

### XML OSCAL

- XSD Production [xml/produce-xsd.xsl](xml/produce-xsd.xsl) - use XSD to provide structural validation to your OSCAL XML
- XML-to-JSON converter production: [xml/produce-xml-converter.xsl](xml/produce-xml-converter.xsl) - makes a utility for converting XML OSCAL into equivalent JSON OSCAL
- XML-oriented documentation [xml/produce-and-run-either-documentor.xsl](xml/produce-and-run-either-documentor.xsl)

### JSON OSCAL

- JSON Schema Production: [json/produce-json-schema.xsl](json/produce-json-schema.xsl) structural validations again but this time over JSON using JSON Schema v7
- JSON-to-XML converter production: [json/produce-json-converter.xsl](json/produce-json-converter.xsl) Note: run with parameter `$json-file` to name the JSON input file as noted in the shell script
- JSON-oriented documentation [xml/produce-and-run-either-documentor.xsl](xml/produce-and-run-either-documentor.xsl)
