

### xsl

#### nist-metaschema-COMPOSE.xsl

- XSLT stylesheet version 3.0 (0 templates)
- **Purpose:** Assemble a logical metaschema instance out of its modules and reconcile definitions
- **Dependencies:** This is a 'shell' XSLT and calls several steps in sequence, each implemented as an XSLT
- **Input:** A valid and correct OSCAL Metaschema instance linked to its modules (also valid and correct)
- **Output:** A single metaschema instance, unifying the definitions from the input modules and annotating with identifiers and pointers
- **Note:** This XSLT uses the transform() function to execute a series of transformations (referenced out of line) over its input

- Compile-time dependency (xsl:import) `nist-metaschema-metaprocess.xsl`

#### nist-metaschema-MAKE-JSON-SCHEMA.xsl

- XSLT stylesheet version 3.0 (0 templates)
- **Purpose:** Produce a JSON Schema reflecting constraints defined in a metaschema
- **Dependencies:** This is a 'shell' XSLT and calls several steps in sequence, each implemented as an XSLT
- **Input:** A top-level metaschema; this XSLT also composes metaschema input so composition is not necessary
- **Output:** A JSON Schema (v7) describing a JSON format consistent with definitions given in the input metaschema
- **Note:** This XSLT uses the transform() function to execute a series of transformations (referenced out of line) over its input
- Runtime parameter `$trace` as xs:string

- Compile-time dependency (xsl:import) `nist-metaschema-metaprocess.xsl`

#### nist-metaschema-MAKE-JSON-TO-XML-CONVERTER.xsl

- XSLT stylesheet version 3.0 (6 templates)
- **Purpose:** Produce an XSLT transformation capable of converting a JSON format defined in a metaschema, into an XML JSON format capturing an equivalent data set
- **Dependencies:** This is a 'shell' XSLT and calls several steps in sequence, each implemented as an XSLT
- **Dependencies:** Additionally, it directly calls resources in the converter-gen subdirectory as follows: converter-gen/markdown-to-supermodel-xml-converter.xsl, converter-gen/supermodel-to-xml.xsl (see lines 132, 136)
- **Input:** A top-level metaschema; this XSLT also composes metaschema input so composition is not necessary
- **Output:** A standalone XSLT suitable for use or deployment, accepting JSON valid to the metaschema-defined constraints
- **Note:** see the result XSLT for information regarding its runtime interface
- **Note:** This XSLT uses the transform() function to execute a series of transformations (referenced out of line) over its input
- Runtime parameter `$trace` as xs:string

- Compile-time dependency (xsl:import) `nist-metaschema-metaprocess.xsl`

#### nist-metaschema-MAKE-XML-METATRON.xsl

- XSLT stylesheet version 3.0 (0 templates)
- **Purpose:** Produce a Schematron capable of validating metaschema-defined constraints over (schema-valid) data conforming to a metaschema
- **Dependencies:** This is a 'shell' XSLT and calls several steps in sequence, each implemented as an XSLT
- **Input:** A top-level metaschema; this XSLT also composes metaschema input so composition is not necessary
- **Output:** A Schematron suitable for use or deployment, testing the formal validity of XML to metaschema-defined constraints
- **Note:** This XSLT uses the transform() function to execute a series of transformations (referenced out of line) over its input
- Runtime parameter `$trace` as xs:string

- Compile-time dependency (xsl:import) `nist-metaschema-metaprocess.xsl`

#### nist-metaschema-MAKE-XML-TO-JSON-CONVERTER.xsl

- XSLT stylesheet version 3.0 (3 templates)
- **Purpose:** Produce an XSLT transformation capable of converting an XML format defined in a metaschema, into a JSON format capturing an equivalent data set
- **Dependencies:** This is a 'shell' XSLT and calls several steps in sequence, each implemented as an XSLT
- **Input:** A top-level metaschema; this XSLT also composes metaschema input so composition is not necessary
- **Output:** A standalone XSLT suitable for use or deployment, accepting XML valid to the metaschema-defined constraints
- **Note:** see the result XSLT for information regarding its runtime interface
- **Note:** This XSLT uses the transform() function to execute a series of transformations (referenced out of line) over its input
- Runtime parameter `$trace` as xs:string

- Compile-time dependency (xsl:import) `nist-metaschema-metaprocess.xsl`

#### nist-metaschema-MAKE-XSD.xsl

- XSLT stylesheet version 3.0 (0 templates)
- **Purpose:** Produce an XML Schema Definition (XSD) reflecting constraints defined in a metaschema
- **Dependencies:** This is a 'shell' XSLT and calls several steps in sequence, each implemented as an XSLT
- **Input:** A top-level metaschema; this XSLT also composes metaschema input so composition is not necessary
- **Output:** An XSD describing an XML format consistent with definitions given in the input metaschema
- **Note:** This XSLT uses the transform() function to execute a series of transformations (referenced out of line) over its input
- Runtime parameter `$trace` as xs:string

- Compile-time dependency (xsl:import) `nist-metaschema-metaprocess.xsl`

#### nist-metaschema-metaprocess.xsl

- XSLT stylesheet version 3.0 (4 templates)
- Runtime parameter `$trace` as xs:string

### xpl

#### make-metaschema-abstract-map.xpl

- XProc pipeline version 1.0 (4 steps)

- Runtime dependency: `compose/make-definition-map.xsl`

#### make-metaschema-converters.xpl

- XProc pipeline version 1.0 (7 steps)
- Runtime dependency: `compose/make-model-map.xsl`
- Runtime dependency: `compose/reduce-map.xsl`
- Runtime dependency: `compose/unfold-model-map.xsl`
- Runtime dependency: `converter-gen/produce-json-converter.xsl`
- Runtime dependency: `converter-gen/produce-xml-converter.xsl`

#### make-metaschema-css.xpl

- XProc pipeline version 1.0 (3 steps)
- Runtime dependency: `util/make-plain-CSS.xsl`

#### make-metaschema-json-schema.xpl

- XProc pipeline version 1.0 (4 steps)
- Runtime dependency: `lib/xpath-json-to-json.xsl`
- Runtime dependency: `schema-gen/make-json-schema-metamap.xsl`

#### make-metaschema-metatron.xpl

- XProc pipeline version 1.0 (4 steps)
- **Purpose:** Produces a Schematron instance (Metatron)
- **Input:** A valid and correct OSCAL Metaschema instance linked to its modules (also valid and correct)
- **Output:** Port exposes a Schematron
- Runtime dependency: `schema-gen/make-metaschema-metatron.xsl`

#### make-metaschema-sandbox.xpl

- XProc pipeline version 1.0 (3 steps)
- Runtime dependency: `compose/make-definition-map.xsl`

#### make-metaschema-standalone-docs.xpl

- XProc pipeline version 1.0 (23 steps)
- **Purpose:** Emit XML and JSON-oriented metaschema documentation
- **Input:** A valid and correct OSCAL Metaschema instance linked to its modules (also valid and correct)
- **Output:** Ports expose standalone (and linked) HTML for analysis
- **Note:** This is for debugging; see write-hugo-metaschema.xpl for build runtime XProc
- Runtime dependency: `compose/annotate-model-map.xsl`
- Runtime dependency: `compose/make-model-map.xsl`
- Runtime dependency: `compose/unfold-model-map.xsl`
- Runtime dependency: `document/hugo-css-emulator.xsl`
- Runtime dependency: `document/json/json-definitions.xsl`
- Runtime dependency: `document/json/object-index-html.xsl`
- Runtime dependency: `document/json/object-map-html.xsl`
- Runtime dependency: `document/json/object-reference-html.xsl`
- Runtime dependency: `document/json/object-tree.xsl`
- Runtime dependency: `document/xml/element-index-html.xsl`
- Runtime dependency: `document/xml/element-map-html.xsl`
- Runtime dependency: `document/xml/element-reference-html.xsl`
- Runtime dependency: `document/xml/element-tree.xsl`
- Runtime dependency: `document/xml/xml-definitions.xsl`

#### make-metaschema-xml-to-supermodel-xslt.xpl

- XProc pipeline version 1.0 (6 steps)
- **Purpose:** Produces a single converter XSLT (for debugging)
- **Input:** A valid and correct OSCAL Metaschema instance linked to its modules (also valid and correct)
- **Output:** Port exposes a converter XSLT but does not run it

- Runtime dependency: `compose/make-model-map.xsl`
- Runtime dependency: `compose/reduce-map.xsl`
- Runtime dependency: `compose/unfold-model-map.xsl`
- Runtime dependency: `converter-gen/produce-xml-converter.xsl`

#### make-metaschema-xsd.xpl

- XProc pipeline version 1.0 (5 steps)

- Runtime dependency: `schema-gen/configure-namespaces.xsl`
- Runtime dependency: `schema-gen/make-metaschema-xsd.xsl`

#### write-hugo-metaschema-docs.xpl

- XProc pipeline version 1.0 (15 steps)
- **Purpose:** Write Hugo-ready HTML with XML and JSON-oriented metaschema documentation
- **Input:** A valid and correct OSCAL Metaschema instance linked to its modules (also valid and correct)
- **Output:** Options indicate file names to assign to outputs in serialization
- **Note:** See make-metaschema-standalone-docs.xpl for debugging
- Runtime dependency: `compose/annotate-model-map.xsl`
- Runtime dependency: `compose/make-model-map.xsl`
- Runtime dependency: `compose/unfold-model-map.xsl`
- Runtime dependency: `document/json/json-definitions.xsl`
- Runtime dependency: `document/json/object-index-html.xsl`
- Runtime dependency: `document/json/object-map-html.xsl`
- Runtime dependency: `document/json/object-reference-html.xsl`
- Runtime dependency: `document/json/object-tree.xsl`
- Runtime dependency: `document/xml/element-index-html.xsl`
- Runtime dependency: `document/xml/element-map-html.xsl`
- Runtime dependency: `document/xml/element-reference-html.xsl`
- Runtime dependency: `document/xml/element-tree.xsl`
- Runtime dependency: `document/xml/xml-definitions.xsl`
