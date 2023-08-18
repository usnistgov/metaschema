---
title: "Constraints"
description: ""
weight: 50
---

# Constraints

**Note: This section of the specification is still a work in progress.**

TODO: P3: Address issue https://github.com/usnistgov/metaschema/issues/325

## Common Constraint Data

## Enumerated values

One kind of Metaschema constraint is restricting assembly, field, or flag value(s) with `allowed-values` enumerations. Metaschema processors MUST process `allowed-values` enumerations as defined with the `allow-other` attribute.

1. When the `allow-other` attribute is defined as `allow-other="no"`, the processor MUST strictly validate content instances with enumerations: only defined `enum` values are valid for the given target(s).
2. When the `allow-other` attribute is defined as `allow-other="yes"`, the processor MUST loosely validate content instances with enumerations: both `enum` values and other values are valid.
3. When the `allow-other` attribute is not explicitly defined, the Metaschema processor MUST strictly validate content instances. The implied default is `allow-other="no"`.

Within `allowed-values` of a `constraint`, a Metaschema processor MUST strictly or loosely validate `enum` values with the `@value` attribute. A Metaschema processor MAY use the text value of the `enum`'s XML element as documentation for a given allowed value enumeration. Below is an example.

```xml
<define-flag name="form-factor">
  <formal>Computer Form Factor</formal-name>
    <description>The type of computer in the example application's data model.</description>
    <constraint>
      <allowed-values allow-other="yes">
        <enum value="laptop">this text value documents the domain and information model's meaning of a laptop</enum>
        <enum value="desktop">this text value documents the domain and information model's meaning of a desktop</enum>
      </allowed-values>
    </constraint> ...  
</define-flag>
```

## `define-flag` constraints

## `define-field` constraints

## `define-assembly` constraints
