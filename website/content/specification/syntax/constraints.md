---
title: "Constraints"
description: ""
weight: 50
---

# Constraints

**Note: This section of the specification is still a work in progress.**

TODO: P3: Address issue https://github.com/usnistgov/metaschema/issues/325

## Common Constraint Data

Metaschema modules can define different kinds of constraints to support data validation, inter-documenting indices, and intra-document indices. Below are constraint data that modules may include within any of those different constraint types.

### `@id`

A constraint MAY have an OPTIONAL `@id` attribute so Metaschema processors MAY identify use the identifier for processing constraints and/or referencing them in output for later analysis.

### `@level`

A constraint MAY have an OPTIONAL `@level` attribute so Metaschema processors MAY perform conditional processing and/or presentation of constraint violations based on the value of applicable constraints for a document. If defined, a `@level` MUST have a value of either `INFORMATIONAL`, `WARNING`, `ERROR`, or `CRITICAL`.

### `@target`

A constraint MAY have a `@target`. A `@target` value is a valid a Metapath expression. In a document conforming to a Metaschema module, a Metaschema processor MUST process the constraint to any path in that model definition that matches the given Metapath expression. If a `@target` value is not defined, a Metaschema processor must process the value as `target="."`, the current context of that constraint definition in a module, for a [field](#define-field-constraints) or [flag](#define-flag-constraints). For [assemblies](#define-assembly-constraints), a Metaschema processor MUST NOT process any constraint within its `model` with a value of `target="."`.

## Enumerated values

The `allowed-values` constraint is a kind of Metaschema constraint that restricts field or flag value(s) based on an enumerated set of permitted values.

Metaschema processors MUST process `allowed-values` enumerations.

The `@target` attribute of an `<allowed-values>` constraint is used to determine the specific content values the constraint applies to. For any given value or node, it is possible to identify the *targeting set* of `<allowed-values>` constraints based on their `@target` attributes. If the value or node among is among those being targeted, the constraint is a member of its targeting set.

The *source* of each allowed `<allowed-values>` constraint in the *target set* is identified as one of the following sources:

- **model:** The constraint is defined *in* a Metaschema module.
- **external:** The constraint is defined *outside* a Metaschema module, e.g. external constraints.

The *target set* of `<allowed-values>` constraints is verified for correctness using the `@extension` attribute on each set member.

Once the *targeting set* of `<allowed-values>` constraints is determined, their respective `@allow-other` attributes are used to determine the *expected value set* for a given content value.

The following subsections detail the processing requirements for the `@extension` and `@allow-other` attributes.

### `@extension`

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

### `@allow-other`

The *expected value set* can be considered *open* or *closed*.

- **open:** In an open set, the actual value can be any value. The *expected value set* provides suggested values.
- **closed:** In a closed set, the actual value is expected to match a value in the *expected value set*.

For each `<allowed-values>` constraint, the `@allow-other` attribute MUST be one of the following values.

- **`yes`:** Identifies the *expected value set* as *open*, as long as no other `<allowed-values>` constraint in the *target set* has `@allow-other="no"` declared explicitly or implicitly.
- **`no`:** (default) Identifies the *expected value set* as *closed*. **This is the implicit default value if no `@allow-other` is provided.**

One of the following requirements MUST apply when processing a value's *targeting set* of `<allowed-values>` constraints to determine the *expected value set*.

1. One `<allowed-values>` constraint in the *target set* MUST have the `@allow-other` attribute value `no`. The *expected value set* is *closed*.

    The actual value MUST match one of the enumerated values declared on any of the `<allowed-values>` constraints in the *targeting set*. An error MUST be produced to indicate that the value doesn't match one of the enumerated values.
    
2. All `<allowed-values>` constraints in the *targeting set* MUST have the `@allow-other` attribute value `yes`.  The *expected value set* is *open*.

    Any type-appropriate actual value MUST be allowed. A warning MAY be produced to indicate that the value doesn't match one of the enumerated values.

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
