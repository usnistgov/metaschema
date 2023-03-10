---
title: "Metaschema Terminology"
Description: "Definitions of Metaschema Terms"
sidenav:
  title: Terminology
---

The following terminology is used in this specification:

## Assembly

An *assembly* is defined as follows:

{{<callout>}}A type of [*object definition*](#object-definition) within a given [*metaschema definition*](#metaschema-definition) used to represent a complex [*information element*](#information-element).{{</callout>}}

An assembly does not have an associated value.

An assembly may reference or directly define zero or more [*flags*](#flag).

An Assembly has a model consisting of references to zero or more [*assemblies*](#assembly) or [*fields*](#field).

## Data Model

A *data model*, abbreviated as DM, is defined as follows:

{{<callout>}}A representation of an [*information model*](#information-model) in a format specific serializable form (e.g., XML, JSON, YAML) expressed using a format-specific schema definition syntax.{{</callout>}}

> As described by [RFC 3444](https://tools.ietf.org/html/rfc3444#section-4)), a data model is defined at a lower level of abstraction and include many details.
>
> - Intended for implementors
> - Include protocol-specific constructs.

In metaschema, the format-specific schema definition (XML or JSON Schema) is generated within the Metaschema architecture from a [*metaschema-definition*](#metaschema-definition). These generated schema can be used to validate that data is conformant to the associated format, and thus conformant to the *information model* defined by a given *metaschema definition*.

## Domain

An *domain* is defined as follows:

{{<callout>}}A specific area of knowledge, interest, and/or practice.{{</callout>}}

## Flag

A *flag* is defined as follows:

{{<callout>}}A simple named data element with an associated primative value. A *flag* is a type of [*object definition*](#object-definition) within a given [*metaschema definition*](#metaschema-definition) used to represent a simple, named [*information element*](#information-element) with an associated primative value.{{</callout>}}

A *flag* is a pairing of a name and a value.

A flag typically provides identifying or classifying information for the containing assembly or field.

## Field

A *field* is defined as follows:

{{<callout>}}A *field* is a type of [*object definition*](#object-definition) within a given [*metaschema definition*](#metaschema-definition) used to represent a named complex [*information element*](#information-element) with an associated primative or markup typed value, and zero or more [*flags*](#flag).{{</callout>}}

A field has a required value.

A field may reference or directly define zero or more [*flags*](#flag).

A field does not have a model.

A field provides supporting information for the containing assembly.

## Information Model

An *information model*, abbreviated as IM, is defined as follows:

{{<callout>}}A format-neutral description of a set of [*information elements*](#information-element) for a given [*domain*](#domain).{{</callout>}}

> As described by [RFC 3444](https://tools.ietf.org/html/rfc3444#section-3)), an IM describes *information elements* at a conceptual level, independent of any specific implementations or protocols used to transport the data.
>
> - Level of abstraction depends on the modeling needs of the designers
> - Define relationships between managed objects
> - Should hide all protocol or implementation details, allowing for different implementations

A [*Metaschema definition*](#metaschema-definition) is a format for representing an *information model*.

## Information Element

An *information element* is defined as follows:

{{<callout>}}A given data concept within a specific [*domain*](#domain) representing a semantically well-defined data structure, along with their data type(s), cardinalities, and other information characteristics. A part of a larger [*information model*](#information-model).{{</callout>}}

An *information element* is implemented by an [*object definition*](#object-definition) in a [*metaschema definition*](#metaschema-definition).

## Metaschema Definition

An *metaschema definition* is defined as follows:

{{<callout>}}A format for describing the implementation of [*information elements*](#information-element) in an [*information model*](#information-model) using Metaschema syntax. Each *information element* is defined by an [*object definition*](#object-definition) which provides details about the information element's structure, meaning (semantics) and use.{{</callout>}}

A metaschema definition is composed of flag, field, and assembly definitions:

- **[Flag](#flag):** A named data element with an associated scalar value. A simple name / value pair.
- **[Field](#field):** A complex named data element with an associated scalar or markup typed value and zero or more flags.
- **[Assembly](#assembly):** A complex named data object, with no value, zero or more flags, and a complex model consisting of a combination of child fields and assemblies.

*Flags* and *fields* are leaf information elements.

A metaschema definition is used as the basis for producing schema files, conversion files, documentation and utilities in support of that format. For any given model defined by a metaschema, the XML Schema (XSD) and JSON Schema will be consistent to a common information model because they are produced from the same metaschema definition.

## Object Definition

{{<callout>}}A distinct [*information element*](#information-element) implementation within a [*metaschema definition*](#metaschema-definition) representing a semantically well-defined data structure, along with the data type(s), cardinalities, and other information characteristics.{{</callout>}}

An [*assembly*](#assembly) definition, [*field*](#field) definition, or [*flag*](#flag) definition are types of *object definitions* within a *metaschema definition*.
