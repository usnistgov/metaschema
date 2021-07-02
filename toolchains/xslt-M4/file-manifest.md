

### xsl

#### nist-metaschema-COMPOSE.xsl

* XSLT stylesheet version 3.0 (0 templates)
* **Purpose:** Assemble a logical metaschema instance out of its modules and reconcile definitions
* **Dependencies:** This is a 'shell' XSLT and calls several steps in sequence, each implemented as an XSLT
* **Input:** A valid and OSCAL Metaschema instance linked to its modules (also valid and correct)
* **Output:** A single metaschema instance, unifying the definitions from the input modules and annotating with identifiers and pointers
* Compile-time dependency (xsl:import) `lib/metaschema-metaprocess.xsl`
* Stylesheet variable `$home` 
* Stylesheet variable `$xslt-base` 
* Stylesheet variable `$transformation-sequence` 

#### nist-metaschema-MAKE-JSON-DOCS.xsl

* XSLT stylesheet version 3.0 (0 templates)
* Compile-time dependency (xsl:import) `lib/metaschema-metaprocess.xsl`
* Runtime parameter `$trace` as xs:string
* Stylesheet variable `$louder` 
* Stylesheet variable `$xslt-base` 
* Stylesheet variable `$transformation-sequence` 

#### nist-metaschema-MAKE-JSON-MAP.xsl

* XSLT stylesheet version 3.0 (0 templates)
* Compile-time dependency (xsl:import) `lib/metaschema-metaprocess.xsl`
* Runtime parameter `$trace` as xs:string
* Stylesheet variable `$louder` 
* Stylesheet variable `$xslt-base` 
* Stylesheet variable `$transformation-sequence` 

#### nist-metaschema-MAKE-JSON-SCHEMA.xsl

* XSLT stylesheet version 3.0 (0 templates)
* Compile-time dependency (xsl:import) `lib/metaschema-metaprocess.xsl`
* Runtime parameter `$trace` as xs:string
* Stylesheet variable `$louder` 
* Stylesheet variable `$xslt-base` 
* Stylesheet variable `$transformation-sequence` 

#### nist-metaschema-MAKE-JSON-TO-XML-CONVERTER.xsl

* XSLT stylesheet version 3.0 (6 templates)
* Compile-time dependency (xsl:import) `lib/metaschema-metaprocess.xsl`
* Runtime parameter `$trace` as xs:string
* Stylesheet variable `$louder` 
* Stylesheet variable `$xslt-base` 
* Stylesheet variable `$produce-json-converter` 
* Stylesheet variable `$metaschema-source` 
* Stylesheet variable `$transformation-architecture` 

#### nist-metaschema-MAKE-XML-DOCS.xsl

* XSLT stylesheet version 3.0 (0 templates)
* Compile-time dependency (xsl:import) `lib/metaschema-metaprocess.xsl`
* Runtime parameter `$trace` as xs:string
* Stylesheet variable `$louder` 
* Stylesheet variable `$xslt-base` 
* Stylesheet variable `$transformation-sequence` 

#### nist-metaschema-MAKE-XML-MAP.xsl

* XSLT stylesheet version 3.0 (0 templates)
* Compile-time dependency (xsl:import) `lib/metaschema-metaprocess.xsl`
* Runtime parameter `$trace` as xs:string
* Stylesheet variable `$louder` 
* Stylesheet variable `$xslt-base` 
* Stylesheet variable `$transformation-sequence` 

#### nist-metaschema-MAKE-XML-METATRON.xsl

* XSLT stylesheet version 3.0 (0 templates)
* Compile-time dependency (xsl:import) `lib/metaschema-metaprocess.xsl`
* Runtime parameter `$trace` as xs:string
* Stylesheet variable `$louder` 
* Stylesheet variable `$xslt-base` 
* Stylesheet variable `$transformation-sequence` 

#### nist-metaschema-MAKE-XML-TO-JSON-CONVERTER.xsl

* XSLT stylesheet version 3.0 (3 templates)
* Compile-time dependency (xsl:import) `lib/metaschema-metaprocess.xsl`
* Runtime parameter `$trace` as xs:string
* Stylesheet variable `$louder` 
* Stylesheet variable `$xslt-base` 
* Stylesheet variable `$produce-xml-converter` 
* Stylesheet variable `$metaschema-source` 
* Stylesheet variable `$transformation-architecture` 

#### nist-metaschema-MAKE-XSD.xsl

* XSLT stylesheet version 3.0 (0 templates)
* Compile-time dependency (xsl:import) `lib/metaschema-metaprocess.xsl`
* Runtime parameter `$trace` as xs:string
* Stylesheet variable `$louder` 
* Stylesheet variable `$xslt-base` 
* Stylesheet variable `$transformation-sequence` 

### xpl

#### make-metaschema-abstract-map.xpl

* XProc pipeline version 1.0 (4 steps)
* Runtime dependency: `compose/make-definition-map.xsl`

#### make-metaschema-converters.xpl

* XProc pipeline version 1.0 (8 steps)
* Runtime dependency: `compose/make-model-map.xsl`
* Runtime dependency: `compose/unfold-model-map.xsl`
* Runtime dependency: `compose/reduce-map.xsl`
* Runtime dependency: `document/xml/element-tree.xsl`
* Runtime dependency: `document/json/object-tree.xsl`
* Runtime dependency: `document/json/object-map-html.xsl`

#### make-metaschema-css.xpl

* XProc pipeline version 1.0 (3 steps)
* Runtime dependency: `util/make-plain-CSS.xsl`

#### make-metaschema-docs.xpl

* XProc pipeline version 1.0 (4 steps)
* Runtime dependency: `document/xml/xml-docs-hugo-uswds.xsl`
* Runtime dependency: `document/json/json-docs-hugo-uswds.xsl`

#### make-metaschema-json-schema.xpl

* XProc pipeline version 1.0 (4 steps)
* Runtime dependency: `schema-gen/make-json-schema-metamap.xsl`
* Runtime dependency: `lib/xpath-json-to-json.xsl`

#### make-metaschema-metatron.xpl

* XProc pipeline version 1.0 (4 steps)
* Runtime dependency: `schema-gen/make-metaschema-metatron.xsl`

#### make-metaschema-model-maps.xpl

* XProc pipeline version 1.0 (9 steps)
* Runtime dependency: `compose/make-model-map.xsl`
* Runtime dependency: `compose/unfold-model-map.xsl`
* Runtime dependency: `compose/reduce-map.xsl`
* Runtime dependency: `document/xml/element-tree.xsl`
* Runtime dependency: `document/xml/element-map-html.xsl`
* Runtime dependency: `document/json/object-tree.xsl`
* Runtime dependency: `document/json/object-map-html.xsl`

#### make-metaschema-sandbox.xpl

* XProc pipeline version 1.0 (3 steps)
* Runtime dependency: `compose/make-definition-map.xsl`

#### make-metaschema-xml-to-supermodel-xslt.xpl

* XProc pipeline version 1.0 (6 steps)
* Runtime dependency: `compose/make-model-map.xsl`
* Runtime dependency: `compose/unfold-model-map.xsl`
* Runtime dependency: `compose/reduce-map.xsl`
* Runtime dependency: `converter-gen/produce-xml-converter.xsl`

#### make-metaschema-xsd.xpl

* XProc pipeline version 1.0 (5 steps)
* Runtime dependency: `schema-gen/make-metaschema-xsd.xsl`
* Runtime dependency: `schema-gen/configure-namespaces.xsl`

#### metaschema-compose.xpl

* XProc pipeline version 1.0 (6 steps)
* Runtime dependency: `compose/metaschema-collect.xsl`
* Runtime dependency: `compose/metaschema-reduce1.xsl`
* Runtime dependency: `compose/metaschema-reduce2.xsl`
* Runtime dependency: `compose/metaschema-digest.xsl`

#### produce-xsd-OLD.xpl

* XProc pipeline version 1.0 (7 steps)
* Runtime dependency: `compose/metaschema-collect.xsl`
* Runtime dependency: `compose/metaschema-reduce.xsl`
* Runtime dependency: `compose/metaschema-digest.xsl`
* Runtime dependency: `schema-gen/produce-xsd-OLD.xsl`

#### scratch.xpl

* XProc pipeline version 1.0 (3 steps)
* Runtime dependency: `lib/metaschema-compose.xsl`

### compose\

#### compose\

### converter-gen\

#### converter-gen\

### document\

#### document\

### md

### sh

#### init.sh

### lib\

#### lib\

### metapath\

#### metapath\

### older\

#### older\

### schema-gen\

#### schema-gen\

### testing\

#### testing\

### util\

#### util\

### validate\

#### validate\