# Allowed Values

**Status** - down - in flux - come back to -

**Dependendency** - architectural decisions re deployment of constraints validation capabilities (XML and JSON sides respectively)

The `allowed-values` construct was our initial effort at values constraints, now being generalized as part of the constraints work.

The tests here do not currently pass due to bugs in the mapping:

- We do not get a numeric datatype in the JSON for PositiveInteger, shouldn't we?
- There is currently no support at all for examining / reporting against allowed values under XSD, whether under allow-other 'yes' or 'no' (?)

