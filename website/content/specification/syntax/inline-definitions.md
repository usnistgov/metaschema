---
title: "Inline Definitions"
Description: ""
weight: 40
---

*Inline definitions* are a mechanism to both define a named [*information element*](/specification/glossary/#information-element) and instantiate it. In this way, *inline definitions* can be thought of as both [*definitions*](/specification/syntax/definitions/) and [*instances*](/specification/syntax/instances/), sharing the many of the data elements of both.

*Inline definitions* are provided as a convenience to allow single-use *information elements* to declared inline, within other *definitions*. In the case of a single-use, inline declarations are easier to maintain than a *top-level definition* that is referenced, since the maintainer doesn't have to trace the reference.

## Common Inline Definition Data

All *inline definition* types share a common syntax comprised of the following XML attributes and elements.

Attributes:

| Attribute | Data Type | Use      | Default Value |
|:---       |:---       |:---      |:---           |
| [`@deprecated`](#deprecated-version) | version ([`string`](/specification/datatypes/#string)) | optional | *(no default)* |
| [`@name`](#name) | [`token`](/specification/datatypes/#token) | required | *(no default)* |

Elements:

| Element | Data Type | Use      |
|:---       |:---       |:---      |
| [`<formal-name>`](#formal-name) | [`string`](/specification/datatypes/#string) | 0 or 1 |
| [`<description>`](#description) | [`markup-line`](/specification/datatypes/#markup-line) | 0 or 1 |
| [`<prop>`](#prop) | special | 0 to ∞ |
| [`<remarks>`](#remarks) | special | 0 or 1 |
| [`<example>`](#example) | special | 0 to ∞ |

These attributes and elements are described in the following subsections.

Inline definitions do not allow the use of `<use-name>` or `@scope`. Use of a `<use-name>` is not needed, since strick control of naming is provided by `@name`. Use of `scope` is not necessary since inline definitions are always scoped to the context of their use.

### `@deprecated` Version

This attribute has the same semantics and use as the *definition* [`@deprecated`](/specification/syntax/definitions/#deprecated-version) attribute.

### `@name`

This attribute has the same semantics and use as the *definition* [`@deprecated`](/specification/syntax/definitions/#name) attribute.

### `<formal-name>`

This element has the same semantics and use as the *definition* [`<formal-name>`](/specification/syntax/definitions/#formal-name) element.

### `<description>`

This element has the same semantics and use as the *definition* [`<description>`](/specification/syntax/definitions/#description) element.

### `<prop>`

This element has the same semantics and use as the *definition* [`<prop>`](/specification/syntax/definitions/#prop) element.

### `<remarks>`

This element has the same semantics and use as the *definition* [`<remarks>`](/specification/syntax/definitions/#remarks) element.

### `<example>`

This element has the same semantics and use as the *definition* [`<example>`](/specification/syntax/definitions/#example) element.

## Inline `<define-flag>`

An *inline flag definition*, represented by the `<define-flag>` element, is used to declare a single use, inline scoped [flag](/specification/glossary/#flag) within a [top-level `<define-field>`](/specification/syntax/definitions/#top-level-define-field), a [top-level `<define-assembly>`](/specification/syntax/definitions/#top-level-define-assembly), an [inline `<define-field>`](#inline-define-field), or an [inline `<define-assembly>`](#inline-define-assembly).

A *inline flag definition* provides the means to implement a simple, named [*information element*](/specification/glossary/#information-element) with a value.

{{<callout>}}
*Inline flag definitions* are leaf nodes in a Metaschema-based model that are intended to represent granular particles of identifying and qualifying information.
{{</callout>}}

The flag's value is strongly typed using one of the built in [simple data types](/specification/datatypes/#simple-data-types) identified by the `@as-type` attribute.

The syntax of a flag is comprised of the following XML attributes and elements.

Attributes:

| Attribute | Data Type | Use      | Default Value |
|:---       |:---       |:---      |:---           |
| [`@as-type`](#as-type) | [`token`](/specification/datatypes/#token) | optional | [`string`](/specification/datatypes/#string) |
| [`@default`](#default) | [`string`](/specification/datatypes/#string) | optional | *(no default)* |
| [`@deprecated`](#deprecated-version) | version ([`string`](/specification/datatypes/#string)) | optional | *(no default)* |
| [`@name`](#name) | [`token`](/specification/datatypes/#token) | required | *(no default)* |

Elements:

| Element | Data Type | Use      |
|:---       |:---       |:---      |
| [`<formal-name>`](#formal-name) | [`string`](/specification/datatypes/#string) | 0 or 1 |
| [`<description>`](#description) | [`markup-line`](/specification/datatypes/#markup-line) | 0 or 1 |
| [`<prop>`](#prop) | special | 0 to ∞ |
| [`<constraint>`](/specification/syntax/constraints/#define-flag-constraints) | special | 0 or 1 |
| [`<remarks>`](#remarks) | special | 0 or 1 |
| [`<example>`](#example) | special | 0 to ∞ |

The attributes and elements specific to the inline `<define-flag>` are described in the following subsections. The elements and attributes common to all *inline definitions* are [defined earlier](#common-inline-definition-data) in this specification.

### `@as-type`

This attribute has the same semantics and use as the *flag definition* [`@as-type`](/specification/syntax/definitions/#as-type) attribute.

### `@default`

This attribute has the same semantics and use as the *flag definition* [`@default`](/specification/syntax/definitions/#default) attribute.

### `@required`

This attribute has the same semantics and use as the *flag definition* [`@required`](/specification/syntax/instances/#required) attribute.

## Inline `<define-field>`

## Inline `<define-assembly>`
