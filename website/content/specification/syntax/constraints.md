---
title: "Constraints"
Description: ""
weight: 50
---


# Constraints

## Common Metadata

## Enumerated values

Additionally, flags may be constrained to a set of known values listed in advance.

This restriction can be either:

1. strict (values must be in the list for document validity with `allow-other="no"` attribute for an `allowed-values` element) or
2. loose (i.e. for documentation only, no effect in schemas, with `allow-other="yes"`).

If an `allowed-values` constraint does not have the `allow-other` attribute defined, the default is `allow-other="no"`, resulting in strict validation where the only valid values are those in the list.

Within `allowed-values` of a `constraint`, an `enum` element's `@value` attribute assigns the permissible value, while its data content provides documentation. For example:

```xml
<define-flag name="algorithm" datatype="string">
    <formal-name>Hash algorithm</formal-name>
    <description>Method by which a hash is derived</description>
    <constraint>
      <allowed-values allow-other="yes">
        <enum value="SHA-224">Documentation for one permissible option.</enum>
        <enum value="SHA-256">Documentation for another permissible option.</enum>
      </allowed-values>
    </constraint> ...
```

## `define-flag` constraints

## `define-field` constraints

## `define-assembly` constraints
