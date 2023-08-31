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

The `allowed-values` constraint is a kind of Metaschema constraint that restricts field or flag value(s) based on an enumerated set of permitted values.

Metaschema processors MUST process `allowed-values` enumerations.


- strict: only defined `enum` values are valid for the given target(s)
- loose: both `enum` values and other values are valid

### `<allowed-values>`

The `@target` attribute of an `<allowed-values>` constraint is used to determine the specific content values the constraint applies to. By evaluating the `@target`, it is possible to identify the *target set* of `<allowed-values>` constraints targeting a given value.

The *source* of each allowed `<allowed-values>` constraint in the *target set* is identified as one of the following sources:

- **model:** The constraint is defined *in* a Metaschema module.
- **external:** The constraint is defined *outside* a Metaschema module, e.g. external constraints.

The *target set* of `<allowed-values>` constraints is verified for correctness using the `@extension` attribute on each set member.

Once the *target set* of `<allowed-values>` constraints is validated, the `@allow-other` attribute is used to determine the *expected value set* for a given content value.

The following subsections detail the processing requirements for the `@extension` and `@allow-other` attributes.

#### `@extension`

For each `<allowed-values>` constraint, the `@extension` attribute MUST be one of the following values.

- **`none`:** There can be no other matching `<allowed-values>` constraint for the same target value. This is the least permissive option.

- **`model`:** (default) Multiple matching `<allowed-values>` constraints are allowed for the same target value as long as the constraints are defined in the same model. Constraints sourced from outside the model are not allowed.

    All allowed-values constraints declared within a Metaschema model matching the same @target can be combined. If a matching constraint within the model has allow-other="no", then constraints declared externally from the model are not allowed. **This is the implicit default value if no `@extension` is provided.**

- **`external`:** Multiple matching `<allowed-values>` constraints are allowed for the same target value, which can be sourced from within the model or externally through a set of external constraints.

    All allowed-values constraints, declared within the model and externally through an extension, that match the same @target can be combined. This is the most permissive option.

One of the following requirements MUST apply when processing a value's *target set* to validate it.

1. The *target set* MUST contain a single `<allowed-values>` constraint with the `@extension` attribute value `none`.
1. All `<allowed-values>` constraints in the *target set* MUST have the `@extension` attribute value `model` and originate from a *model* source.
1. All `<allowed-values>` constraints in the *target set* MUST have the `@extension` attribute value `external` and originate from either a *model* or *extension* source.
1. An error MUST be raised indicating the *target set* is invalid.

#### `@allow-other`

The *expected value set* can be considered *open* or *closed*.

- **open:** In an open set, the actual value can be any value. The *expected value set* provides suggested values.
- **closed:** In a closed set, the actual value is expected to match a value in the *expected value set*.

For each `<allowed-values>` constraint, the `@allow-other` attribute MUST be one of the following values.

- **`yes`:** Identifies the *expected value set* as *open*, as long as no other `<allowed-values>` constraint in the *target set* has `@allow-other="no"` declared explicitly or implicitly.
- **`no`:** (default) Identifies the *expected value set* as *closed*. **This is the implicit default value if no `@allow-other` is provided.**

One of the following requirements MUST apply when processing the a value's *target set* to determine the *expected value set*.

1. One `<allowed-values>` constraint in the *target set* MUST have the `@allow-other` attribute value `no`. The *expected value set* is *closed*.

    The actual value MUST match one of the enumerated values declared on any of the `<allowed-values>` constraints in the *target set**target set*. An error MUST be produced to indicate that the value doesn't match one of the enumerated values.
    
2. All `<allowed-values>` constraints in the *target set* MUST have the `@allow-other` attribute value `yes`.  The *expected value set* is *open*.

    Any type appropriate actual value MUST be allowed. A warning MAY be produced to indicate that the value doesn't match one of the enumerated values.

A Metaschema processor MAY use the text value of the `enum`'s XML element as documentation for a given allowed value enumeration. Below is an example.

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
