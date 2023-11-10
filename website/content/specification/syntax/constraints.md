---
title: "Constraints"
description: ""
weight: 50
---

# Constraints

**Note: This section of the specification is still a work in progress.**

TODO: P3: Address issue https://github.com/usnistgov/metaschema/issues/325

## Common Constraint Data

## Let expressions

Using the `let` element, a variable can be defined, which can be used in a Metapath expression in subsequent constraints.

A `let` statement has a REQUIRED `@var` attribute, which defines the variable name.

A `let` statement has a REQUIRED `@expression` attributes, which defines an Metapath expression, whose result is used to define the variable's value in the evaluation context.

During constraint evaluation, each `let` statement MUST be evaluated in encounter order. If a previous variable is bound with the same name in the evaluation context, the new value MUST bound in a sub-context to avoid side effects. This sub-context MUST be made available to any constraints following the `let` statement declaration, and to any constraints defined on child nodes of the current context.

During evaluation, when a variable is bound for a `let` statement, the variables value MUST be set to the result of evaluating the `@expression` using the current node as the Metapath evaluation focus.

For example:

Given the following fragment of a Metaschema module.

```xml
<define-assembly name="sibling">
  <define-flag name="name" required="yes"/>
  <constraint>
    <let var="parent" expression=".."/><!-- stores the parent of the current node -->
    <let var="sibling-count" expression="count($parent/sibling)"/>
    <expect target="." test="$sibling-count = 3"/>
  </constraint>
</define-assembly>
```

And the following document.

```xml
<parent name="p1">
  <sibling name="a"/>
  <sibling name="b"/>
  <sibling name="c"/>
</parent>
<parent name="p2">
  <sibling name="x"/>
  <sibling name="Y"/>
</parent1>
```

The expect constraint would pass for each `sibling` in the `parent` named "p1", and would fail for each `sibling` in the `parent` named "p2".

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
