# Metaschema processing XSpec testing

XSpec testing is offered for various aspects of metaschema processing including processing relating to composition (which includes preprocessing/annotation) and validation of metaschemas for constraints related to structural integrity.

To run XSpec, we suggest either an XML IDE or a command line tool as described in [XSpec documentation in Github](https://github.com/xspec/xspec/wiki).

See each subdirectory for status updates.

NOT ALL TESTS ARE OPERATIONAL / FUNCTIONAL

(See CI/CD configuration).


### Tests here are FUNCTIONAL:

* `composition/metaschema-composition.xspec`

Tests XSLT `../../../toolchains/xslt-M4/nist-metaschema-COMPOSE.xsl`

Currently checks if unused definitions are correctly filtered away from a metaschema source instance, in composition.

(This prevents result schemas from including unused models.)

* `composition/metaschema-prune-unused-definitions.xspec`

Also testing the same bug, but using standoff instances, with a start at to some more comprehensive tests.

### REQUIRING REFRESH / EXTENSION

* XSpec `metaschema-basic-schematron.xspec` testing Schematron:  `../../toolchains/xslt-M4/validate/metaschema-simple-check.sch`

*Needs updating and pointing to Schematron in its new location.*

* XSpec `metaschema-composition-schematron.xspec` testing Schematron: `../../toolchains/xslt-M4/validate/metaschema-composition-check.sch`

*Needs updating and pointing to Schematron in its new location*

