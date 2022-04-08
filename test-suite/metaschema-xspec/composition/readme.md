# Metaschema processing XSpec testing - Metaschema Composition end-to-end (E2E)

To run XSpec, we suggest either an XML IDE or a command line tool as described in [XSpec documentation in Github](https://github.com/xspec/xspec/wiki).

* `composition/metaschema-composition.xspec`

Tests XSLT `../../../toolchains/xslt-M4/nist-metaschema-COMPOSE.xsl`

Currently checks if unused definitions are correctly filtered away from a metaschema source instance, in composition.

(This prevents result schemas from including unused models.)

* `composition/metaschema-prune-unused-definitions.xspec`

Also testing the same bug, but using standoff instances, with a start on more comprehensive tests.
