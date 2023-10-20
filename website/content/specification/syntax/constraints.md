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

A constraint MAY have an OPTIONAL `@id` attribute, which provides an identifier for the constraint. Metaschema processors MAY use the identifier for processing constraints and/or referencing them in output for later analysis.

### `@level`

A constraint MAY have an OPTIONAL `@level` attribute, which identifies the severity level of a violation of the constraint. If defined, a `@level` MUST have a value of either: `INFORMATIONAL`, `WARNING`, `ERROR`, or `CRITICAL`. Metaschema processors MAY perform conditional processing and/or presentation of constraint violations based on the level value.

### `@target`

The *target* of a constraint identifies the content nodes that a constraint applies to.

A *target* can apply to any node(s) in the document instance(s). There is no guarantee the constraint is a child of its respective assembly, field, or flag.

When validating content, any constraint whose target does not match any content node MUST be ignored.

A constraint MAY have a `@target`. A `@target` value is a valid Metapath expression. In a document conforming to a Metaschema module, a Metaschema processor MUST process the constraint to any path in that model definition that matches the given Metapath expression.

If a `@target` value is not defined, a Metaschema processor must process the value as `target="."`, the current context of that constraint definition in a module, for a [field](#define-field-constraints) or [flag](#define-flag-constraints).

## Constraint Processing

### Processing Error Handling

Processing errors occur when a defect in the constraint definition causes an unintended error to occur during constraint processing. This differs from a validation error that results from not meeting the requirement of a constraint.

- If a processing error occurs while processing a constraint, which can result from evaluating a Metapath expression, the error SHOULD be reported.
- If a processing error occurs while processing a constraint, then the document instance being validated MUST NOT be considered valid. This is due to the inability to make a conclusion around validity, since some constraints were not validated due to errors.

## Enumerated values

The `allowed-values` constraint is a kind of Metaschema constraint that restricts field or flag value(s) based on an enumerated set of permitted values.

Each `allowed-values` constraint has a *source* that will be either:

- **model:** The constraint is defined *in* a Metaschema module.
- **external:** The constraint is defined *outside* a Metaschema module, e.g. external constraints.

The `@target` of an `<allowed-values>` constraint specifies the node(s) in a document instance whose value is restricted by the constraint.

### Enumerated value processing

Metaschema processors MUST process `<allowed-values>` constraints.

The constraint's `@target` MUST be evaluated as a Metapath expression relative to the node instances of the definition it is enclosed in. These nodes will be the *focus* for Metapath evaluation. Thus, the target is evaluated relative to any node that is an instance of that definition.

The sequence of nodes that result from Metapath evaluation are the constraints *target node(s)*.

The nodes resulting from evaluating an `<allowed-values>` `@target` are intended to be *field* or *flag* nodes, which have a value. If these nodes are an instance of an *assembly*, a Metaschema processor error SHOULD be raised.

Multiple `<allowed-values>` constraints can apply to a given *target node*. Fo a given *target node*, it is necessary to determine which `<allowed-values>` constraints apply to its value. This can be done through a full instance transversal or any other means that is capable of accurately determining the set of `<allowed-values>` constraints that target a given node. This set of  `<allowed-values>` constraints is considered the *applicable set*.

The `<allowed-values>` `@allow-other` attribute determines the *expected value set* for a given content value.

The *target set* of `<allowed-values>` constraints is verified for correctness using the `@extension` attribute on each set member.

The following subsections detail the processing requirements for the `@extension` and `@allow-other` attributes.

### `@extension`

For each `<allowed-values>` constraints the *applicable set*, the `@extension` attribute MUST be one of the following values.

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

## External Constraints

