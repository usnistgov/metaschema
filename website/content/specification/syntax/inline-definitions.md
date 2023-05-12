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
| [`@deprecated`](/specification/syntax/definitions/#deprecated-version) | version ([`string`](/specification/datatypes/#string)) | optional | *(no default)* |
| [`@name`](/specification/syntax/definitions/#name) | [`token`](/specification/datatypes/#token) | required | *(no default)* |

Elements:

| Element | Data Type | Use      |
|:---       |:---       |:---      |
| [`<formal-name>`](/specification/syntax/definitions/#formal-name) | [`string`](/specification/datatypes/#string) | 0 or 1 |
| [`<description>`](/specification/syntax/definitions/#description) | [`markup-line`](/specification/datatypes/#markup-line) | 0 or 1 |
| [`<prop>`](/specification/syntax/definitions/#prop) | special | 0 to ∞ |
| [`<remarks>`](/specification/syntax/definitions/#remarks) | special | 0 or 1 |
| [`<example>`](/specification/syntax/definitions/#example) | special | 0 to ∞ |

These attributes and elements are based on the [*definition* common data elements](/specification/syntax/definitions/#common-definition-data), since an *inline definition* uses the a reduced set of the same data with the same semantics.

Due to their single use nature, *inline definitions* do not allow the use of `@scope` or `<use-name>`. Use of `scope` is not necessary since inline definitions are always scoped to the context of their use. Use of a `<use-name>` is not needed, since strick control of naming is provided by `@name`.

## Inline `<define-flag>`

An *inline flag definition*, represented by the `<define-flag>` element, is used to declare a single use, locally scoped [flag](/specification/glossary/#flag) within a [top-level `<define-field>`](/specification/syntax/definitions/#top-level-define-field), a [top-level `<define-assembly>`](/specification/syntax/definitions/#top-level-define-assembly), an [inline `<define-field>`](#inline-define-field), or an [inline `<define-assembly>`](#inline-define-assembly).

A *inline flag definition* provides the means to implement a simple, named [*information element*](/specification/glossary/#information-element) with a value.

{{<callout>}}
*Inline flag definitions* are leaf nodes in a Metaschema-based model that are intended to represent granular particles of identifying and qualifying information.
{{</callout>}}

The flag's value is strongly typed using one of the built in [simple data types](/specification/datatypes/#simple-data-types) identified by the `@as-type` attribute.

The syntax of an *inline flag definition* is comprised of the following XML attributes and elements.

Attributes:

| Attribute | Data Type | Use      | Default Value |
|:---       |:---       |:---      |:---           |
| [`@as-type`](/specification/syntax/definitions/#as-type) | [`token`](/specification/datatypes/#token) | optional | [`string`](/specification/datatypes/#string) |
| [`@default`](/specification/syntax/definitions/#default) | [`string`](/specification/datatypes/#string) | optional | *(no default)* |
| [`@deprecated`](/specification/syntax/definitions/#deprecated-version) | version ([`string`](/specification/datatypes/#string)) | optional | *(no default)* |
| [`@name`](/specification/syntax/definitions/#name) | [`token`](/specification/datatypes/#token) | required | *(no default)* |
| [`@required`](/specification/syntax/instances/#required) | `yes` or `no` | optional | `no` |

Elements:

| Element | Data Type | Use      |
|:---       |:---       |:---      |
| [`<formal-name>`](/specification/syntax/definitions/#formal-name) | [`string`](/specification/datatypes/#string) | 0 or 1 |
| [`<description>`](/specification/syntax/definitions/#description) | [`markup-line`](/specification/datatypes/#markup-line) | 0 or 1 |
| [`<prop>`](/specification/syntax/definitions/#prop) | special | 0 to ∞ |
| [`<constraint>`](/specification/syntax/constraints/#define-flag-constraints) | special | 0 or 1 |
| [`<remarks>`](/specification/syntax/definitions/#remarks) | special | 0 or 1 |
| [`<example>`](/specification/syntax/definitions/#example) | special | 0 to ∞ |

These attributes and elements are based on a combination of a reduced set of the data elements provided by the [*top-level flag definition*](/specification/syntax/definitions/#top-level-define-flag) and the [*flag instance*](/specification/syntax/instances/#flag-instance), since an *inline flag definition* uses a reduced set of the same data with the same semantics.

The elements and attributes common to all *inline definitions* are [defined earlier](#common-inline-definition-data) in this specification.

## Inline `<define-field>`

TODO: front matter.

Attributes:

| Attribute | Data Type | Use      | Default Value |
|:---       |:---       |:---      |:---           |
| [`@as-type`](/specification/syntax/definitions/#as-type-1) | [`token`](/specification/datatypes/#token) | optional | [`string`](/specification/datatypes/#string) |
| [`@collapsible`](/specification/syntax/definitions/#collapsible) | `yes` or `no` | optional | `no` |
| [`@default`](/specification/syntax/definitions/#default-1) | [`string`](/specification/datatypes/#string) | optional | *(no default)* |
| [`@deprecated`](/specification/syntax/definitions/#deprecated-version) | version ([`string`](/specification/datatypes/#string)) | optional | *(no default)* |
| [`@in-xml`](/specification/syntax/instances/#in-xml-1) | `WITH_WRAPPER` or `UNWRAPPED` | optional | `WITH_WRAPPER` |
| [`@max-occurs`](/specification/syntax/instances/#max-occurs) | [`positive-integer`](/specification/datatypes/#non-negative-integer) or `unbounded` | optional | 1 |
| [`@min-occurs`](/specification/syntax/instances/#min-occurs) | [`non-negative-integer`](/specification/datatypes/#non-negative-integer) | optional | 0 |
| [`@name`](/specification/syntax/definitions/#name) | [`token`](/specification/datatypes/#token) | required | *(no default)* |

Elements:

| Element | Data Type | Use      |
|:---       |:---       |:---      |
| [`<formal-name>`](/specification/syntax/definitions/#formal-name) | [`string`](/specification/datatypes/#string) | 0 or 1 |
| [`<description>`](/specification/syntax/definitions/#description) | [`markup-line`](/specification/datatypes/#markup-line) | 0 or 1 |
| [`<prop>`](/specification/syntax/definitions/#prop) | special | 0 to ∞ |
| [`json-key`](/specification/syntax/definitions/#json-key) | special | 0 or 1 |
| [`json-value-key`](/specification/syntax/definitions/#json-value-key) or<br/>[`json-value-key-flag`](/specification/syntax/definitions/#json-value-key-flag) | special | 0 or 1 |
| [`<group-as>`](/specification/syntax/instances/#group-as) | special | 0 or 1 |
| [`flag`](/specification/syntax/definitions/#flag-instance-children) or<br/>[`define-flag`](/specification/syntax/definitions/#define-flag-inline-definition) | special | 0 or ∞ |
| [`<constraint>`](/specification/syntax/constraints/#define-flag-constraints) | special | 0 or 1 |
| [`<remarks>`](/specification/syntax/definitions/#remarks) | special | 0 or 1 |
| [`<example>`](/specification/syntax/definitions/#example) | special | 0 to ∞ |


TODO: rear matter.

## Inline `<define-assembly>`

TODO: front matter.

Attributes:

| Attribute | Data Type | Use      | Default Value |
|:---       |:---       |:---      |:---           |
| [`@deprecated`](/specification/syntax/definitions/#deprecated-version) | version ([`string`](/specification/datatypes/#string)) | optional | *(no default)* |
| [`@max-occurs`](/specification/syntax/instances/#max-occurs) | [`positive-integer`](/specification/datatypes/#non-negative-integer) or `unbounded` | optional | 1 |
| [`@min-occurs`](/specification/syntax/instances/#min-occurs) | [`non-negative-integer`](/specification/datatypes/#non-negative-integer) | optional | 0 |
| [`@name`](/specification/syntax/definitions/#name) | [`token`](/specification/datatypes/#token) | required | *(no default)* |

Elements:

| Element | Data Type | Use      |
|:---       |:---       |:---      |
| [`<formal-name>`](/specification/syntax/definitions/#formal-name) | [`string`](/specification/datatypes/#string) | 0 or 1 |
| [`<description>`](/specification/syntax/definitions/#description) | [`markup-line`](/specification/datatypes/#markup-line) | 0 or 1 |
| [`<prop>`](/specification/syntax/definitions/#prop) | special | 0 to ∞ |
| [`json-key`](/specification/syntax/definitions/#json-key) | special | 0 or 1 |
| [`json-value-key`](/specification/syntax/definitions/#json-value-key) or<br/>[`json-value-key-flag`](/specification/syntax/definitions/#json-value-key-flag) | special | 0 or 1 |
| [`<group-as>`](/specification/syntax/instances/#group-as) | special | 0 or 1 |
| [`flag`](/specification/syntax/definitions/#flag-instance-children) or<br/>[`define-flag`](/specification/syntax/definitions/#define-flag-inline-definition) | special | 0 or ∞ |
| [`<constraint>`](/specification/syntax/constraints/#define-flag-constraints) | special | 0 or 1 |
| [`<remarks>`](/specification/syntax/definitions/#remarks) | special | 0 or 1 |

TODO: rear matter.
