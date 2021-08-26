### Converter generator support XSLTs

These transformations support the automated production of conversion XSLTs for formats defined by OSCAL metaschema. These are general-purpose, lossless utility conversions.

For example, starting with the OSCAL Catalog Metaschema, XSLTs here can produce an XSLT that can convert any valid OSCAL XML Catalog into its equivalent JSON, and back again.

They can also produce the component parts of such standalone stylesheets, for independent testing.

To trace through this combination of resources, understanding the architecture of the target (itself a *transformation* is necessary.

catalog metaschema + xml-converter-generator  => catalog-xml-converter
catalog metaschema + json-converter-generator => catalog-json-converter

Both converters are *pipelines* and can be deployed as either standalone stylesheets (XSLTs), or in/as component parts that can be executed and tested independently (for example from XProc scripts for debugging)).
In more detail, both converters work the same way, by using a 'hub' or intermediate format for temporary representation of a data instance. This so-called 'supermodel' captures, with any OSCAL instance, an information set defined by a metaschema applicable to that instance -- an information set rich enough to support the creation of either XML or JSON representations, deterministically.

1. XML to JSON
1.1 XML is converted to 'supermodel' XML (a defined format)
1.2 supermodel XML is converted to XPath JSON (XML)
1.3 XPath JSON (XML) is serialized as JSON
  
2. JSON to XML
2.1 JSON is converted (marshalled/deserialized) to XPath JSON (XML)
2.2 XPath JSON (XML) is converted to supermodel XML
2.3 supermodel XML is serialized as XML
  
Of these, two steps (1.3 and 2.1) can be delivered by commodity tooling such as the `[json-to-xml()](https://www.w3.org/TR/xpath-functions-31/#func-json-to-xml)` function to deliver XPath JSON XML from JSON). Another two (1.2 and 2.2) are generic "downhill conversions" from the hub 'supermodel' format, and can be encapsulated as such.

This leaves two filters (conversions) that must be generated per metaschema, namely steps 1.1 and 2.2. To produce either converter is a process of generating this step and then assembling it with the logic to accomplish the others. The template sets produced by each of these describe tranformations with the same target format -- nominal 'supermodel' XML -- and differ only in that one applies to metaschema-defined XML, and the other to  metaschema-defined JSON (as XPath XML).

The source format from which each of these "core conversions" is produced is, in both cases, a 'definition map' produced from a composed Metaschema. A definition map for a metaschema is produced by composing the metaschema and applying a sequence of three subsequent transformation steps over the composed result:

- `../compose/make-model-map.xsl` - spills out a metaschema into an AST representation
- `../compose/unfold-model-map.xsl` - rewrites AST to make grouping explicit
- `../compose/reduce-map.xsl` - reduces into a more lightweight form

The resulting definition map document can then be submitted to the appropriate converter generator.

See `../nist-metaschema-MAKE-JSON-TO-XML-CONVERTER.xsl` for an example of this sequencing.

Additionally, steps 1.2 and 2.2 entail generic conversion between XML (tagged) and Markdown (inline 'decorated') renditions of unstructured text (prose). Stylesheets in this folder also deliver this functionality.

Note that XSLTs here may be invoked from elsewhere including not only from XProc testing pipelines, but runtime XSLTs: in particular see `../nist-metaschema-MAKE-XML-TO-JSON-CONVERTER.xsl`.

#### produce-json-converter.xsl

- XSLT stylesheet version 3.0 (23 templates)
- **Purpose:** Produce an XSLT for converting JSON valid to a Metaschema model, to its supermodel equivalent.
- **Input:** A Metaschema definition map
- **Output:** An XSLT
- Runtime parameter `$px` as xs:string
- Runtime parameter `$definition-map` with default '/'
- Compile-time dependency (xsl:import) `../metapath/metapath-jsonize.xsl`
- Compile-time dependency (xsl:import) `produce-xml-converter.xsl`

#### produce-xml-converter.xsl

- XSLT stylesheet version 3.0 (36 templates)
- **Purpose:** Produce an XSLT for converting XML valid to a Metaschema model, to its supermodel equivalent.
- **Input:** A Metaschema definition map
- **Output:** An XSLT

#### markdown-to-supermodel-xml-converter.xsl

- XSLT stylesheet version 3.0 (35 templates)
- Supports conversion of (arbitrary) Markdown into its tagged  equivalent
- Emulates `markdown-to-xml.xsl` inside pipelines

#### markdown-to-xml.xsl

- XSLT stylesheet version 3.0 (33 templates)
- Runtime parameter `$target-ns` as xs:string?
- Generic processing for converting Markdown to produce arbitrary (namespaced) XML (HTMLish tagging)

#### md-converter-test.xsl

- XSLT stylesheet version 3.0 (2 templates)
- **Purpose:** test harness for calling Markdown conversion logic
- Runtime parameter `$target-ns` as xs:string?
- Compile-time dependency (xsl:import) `markdown-to-supermodel-xml-converter.xsl`
#### supermodel-to-json.xsl

- XSLT stylesheet version 3.0 (43 templates)
- Casts the unified 'supermodel' format into its JSON (object) representation (using XPath JSON XML format) 

#### supermodel-to-markdown.xsl

- XSLT stylesheet version 3.0 (26 templates)
- **Purpose:** Convert XML to markdown. Note that namespace bindings must be given.

#### supermodel-to-xml.xsl

- XSLT stylesheet version 3.0 (5 templates)
- Casts the unified 'supermodel' format into its (reduced) XML representation; NB this functionality is also provided by any "to XML" shell, dynamically. Here it is encapsulated for use in pipelines.

#### xml-to-markdown.xsl

- XSLT stylesheet version 3.0 (23 templates)
- **Purpose:** Convert XML to markdown. Note that namespace bindings must be given.
- This is a specialized form (utility for testing) of `supermodel -to-markdown.xsl`

#### xpath-json-to-json.xsl

- XSLT stylesheet version 3.0 (4 templates)
- Runtime parameter `$indent` as xs:string
- A wrapper for use in testing outputs