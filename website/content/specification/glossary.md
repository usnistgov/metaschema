---
title: "Metaschema Framework Specification Glossary"
linktitle: "Glossary"
Description: "Definitions of Metaschema Terms"
weight: 90
toc:
  enabled: true
alias:
- /specification/concepts/terminology/
---

The following terminology is used in this specification:

## Assembly

An *assembly* is defined as follows:

{{<callout>}}A complex named data element consisting of an optional set of [*flags*](#flag) and an optional sequence of model instances.{{</callout>}}

An assembly does not have an associated value.

An assembly may reference or directly define zero or more [*flags*](#flag). Flag instances associated with an assembly definition typically provide additional metadata used to identify or characterize the object represented by the assembly.

An Assembly has an optional model consisting of references to zero or more [*assemblies*](#assembly) or [*fields*](#field) as model instances. These model instances allow complex data to be composed within an assembly.

An *assembly definition* is a type of [*definition*](#definition) within a given [*Metaschema module*](#metaschema-module) used to represent the implementation of a complex [*information element*](#information-element) as an assembly.

## Data Model

A *data model*, abbreviated as DM, is defined as follows:

{{<callout>}}A representation of an [*information model*](#information-model) in a format specific serializable form (e.g., XML, JSON, YAML) expressed using a format-specific schema syntax.{{</callout>}}

> As described by [RFC 3444](https://tools.ietf.org/html/rfc3444#section-4)), a data model is defined at a lower level of abstraction than the information model it represents, and includes many details.
>
> - Intended for implementors
> - Include protocol-specific constructs.

In Metaschema, the format-specific schema (i.e., XML or JSON Schema) is generated within the Metaschema architecture from a [*Metaschema module*](#metaschema-module). By defining *data models* appropriate and tuned for each format, these generated schemas can be used to validate that data is conformant to the associated format, and thus conformant to the *information model* defined by a given *Metaschema module*.

## Definition

{{<callout>}}A distinct [*information element*](#information-element) implementation within a [*Metaschema module*](#metaschema-module) representing a semantically well-defined data structure, along with any associated data type(s), information element relationships, cardinalities, and other information characteristics.{{</callout>}}

An [*assembly*](#assembly) definition, [*field*](#field) definition, or [*flag*](#flag) definition are types of *definitions* within a *Metaschema module*.

## Domain

An information *domain* is defined as follows:

{{<callout>}}A specific area of knowledge, interest, and/or practice.{{</callout>}}

## Flag

A *flag* is defined as follows:

{{<callout>}}A simple named data element with an associated primitive value.{{</callout>}}

A *flag* is a pairing of a name and a value.

A flag typically provides identifying or classifying information for the containing [*assembly*](#assembly) or [*field*](#field).

The flag's value is strongly typed using one of the built in [simple data types](/specification/datatypes/#simple-data-types).

A *flag definition* is a type of [*definition*](#definition) within a given [*Metaschema module*](#metaschema-module) used to represent the implementation of a simple, named [*information element*](#information-element) with an associated primitive value as a flag.

## Field

A *field* is defined as follows:

{{<callout>}}A complex named data element consisting of a required value and an optional set of [*flags*](#flag).{{</callout>}}

A field is typically used to provide supporting information for a containing [*assembly*](#assembly).

The field's value is strongly typed using one of the built in [simple data types](/specification/datatypes/#simple-data-types) or [markup data types](/specification/datatypes/#markup-data-types).

A *field definition* is a type of [*definition*](#definition) within a given [*Metaschema module*](#metaschema-module) used to represent the implementation of a named complex [*information element*](#information-element) with an associated primitive or markup typed value, and zero or more [*flags*](#flag) as a field.

## Information Element

An *information element* is defined as follows:

{{<callout>}}A given data concept within a specific [*domain*](#domain) representing a semantically well-defined data structure, along with their data type(s), cardinalities, and other information characteristics. A part of a larger [*information model*](#information-model).{{</callout>}}

An *information element* is implemented by a [*definition*](#definition) in a [*Metaschema module*](#metaschema-module).

## Information Model

An *information model*, abbreviated as IM, is defined as follows:

{{<callout>}}A format-neutral description of a set of [*information elements*](#information-element) for a given [*domain*](#domain).{{</callout>}}

> As described by [RFC 3444](https://tools.ietf.org/html/rfc3444#section-3)), an IM describes *information elements* at a conceptual level, independent of any specific implementations or protocols used to transport the data.
>
> - Level of abstraction depends on the modeling needs of the designers
> - Define relationships between managed objects
> - Should hide all protocol or implementation details, allowing for different implementations

A [*Metaschema module*](#metaschema-module) is a format for representing an *information model*. Each [*definition*](#definition) defined by a Metaschema module represents a managed object of the information model.

## Metaschema Module

A *Metaschema module* is defined as follows:

{{<callout>}}A format for describing the implementation of each [*information element*](#information-element) contained within an [*information model*](#information-model) using Metaschema syntax. Each *information element* is implemented by a [*definition*](#definition) which provides details about the information element's structure, meaning (semantics) and use.{{</callout>}}

A Metaschema module is composed of flag, field, and assembly definitions.

- **[Flag](#flag):** A simple named data object with an associated scalar value. A simple name / value pair. A flag is used to represent a leaf information element.
- **[Field](#field):** A complex named data object with an associated scalar or markup typed value and zero or more flags. A field is used to represent an edge information element.
- **[Assembly](#assembly):** A complex named data object, with no value, zero or more flags, and a complex model consisting of a combination of child fields and assemblies. An assembly is used to represent a composite information element.

A Metaschema module can be used as the basis for producing schema files, content conversion utilities, documentation, parsing code, and other artifacts that can be used in support of handling data aligned with an information model.
