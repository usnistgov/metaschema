An XSLT implementation of the metaschema toolchain for generating schemas, converters, and model documentation.

# ENTRY POINTS

## XProc

These are in XProc 1.0 tested under XML Calabash. Soon, hopefully, to be migrated to XProc 3.0.

These are built primarily for purposes of testing in an IDE. End users would ordinarily use a different pipelining means such as the XSLT described next.

### Compose metaschema

Pick up a top-level metaschema component and combine all its pieces, resolving its imports and normalizing its representation.

Metaschema composition is ordinarily the first step in any metaschema processing after editing.

`metaschema-compose.xpl` - executes metaschema composition, in multiple steps.

## XSLT

The same processes are implemented in XSLT so they can be run in an XSLT processor standalone, without XProc support.


### Compose metaschema

`nist-metaschema-COMPOSE.xsl` primary input, a top-level metaschema module. result: a standalone, normalized metaschema instance.
