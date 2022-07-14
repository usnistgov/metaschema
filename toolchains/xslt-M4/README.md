# XSLT-M4

An XSLT implementation of the metaschema toolchain for generating schemas, converters, and model documentation.

Typically any of these operations will combine several lower-level operations in a defined sequence.

More details (produced by surveying the files) can be seen in [file-manifest.md](file-manifest.md). Note however that this file is not reliable if it is not more recent than the files described.

In addition to this readme, this folder contains XSLT transformations (`*.xsl`), and XProc pipelines (`xpr`). The XSLT provides stable runtimes to the supported operations as described below. The XProc  The XProc is provided for convenience in development and debugging, and can be expected to change (develop/proliferate) somewhat more freely. These are currently XProc 1.0 pending further development.

Routines described below provide the XSLT entry point for the service. In general, any service consumes a metaschema input and produces one or more outputs, publishable as artifacts. For any XSLT, an analogous XProc is usually discernable from a file name (for example, `make-metaschema-xsd.xpr` instantiates the same pipeline as `nist-metaschema-MAKE-XSD.xsl`). For documentation production, only XProc is given.

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

An XML instance valid to a given metaschema-defined model can be converted by the XSLT produced by this XSLT (operating on the metaschema), into an information-identical JSON representation, losslessly, valid to the analogous JSON Schema.

### JSON to XML converter

source: metaschema (main module)

XSLT: `nist-metaschema-MAKE-JSON-TO-XML-CONVERTER.xsl`

result: XSLT (suffix `*.xsl`)

A JSON serialization (string) valid to a given metaschema-defined model can be converted by the XSLT produced by this XSLT (operating on the metaschema), into an information-identical XML representation, losslessly, valid to the analogous XML Schema (XSD).

## Generate Metatron / Metaschema-based constraints validation

source: metaschema (main module)

XSLT: `nist-metaschema-MAKE-XML-METATRON.xsl`

result: Schematron (suffix `*.sch`)

tbd: Schematron that operates on JSON inputs (JSONatron)

## Generate documentation

For any metaschema a range of documentation artifacts are produced for consumption by Hugo (ingest into a static published documentation repository / web sites).

Accordingly see these XProc pipelines for details:

`make-metaschema-standalone-docs.xpl` a generic pipeline producing standalone documentation (by passing Hugo ingest files through a normalizer/stabilizer).

Use with a debugging pipeline that binds the output ports for inspection.

`write-hugo-metaschema-docs.xpl` producing the same set of docs, except writing them to the file system ready for Hugo. Note that this pipeline writes files to the system.

Produced by both these pipelines (which should be work-alikes):
  - XML and JSON-oriented model documents with cross-links
    - Both instance- and model-oriented
  - XML and JSON model maps / synopsis
  - Indexes

## Extras

The XSLT `nist-metaschema-metaprocess.xsl` is a utility XSLT providing a unified interface for orchestrating the order and application of subordinate transformations, via configurations.

### Metaschema schemas / `validate` folder

Any metaschema, metaschema module, or composed metaschema, should all be valid to the Metaschema XSD `../../../schema/xml/metaschema.xsd` and to the `validate/metaschema-check.sch` Schematron.

A composed metaschema is essentially what a metaschema will look like with all imports resolved (last appearing definition prevailing, imports read before main definitions); so a metaschema with no imports maps directly to its own composed expression. In composition, pointers are also written into the metaschema representation to provide useful information for downstream processing in resolving referential ambiguities (resulting from unintended or intended import clashes).

The Schematron currently runs the composition step irrespectively. We should perhaps factor out Schematron checks that are dependent on Metaschema composition, from those that should apply to any metaschema (composed, standalone) or module.

### Compose metaschema

Schema composition is essentially import resolution, wherein overriding imports are resolved. Since the last definition prevails, any definition in a main module overrides any imported definition of the same name; similarly, imports can cascade, any import overriding earlier imports. Metaschema composition does not guarantee a viable schema result: definitions must still be sensible.

source: metaschema (main module)

XSLT: `nist-metaschema-MAKE-JSON-MAP.xsl`

result: XML conformant to Metaschema XSD/Schematron

A composition step is provided internally by other processes, but it can also be run independently.

### XProc

As noted above, everything can also be done under XProc 1.0 (`*.xpl` files) for debugging.

Porting to XProc 3.0 and/or to other pipelining approaches is on the further horizon.
