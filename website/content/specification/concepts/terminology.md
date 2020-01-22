---
title: "Metaschema Terminology"
Description: "Definitions of Metaschema Terms"
---

The following terminology is used in this specification:

## Assembly

An *assembly* is defined as follows:

{{<callout>}}The [*information structure*](#information-structure) used to represent a [*managed object*](#managed-object) within a given [*metaschema definition*](#metaschema-definition).{{</callout>}}

An assembly does not have an associated value.

An assembly may reference or directly define zero or more [*flags*](#flag).

An Assembly has a model consisting of references to zero or more [*assemblies*](#assembly) or [*flags*](#flag).

## Data Model

A *data model*, abbreviated as DM, is defined as follows:

{{<callout>}}A representation of an [*information model*](#information-model) in a format specific serializable form (e.g., XML, JSON, YAML) expressed in a format-specific schema definition syntax. The format-specific schema definition is generated within the Metaschema architecture from the [*metaschema-definition*](#metaschema-definition). These generated schema can be used to validate that data is conformant to the asscoiated format, and thus conformant to the *information model* defined by a given *metaschema defintion*.{{</callout>}}

> As described by [RFC 3444](https://tools.ietf.org/html/rfc3444#section-4)), a data model is defined at a lower level of abstraction and include many details.

> - Intended for implementors
> - Include protocol-specific constructs.

## Domain

An *domain* is defined as follows:

{{<callout>}}A specific area of knowledge, interest, and/or practice.{{</callout>}}

## Flag

A *flag* is defined as follows:

{{<callout>}}A simple named data element with an associated scalar value. A *flag* is a simple [*information structure*](#information-structure) used to represent a part of a [*managed object*](#managed-object) within a given [*metaschema definition*](#metaschema-definition).{{</callout>}}

A *flag* is a pairing of a name and a value.

A flag typically provides identifying or classifying information for the containing assembly or field.

## Field

A *field* is defined as follows:

{{<callout>}}A complex named data element with an associated scalar or markup typed value and zero or more flags. A *field* is a complex [*information structure*](#information-structure) used to represent a part of a [*managed object*](#managed-object) within a given [*metaschema definition*](#metaschema-definition).{{</callout>}}

A field has a required value.

A field may reference or directly define zero or more [*flags*](#flag).

A field does not have a model.

A field provides supporting information for the containing assembly.

## Information Model

An *information model*, abbreviated as IM, is defined as follows:

{{<callout>}}A format-neutral description of a set of [*managed objects*](#managed-object) for a given [*domain*](#domain).{{</callout>}}

> As described by [RFC 3444](https://tools.ietf.org/html/rfc3444#section-3)), an IM describes managed objects at a conceptual level, independent of any specific implementations or protocols used to transport the data.

> - Level of abstraction depends on the modeling needs of the designers
> - Define relationships between managed objects
> - Should hide all protocol or implementation details, allowing for different implementations

## Information Structure

An *information structure* is defined as follows:

{{<callout>}}A description of heirarchically related information elements, along with their cardinalities, representing a semanticly well-defined data structure.{{</callout>}}

## Managed Object

An *managed object* is defined as follows:

{{<callout>}}A given concept within a specific [*domain*](#domain) consisting of a defined [*information structure*](#information-structure).{{</callout>}}

A *managed object* is represented by an [*assembly*] in a [*metaschema definition*](#metaschema-definition).

## Metaschema Definition

An *metaschema definition* is defined as follows:

{{<callout>}}A format for describing the [*managed objects*](#managed-object) in an [*information model*](#information-model) using Metaschema syntax. For each managed object, details are provided about its structure, meaning (semantics) and use.{{</callout>}}

A metaschema definition consists of a few different types of information elements:

- **Flag:** A named data element with an associated scalar value. A simple name / value pair.
- **Field:** A complex named data element with an associated scalar or markup typed value and zero or more flags.
- **Assembly:** A complex named data object, with no value, zero or more flags, and a complex model consisting of a combination of child fields and assemblies.

![A metaschema definition is composed of flag, field, and assembly definitions. A flag has a value. A Field has a value and may associate zero or more flags. An assembly has no value, may associate zero or more flags, and has a model which may associate zero or more assemblies or fields.](../metaschema-information-elements.png)

*Flags* and *fields* are leaf information elements that support the managed object.

A metaschema definition is used as the basis for producing schema files, conversion files, documentation and utilities in support of that format. For any given model defined by a metaschema, the XML Schema (XSD) and JSON Schema will be consistent to a common information model because they are produced from the same metaschema definition.
