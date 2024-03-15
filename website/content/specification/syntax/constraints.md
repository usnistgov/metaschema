---
title: "Constraints"
description: ""
weight: 50
---

# Constraints

Metaschema modules can define different kinds of constraints to support data validation within and between document instances.

The types of constraints allowed for a given definition 

## `<define-flag>` constraints

The following constraint types are allowed for `<define-flag>` definitions.

- [`<let>`](#let-expressions)
- [`<allowed-values>`](#allowed-values-constraints)
- [`<expect>`](#expect-constraints)
- [`<index-has-key>`](#index-has-key-constraints)
- [`<matches>`](#matches-constraints)

For each of these constraint types, use of the `@target` attribute is prohibited. This is because a flag constraint may only target the flag, since a flag has no child nodes.

## `<define-field>` constraints

The following constraint types are allowed for `<define-field>` definitions.

- [`<let>`](#let-expressions)
- [`<allowed-values>`](#allowed-values-constraints)
- [`<expect>`](#expect-constraints)
- [`<index-has-key>`](#index-has-key-constraints)
- [`<matches>`](#matches-constraints)

## `<define-assembly>` constraints

The following constraint types are allowed for `<define-assembly>` definitions.

- [`<let>`](#let-expressions)
- [`<allowed-values>`](#allowed-values-constraints)
- [`<expect>`](#expect-constraints)
- [`<has-cardinality>`](#has-cardinality-constraints)
- [`<index>`](#index-constraints)
- [`<index-has-key>`](#index-has-key-constraints)
- [`<is-unique>`](#is-unique-constraints)
- [`<matches>`](#matches-constraints)

## Common Constraint Data

All *constraints* share a common syntax composed of the following:

| Data | Data Type | Use      | Default Value |
|:--- |:--- |:--- |:--- |
| [`@id`](#id) | [`token`](/specification/datatypes/#token) | optional | *(no default)* |
| [`@level`](#level) | `DEBUG`,`INFORMATIONAL`, `WARNING`, `ERROR`, or `CRITICAL` | optional | `ERROR` |
| [`@target`](#target) | special | *(varies)* | `.` |
| [`<formal-name>`](#formal-name) | [`string`](/specification/datatypes/#string) | 0 or 1 | *(no default)* |
| [`<description>`](#description) | [`markup-line`](/specification/datatypes/#markup-line) | 0 or 1 | *(no default)* |
| [`<prop>`](#prop) | special | 0 to ∞ | *(no default)* |
| [`<remarks>`](#remarks) | special | 0 or 1 | *(no default)* |

Each individual constraint allows the following data.

### `@id`

A constraint MAY have an OPTIONAL `@id` flag, which provides an identifier for the constraint.

Metaschema processors MAY use the identifier for processing constraints and/or referencing them in output for later analysis.

### `@level`

A constraint MAY have an OPTIONAL `@level` attribute, which identifies the severity level of a violation of the constraint.

If defined, a `@level` MUST have a value of either: `CRITICAL`, `ERROR`, `WARNING`, `INFORMATIONAL`, or `DEBUG`.

These values have the following definitions:

- **CRITICAL**: A violation of the constraint represents a serious fault in the content that will prevent typical use of the content.
- **ERROR**: A violation of the constraint represents a fault in the content. This may include issues around compatibility, integrity, consistency, etc.
- **WARNING**: A violation of the constraint represents a potential issue with the content.
- **INFORMATIONAL**: A violation of the constraint represents a point of interest.
- **DEBUG**: A violation of the constraint represents a fault in the content that may warrant review by a developer when performing model or tool development.

Metaschema processors MAY perform conditional processing and/or presentation of constraint violations based on the level value.

### `@target`

The *target* of a constraint identifies the content nodes that a constraint applies to.

Not all constraint types require a `@target`. Each constraint type defines if the `@target` is required, optional, or implicit.

When provided, the value of a `@target` MUST be a valid Metapath expression.

If a `@target` value is not defined, a Metaschema processor MUST process the value as `target="."`, the current context of that constraint definition in a module, for a [field](#define-field-constraints) or [flag](#define-flag-constraints).

A *target* can apply to any node(s) in the document instance(s). There is no guarantee the constraint *target* is a child of its respective assembly, field, or flag. Thus, a Metaschema processor MUST resolve the Metapath expression to identify the actual target nodes that the constraint applies to. If no resulting target nodes are identified, then the constraint MUST be ignored.

### `@deprecated` Version

The optional `@deprecated` attribute communicates that use of the given *information element* implemented by the *definition* is intended to be discontinued, starting with the *information model* revision indicated by the attribute's value.

This attribute's value MUST be a version [string](/specification/datatypes/#string) that is equal to or comes before the [`<schema-version>`](/specification/syntax/module/#schema-version) declared in the *Metaschema module* *header*.

{{<callout>}}
Declaring the `@deprecated` attribute communicates to content creators that all use of the annotated *information element* is to be avoided. This annotation can be used in documentation generation and in Metaschema-aware tools that provide context around use of the definition.
{{</callout>}}

The following example illustrates deprecating the flag named `flag-name` starting with the *information model* semantic version `1.1.0`.

```xml {linenos=table,hl_lines=[3]}
<define-flag
  name="flag-name"
  deprecated="1.1.0"/>
```

### `@name`

The `@name` attribute provides the definition's identifier, which can be used in other parts of a module, or in an importing *Metaschema module*, to reference the definition.

In top-level definitions, this attribute's value MUST be a [token](/specification/datatypes/#token) that is unique among sibling definitions of the same type.

**Note:** The names of flags, fields, and assemblies are expected to be maintained as separate identifier sets. This allows a *flag definition*, a *field definition*, and an *assembly definition* to each have the same name in a given *Metaschema module*.

### `@scope`

The optional `@scope` attribute is used to communicate the intended visibility of the definition when accessed by another module through an [`<import>`](/specification/syntax/module/#import) element.

- `global` - Indicates that the definition MUST be made available for reference within importing modules. Definitions in the same and importing modules can reference it. This is the default behavior when `@scope` is not declared.
- `local` - Indicates that the definition MUST NOT be made available for reference within importing modules. Only definitions in the same module can reference it.

Note: References to definitions in the same module are always possible regardless of scope.

The scope of a definition affects how the [definition's name is resolved](/specification/syntax/module/#definition-name-resolution).

### `<formal-name>`

The optional `<formal-name>` field provides a human-readable, short string label for the constraint for use in documentation.

{{<callout>}}
The `<formal-name>` label is intended to provide an easy to recognize, meaningful name for the constraint.

While not required, it is best practice to include a `<formal-name>`.
{{</callout>}}

### `<description>`

The optional `<description>` field is a [single line of markup](/specification/datatypes/#markup-line) that describes the semantic meaning and use of the constraint.

{{<callout>}}
The description ties the constraint to the related information element concept in the information domain that the constraint is representing. This information is ideal for use in documentation.

While not required, it is best practice to include a `<description>`.
{{</callout>}}

### `<prop>`

The optional `<prop>` assembly provides a structure for declaring arbitrary properties, which consist of a `@namespace`, `@name`, and `@value`.

| Data | Data Type | Use      | Default Value |
|:--- |:--- |:--- |:--- |
| `@namespace` | [`uri`](/specification/datatypes/#uri) | optional | `http://csrc.nist.gov/ns/oscal/metaschema/1.0` |
| `@name` | [`token`](/specification/datatypes/#token) | required | *(no default)* |
| `@value` |  [`token`](/specification/datatypes/#token) | required | *(no default)* |

The `@name` and `@namespace` is used in combination to define a semantically unique name, represented by the `@name` attribute, within the managed namespace defined by the `@namespace` attribute. If the `@namespace` attribute is omitted, the `@name` MUST be considered in the `http://csrc.nist.gov/ns/oscal/metaschema/1.0` namespace.

The `@value` flag represents the lexical value assignment for the semantically unique name represented by the combination of the `@name` and `@namespace`. The lexical values of the `@value` attribute may be restricted for the specific semantically unique name, but such restrictions are not enforced directly in this model.

{{<callout>}}
A property is useful for annotating a constraint with additional information that might describe, in a structured way, the semantics, use, nature, or other significant information related to the constraint. In many cases, a property might be used to tailor generated documentation or to support an experimental, non-standardized feature in Metaschema.
{{</callout>}}

### `<remarks>`

The optional `<remarks>` field provides a place to add notes related to the use of the constraint. Remarks can be used to clarify the semantics of the constraint in specific conditions, or to better describe how the constraint is utilized within a model.

The `<remarks>` field is optional and may occur multiple times.

It supports an optional `@class` flag that can be used to identify format specific remarks, to be handled appropriately (or ignored when not useful) in a downstream application. Valid values for `@class` are:

- `XML`: The remark applies to the XML format binding.
- `JSON`: The remark applies to the JSON or YAML format bindings.

## Constraint Types

The following describes the supported constraint constructs.

### `let` Expressions

The optional `<let>` assembly provides a structure for variable/expression bindings, which consist of a `@var` and `@expression`.

| Data | Data Type | Use      | Default Value |
|:--- |:--- |:--- |:--- |
| `@var` | [`token`](/specification/datatypes/#token) | required | *(no default)* |
| `@expression` | [special](/specification/syntax/metapath) | required | *(no default)* |

Using the `let` assembly, a variable can be defined, which can be used by reference in a Metapath expression in subsequent constraints.

A `let` statement has a REQUIRED `@var` flag, which defines the variable name.

A `let` statement has a REQUIRED `@expression` flag, which defines an [Metapath expression](/specification/syntax/metapath), whose result is used to define the variable's value in the evaluation context.

During constraint evaluation, each `let` statement MUST be evaluated in encountered order. If a previous variable is bound with the same name in the evaluation context, the new value MUST bound in a sub-context to avoid side effects. This sub-context MUST be made available to any constraints following the `let` statement declaration, and to any constraints defined on child nodes of the current context.

A `let` statement MAY be defined in a constraint assembly by itself, before, or after other constraint types. One or more `let` statements SHOULD be declared before any other constraint types as a best practice, but it is not required.

During evaluation, when a variable is bound for a `let` statement, the variables value MUST be set to the result of evaluating the `@expression` using the current node as the Metapath evaluation focus.

For example:

Given the following fragment of a Metaschema module.

```xml
<define-assembly name="sibling">
  <define-flag name="name" required="yes"/>
  <constraint>
    <!-- stores the parent of the current node -->
    <let var="parent" expression=".."/>
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

### `allowed-values` Constraints

The `allowed-values` constraint is a type of Metaschema constraint that restricts field or flag value(s) based on an enumerated set of permitted values.

The syntax of `<allowed-values>` consists of the following:

| Data | Data Type | Use      | Default Value |
|:--- |:--- |:--- |:--- |
| [`@allow-other`>](#allow-other) | `yes` or `no` | optional | `no` |
| [`@extensible`>](#extensible) | `model`, `external`, or `none` | optional | `no` |
| [`@id`](#id) | [`token`](/specification/datatypes/#token) | optional | *(no default)* |
| [`@level`](#level) | `DEBUG`,`INFORMATIONAL`, `WARNING`, `ERROR`, or `CRITICAL` | optional | `ERROR` |
| [`@target`](#target) | special | *(varies)* | *(no default)* |
| [`<formal-name>`](#formal-name) | [`string`](/specification/datatypes/#string) | 0 or 1 | *(no default)* |
| [`<description>`](#description) | [`markup-line`](/specification/datatypes/#markup-line) | 0 or 1 | *(no default)* |
| [`<prop>`](#prop) | special | 0 to ∞ | *(no default)* |
| [`<enum>`](#enum) | special | 1 to ∞ | *(no default)* |
| [`<remarks>`](#remarks) | special | 0 or 1 | *(no default)* |

Each `allowed-values` constraint has a *source* that will be either:

- **model:** The constraint is defined *in* a Metaschema module, i.e. an internal constraint.
- **external:** The constraint is defined *outside* a Metaschema module, i.e. an external constraint.

The `@target` of an `<allowed-values>` constraint is a [Metapath expression](/specification/syntax/metapath) that specifies the node(s) in a document instance whose value is restricted by the constraint.

#### `@enum`

Within a given `<allowed-values>` constraint, an `<enum>` expresses an individual allowed value, expressed using that field's `@value` flag.

A Metaschema processor MAY use the text value of the `enum`'s XML element as documentation for a given allowed value enumeration. Below is an example.

```xml
<define-flag name="form-factor">
  <formal>Computer Form Factor</formal-name>
    <description>The type of computer in the example application's data
      model.</description>
    <constraint>
      <allowed-values allow-other="yes">
        <enum value="laptop">this text value documents the domain and
          information model's meaning of a laptop</enum>
        <enum value="desktop">this text value documents the domain and
          information model's meaning of a desktop</enum>
      </allowed-values>
    </constraint> ...  
</define-flag>
```

#### `allowed-values` Processing

Metaschema processors MUST process `<allowed-values>` constraints.

The constraint's `@target` is a [Metapath expression](/specification/syntax/metapath) that identifies the node values the constraint applies to.

A `@target` is REQUIRED for allowed value constraints associated with a field and assembly. A `@target` MUST NOT be provided for an allowed value constraint associated with a flag, since such a constraint can only target the flag's value. In flag use cases the `@target` MUST be considered `.`, referring to the flag node.

When evaluating the `@target` Metapath expression, the Metapath focus MUST be the constraint's *evaluation focus*. Thus, the targets are determined in the context in where the constraint is declared.

The sequence of nodes that result from Metapath evaluation are the constraints *target node(s)*.

The nodes resulting from evaluating an `<allowed-values>` `@target` are intended to be *field* or *flag* nodes, which have a value. If these nodes are an instance of an *assembly*, a Metaschema processor error SHOULD be raised.

Multiple `<allowed-values>` constraints can apply to a given *target node*, which may be declared by constraints defined on different content nodes. Implementations will need a means to determine the complete set of `<allowed-values>` constraints that apply to a given *target node*, which is referred to as the *target node's* "*applicable set*".

This may be handled using a two phased evaluation that first resolves the `<allowed-values>` constraints associated with each *target node* determining the *applicable set*, then, second, evaluates the *applicable set* for each *target node*. Other implementations may be possible and are allowed if they result in the same effective behavior.

The *applicable set* of `<allowed-values>` constraints is verified for correctness using the `@extension` attribute on each set member.

For each `<allowed-values>` in the *applicable set*, the `@allow-other` attribute is used to determine the *expected value set* for a given content value.

The following subsections detail the processing requirements for the `@extension` and `@allow-other` attributes.

##### `@extensible`

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

##### `@allow-other`

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

### `expect` Constraints

The `<expect>` constraint is a type of Metaschema constraint that restricts field or flag value(s) based on the evaluation of a `@test` Metapath expression.

The syntax of `<expect>` consists of the following:

| Data | Data Type | Use      | Default Value |
|:--- |:--- |:--- |:--- |
| [`@id`](#id) | [`token`](/specification/datatypes/#token) | optional | *(no default)* |
| [`@level`](#level) | `DEBUG`,`INFORMATIONAL`, `WARNING`, `ERROR`, or `CRITICAL` | optional | `ERROR` |
| [`@target`](#target) | special | *(varies)* | *(no default)* |
| `@test` | special | required | *(no default)* |
| [`<formal-name>`](#formal-name) | [`string`](/specification/datatypes/#string) | 0 or 1 | *(no default)* |
| [`<description>`](#description) | [`markup-line`](/specification/datatypes/#markup-line) | 0 or 1 | *(no default)* |
| [`<prop>`](#prop) | special | 0 to ∞ | *(no default)* |
| `<message>` | special | 0 or 1 | *(no default)* |
| [`<remarks>`](#remarks) | special | 0 or 1 | *(no default)* |

The `@target` attribute of an `<expect>` constraint is a [Metapath expression](/specification/syntax/metapath) that specifies the node(s) in a document instance whose value is restricted by the constraint.

A `@target` is REQUIRED for expect constraints associated with a field and assembly. A `@target` MUST NOT be provided for an expect constraint associated with a flag, since such a constraint can only target the flag's value. In flag use cases the `@target` MUST be considered `.`, referring to the flag node.

The `@test` attribute of an `<expect>` constraint specifies the logical condition to be evaluated against each value node resulting from evaluating the `@target`. This expression MUST evaluate to [a Metaschema boolean value](/specification/datatypes#boolean) `true` or `false`.

When the `@test` expression evaluates to `true` for a target value node, then the target value node MUST be considered valid and passing the constraint.

When the `@test` expression evaluates to `false` for a target value node, then the target value node MUST be considered not valid and failing the constraint.

A constraint may have an OPTIONAL [`@level`](#level) attribute and/or an OPTIONAL child `<message>` element to indicate severity and documentation explaining how the target nodes are invalid.

If defined, the `<message>` value MUST be a [Metaschema string value](/specification/datatypes#string). It MAY contain a Metapath expression templates that starts with `{`, contains a Metapath expression, and ends with `}`.  When evaluating a template Metapath expression, the context of the Metapath [evaluation focus](#constraint-processing) MUST be the failing value node.

### `has-cardinality` Constraints

The `has-cardinality` constraint is a type of Metaschema constraint that defines the cardinality of assemblies, flags, and, fields, i.e. the required minimum count of occurrences, the maximum count of occurrences, or both for applicable document instances.

The syntax of `<has-cardinality>` consists of the following:

| Data | Data Type | Use      | Default Value |
|:--- |:--- |:--- |:--- |
| [`@id`](#id) | [`token`](/specification/datatypes/#token) | optional | *(no default)* |
| [`@level`](#level) | `DEBUG`,`INFORMATIONAL`, `WARNING`, `ERROR`, or `CRITICAL` | optional | `ERROR` |
| [`@target`](#target) | special | *(varies)* | *(no default)* |
| `@min-occurs` | [`non-negative-integer`](/specification/datatypes/#non-negative-integer) | optional | *(no default)* |
| `@max-occurs` | [`non-negative-integer`](/specification/datatypes/#non-negative-integer) or `unbounded` | optional | *(no default)* |
| [`<formal-name>`](#formal-name) | [`string`](/specification/datatypes/#string) | 0 or 1 | *(no default)* |
| [`<description>`](#description) | [`markup-line`](/specification/datatypes/#markup-line) | 0 or 1 | *(no default)* |
| [`<prop>`](#prop) | special | 0 to ∞ | *(no default)* |
| [`<remarks>`](#remarks) | special | 0 or 1 | *(no default)* |

The `@target` flag of an `<has-cardinality>` constraint is a [Metapath expression](/specification/syntax/metapath) that defines the node(s) in a document instance to count.

The constraint MUST define a [`@target`](#target) with a Metapath expression. The processor MUST only count the document instance node(s) resulting from its evaluation.

A constraint MUST define a value for either the `@min-occurs` or `@max-occurs` flag. It MAY optionally have both flags defined.

The `@min-occurs` flag MUST be an integer that defines the minimum number of required occurrences for results matching the evaluation of the `@target`.

The `@max-occurs` flag MUST be an integer that defines the maximum number of required occurrences for results matching the evaluation of the `@target`.

A constraint passes and document instance(s) valid if the count of results matching the evaluation of the `@target` Metapath is equal or more than the value of `@min-occurs`, if defined, and equal to or less than the value of `@max-occurs`, if defined. If these requirements are not met when defined, the constraint is not passing and the document instance(s) are not valid.

### `index` Constraints

The `<index>` constraint is a type of Metaschema constraint that defines an index of document instance nodes addressable by key.

The syntax of `<index>` consists of the following:

| Data | Data Type | Use      | Default Value |
|:--- |:--- |:--- |:--- |
| [`@id`](#id) | [`token`](/specification/datatypes/#token) | optional | *(no default)* |
| [`@level`](#level) | `DEBUG`,`INFORMATIONAL`, `WARNING`, `ERROR`, or `CRITICAL` | optional | `ERROR` |
| `@name` | [`token`](/specification/datatypes/#token) | required | *(no default)* |
| [`@target`](#target) | special | required | *(no default)* |
| [`<formal-name>`](#formal-name) | [`string`](/specification/datatypes/#string) | 0 or 1 | *(no default)* |
| [`<description>`](#description) | [`markup-line`](/specification/datatypes/#markup-line) | 0 or 1 | *(no default)* |
| [`<prop>`](#prop) | special | 0 to ∞ | *(no default)* |
| `<key-field>` | special | 1 to ∞ | *(no default)* |
| [`<remarks>`](#remarks) | special | 0 or 1 | *(no default)* |

The syntax of `<key-field>` consists of the following:

| Data | Data Type | Use      | Default Value |
|:--- |:--- |:--- |:--- |
| `@target` | special | required | *(no default)* |
| `@pattern` | regex | optional | *(no default)* |
| `<remarks>` | special | 0 or 1 | *(no default)* |

The `@name` flag of an `<index>` constraint specifies the identity of the index. The constraint MUST define the name.

The `@target` flag of an `<index>` constraint defines the node(s) in a document instance to index. The index MUST define a [`@target`](#target) with a [Metapath expression](/specification/syntax/metapath). The processor MUST index only the node(s) resulting from evaluating the `@target`.

The `<key-field>` assembly of an `<index>` constraint defines the flag or field value that is the key for each entry in the index. A `<key-field>` assembly MUST define at least one [`@target`](#target) flag with a Metapath expression evaluated relative to [the evaluation focus](#constraint-processing) using each node that matches the constraint's `@target`.

An `<index>` constraint MAY define more than one `<key-field>` assembly. The composite key for each entry in the index is the combination of values for the `@target` of every `<key-field/>`. The composite values of the key are the discriminator for the uniqueness of the index entry.

An `<index>` constraint requires that each member entry be unique based upon this composite key.

If the evaluation of the Metapath `@target` of the `<key-field/>` does not result in a value, its value for that key in the index is null.

If two entries have the same key computed from the `<key-field>` `@target`s when generating the index, the processor MUST return a processing error.

### `index-has-key` Constraints

The `<index-has-key>` constraint is a type of Metaschema constraint that checks if a value is a valid cross-reference to values in an existing `index` constraint`.

The `index-has-key` constraint has the same flags and assemblies as a [`index`](#index-constraints) constraint.

The `@target` flag of an `<index-has-key>` constraint defines the node(s) in a document instance to check as a cross-reference. The index MUST define a [`@target`](#target) with a [Metapath expression](/specification/syntax/metapath) to identify the nodes to check. The processor MUST only check the node(s) resulting from evaluating the `@target`.

The similar to an `<index>` constraint, the `<key-field/>` assembly is used to compute the cross-reference's key.

The `@name` flag of an `<index>` constraint MUST specify the name of a previously defined `index` constraint.

### `is-unique` Constraints

The `<is-unique>` constraint is a type of Metaschema constraint that checks that a computed key, based on field and flag values, does not occur more than once. Unlike `<index>`, an explicit, named index is not created. Therefore, this constraint MUST NOT define a `@name` flag.

The `index-has-key` constraint has the same flags and assemblies as a [`index`](#index-constraints) constraint, except it doesn't have a `@name`.

The [`id`](#id) flag of an `<is-unique>` constraint specifies an identifier for the constraint.

The `@target` flag of an `<is-unique>` constraint identifies the node(s) in a document instance to check for uniqueness. The `<is-unique>` MUST define a [`@target`](#target) with a Metapath expression. The processor MUST check uniqueness for only the node(s) resulting from evaluating the `@target`.

A `<key-field>` assembly of an `<is-unique>` constraint identifies the flag or field value that is the key used to determine the uniqueness of each entry based on a computed key. A `<key-field>` element MUST define at least one [`@target`](#target) flag with a Metapath expression evaluated relative to [the evaluation focus](#constraint-processing) using each node that matches the constraint's `@target`.

An `is-unique` constraint MAY define more than one `<key-field>` assembly. The composite key for each entry in the index is the combination of values for the `@target` of every `<key-field/>`. The composite values of the key are the discriminator for the uniqueness of the index entry. 

When evaluating a given key relative to other computed keys for the same constraint, if the given key has the same computed key value as another node matching the same constraint, then the target node MUST be considered to not pass the constraint.

### `matches` Constraints

The `<matches>` constraint is a type of Metaschema constraint that restricts field or flag value(s) based on node(s) matching the target Metapath expression. Each one of these are discussed below.

The syntax of `<matches>` consists of the following:

| Data | Data Type | Use      | Default Value |
|:--- |:--- |:--- |:--- |
| [`@id`](#id) | [`token`](/specification/datatypes/#token) | optional | *(no default)* |
| [`@level`](#level) | `DEBUG`,`INFORMATIONAL`, `WARNING`, `ERROR`, or `CRITICAL` | optional | `ERROR` |
| `@datatype` | special | optional | *(no default)* |
| `@regex` | special | optional | *(no default)* |
| [`@target`](#target) | special | *(varies)* | *(no default)* |
| [`<formal-name>`](#formal-name) | [`string`](/specification/datatypes/#string) | 0 or 1 | *(no default)* |
| [`<description>`](#description) | [`markup-line`](/specification/datatypes/#markup-line) | 0 or 1 | *(no default)* |
| [`<prop>`](#prop) | special | 0 to ∞ | *(no default)* |
| [`<remarks>`](#remarks) | special | 0 or 1 | *(no default)* |

A match can be made by 2 different ways based on `@datatype` and/or based on `@regex`.

The `@target` flag of an `matches` constraint specifies the node(s) in a document instance whose value matches the `@datatype` and/or the `@regex`.

A `@target` is REQUIRED for matches constraints associated with a field and assembly. A `@target` MUST NOT be provided for a matches constraint associated with a flag, since such a constraint can only target the flag's value. In flag use cases the `@target` MUST be considered `.`, referring to the flag node.

The `matches` constraint MUST define a [`target`](#target) with a Metapath expression. The processor MUST evaluate only the node(s) resulting from evaluating the `@target`.

If a `@datatype` is provided, each resulting node's value MUST match the syntax of the given `@datatype`.

If a `@regex` is provided, each resulting node's value MUST match the pattern specified by the given `@regex`.

When evaluating node(s) matching the `@target`, the node(s) pass the constraint when matching all requirements of `@datatype`, if defined, and `@regex`, if defined. 

If the node(s) do not match any of these requirements, then the node(s) MUST be considered to not pass the constraint.

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

```text
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

## External Constraints

TBD
