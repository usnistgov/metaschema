---
title: "Metaschema Syntax"
description: "Overview of the Metaschema syntax"
weight: 50
sidenav:
  toc:
    includeHtml: true
    headingselectors: h2,h3,h4,h5
---

A Metaschema instance has two parts: a header (the `METASCHEMA` element), and a set of definitions for the model components or parts supported by the `define-assembly`, `define-field`, and `define-flag` elements.

Top level documentation for the Metaschema instance appears in the header section, while documentation for all the model components appears with the definitions for those constructs. There is no explicit separation between the header and the definitions: the header ends when the definitions start.

## Root Element
### `METASCHEMA` element

The root element is `METASCHEMA` using all capitals. To name the root element in all capitals (unlike the general rule) and to give it a name somewhat peculiar to its application, retains and expresses the information that it is intended to be the document root. This is the only element named in all caps.

Attributes:

- `@root`: indicates the root element or object for the schema, which must correspond to the `@name` of one of the (assembly) definitions in the metaschema.

A metaschema definition may include these elements, in order:

#### `schema-name`

Describing the scope of application of the data format, for example "OSCAL Catalog".

#### `schema-version`

A literal value indicating the version to be assigned to schemas and tools produced from the Metaschema.

#### `short-name`

A coded version of the schema name, for use when a string-safe identifier is needed, for example on artifact file names. Expect this short name to be propagated anytime such a "handle" is needed. A short name for the OSCAL Catalog metaschema (and schemas) might be `oscal-catalog`.

#### `namespace`

An XML namespace identifier (URI) to be used for the resulting XSD. All elements in the metaschema will be assigned to this namespace, including elements defined in metaschema modules, that are designated with their own namespaces. (In other words, this data value is operative only for the top-level metaschema, not for any of its imported modules. This makes it possible to use modules in metaschemas defined with different namespaces.)

#### `remarks`

Paragraphs describing the metaschema.

Note that the `remarks` element is also permitted to appear elsewhere; this is a general-purpose element for including explanatory commentary of any kind; its scope of application is generally shown by its location in the document - the top-level remarks should describe the entire metaschema.

#### `import`

Used to import the components defined in another metaschema definition into this metaschema definition.

#### Component Definitions

Following the `METASCHEMA/remarks`, any number of schema component definitions may follow. These describe each component, provide information determining details of its representation and handling (in XML and JSON), and include documentation.

Each component is defined by one of the `define-assembly`, `define-field`, and `define-flag` child elements, which are described individually below.

## Component Definitions

The `define-assembly`, `define-field`, and `define-flag` child elements have a common base model.

### Common Elements

#### `formal-name`

A label for use in documentation to provide a human-readable name for the component. The `formal-name` element is required.

#### `description`

A semantic definition for the component for use in documentation. This definition ties the component to the related concept in the information domain the model is representing. The `description` element is required.

#### `remarks`

Provides notes on the use of the component that may clarify the semantic definition for the component for use in documentation. The `remarks` element is optional and may occur multiple times.

#### `example`

Used to provide inline use examples in XML, which can then be automatically converted into other formats. The `example` element is optional and may occur multiple times.

### `define-field`

Fields can be thought of as simple text values, either scalars or sequences of scalars, or when appropriate, of "rich text" or mixed content, i.e. text permitting inline formatting. Depending on modeling requirements, fields may also be used for even simpler bits of data, such as objects that carry specialized flags but have no values or structures otherwise. This means that fields can be more or less complex, depending on the need. 

Attributes:

- `@as-type`(type: string, use: optional, default: string): Defines the type of the field's value. The `@as-type` attribute must have a value that corresponds to a [data type](#data-types).
- `@collapsible`(type: yes/no, use: optional, default: yes): Is a JSON and YAML specific behavior that allows multiple fields having the same set of flag values to be collapsed into a single object with a value property that is an array of values. This makes JSON and YAML formatted data more concise.
- `@name`(type: NCName, use: required): Used to identify the field when it is referenced within the metaschema definition. 

The following elements are supported:

#### `json-key`

See [using `@json-key`](#using-json-key).

#### `json-value-key`

In XML, the value of a field appears as the child of the field's element. In JSON and YAML, a property name is needed for the value. The `json-value-key` element provides the property name in one of three possible ways:

1. A value is provided that is used as the property name.
2. A `@flag-name` value is provided that indicates the flag's value to use as the property name. This results in a property that is a combination of the referenced flag's value and the field's value. For example: "flag-value": "field-value".
3. If the `json-value-key` is not specified, a default value will be chosen based on the data type as follows:
    - If the data type is `empty` no property will exist, so no property name is needed.
    - If the data type is `markup-line`, then the property name will be `RICHTEXT`.
    - If the data type is `markup-multiline`, then the property name will be `prose`.
    - Otherwise, the property name will be `STRVALUE`.

#### `flag`

See [local defintion of `flag` components](#local-defintion-of-flag-components).

In addition to these settings, fields may be defined with flags. Do this by including `flag` elements directly in the definition.

#### `allowed-values`

See [using `allowed-values`](#using-allowed-values).

### `define-assembly`

An assembly is similar to a field, except it contains structured content (objects or elements), not text or unstructured "rich text". The contents permitted in a particular (type of) assembly are indicated in its `model` element.

An `@as-type` attribute is not permitted on an assembly definition.

#### `json-key`

See [using `@json-key`](#using-json-key).

#### `flag`

See [local defintion of `flag` components](#local-defintion-of-flag-components).

#### `model`

This element is used to reference the `field` and `assembly` components that compose the assembly's model. A `choice` element is also provided to define mutually exclusive model members.

##### Redefining the `description`

The optional `description` element of the child `field` and `assembly` elements can be used to provide a different description for when the referenced component is used in the specified model context.

##### Using cardinalities and `group-as`

The child `field` and `assembly` elements share the following common set of attributes:

- `@ref`(type: NCName, use: required): References the name of the corresponding `define-field` or `define-assembly`.
- `@min-occurs` (type: nonNegativeInteger, use: optional, default: 0): Indicates the minimum allowed occurance of the corresponding `define-field` or `define-assembly`.
- `@max-occurs` (type: positiveInteger or "unbounded", use: optional, default: 1): Indicates the maximum allowed occurance of the corresponding `define-field` or `define-assembly`. The value `unbounded` indicates the the referenced component can occur any number of times.

The `group-as` element is required if the `@max-occurs` attribute has a value greater than '1' or `unbounded` to provide additional information about how to handle the collection of data.

The `group-as` element has the following set of attributes:

- `@name`(type: NCName, use: required): The grouping name to use in XML, JSON, and YAML. Use of this name is further clarified by the `@in-xml` attribute, when used.
- `@in-json` (type: special, use: optional, default: SINGLETON_OR_ARRAY): 

    In all cases, `@name` value is used as the property name.

    | Value | JSON Behavior |
    |:--- |:--- |
    | ARRAY | The child objects are to be represented as an array of objects. |
    | SINGLETON_OR_ARRAY | If a single object is provided, then the child will be an object, otherwise the child objects will be represented as an array of objects. |
    | BY_KEY | An itermediate object will be used as the child, with property names equal to the value of the referenced `define-field` or `define-assembly` component's flag as specified by the `@json-key` attribute on that component. See [using `@json-key`](#using-json-key). |

- `@in-xml` (type: special, use: optional, default: UNGROUPED): 

    | Value | JSON Behavior |
    |:--- |:--- |
    | GROUPED | The child elements will be placed within a wrapper element with a localname equal to the value of the `@name` attribute. Each child element's localname will be the `@name` of the referenced component. |
    | UNGROUPED | The `@name` attribute is ignored. Each child element's localname will be the `@name` of the referenced component. |

##### `assembly`

Used to reference an `assembly-definition` who's `@name` matches the value of the `@ref` attribute.

##### `field`

Used to reference a `field-definition` who's `@name` matches the value of the `@ref` attribute.

- `@in-xml`

See [using `allowed-values`](#using-allowed-values).

### `define-flag`

While data of arbitrary complexity is represented by assemblies (which may contain assemblies), at the other extreme, flags are available for the most granular bits of qualifying information. Since data already appears as text values of fields, flags might not be necessary. But they are extremely useful both for enabling more economical expression of data and especially process-oriented or "semantic" metadata such as controlled values, formal or informal taxonomic classifications etc. etc.

Attributes:

- `@as-type`(type: string, use: optional, default: string): Defines the type of the flag's value. The `@as-type` attribute must have a value that corresponds to a [simple](#simple-data-types) (excluding "empty") or [formatted string](#formatted-string-data-types) data type.
- `@name`(type: NCName, use: required): Used to identify the flag when it is referenced within the metaschema definition. 

#### `allowed-values`

See [using `allowed-values`](#using-allowed-values).

## Local Refinements

### Local defintion of `flag` components

TBD

### Using `@json-key`

TBD

### Using `allowed-values`

TBD

## Data types

A data type can be specified in a metaschema definition within a `define-field`, `field`, `define-flag`, or `flag` component definition using the `@as-type` attribute. The following are the allowed data types.

### Simple Data types

#### empty

This data type indicates that the model information element contains no value content, but may contain other structured information elements.

In XML, this may represent an element without text content.

In JSON, this may represent an object with labels corresponding to other child information elements, but no label corresponding to a text value.

#### boolean

A boolean value mapped in XML, JSON, and YAML as follows:

| Value | XML | JSON | YAML |
|:--- |:--- |:--- |:--- |
| true | `true` or `1` | `true` | `true` |
| false | `false` or `0` | `false` | `false` |

#### string

A string of Unicode characters.

#### NCName

A non-colonized name as defined by [XML Schema Part 2: Datatypes Second Edition](https://www.w3.org/TR/xmlschema11-2/#NCName).

#### integer

An integer value.

OSCAL represents integers [as defined in XSD](https://www.w3.org/TR/xmlschema11-2/#integer).

In JSON Schema, the [`integer` type](https://tools.ietf.org/html/draft-handrews-json-schema-validation-01#section-6.1.1) is used. Additionally, the `multipleOf` keyword is set to `1.0` to ensure an integer value in systems that do not have a native type.

#### nonNegativeInteger

An integer value that is equal to or greater than `0`.

In XSD, [nonNegativeInteger](https://www.w3.org/TR/xmlschema11-2/#nonNegativeInteger) is a built in type derived from the `integer` type.

In JSON Schema, this becomes an `integer` value with an additional `minimum` constraint of `0`. Additionally, the `multipleOf` keyword is set to `1.0` to ensure an integer value in systems that do not have a native type.

#### positiveInteger

A positive integer value.

In XML Schema, [positiveInteger](https://www.w3.org/TR/xmlschema11-2/#nonNegativeInteger) is a built in type derived from the 'nonNegativeInteger' type.

In JSON Schema, this becomes an `integer` value with an additional `minimum` constraint of `1`. Additionally, the `multipleOf` keyword is set to `1.0` to ensure an integer value in systems that do not have a native type.

#### decimal

A real number expressed using decimal numerals.

In XML Schema this is represented as the built in type [decimal](https://www.w3.org/TR/xmlschema11-2/#decimal).

In JSON Schema, this is represented as:

```JSON
{
  "type": "number",
  "pattern": "(\\+|-)?([0-9]+(\\.[0-9]*)?|\\.[0-9]+)"
}
```

### Formatted String Data types

#### date

In XML, the [date](https://www.w3.org/TR/xmlschema11-2/#date) datatype is used. This is the same as
[date-with-timezone](#date-with-timezone), except the time zone portion is optional.

In JSON, lexical conformance to dates with optional time zones is provided by a regular expression, the same as given above for [date-with-timezone](#date-with-timezone), except as adjusted for the requirement.

#### date-with-timezone

A string representing a 24-hour period in a given timezone. A `date-with-timezone` is formatted according to "full-date" as defined [RFC3339](https://tools.ietf.org/html/rfc3339#section-5.6). This type additionally requires that the time-offset (timezone) is always provided.

For example:

```
2019-09-28Z
2019-12-02-08:00
```

In XML Schema this is represented as a restriction on the built-in type [date](https://www.w3.org/TR/xmlschema11-2/#date) as follows:

```XML
<xs:simpleType name="date-with-timezone">
  <xs:annotation>
    <xs:documentation>The xs:date with a required timezone.</xs:documentation>
  </xs:annotation>
  <xs:restriction base="xs:date">
    <xs:pattern value="((2000|2400|2800|(19|2[0-9](0[48]|[2468][048]|[13579][26])))-02-29)|(((19|2[0-9])[0-9]{2})-02-(0[1-9]|1[0-9]|2[0-8]))|(((19|2[0-9])[0-9]{2})-(0[13578]|10|12)-(0[1-9]|[12][0-9]|3[01]))|(((19|2[0-9])[0-9]{2})-(0[469]|11)-(0[1-9]|[12][0-9]|30))(Z|[+-][0-9]{2}:[0-9]{2})(Z|[+-][0-9]{2}:[0-9]{2})"/>
  </xs:restriction>
</xs:simpleType>
```

In JSON Schema, this is represented as:

```JSON
{
  "type": "string",
  "pattern": "((2000|2400|2800|(19|2[0-9](0[48]|[2468][048]|[13579][26])))-02-29)|(((19|2[0-9])[0-9]{2})-02-(0[1-9]|1[0-9]|2[0-8]))|(((19|2[0-9])[0-9]{2})-(0[13578]|10|12)-(0[1-9]|[12][0-9]|3[01]))|(((19|2[0-9])[0-9]{2})-(0[469]|11)-(0[1-9]|[12][0-9]|30))(Z|[+-][0-9]{2}:[0-9]{2})(Z|[+-][0-9]{2}:[0-9]{2})"
}
```

#### dateTime

In XML, the [dateTime](https://www.w3.org/TR/xmlschema11-2/#dateTime) datatype is used. This is the same as
[dateTime-with-timezone](#datetime-with-timezone), except the time zone portion is optional.

In JSON, lexical conformance to date-times with optional time zones is provided by a regular expression, the same as given above for [dateTime-with-timezone](#datetime-with-timezone), except as adjusted for the requirement.

#### dateTime-with-timezone

A string containing a date and time formatted according to "date-time" as defined [RFC3339](https://tools.ietf.org/html/rfc3339#section-5.6). This type requires that the time-offset (timezone) is always provided. This use of timezone ensure that date/time information that is exchanged across timezones is unambiguous.

For example:

```
2019-09-28T23:20:50.52Z
2019-12-02T16:39:57-08:00
2019-12-31T23:59:60Z
```

In XML Schema this is represented as a restriction on the built in type [dateTime](https://www.w3.org/TR/xmlschema11-2/#dateTime) as follows:

```XML
<xs:simpleType name="dateTime-with-timezone">
  <xs:annotation>
    <xs:documentation>The xs:dateTime with a required timezone.</xs:documentation>
  </xs:annotation>
  <xs:restriction base="xs:dateTime">
    <xs:pattern value="((2000|2400|2800|(19|2[0-9](0[48]|[2468][048]|[13579][26])))-02-29)|(((19|2[0-9])[0-9]{2})-02-(0[1-9]|1[0-9]|2[0-8]))|(((19|2[0-9])[0-9]{2})-(0[13578]|10|12)-(0[1-9]|[12][0-9]|3[01]))|(((19|2[0-9])[0-9]{2})-(0[469]|11)-(0[1-9]|[12][0-9]|30))T(2[0-3]|[01][0-9]):([0-5][0-9]):([0-5][0-9])(\.[0-9]+)?(Z|[+-][0-9]{2}:[0-9]{2})"/>
  </xs:restriction>
</xs:simpleType>
```

In JSON Schema, this is represented as:

```JSON
{
  "type": "string",
  "format": "date-time",
  "pattern": "((2000|2400|2800|(19|2[0-9](0[48]|[2468][048]|[13579][26])))-02-29)|(((19|2[0-9])[0-9]{2})-02-(0[1-9]|1[0-9]|2[0-8]))|(((19|2[0-9])[0-9]{2})-(0[13578]|10|12)-(0[1-9]|[12][0-9]|3[01]))|(((19|2[0-9])[0-9]{2})-(0[469]|11)-(0[1-9]|[12][0-9]|30))T(2[0-3]|[01][0-9]):([0-5][0-9]):([0-5][0-9])(\\.[0-9]+)?(Z|[+-][0-9]{2}:[0-9]{2})"
}
```

#### email

An email address string formatted acording to [RFC 6531](https://tools.ietf.org/html/rfc6531).

In XML Schema this is represented as the built in type [string](https://www.w3.org/TR/xmlschema11-2/#string) until a suitable pattern can be developed.

In JSON Schema, this is represented as:

```JSON
{
  "type": "string",
  "format": "idn-email",
  "pattern": ".+@.+"
}
```

Once a suitable pattern for XML is developed, this pattern will be ported to JSON for more consistent validation.

#### hostname

An internationalized Internet host name string formatted acording to [section 2.3.2.3](https://tools.ietf.org/html/rfc5890#section-2.3.2.3) of RFC 5890.

In XML Schema this is represented as the built in type [string](https://www.w3.org/TR/xmlschema11-2/#string) until a suitable pattern can be developed.

In JSON Schema, this is represented as:

```JSON
{
  "type": "string",
  "format": "idn-hostname"
}
```

Once a suitable pattern for XML is developed, this pattern will be ported to JSON for more consistent validation.

#### ip-v4-address

An Internet Protocol version 4 address in dotted-quad ABNF syntax as defined in [section 3.2](https://tools.ietf.org/html/rfc2673#section-3.2) of RFC 2673.

In XML Schema this is represented as a restriction on the built in type [string](https://www.w3.org/TR/xmlschema11-2/#string) as follows:

```XML
<xs:simpleType name="ip-v4-address">
  <xs:annotation>
    <xs:documentation>The ip-v4-address type specifies an IPv4 address in dot decimal notation.</xs:documentation>
  </xs:annotation>
  <xs:restriction base="xs:string">
    <xs:whiteSpace value="collapse"/>
    <xs:pattern value="((25[0-5]|2[0-4][0-9]|1[0-9][0-9]|[1-9][0-9]|[0-9]).){3}(25[0-5]|2[0-4][0-9]|1[0-9][0-9]|[1-9][0-9]|[0-9])"/>
  </xs:restriction>
</xs:simpleType>
```

In JSON Schema, this is represented as:

```JSON
{
  "type": "string",
  "format": "ipv4",
  "pattern": "((25[0-5]|2[0-4][0-9]|1[0-9][0-9]|[1-9][0-9]|[0-9]).){3}(25[0-5]|2[0-4][0-9]|1[0-9][0-9]|[1-9][0-9]|[0-9])"
}
```

#### ip-v6-address

An Internet Protocol version 6 address in dotted-quad ABNF syntax as defined in [section 2.2](https://tools.ietf.org/html/rfc3513#section-2.2) of RFC 3513.

In XML Schema this is represented as a restriction on the built in type [string](https://www.w3.org/TR/xmlschema11-2/#string) as follows:

```XML
<xs:simpleType name="ip-v6-address">
  <xs:annotation>
    <xs:documentation>The ip-v4-address type specifies an IPv4 address in dot decimal notation.</xs:documentation>
  </xs:annotation>
  <xs:restriction base="xs:string">
    <xs:whiteSpace value="collapse"/>
    <xs:pattern value="(([0-9a-fA-F]{1,4}:){7,7}[0-9a-fA-F]{1,4}|([0-9a-fA-F]{1,4}:){1,7}:|([0-9a-fA-F]{1,4}:){1,6}:[0-9a-fA-F]{1,4}|([0-9a-fA-F]{1,4}:){1,5}(:[0-9a-fA-F]{1,4}){1,2}|([0-9a-fA-F]{1,4}:){1,4}(:[0-9a-fA-F]{1,4}){1,3}|([0-9a-fA-F]{1,4}:){1,3}(:[0-9a-fA-F]{1,4}){1,4}|([0-9a-fA-F]{1,4}:){1,2}(:[0-9a-fA-F]{1,4}){1,5}|[0-9a-fA-F]{1,4}:((:[0-9a-fA-F]{1,4}){1,6})|:((:[0-9a-fA-F]{1,4}){1,7}|:)|[fF][eE]80:(:[0-9a-fA-F]{0,4}){0,4}%[0-9a-zA-Z]{1,}|::([fF]{4}(:0{1,4}){0,1}:){0,1}((25[0-5]|2[0-4][0-9]|1[0-9][0-9]|[1-9][0-9]|[0-9]).){3,3}(25[0-5]|2[0-4][0-9]|1[0-9][0-9]|[1-9][0-9]|[0-9])|([0-9a-fA-F]{1,4}:){1,4}:((25[0-5]|2[0-4][0-9]|1[0-9][0-9]|[1-9][0-9]|[0-9]).){3,3}(25[0-5]|2[0-4][0-9]|1[0-9][0-9]|[1-9][0-9]|[0-9]))"/>
  </xs:restriction>
</xs:simpleType>
```

In JSON Schema, this is represented as:

```JSON
{
  "type": "string",
  "format": "ipv6",
  "pattern": "(([0-9a-fA-F]{1,4}:){7,7}[0-9a-fA-F]{1,4}|([0-9a-fA-F]{1,4}:){1,7}:|([0-9a-fA-F]{1,4}:){1,6}:[0-9a-fA-F]{1,4}|([0-9a-fA-F]{1,4}:){1,5}(:[0-9a-fA-F]{1,4}){1,2}|([0-9a-fA-F]{1,4}:){1,4}(:[0-9a-fA-F]{1,4}){1,3}|([0-9a-fA-F]{1,4}:){1,3}(:[0-9a-fA-F]{1,4}){1,4}|([0-9a-fA-F]{1,4}:){1,2}(:[0-9a-fA-F]{1,4}){1,5}|[0-9a-fA-F]{1,4}:((:[0-9a-fA-F]{1,4}){1,6})|:((:[0-9a-fA-F]{1,4}){1,7}|:)|[fF][eE]80:(:[0-9a-fA-F]{0,4}){0,4}%[0-9a-zA-Z]{1,}|::([fF]{4}(:0{1,4}){0,1}:){0,1}((25[0-5]|2[0-4][0-9]|1[0-9][0-9]|[1-9][0-9]|[0-9]).){3,3}(25[0-5]|2[0-4][0-9]|1[0-9][0-9]|[1-9][0-9]|[0-9])|([0-9a-fA-F]{1,4}:){1,4}:((25[0-5]|2[0-4][0-9]|1[0-9][0-9]|[1-9][0-9]|[0-9]).){3,3}(25[0-5]|2[0-4][0-9]|1[0-9][0-9]|[1-9][0-9]|[0-9]))"
}
```

#### uri

A universal resource identifier (URI) formatted according to [RFC3986](https://tools.ietf.org/html/rfc3986).

In XML Schema this is represented as the built in type [anyURI](https://www.w3.org/TR/xmlschema11-2/#anyURI) until a suitable pattern can be developed.

In JSON Schema, this is represented as:

```JSON
{
  "type": "string",
  "format": "uri"
}
```

Once a suitable pattern for XML is developed, this pattern will be ported to JSON for more consistent validation.

#### uri-reference

A URI Reference (either a URI or a relative-reference) formatted according to [section 4.1](https://tools.ietf.org/html/rfc3986#section-4.1) of RFC3986,

In XML Schema this is represented as the built in type [anyURI](https://www.w3.org/TR/xmlschema11-2/#anyURI) until a suitable pattern can be developed.

In JSON Schema, this is represented as:

```JSON
{
  "type": "string",
  "format": "uri-reference"
}
```

Once a suitable pattern for XML is developed, this pattern will be ported to JSON for more consistent validation.

#### base64Binary

A string representing arbitrary Base64-encoded binary data.

In XML Schema this is represented as the built in type [base64Binary](https://www.w3.org/TR/xmlschema11-2/#base64Binary) until a suitable pattern can be developed.

In JSON Schema, this is represented as:

```JSON
{
  "type": "string",
  "contentEncoding": "base64"
}
```

Once a suitable pattern for XML is developed, this pattern will be ported to JSON for more consistent validation.

### Markup Data Types

Structured prose text in OSCAL is designed to map cleanly to equivalent subsets of HTML and Markdown. This allows HTML-like markup to be incorporated in OSCAL XML-based content using an element set maintained in the OSCAL namespace. This HTML-equivalent element set is not intended to be treated directly as HTML, but to be readily and transparently converted to HTML (or other presentational formats) as needed. Similarly, OSCAL uses a subset of Markdown for use in OSCAL JSON- and YAML-based content. A mapping is supported between the HTML-like element set and the Markdown syntax, which supports transparent and lossless bidirectional mapping between both OSCAL markup representations.

The OSCAL HTML-like syntax supports:

- HTML paragraphs (`p`), headers (`h1`-`h6`), tables (`table`), preformatted text (`pre`), code blocks (`code`), and ordered and unordered lists (`ol` and `ul`.)

- Within paragraphs or text content: `a`, `img`, `strong`, `em`, `b`, `i`, `sup`, `sub`.


In remarks below and throughout this documentation, this element set may be referred to as "prose content" or "prose". A future OSCAL could support the definition of this tag set (and Markdown equivalent) as a module, enabling our HTML subset to be switched out for something else. (Its prose model would be different from OSCAL prose as currently defined.)

Note that elements such as `div`, `blockquote`, `section` or `aside`, used in HTML to provide structure, are *not permitted in OSCAL*. Structures in OSCAL should be represented using OSCAL elements (or objects in JSON) such as `part`, which can include prose.

In addition, there are contexts in OSCAL where prose usage may be further constrained. For example, at a higher level (outside the base schema) an OSCAL application could forbid the use of prose headers `h1-h6` in favor of nested OSCAL `part` elements with their own titles.

The OSCAL Markdown syntax is loosely based on CommonMark. When in doubt about Markdown features and syntax, we look to CommonMark for guidance, largely because it is more rigorously tested than many others forms of Markdown.

#### markup-line

The following table describes the equavalent constructs in HTML and Markdown used in OSCAL within the `markup-line` data type.

| Markup Type | HTML | Markdown |
|:--- |:--- |:--- |
| Emphasis (preferred) | &lt;em&gt;*text*&lt;/em&gt; | \**text*\*
| Emphasis | &lt;i&gt;*text*&lt;/i&gt; | \**text*\*
| Important Text (preferred) | &lt;strong&gt;*text*&lt;/strong&gt; | \*\**text*\*\*
| Important Text | &lt;b&gt;*text*&lt;/b&gt; | \*\**text*\*\*
| Inline code | &lt;code&gt;*text*&lt;/code&gt; | \`*text*\`
| Quoted Text | &lt;q&gt;*text*&lt;/q&gt; | "*text*"
| Subscript Text | &lt;sub&gt;*text*&lt;/sub&gt; | \~*text*\~
| Superscript Text | &lt;sup&gt;*text*&lt;/sup&gt; | \^*text*\^
| Image | &lt;img alt="*alt text*" src="*url*" title="*title text*"/&gt; | !\[*alt text*](*url* "*title text*")
| Link | &lt;a *href*="*url*"&gt;*text*&lt;/a&gt; | \[*text*](*url*)

Note: Markdown does not have an equivalent of the HTML &lt;i&gt; and &lt;b&gt; tags, which indicate italics and bold respectively. These concepts are mapped in OSCAL markup text to &lt;em&gt; and &lt;strong&gt; [common mark](https://spec.commonmark.org/0.29/#emphasis-and-strong-emphasis), which render equivalently in browsers, but do not have exactly the same semantics. While this mapping is imperfect, it represents the common uses of these HTML tags.

##### Parameter Insertion

The OSCAL catalog, profile, and implementation layer models allow for control parameters to be defined and injected into prose text.

Parameter injection is handled in OSCAL as follows using the &lt;insert&gt; tag:

```html
Reviews and updates the risk management strategy <insert param-id="pm-9_prm_1"/> or as required, to address organizational changes.
```

The same string in Markdown is represented as follows:

```markdown
Reviews and updates the risk management strategy {{ pm-9_prm_1 }} or as required, to address organizational changes.
```

##### Specialized Character Mapping

The following characters have special handling in their HTML and/or Markdown forms.

| Character                                      | XML HTML                             | (plain) Markdown | Markdown in JSON | Markdown in YAML |
| ---                                            | ---                                  | ---              | ---              | ---              |
| &amp; (ampersand)                              | &amp;amp;                            | &amp;            | &amp;            | &amp;            |
| &lt; (less-than sign or left angle bracket)    | &amp;lt;                             | &lt;             | &lt;             | &lt;             |
| &gt; (greater-than sign or right angle bracket | &gt; **or** &amp;gt;                 | &gt;             | &gt;             | &gt;             |
| &#34; (straight double quotation mark)         | &#34; **or** &amp;quot;              | \\&#34;          |  \\\\&#34;       | \\\\&#34;        |
| &#39; (straight apostrophe)                    | &#39; **or** &amp;apos;              | \\&#39;          | \\\\&#39;        | \\\\&#39;        |
| \* (asterisk)                                  | \*                                   | \\\*             | \\\\\*           | \\\\\*           |
| &#96; (grave accent or back tick mark)         | &#96;                                | \\&#96;          | \\\\&#96;        | \\\\&#96;        |
| ~ (tilde)                                      | ~                                    | \\~              | \\\\~            | \\\\~            |
| ^ (caret)                                      | ^                                    | \\^              | \\\\^            | \\\\^            |

While the characters ``*`~^`` are valid for use unescaped in JSON strings and YAML double quoted strings, these characters have special meaning in Markdown markup. As a result, when these characters appear as literals in a Markdown representation, they must be escaped to avoid them being parsed as Markdown to indicate formatting. The escaped representation indicates these characters are to be represented as characters, not markup, when the Markdown is mapped to HTML.

Because the character "\\" (back slash or reverse solidus) must be escaped in JSON, note that those characters that require a back slash to escape them in Markdown, such as "\*" (appearing as "\\\*"), must be *double escaped* (as "\\\\\*") to represent the escaped character in JSON or YAML. In conversion, the JSON or YAML processor reduces these to the simple escaped form, again permitting the Markdown processor to recognize them as character contents, not markup.

Since these characters are not markup delimiters in XML, they are safe to use there without special handling. The XML open markup delimiters "&lt;" and "&amp;", when appearing in XML contents, must as always be escaped as named entities or numeric character references, if they are to be read as literal characters not markup.

#### markup-multiline

All constructs supported by the [markup-line](#markup-line) data type are also supported by the `markup-multiline` data type, when appearing within a header (`h1`-`h6`), paragraph (`p`), list item (`li`) or table cell (`th` or `td`).

The following additional constructs are also supported. Note that the syntax for these elements must appear on their own lines (i.e., with additional line feeds as delimiters), as is usual in Markdown.

| Markup Type | HTML | Markdown |
|:--- |:--- |:--- |
| Heading: Level 1 | &lt;h1&gt;*text*&lt;/h1&gt; | # *text*
| Heading: Level 2 | &lt;h2&gt;*text*&lt;/h2&gt; | ## *text*
| Heading: Level 3 | &lt;h3&gt;*text*&lt;/h3&gt; | ### *text*
| Heading: Level 4 | &lt;h4&gt;*text*&lt;/h4&gt; | #### *text*
| Heading: Level 5 | &lt;h5&gt;*text*&lt;/h5&gt; | ##### *text*
| Heading: Level 6 | &lt;h6&gt;*text*&lt;/h6&gt; | ###### *text*
| Preformatted Text | &lt;pre&gt;*text*&lt;/pre&gt; | \`\`\`*text*\`\`\`
| Ordered List, with a single item | &lt;ol&gt;&lt;li&gt;*text*&lt;/li&gt;&lt;/ol&gt; | 1. *text*
| Unordered List with single item | &lt;ul&gt;&lt;li&gt;*text*&lt;/li&gt;&lt;/ul&gt; | - *text*

##### Paragraphs

Additionally, the use of &lt;p&gt; tags in HTML is mapped to Markdown as two double, escaped newlines within a JSON or YAML string (i.e., "\\\\n\\\\n"). This allows Mardown text to be split into paragraphs when this data type is used.

##### Tables

Tables are also supported by `markup-multiline` which are mapped from Markdown to HTML as follows:

- The first row in a Markdown table is considered a header row, with each cell mapped as a &lt;th&gt;.
- The alignment formatting (second) row of the Markdown table is not converted to HTML. Formatting is currently ignored.
- Each remaining row is mapped as a cell using the &lt;td&gt; tag.
- HTML `colspan` and `rowspan` are not supported by Markdown, and so are excluded from OSCAL.

OSCAL attempts to support simple tables mainly due to the prevalence of tables in legacy data sets. However, producers of OSCAL data should note that when they have tabular information, these are frequently semantic structures or matrices that can be described directly in OSCAL as named parts and properties or as parts, sub-parts and paragraphs. This ensures that their nominal or represented semantics are accessible for processing when this information would be lost in plain table cells. Table markup should be used only as a fallback option when stronger semantic labeling is not possible.

Tables are mapped from HTML to Markdown as follows:

* Only a single header row &lt;tr&gt;&lt;th&gt; is supported. This row is mapped to the Markdown table header, with header cells preceded, delimited, and terminated by `|`.
* The second row is given as a sequence of `---`, as many as the table has columns, delimited by single `|`. In Markdown, a simple syntax here can be used to indicate the alignment of cells; OSCAL HTML does not support this feature.
* Each subsequent row is mapped to the Markdown table rows, with cells preceded, delimited, and terminated by `|`.

For example:

The following HTML table:

```html
<table>
  <tr><th>Col A</th><th>Col B</th></tr>
  <tr><td>Have some of</td><td>Try all of</td></tr>
</table>
```

Is mapped to the Markdown table:

```markdown
| Col A | Col B |
| --- | --- |
| Have some of | Try all of |
```


##### Line feeds in Markdown

Additionally, line feed (LF) characters must be escaped as "\\n" when appearing in string contents in JSON and (depending on placement) in YAML. In Markdown, the line feed is used to delimit paragraphs and other block elements, represented using markup (tagging) in the XML version. When transcribed into JSON, these LF characters must also appear as "\\n".


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
## Metaschema modeling

In the case of field and flag objects, the modeling constraints to be imposed by the result schemas (either XSD or JSON Schema) over the data set, can be determined on the basis of how they are described. Assembly definitions, however, permit not only flags to be assigned to assemblies of the defined type; additionally, they contain a `model` element for a *mode declaration*. This declaration names the subcomponents to be permitted (in documents valid to the target schemas) within any assembly of the type being defined.

Five elements are used within `model` to define permissible contents of assemblies (elements or objects) being defined. Each of these represents a different object type. Flags are not assigned via `model` but directly in the definition; for the model, we can choose either singles or plurals of named fields or assemblies (i.e., a binary choice between cardinality constraints to be applied). This gives us four choices; additionally, we have the opportunity to use an element `prose`, once inside any assembly's model.

Among these elements, no single `@named` attribute value (which refers a model component to its definition) may be used more than once. Additionally, no `@group-as` (on a `fields` or `assemblies`) may be reused or be the same as any `@named`. The `prose` element may be used only once. Finally, no value of `@named` or `@group-as` must be the same as a recognized name of an element directly within prose, namely (at present) `p`, `ul`, `ol`, and `pre`.

With these limitations, a model may be defined to contain any mix of fields and assemblies.

* `field` refers to a field definition and permits a single occurrence of the indicated field
* `field/@required='yes'` a field component is to be required in a model by any schema based on the metaschema
* `assembly` refers to an assembly definition and permits a single occurrence of the indicated assembly.
* `fields` - same as `field`, but permits the field to be repeated. In the JSON representation the multiple values are represented as any array unless `@address` is given
* `assemblies` - same as `fields`, but for assemblies. In JSON, this construct is also presented as an array unless there is an `@address`
* `prose` refers to a "region of prose", that is, a section of prose text of unspecified length. In XML, prose is represented in conventional fashion as (a sequence of) `<p>` and list elements (`<ul>` or `<ol>`) perhaps with inline markup (indicating further formatting). For consistency across metaschema applications, the permitted tagging will always be conformant to the same model for prose, managed to reflect (echo) a clean HTML subset. This specification also permits the markup vocabulary to be mapped to a text-based markdown syntax, suitable for use within JSON expressions of the same or similar data. 


## JSON Enhancement features

### Use of `key`

One problem with zero-or-more cardinality as supported by `fields` and `assemblies` is that in JSON, no suitable structure is available for the inclusion of truly arbitrary but repeatable properties or 'contents' (as to its structural type) on an object. The closest thing is an array, which can be pulled into use for this -- at the cost of not permitting a JSON property label on items in the array. In order to capture the same information as is transparently available on the XML, it is therefore necessary to 'finesse' the JSON object type: Metaschema does this by mapping each field or assembly in a zero-or-many set, to an array with the corresponding number of items. The name of the objects can thus be captured implicitly, by naming (labeling) their containing array.

This works, but there are also occasions when a much more concise mapping may also be supported -- if the data can be ensured to follow another rule, namely that data elements (string data) can be known to be uniquely-valued. In these cases there is a different option, namely to promote a flag of a particular known (and controlled) type, to a role as "address" -- which can (incidentally) serve as a label on a JSON property, thus improving both presentation, and addressability.

Accordingly, `@address` on `field` or `assemblies` indicates that their contents (components, that is each field or assembly in the series) may be addressed using the flag (attribute) of the given name. So if `address='id'`, for example, and an `id` flag is included on the field or assemply, such flag is assumed to be unique and validable as such (at least within the scope of its parent or containing structure), thus making it suitable for use as a label; consequently, in JSON, the field or assembly can be represented as a labeled property (of an object) rather than an unlabeled member of an array (of similar objects). This both reduces the data footprint and renders the data more addressable via key constructs such as identifiers.

To support this, flags used as addresses should be declared as type `ID`, providing "an extra layer of protection". On the JSON side, validating the uniqueness of these values (on same-named properties across document scope) remains TBD.



```
<define-field name="title" as="mixed"/>
```

```
<title>Water (H<sub>2</sub>0</title>
```
 
```
"title" : "Water (H~~2~~0)"
```

