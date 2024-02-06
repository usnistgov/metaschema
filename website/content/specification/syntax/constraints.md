---
title: "Constraints"
description: ""
weight: 50
---

# Constraints

**Note: This section of the specification is still a work in progress.**

Metaschema modules can define different kinds of constraints to support data validation within and between document instances.

The types of constraints allowed for a given definition 

## `<define-flag>` constraints

The following constraint types are allowed for `<define-flag>` definitions.

- [`<allowed-values>`](#enumerated-values)
- `<matches>`
- [`<index-has-key>`](#index-has-key-constraints)
- `<expect>`

For each of these constraint types, use of the `@target` attribute is prohibited. This is because a flag constraint may only target the flag, since a flag has no child nodes.

## `<define-field>` constraints

The following constraint types are allowed for `<define-field>` definitions.

- [`<allowed-values>`](#enumerated-values)
- `<matches>`
- [`<index-has-key>`](#index-has-key-constraints)
- `<expect>`

## `<define-assembly>` constraints

The following constraint types are allowed for `<define-assembly>` definitions.

- [`<allowed-values>`](#enumerated-values)
- `<matches>`
- [`<index-has-key>`](#index-has-key-constraints)
- `<expect>`
- [`<index>`](#index-constraints)
- `<is-unique>`
- [`<has-cardinality>`](#has-cardinality-constraints)

## Common Constraint Data

Each individual constraint allows the following data.

### `@id`

A constraint MAY have an OPTIONAL `@id` attribute, which provides an identifier for the constraint.

Metaschema processors MAY use the identifier for processing constraints and/or referencing them in output for later analysis.

### `@level`

A constraint MAY have an OPTIONAL `@level` attribute, which identifies the severity level of a violation of the constraint.

If defined, a `@level` MUST have a value of either: `CRITICAL`, `ERROR`, `WARNING`, `INFORMATIONAL`, or `DEBUG`.

Metaschema processors MAY perform conditional processing and/or presentation of constraint violations based on the level value.

### `@target`

The *target* of a constraint identifies the content nodes that a constraint applies to.

Not all constraint types require a `@target`. Each constraint type defines if the `@target` is required, optional, or implicit.

When provided, the value of a `@target` MUST be a valid Metapath expression.

If a `@target` value is not defined, a Metaschema processor MUST process the value as `target="."`, the current context of that constraint definition in a module, for a [field](#define-field-constraints) or [flag](#define-flag-constraints).

A *target* can apply to any node(s) in the document instance(s). There is no guarantee the constraint *target* is a child of its respective assembly, field, or flag. Thus, a Metaschema processor MUST resolve the Metapath expression to identify the actual target nodes that the constraint applies to. If no resulting target nodes are identified, then the constraint MUST be ignored.

## Constraint Processing

In a Metaschema-based document instance, each node in the document instance is associated with a definition in a Metaschema module. Thus, a given content node has one and only one associated definition.

A constraint is defined relative to an assembly, field, or flag [definition](../definitions/) in a Metaschema module.

All constraints associated with a definition MUST be evaluated against all associated content nodes.

Constraints may be declared internally within a definition or as an external set of constraints associated with a definition. To determine the evaluation order, internal and external constraints associated with a definition need to be combined.

Declaration order MUST be determined in the following way.

1. Internal constraints defined directly in the definition are ordered first according to their original order.
2. External constraints are appended in the order the external constraints were provided to the processor.

Each constraint MUST be evaluated in declaration order.

For example:

Given the Metaschema module definitions below:

```
Assembly(name="asmA")
  Field(name="fldX)
    Flag(name="flgS")
  Assembly(name="asmB")
    Flag(name="flgT")
```

Constraint evaluation would be handled depth-first as follows:

- When document node `asmA` is processed, constraints defined on that node's definition will be evaluated.
- When document node `fldX` is processed, constraints defined on that node's definition will be evaluated.
- and so on...

Note: The target of the constraint does not affect this evaluation order, but may affect what resulting node the constraint applies to.

When a constraint is evaluated against the associated content node, this node is considered the constraints *evaluation focus*.

### Processing Error Handling

Processing errors occur when a defect in the constraint definition causes an unintended error to occur during constraint processing. This differs from a validation error that results from not meeting the requirement of a constraint.

- If a processing error occurs while processing a constraint, which can result from evaluating a Metapath expression, the error SHOULD be reported.
- If a processing error occurs while processing a constraint, then the document instance being validated MUST NOT be considered valid. This is due to the inability to make a conclusion around validity, since some constraints were not validated due to errors.

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

## `expect` constraints

The `expect` constraint is a type of Metaschema constraint that restricts field or flag value(s) based on the evaluation of a test Metapath expression.

The `@target` attribute of an `<expect>` constraint specifies the node(s) in a document instance whose value is restricted by the constraint.

The `@test` attribute of an `<expect>` constraint specifies the logical condition to be evaluated against each value node resulting from evaluating the `@target`. This expression MUST evaluate to [a Metaschema boolean value](/specification/datatypes#boolean) `true` or `false`.

When the `@test` expression evaluates to `true` for a target value node, then the target value node MUST be considered valid and passing the constraint.

When the `@test` expression evaluates to `false` for a target value node, then the target value node MUST be considered not valid and failing the constraint.

A constraint may have an OPTIONAL [`@level`](#level) attribute and/or an OPTIONAL child [`<message>`](#message) element to indicate severity and documentation explaining how the target nodes are invalid.

If defined, the `<message>` value MUST be a [Metaschema string value](/specification/datatypes#string). It MAY contain a Metapath expression templates that starts with `{`, contains a Metapath expression, and ends with `}`.  When evaluating a template Metapath expression, the context of the Metapath [evaluation focus](#constraint-processing) MUST be the failing value node.

## `index` constraints

The `index` constraint is a type of Metaschema constraint that defines an index of document instance nodes addressable by key.

The `@name` flag of an `<index>` constraint specifies the identity of the index. The constraint MUST define the name.

The `@target` flag of an `<index>` constraint defines the node(s) in a document instance to index. The index MUST define a [`@target`](#target) with a Metapath expression. The processor MUST index only The document instance node(s) resulting from its evaluation.

The `<key-field>` assembly of an `<index>` constraint defines the flag or field value that is the key for each entry in the index. The `<key-field>` field MUST define a [`@target`](#target) flag with a Metapath expression evaluated relative to [the evaluation focus](#constraint-processing) of each entry of the matches of the constraint's `@target`.

An `index` constraint MAY define more than one `<key-field>` assembly. The composite key for each entry in the index is the combination of values for the `@target` of every `<key-field/>`. The composite values of the key are the discriminator for the uniqueness of the index entry.

An `index` constraint requires that each member entry be unique based upon this composite key.

If the evaluation of the Metapath `@target` of the `<key-field/>` does not result in a value, its value for that key in the index is null.

If two entries have the same key computed from the `<key-field>` `@target`s when generating the index, the processor MUST return a processing error.

## `index-has-key` constraints

The `index-has-key` constraint is a type of Metaschema constraint that cross-references values an existing `index` constraint` with a separate `@target` and `<key-field/>`.

The `@name` flag of an `<index>` constraint MUST specify the name of a previously defined `index` constraint.

The `index-has-key` constraint has the same flags and assemblies as a [`index`](#index-constraints) constraint.
## `is-unique` constraints

The `is-unique` constraint is a type of Metaschema constraint that checks that a computed key, based on field and flag values, does not occur more than once.

The [`id`](#id) attribute of an `is-unique` constraint specifies an identifier for the constraint.

The `@target` attribute of an `<is-unique>` constraint identifies the node(s) in a document instance that are checked for uniqueness based on the computed key. The `is-unique` constraint MUST define a [`@target`](#target) with a Metapath expression.

The `key-field` field of an `<is-unique>` constraint defines the attribute or element value that is the key for each entry in the index. The `<key-field>` element MUST define a [`@target`](#target) attribute with a Metapath expression evaluated relative to [the evaluation focus](#constraint-processing) of each entry of the matches of the constraint's `@target`.

An `is-unique` constraint MUST define only one `@key-field`. 

If the evaluation of the Metapath `@target` of the `is-unique`, then the computed key does not occur more than once within the same capability, its value will result to true.


## `has-cardinality` constraints

The `has-cardinality` constraint is a type of Metaschema constraint that defines the cardinality of assemblies, flags, and, fields, i.e. the required minimum count of occurrences, the maximum count of occurrences, or both for applicable document instances.

The `@target` flag of an `<has-cardinality>` constraint defines the node(s) in a document instance to count. The constraint MUST define a [`@target`](#target) with a Metapath expression. The processor MUST only count the document instance node(s) resulting from its evaluation.

A constraint MUST define a value for either the `@min-occurs` or `@max-occurs` flag. It MAY optionally have both flags defined.

The `@min-occurs` flag MUST be an integer that defines the minimum number of required occurrences for results matching the evaluation of the `@target`.

The `@max-occurs` flag MUST be an integer that defines the maximum number of required occurrences for results matching the evaluation of the `@target`.

A constraint passes and document instance(s) valid if the count of results matching the evaluation of the `@target` Metapath is equal or more than the value of `@min-occurs`, if defined, and equal to or less than the value of `@max-occurs`, if defined. If these requirements are not met when defined, the constraint is not passing and the document instance(s) are not valid.

## Enumerated values

The `allowed-values` constraint is a type of Metaschema constraint that restricts field or flag value(s) based on an enumerated set of permitted values.

Each `allowed-values` constraint has a *source* that will be either:

- **model:** The constraint is defined *in* a Metaschema module, i.e. an internal constraint.
- **external:** The constraint is defined *outside* a Metaschema module, i.e. an external constraint.

The `@target` of an `<allowed-values>` constraint specifies the node(s) in a document instance whose value is restricted by the constraint.

### Enumerated value processing

Metaschema processors MUST process `<allowed-values>` constraints.

The constraint's `@target` is a Metapath expression that identifies the node values the constraint applies to.

When evaluating the `@target` metapath expression, the Metapath focus MUST be the constraint's *evaluation focus*. Thus, the targets are determined in the context in where the constraint is declared.

The sequence of nodes that result from Metapath evaluation are the constraints *target node(s)*.

The nodes resulting from evaluating an `<allowed-values>` `@target` are intended to be *field* or *flag* nodes, which have a value. If these nodes are an instance of an *assembly*, a Metaschema processor error SHOULD be raised.

Multiple `<allowed-values>` constraints can apply to a given *target node*, which may be declared by constraints defined on different content nodes. Implementations will need a means to determine the complete set of `<allowed-values>` constraints that apply to a given *target node*, which is referred to as the *target node's* "*applicable set*".

This may be handled using a two phased evaluation that first resolves the `<allowed-values>` constraints associated with each *target node* determining the *applicable set*, then, second, evaluates the *applicable set* for each *target node*. Other implementations may be possible and are allowed if they result in the same effective behavior.

The *applicable set* of `<allowed-values>` constraints is verified for correctness using the `@extension` attribute on each set member.

For each `<allowed-values>` in the *applicable set*, the `@allow-other` attribute is used to determine the *expected value set* for a given content value.

The following subsections detail the processing requirements for the `@extension` and `@allow-other` attributes.

#### `@extension`

For each `<allowed-values>` constraints the *applicable set*, the `@extension` attribute MUST be one of the following values.

- **`none`:** There can be no other matching `<allowed-values>` constraint for the same target value. This is the least permissive option.

- **`model`:** (default) Multiple matching `<allowed-values>` constraints are allowed for the same target value as long as the constraints are defined in the same model. Constraints sourced from outside the model are not allowed.

    All allowed-values constraints declared within a Metaschema model matching the same @target can be combined. If a matching constraint within the model has allow-other="no", then constraints declared externally from the model are not allowed. **This is the implicit default value if no `@extension` is provided.**

- **`external`:** Multiple matching `<allowed-values>` constraints are allowed for the same target value, which can be sourced from within the model or externally through a set of external constraints.

    All allowed-values constraints, declared within the model and externally through an extension, that match the same @target can be combined. This is the most permissive option.

One of the following requirements MUST apply when processing a value's *applicable set* to validate it.

1. The *applicable set* MUST contain a single `<allowed-values>` constraint with the `@extension` attribute value `none`.
1. All `<allowed-values>` constraints in the *applicable set* MUST have the `@extension` attribute value `model` and originate from a *model* source.
1. All `<allowed-values>` constraints in the *applicable set* MUST have the `@extension` attribute value `external` and originate from either a *model* or *extension* source.
1. An error MUST be raised indicating the *applicable set* is invalid.

#### `@allow-other`

The *expected value set* can be considered *open* or *closed*.

- **open:** In an open set, the actual value can be any value. The *expected value set* provides suggested values.
- **closed:** In a closed set, the actual value is expected to match a value in the *expected value set*.

For each `<allowed-values>` constraint, the `@allow-other` attribute MUST be one of the following values.

- **`yes`:** Identifies the *expected value set* as *open*, as long as no other `<allowed-values>` constraint in the *applicable set* has `@allow-other="no"` declared explicitly or implicitly.
- **`no`:** (default) Identifies the *expected value set* as *closed*. **This is the implicit default value if no `@allow-other` is provided.**

One of the following requirements MUST apply when processing a value's *targeting set* of `<allowed-values>` constraints to determine the *expected value set*.

1. One `<allowed-values>` constraint in the *applicable set* MUST have the `@allow-other` attribute value `no`. The *expected value set* is *closed*.

    The actual value MUST match one of the enumerated values declared on any of the `<allowed-values>` constraints in the *targeting set*. An error MUST be produced to indicate that the value doesn't match one of the enumerated values.

    It is possible to require a value that does not align with the value node's Metaschema data type. In such cases, this creates a situation where both the data type and a closed value requirement cannot be met. In such cases, the constraint processor MUST report this as an error.

2. All `<allowed-values>` constraints in the *applicable set* MUST have the `@allow-other` attribute value `yes`. The *expected value set* is *open*.

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

## External Constraints

TBD
