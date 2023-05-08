---
title: "Metaschema Data Types"

description: "A description of the built in data types supported by Metaschema."
heading: Data Types Used in Metaschema
weight: 60
suppressintopiclist: true
sidenav:
  title: Data Types
toc:
  enabled: true
---

Metaschema is a strongly typed modeling language, that uses a collection of built in data types to represent data elements within a Metaschema-based model.

Metaschema's data types represent a data-oriented, leaf nodes in a Metaschema-based model. These data types provide the basis for data elements that have clearly defined syntax and semantics.


There are 2 kinds of data types.

- **[simple data types:](#simple-data-types)** that represent basic data value primitives with a specific syntax and semantics.
- **[markup data types:](#markup-data-types)** that represent semantically formatted text that is intended for presentation.

A data type can be referenced in a metaschema definition within a `define-field`, `field`, `define-flag`, or `flag` component definition using the `@as-type` attribute. The following are the allowed data types.

## Data Type Schema Representations

JSON and XML Schema instances are provided for the built in data types.

### JSON Schema

A single JSON schema is [provided](https://github.com/usnistgov/metaschema/blob/develop/schema/json/metaschema-datatypes.json) for all built in data types supporting JSON and YAML validation. This schema is based on JSON Schema draft-07 ([JSON Schema](https://datatracker.ietf.org/doc/html/draft-handrews-json-schema-01) and [JSON Schema Validation 01](https://datatracker.ietf.org/doc/html/draft-handrews-json-schema-validation-01)).

The data type JSON schema uses regular expression patterns to enforce the syntax of specific data types. The regular expressions supported in JSON schema using the [`pattern`](https://datatracker.ietf.org/doc/html/draft-handrews-json-schema-validation-01#section-6.3.3) keyword are based on the [ECMA 262 regular expression dialect](https://262.ecma-international.org/#sec-regexp-regular-expression-objects).

### XML Schemas

Multiple XML Schemas are provided that support different groups of data types.

The [Simple data types](#simple-data-types) are defined in [a single XML Schema](https://github.com/usnistgov/metaschema/blob/develop/schema/xml/metaschema-datatypes.xsd).

The [markup data types](#markup-data-types) are supported by multiple schemas.

The [`markup-line`](#markup-line) data type is implemented in XML Schema within the [metaschema-markup-line.xsd](https://github.com/usnistgov/metaschema/blob/develop/schema/xml/metaschema-markup-line.xsd) schema.

The [`markup-multiline`](#markup-multiline) data type is implemented in XML Schema within the [metaschema-markup-multiline.xsd](https://github.com/usnistgov/metaschema/blob/develop/schema/xml/metaschema-markup-multiline.xsd) schema.

Both of these schemas use a set of shared XML Schema types from the [metaschema-prose-base.xsd](https://github.com/usnistgov/metaschema/blob/develop/schema/xml/metaschema-prose-base.xsd).

The [metaschema-prose-module.xsd](https://github.com/usnistgov/metaschema/blob/develop/schema/xml/metaschema-prose-module.xsd) XML schema is provided as a convenience to support use of both the `markup-line` and `markup-multiline` data types.

XML Schema uses its [own dialect](https://www.w3.org/TR/xmlschema-2/#regexs) of regular expressions.

### Regular Expressions in Schemas

Regular expressions used in JSON and XML Schemas use a reduced subset of regular expression syntax that is intended to be well supported by most regular expression dialects.

Regular expression features used include:

- Single line matching
- Unicode characters
- Grouping
- Character classes, including use of Unicode property value expressions (e.g., `\p{L}`, `\p{N}`)
- Class ranges
- Class negation
- Quantifiers

These features tend to be widely supported by implementations based on the [Perl Compatible Regular Expression (PCRE)](https://www.pcre.org/), [ECMA](https://262.ecma-international.org/#sec-regexp-regular-expression-objects), [Java](https://cr.openjdk.org/~iris/se/19/latestSpec/api/java.base/java/util/regex/Pattern.html), and [XML Schema 1.0](https://www.w3.org/TR/xmlschema-2/#regexs) regex dialects. As a result, implementations based on any of these standards should be able to support the patterns used in the Metaschema JSON and XML data type schemas.

## Simple Data Types

These data types represent the basic data primitives used in Metaschema to support different types of data values.

- **numeric values:** [decimal](#decimal), [integer](#integer), [non-negative-integer](#non-negative-integer), [positive-integer](#positive-integer)
- **temporal values:** [date](#date), [date-with-timezone](#date-with-timezone), [date-time](#date-time), [date-time-with-timezone](#date-time-with-timezone), [day-time-duration](#day-time-duration), [year-month-duration](#year-month-duration)
- **binary values:** [base64](#base64), [boolean](#boolean)
- **character-based values:** [email-address](#email-address), [hostname](#hostname), [ip-v4-address](#ip-v4-address), [ip-v6-address](#ip-v6-address), [string](#string), [token](#token), [uri](#uri), [uri-reference](#uri-reference), [uuid](#uuid)

Details of these data types follow.

### base64

A string representing arbitrary binary data encoded using the [Base 64 algorithm](https://www.rfc-editor.org/rfc/rfc4648#section-4) as defined by [RFC4648](https://www.rfc-editor.org/rfc/rfc4648).

In XML Schema this is represented as a restriction of the built-in type [base64Binary](https://www.w3.org/TR/xmlschema11-2/#base64Binary) that doesn't allow leading and trailing whitespace.

This data type is defined in XML as follows:

```XML
<xs:simpleType name="Base64Datatype">
  <xs:restriction base="xs:base64Binary">
    <xs:pattern value="[0-9A-Za-z+/]+={0,2}">
      <xs:annotation>
        <xs:documentation>A trimmed string, at least one character with no
          leading or trailing whitespace.</xs:documentation>
      </xs:annotation>
    </xs:pattern>
  </xs:restriction>
</xs:simpleType>
```

In JSON Schema, this is represented as:

```JSON
{
  "type": "string",
  "pattern": "^[0-9A-Za-z+/]+={0,2}$",
  "contentEncoding": "base64"
}
```

### boolean

A boolean value mapped in XML, JSON, and YAML as follows:

| Value | XML | JSON | YAML |
|:--- |:--- |:--- |:--- |
| true | `true` or `1` | `true` | `true` |
| false | `false` or `0` | `false` | `false` |

In XML Schema this is represented as a restriction on the built-in type [boolean](https://www.w3.org/TR/xmlschema11-2/#boolean) as follows:

```XML
<xs:simpleType name="BooleanDatatype">
  <xs:restriction base="xs:boolean">
    <xs:pattern value="true|false|0|1"/>
  </xs:restriction>
</xs:simpleType>
```

The pattern `true|false|0|1` above ensures that leading and trailing whitespace is not allowed in XML-based Metaschema instances using this data type.

In JSON Schema, this is represented as:

```JSON
{
  "type": "boolean"
}
```

### date

A string representing a 24-hour period, optionally qualified by a timezone. A `date-with-timezone` is formatted according to "full-date" as defined [RFC3339](https://tools.ietf.org/html/rfc3339#section-5.6), with the addition of an optional timezone, specified as a time-offset according to RFC3339.

This is the same as [date-with-timezone](#date-with-timezone), except the timezone portion is optional. This can be used to support formats that have ambiguous timezones for date values.

For example:

```
2019-09-28Z
2019-09-28
2019-12-02-08:00
2019-12-02
```

In XML Schema this is represented as a restriction on the built-in type [date](https://www.w3.org/TR/xmlschema11-2/#date) as follows:

```XML
<xs:simpleType name="DateDatatype">
  <xs:restriction base="xs:date">
    <xs:pattern value="(((2000|2400|2800|(19|2[0-9](0[48]|[2468][048]|[13579][26])))-02-29)|(((19|2[0-9])[0-9]{2})-02-(0[1-9]|1[0-9]|2[0-8]))|(((19|2[0-9])[0-9]{2})-(0[13578]|10|12)-(0[1-9]|[12][0-9]|3[01]))|(((19|2[0-9])[0-9]{2})-(0[469]|11)-(0[1-9]|[12][0-9]|30)))(Z|[+-][0-9]{2}:[0-9]{2})?" />
  </xs:restriction>
</xs:simpleType>
```

In JSON Schema, this is represented as:

```JSON
{
  "type": "string",
  "pattern": "^(((2000|2400|2800|(19|2[0-9](0[48]|[2468][048]|[13579][26])))-02-29)|(((19|2[0-9])[0-9]{2})-02-(0[1-9]|1[0-9]|2[0-8]))|(((19|2[0-9])[0-9]{2})-(0[13578]|10|12)-(0[1-9]|[12][0-9]|3[01]))|(((19|2[0-9])[0-9]{2})-(0[469]|11)-(0[1-9]|[12][0-9]|30)))(Z|[+-][0-9]{2}:[0-9]{2})?$"
}
```

### date-with-timezone

A string representing a 24-hour period in a given timezone. A `date-with-timezone` is formatted according to "full-date" as defined [RFC3339](https://tools.ietf.org/html/rfc3339#section-5.6), with the addition of a timezone, specified as a time-offset according to RFC3339.

This type requires that the time-offset (timezone) is always provided. This use of timezone ensure that date information exchanged across timezones is unambiguous.

For example:

```
2019-09-28Z
2019-12-02-08:00
```

In XML Schema this is represented as a restriction on the built-in type [date](https://www.w3.org/TR/xmlschema11-2/#date) as follows:

```XML
<xs:simpleType name="DateWithTimezoneDatatype">
  <xs:restriction base="DateDatatype">
    <xs:pattern value="(((2000|2400|2800|(19|2[0-9](0[48]|[2468][048]|[13579][26])))-02-29)|(((19|2[0-9])[0-9]{2})-02-(0[1-9]|1[0-9]|2[0-8]))|(((19|2[0-9])[0-9]{2})-(0[13578]|10|12)-(0[1-9]|[12][0-9]|3[01]))|(((19|2[0-9])[0-9]{2})-(0[469]|11)-(0[1-9]|[12][0-9]|30)))(Z|[+-][0-9]{2}:[0-9]{2})" />
  </xs:restriction>
</xs:simpleType>
```

In JSON Schema, this is represented as:

```JSON
{
  "type": "string",
  "pattern": "^(((2000|2400|2800|(19|2[0-9](0[48]|[2468][048]|[13579][26])))-02-29)|(((19|2[0-9])[0-9]{2})-02-(0[1-9]|1[0-9]|2[0-8]))|(((19|2[0-9])[0-9]{2})-(0[13578]|10|12)-(0[1-9]|[12][0-9]|3[01]))|(((19|2[0-9])[0-9]{2})-(0[469]|11)-(0[1-9]|[12][0-9]|30)))(Z|[+-][0-9]{2}:[0-9]{2})$"
}
```

### date-time

A string representing a point in time, optionally qualified by a timezone. This date and time value is formatted according to "date-time" as defined [RFC3339](https://tools.ietf.org/html/rfc3339#section-5.6), except the timezone (time-offset) is optional.

This is the same as [date-time-with-timezone](#date-time-with-timezone), except the timezone portion is optional. This can be used to support formats that have ambiguous timezones for date/time values.


For example:

```
2019-09-28T23:20:50.52Z
2019-09-28T23:20:50.52
2019-12-02T16:39:57-08:00
2019-12-02T16:39:57
2019-12-31T23:59:60Z
2019-12-31T23:59:60
```

In XML Schema this is represented as a restriction on the built-in type [dateTime](https://www.w3.org/TR/xmlschema11-2/#dateTime) as follows:

```XML
<xs:simpleType name="DateTimeDatatype">
  <xs:restriction base="xs:dateTime">
    <xs:pattern value="(((2000|2400|2800|(19|2[0-9](0[48]|[2468][048]|[13579][26])))-02-29)|(((19|2[0-9])[0-9]{2})-02-(0[1-9]|1[0-9]|2[0-8]))|(((19|2[0-9])[0-9]{2})-(0[13578]|10|12)-(0[1-9]|[12][0-9]|3[01]))|(((19|2[0-9])[0-9]{2})-(0[469]|11)-(0[1-9]|[12][0-9]|30)))T(2[0-3]|[01][0-9]):([0-5][0-9]):([0-5][0-9])(\.[0-9]*[1-9])?(Z|(-((0[0-9]|1[0-2]):00|0[39]:30)|\+((0[0-9]|1[0-4]):00|(0[34569]|10):30|(0[58]|12):45)))?" />
  </xs:restriction>
</xs:simpleType>
```

In JSON Schema, this is represented as:

```JSON
{
  "type": "string",
  "pattern": "^(((2000|2400|2800|(19|2[0-9](0[48]|[2468][048]|[13579][26])))-02-29)|(((19|2[0-9])[0-9]{2})-02-(0[1-9]|1[0-9]|2[0-8]))|(((19|2[0-9])[0-9]{2})-(0[13578]|10|12)-(0[1-9]|[12][0-9]|3[01]))|(((19|2[0-9])[0-9]{2})-(0[469]|11)-(0[1-9]|[12][0-9]|30)))T(2[0-3]|[01][0-9]):([0-5][0-9]):([0-5][0-9])(\\.[0-9]*[1-9])?(Z|(-((0[0-9]|1[0-2]):00|0[39]:30)|\\+((0[0-9]|1[0-4]):00|(0[34569]|10):30|(0[58]|12):45)))?$"
}
```

### date-time-with-timezone

A string representing a point in time in a given timezone. This date and time value is formatted according to "date-time" as defined [RFC3339](https://tools.ietf.org/html/rfc3339#section-5.6).

This type requires that the time-offset (timezone) is always provided. This use of timezone ensures that date/time information exchanged across timezones is unambiguous.

For example:

```
2019-09-28T23:20:50.52Z
2019-12-02T16:39:57-08:00
2019-12-31T23:59:60Z
```

In XML Schema this is represented as a restriction on the built in type [dateTime](https://www.w3.org/TR/xmlschema11-2/#dateTime) as follows:

```XML
<xs:simpleType name="DateWithTimezoneDatatype">
  <xs:restriction base="DateDatatype">
    <xs:pattern value="(((2000|2400|2800|(19|2[0-9](0[48]|[2468][048]|[13579][26])))-02-29)|(((19|2[0-9])[0-9]{2})-02-(0[1-9]|1[0-9]|2[0-8]))|(((19|2[0-9])[0-9]{2})-(0[13578]|10|12)-(0[1-9]|[12][0-9]|3[01]))|(((19|2[0-9])[0-9]{2})-(0[469]|11)-(0[1-9]|[12][0-9]|30)))T(2[0-3]|[01][0-9]):([0-5][0-9]):([0-5][0-9])(\.[0-9]*[1-9])?(Z|(-((0[0-9]|1[0-2]):00|0[39]:30)|\+((0[0-9]|1[0-4]):00|(0[34569]|10):30|(0[58]|12):45)))" />
  </xs:restriction>
</xs:simpleType>
```

In JSON Schema, this is represented as:

```JSON
{
  "type": "string",
  "format": "date-time",
  "pattern": "^(((2000|2400|2800|(19|2[0-9](0[48]|[2468][048]|[13579][26])))-02-29)|(((19|2[0-9])[0-9]{2})-02-(0[1-9]|1[0-9]|2[0-8]))|(((19|2[0-9])[0-9]{2})-(0[13578]|10|12)-(0[1-9]|[12][0-9]|3[01]))|(((19|2[0-9])[0-9]{2})-(0[469]|11)-(0[1-9]|[12][0-9]|30)))T(2[0-3]|[01][0-9]):([0-5][0-9]):([0-5][0-9])(\\.[0-9]*[1-9])?(Z|(-((0[0-9]|1[0-2]):00|0[39]:30)|\\+((0[0-9]|1[0-4]):00|(0[34569]|10):30|(0[58]|12):45)))$"
}
```

### day-time-duration

An amount of time quantified in days, hours, minutes, and seconds based on [ISO-8601 durations](https://en.wikipedia.org/wiki/ISO_8601#Durations) (see also [RFC3339 appendix A](https://www.rfc-editor.org/rfc/rfc3339.html#appendix-A)).

Examples include:

The duration of 1 day, 12 hours, and 45 minutes can be represented as:

```
P1DT12H45M
```

The using the optional minus sign, the negative duration of 3 hours can be represented as:

```
-PT3H
```

In XML Schema this is defined by [dayTimeDuration](https://www.w3.org/TR/xmlschema11-2/#dayTimeDuration), which is a restriction on the built-in type [duration](https://www.w3.org/TR/xmlschema11-2/#duration) as follows:

```XML
<xs:simpleType name="DayTimeDurationDatatype">
  <xs:restriction base="xs:duration">
    <xs:pattern value="-?P([0-9]+D(T(([0-9]+H([0-9]+M)?(([0-9]+|[0-9]+(\.[0-9]+)?)S)?)|([0-9]+M(([0-9]+|[0-9]+(\.[0-9]+)?)S)?)|([0-9]+|[0-9]+(\.[0-9]+)?)S))?)|T(([0-9]+H([0-9]+M)?(([0-9]+|[0-9]+(\.[0-9]+)?)S)?)|([0-9]+M(([0-9]+|[0-9]+(\.[0-9]+)?)S)?)|([0-9]+|[0-9]+(\.[0-9]+)?)S)"/>
  </xs:restriction>
</xs:simpleType>
```

In JSON Schema, this is represented as:

```JSON
{
  "type": "string",
  "format": "duration",
  "pattern": "^-?P([0-9]+D(T(([0-9]+H([0-9]+M)?(([0-9]+|[0-9]+(\\.[0-9]+)?)S)?)|([0-9]+M(([0-9]+|[0-9]+(\\.[0-9]+)?)S)?)|([0-9]+|[0-9]+(\\.[0-9]+)?)S))?)|T(([0-9]+H([0-9]+M)?(([0-9]+|[0-9]+(\\.[0-9]+)?)S)?)|([0-9]+M(([0-9]+|[0-9]+(\\.[0-9]+)?)S)?)|([0-9]+|[0-9]+(\\.[0-9]+)?)S)$"
}
```

### decimal

A real number expressed using a whole and optional fractional part separated by a period.

In XML Schema this is represented as a restriction on the built-in type [decimal](https://www.w3.org/TR/xmlschema11-2/#decimal) as follows:

```XML
<xs:simpleType name="DecimalDatatype">
  <xs:restriction base="xs:decimal">
    <xs:pattern value="\S(.*\S)?"/>
  </xs:restriction>
</xs:simpleType>
```

In JSON Schema, this is represented as:

```JSON
{
  "type": "number",
  "pattern": "(\\+|-)?([0-9]+(\\.[0-9]*)?|\\.[0-9]+)"
}
```
### email-address

An email address string formatted according to [RFC6531](https://tools.ietf.org/html/rfc6531).

In XML Schema this is represented as a restriction on the built in type [string](https://www.w3.org/TR/xmlschema11-2/#string) as follows:

```XML
<xs:simpleType name="EmailAddressDatatype">
  <xs:restriction base="StringDatatype">
    <xs:pattern value="\S.*@.*\S">
      <xs:annotation>
        <xs:documentation>Need a better pattern.</xs:documentation>
      </xs:annotation>
    </xs:pattern>
  </xs:restriction>
</xs:simpleType>
```

In JSON Schema, this is represented as:

```JSON
{
  "type": "string",
  "format": "email",
  "pattern": "^.+@.+$"
}
```

### hostname

An internationalized Internet host name string formatted according to [section 2.3.2.3](https://tools.ietf.org/html/rfc5890#section-2.3.2.3) of RFC5890.

In XML Schema this is represented as a restriction on the built in type [string](https://www.w3.org/TR/xmlschema11-2/#string) as follows:

```XML
<xs:simpleType name="HostnameDatatype">
  <xs:restriction base="StringDatatype"/>
</xs:simpleType>
```

**Note: A better pattern is needed for normalizing hostname, since the current data type is very open-ended.**

In JSON Schema, this is represented as:

```JSON
{
  "type": "string",
  "pattern": "^\\S(.*\\S)?$",
  "format": "idn-hostname"
}
```

Once a suitable pattern for XML is developed, this pattern will be ported to JSON for more consistent validation.

### integer

A whole number value.

In XML Schema this is represented as a restriction on the built-in type [integer](https://www.w3.org/TR/xmlschema11-2/#integer) as follows:

```XML
<xs:simpleType name="IntegerDatatype">
  <xs:restriction base="xs:integer">
    <xs:pattern value="\S(.*\S)?" />
  </xs:restriction>
</xs:simpleType>
```

In JSON Schema, this is represented as:

```JSON
{
  "type": "integer"
}
```

### ip-v4-address

An Internet Protocol version 4 address represented using dotted-quad syntax as defined in [section 3.2](https://tools.ietf.org/html/rfc2673#section-3.2) of RFC2673.

In XML Schema this is represented as a restriction on the built in type [string](https://www.w3.org/TR/xmlschema11-2/#string) as follows:

```XML
<xs:simpleType name="IPV4AddressDatatype">
  <xs:restriction base="StringDatatype">
    <xs:pattern value="((25[0-5]|2[0-4][0-9]|1[0-9][0-9]|[1-9][0-9]|[0-9]).){3}(25[0-5]|2[0-4][0-9]|1[0-9][0-9]|[1-9][0-9]|[0-9])" />
  </xs:restriction>
</xs:simpleType>
```

In JSON Schema, this is represented as:

```JSON
{
  "type": "string",
  "format": "ipv4",
  "pattern": "^((25[0-5]|2[0-4][0-9]|1[0-9][0-9]|[1-9][0-9]|[0-9]).){3}(25[0-5]|2[0-4][0-9]|1[0-9][0-9]|[1-9][0-9]|[0-9])$"
}
```

### ip-v6-address

An Internet Protocol version 6 address represented using the syntax defined in [section 2.2](https://tools.ietf.org/html/rfc3513#section-2.2) of RFC3513.

In XML Schema this is represented as a restriction on the built in type [string](https://www.w3.org/TR/xmlschema11-2/#string) as follows:

```XML
<xs:simpleType name="IPV6AddressDatatype">
  <xs:restriction base="xs:string">
    <xs:whiteSpace value="collapse"/>
    <xs:pattern value="(([0-9a-fA-F]{1,4}:){7,7}[0-9a-fA-F]{1,4}|([0-9a-fA-F]{1,4}:){1,7}:|([0-9a-fA-F]{1,4}:){1,6}:[0-9a-fA-F]{1,4}|([0-9a-fA-F]{1,4}:){1,5}(:[0-9a-fA-F]{1,4}){1,2}|([0-9a-fA-F]{1,4}:){1,4}(:[0-9a-fA-F]{1,4}){1,3}|([0-9a-fA-F]{1,4}:){1,3}(:[0-9a-fA-F]{1,4}){1,4}|([0-9a-fA-F]{1,4}:){1,2}(:[0-9a-fA-F]{1,4}){1,5}|[0-9a-fA-F]{1,4}:((:[0-9a-fA-F]{1,4}){1,6})|:((:[0-9a-fA-F]{1,4}){1,7}|:)|[fF][eE]80:(:[0-9a-fA-F]{0,4}){0,4}%[0-9a-zA-Z]{1,}|::([fF]{4}(:0{1,4}){0,1}:){0,1}((25[0-5]|2[0-4][0-9]|1[0-9][0-9]|[1-9][0-9]|[0-9]).){3,3}(25[0-5]|2[0-4][0-9]|1[0-9][0-9]|[1-9][0-9]|[0-9])|([0-9a-fA-F]{1,4}:){1,4}:((25[0-5]|2[0-4][0-9]|1[0-9][0-9]|[1-9][0-9]|[0-9]).){3,3}(25[0-5]|2[0-4][0-9]|1[0-9][0-9]|[1-9][0-9]|[0-9]))" />
  </xs:restriction>
</xs:simpleType>
```

In JSON Schema, this is represented as:

```JSON
{
  "type": "string",
  "format": "ipv6",
  "pattern": "^(([0-9a-fA-F]{1,4}:){7,7}[0-9a-fA-F]{1,4}|([0-9a-fA-F]{1,4}:){1,7}:|([0-9a-fA-F]{1,4}:){1,6}:[0-9a-fA-F]{1,4}|([0-9a-fA-F]{1,4}:){1,5}(:[0-9a-fA-F]{1,4}){1,2}|([0-9a-fA-F]{1,4}:){1,4}(:[0-9a-fA-F]{1,4}){1,3}|([0-9a-fA-F]{1,4}:){1,3}(:[0-9a-fA-F]{1,4}){1,4}|([0-9a-fA-F]{1,4}:){1,2}(:[0-9a-fA-F]{1,4}){1,5}|[0-9a-fA-F]{1,4}:((:[0-9a-fA-F]{1,4}){1,6})|:((:[0-9a-fA-F]{1,4}){1,7}|:)|[fF][eE]80:(:[0-9a-fA-F]{0,4}){0,4}%[0-9a-zA-Z]{1,}|::([fF]{4}(:0{1,4}){0,1}:){0,1}((25[0-5]|2[0-4][0-9]|1[0-9][0-9]|[1-9][0-9]|[0-9]).){3,3}(25[0-5]|2[0-4][0-9]|1[0-9][0-9]|[1-9][0-9]|[0-9])|([0-9a-fA-F]{1,4}:){1,4}:((25[0-5]|2[0-4][0-9]|1[0-9][0-9]|[1-9][0-9]|[0-9]).){3,3}(25[0-5]|2[0-4][0-9]|1[0-9][0-9]|[1-9][0-9]|[0-9]))$"
}
```

### non-negative-integer

An integer value that is equal to or greater than `0`.

In XML Schema this is represented as a restriction on the built-in type [nonNegativeInteger](https://www.w3.org/TR/xmlschema11-2/#nonNegativeInteger) as follows:

```XML
<xs:simpleType name="NonNegativeIntegerDatatype">
  <xs:restriction base="xs:nonNegativeInteger">
    <xs:pattern value="\S(.*\S)?"/>
  </xs:restriction>
</xs:simpleType>
```

Note: The pattern above ensures that leading and trailing whitespace is not allowed in XML-based Metaschema instances using this data type.

In JSON Schema, this is represented as:

```JSON
{
  "type": "integer",
  "minimum": 0
}
```

### positive-integer

An integer value that is greater than `0`.

In XML Schema this is represented as a restriction on the built-in type [positiveInteger](https://www.w3.org/TR/xmlschema11-2/#nonNegativeInteger) as follows:

```XML
<xs:simpleType name="PositiveIntegerDatatype">
  <xs:restriction base="xs:positiveInteger">
    <xs:pattern value="\S(.*\S)?" />
  </xs:restriction>
</xs:simpleType>
```

Note: The pattern above ensures that leading and trailing whitespace is not allowed in XML-based Metaschema instances using this data type.

In JSON Schema, this is represented as:

```JSON
{
  "type": "integer",
  "minimum": 1
}
```

### string

A non-empty string of unicode characters with leading and trailing whitespace disallowed.

Whitespace is: `U+9`, `U+10`, `U+32` or `[ \n\t]+`.

In XML Schema this is represented as a restriction on the built in type [string](https://www.w3.org/TR/xmlschema11-2/#string) as follows:

```XML
<xs:simpleType name="StringDatatype">
  <xs:restriction base="xs:string">
    <xs:whiteSpace value="preserve"/>
    <xs:pattern value="\S(.*\S)?"/>
  </xs:restriction>
</xs:simpleType>
```

Note: The pattern above ensures that leading and trailing whitespace is not allowed in XML-based Metaschema instances using this data type.

In JSON Schema, this is represented as:

```JSON
{
  "type": "string",
  "pattern": "^\\S(.*\\S)?$"
}
```

### token

A non-colonized name as defined by [XML Schema Part 2: Datatypes Second Edition](https://www.w3.org/TR/xmlschema11-2/#NCName).

In XML Schema this is represented as a restriction on the built in type [string](https://www.w3.org/TR/xmlschema11-2/#string) as follows:

```XML
<xs:simpleType name="TokenDatatype">
  <xs:restriction base="StringDatatype">
    <xs:pattern value="(\p{L}|_)(\p{L}|\p{N}|[.\-_])*"/>
  </xs:restriction>
</xs:simpleType>
```

In JSON Schema, this is represented as:

```JSON
{
  "type": "string",
  "pattern": "^(\\p{L}|_)(\\p{L}|\\p{N}|[.\\-_])*$"
}
```

### uri

A universal resource identifier (URI) formatted according to [RFC3986](https://tools.ietf.org/html/rfc3986).

In XML Schema this is represented as a restriction on the built in type [anyURI](https://www.w3.org/TR/xmlschema11-2/#anyURI) as follows:

```XML
<xs:simpleType name="URIDatatype">
  <xs:restriction base="xs:anyURI">
    <xs:pattern value="[a-zA-Z][a-zA-Z0-9+\-.]+:.*\S">
      <xs:annotation>
        <xs:documentation>Requires a scheme with colon per RFC3986.</xs:documentation>
      </xs:annotation>
    </xs:pattern>
  </xs:restriction>
</xs:simpleType>
```

In JSON Schema, this is represented as:

```JSON
{
  "type": "string",
  "format": "uri",
  "pattern": "^[a-zA-Z][a-zA-Z0-9+\\-.]+:.+$"
}
```

### uri-reference

A URI Reference, either a URI or a relative-reference, formatted according to [section 4.1](https://tools.ietf.org/html/rfc3986#section-4.1) of RFC3986.

In XML Schema this is represented as a restriction on the built in type [anyURI](https://www.w3.org/TR/xmlschema11-2/#anyURI) as follows:

```XML
<xs:simpleType name="URIReferenceDatatype">
  <xs:annotation>
    <xs:documentation>A trimmed URI having at least one character with no
      leading or trailing whitespace.</xs:documentation>
  </xs:annotation>
  <xs:restriction base="xs:anyURI">
    <xs:pattern value="\S(.*\S)?"/>
  </xs:restriction>
</xs:simpleType>
```

Note: The pattern above ensures that leading and trailing whitespace is not allowed in XML-based Metaschema instances using this data type.

In JSON Schema, this is represented as:

```JSON
{
  "type": "string",
  "format": "uri-reference"
}
```

### uuid

A version 4 or 5 Universally Unique Identifier (UUID) as defined by [RFC4122](https://tools.ietf.org/html/rfc4122).

In XML Schema this is represented as a restriction on the built in type [string](https://www.w3.org/TR/xmlschema11-2/#string) as follows:

```XML
<xs:simpleType name="UUIDDatatype">
  <xs:restriction base="StringDatatype">
    <xs:pattern value="[0-9A-Fa-f]{8}-[0-9A-Fa-f]{4}-[45][0-9A-Fa-f]{3}-[89ABab][0-9A-Fa-f]{3}-[0-9A-Fa-f]{12}">
      <xs:annotation>
        <xs:documentation>A sequence of 8-4-4-4-12 hex digits, with
          extra constraints in the 13th and 17-18th places for version
          4 and 5.</xs:documentation>
      </xs:annotation>
    </xs:pattern>
  </xs:restriction>
</xs:simpleType>
```

In JSON Schema, this is represented as:

```JSON
{
  "type": "string",
  "pattern": "^[0-9A-Fa-f]{8}-[0-9A-Fa-f]{4}-[45][0-9A-Fa-f]{3}-[89ABab][0-9A-Fa-f]{3}-[0-9A-Fa-f]{12}$"
}
```

### year-month-duration

An amount of time quantified in years and months based on [ISO-8601 durations](https://en.wikipedia.org/wiki/ISO_8601#Durations) (see also [RFC3339 appendix A](https://www.rfc-editor.org/rfc/rfc3339.html#appendix-A)).

Examples include:

The duration of 1 year and 6 months can be represented as:

```
P1Y6M
```

The using the optional minus sign, the negative duration of 9 months can be represented as:

```
-P9M
```

In XML Schema this is defined by [dayTimeDuration](https://www.w3.org/TR/xmlschema11-2/#dayTimeDuration), which is a restriction on the built-in type [duration](https://www.w3.org/TR/xmlschema11-2/#duration) as follows:

```XML
<xs:simpleType name="YearMonthDurationDatatype">
  <xs:restriction base="xs:duration">
    <xs:pattern value="-?P([0-9]+Y([0-9]+M)?)|[0-9]+M"/>
  </xs:restriction>
</xs:simpleType>
```

In JSON Schema, this is represented as:

```JSON
{
  "type": "string",
  "format": "duration",
  "pattern": "^-?P([0-9]+Y([0-9]+M)?)|[0-9]+M$"
}
```


## Markup Data Types

Structured prose text is designed to map cleanly to equivalent subsets of HTML and Markdown. This allows HTML-like markup to be incorporated in Metaschema XML-based content using an element set maintained in the Metaschema namespace. This HTML-equivalent element set is not intended to be treated directly as HTML, but to be readily and transparently converted to HTML (or other presentational formats) as needed. Similarly, Metaschema uses a subset of Markdown for use in Metaschema JSON- and YAML-based content. A mapping is supported between the HTML-like element set and the Markdown syntax, which supports transparent and lossless bidirectional mapping between both markup representations.

The HTML-like syntax supports:

- HTML paragraphs (`p`), headers (`h1`-`h6`), tables (`table`), preformatted text (`pre`), code blocks (`code`), and ordered and unordered lists (`ol` and `ul`.)

- Within paragraphs or text content: `a`, `img`, `strong`, `em`, `b`, `i`, `sup`, `sub`.

In remarks below and throughout this documentation, this element set may be referred to as "prose content" or "prose". This tag set (and Markdown equivalent) is defined as a module.

Note that elements such as `div`, `blockquote`, `section` or `aside`, used in HTML to provide structure, are *not permitted*. Instead, structures should be represented using specific model elements (or objects in JSON) such as `part`, which can include prose.

In addition, there are contexts where prose usage may be further constrained by specific applications.

The Markdown syntax is loosely based on [CommonMark](https://commonmark.org/). When in doubt about Markdown features and syntax, we look to CommonMark for guidance, largely because it is more rigorously tested than many other forms of Markdown.

### markup-line

The following table describes the equivalent constructs in HTML and Markdown used within the `markup-line` data type.

| Markup Type | HTML | Markdown |
|:--- |:--- |:--- |
| Emphasis (preferred) | &lt;em&gt;*text*&lt;/em&gt; | \**text*\*
| Emphasis | &lt;i&gt;*text*&lt;/i&gt; | \**text*\*
| Important Text (preferred) | &lt;strong&gt;*text*&lt;/strong&gt; | \*\**text*\*\*
| Important Text | &lt;b&gt;*text*&lt;/b&gt; | \*\**text*\*\*
| Inline code | &lt;code&gt;*text*&lt;/code&gt; | \`*text*\`
| Quoted Text | &lt;q&gt;*text*&lt;/q&gt; | "*text*"
| Subscript Text | &lt;sub&gt;*text*&lt;/sub&gt; | \~*text*\~
| Superscript Text | &lt;sup&gt;*text*&lt;/sup&gt; | ^*text*^
| Image | &lt;img alt="*alt text*" src="*url*" title="*title text*"/&gt; | !\[*alt text*](*url* "*title text*")
| Link | &lt;a *href*="*url*"&gt;*text*&lt;/a&gt; | \[*text*](*url*)

Note: Markdown does not have an equivalent of the HTML &lt;i&gt; and &lt;b&gt; tags, which indicate italics and bold respectively. These concepts are mapped in markup text to &lt;em&gt; and &lt;strong&gt; (see [common mark](https://spec.commonmark.org/0.29/#emphasis-and-strong-emphasis)), which render equivalently in browsers, but do not have exactly the same semantics. While this mapping is imperfect, it represents the common uses of these HTML tags.

#### Parameter Insertion

The Metaschema model allows object references to be referenced and injected into prose text.

Reference injection is handled using the <code>&lt;insert&gt;</code> tag, where you must provide its <code>type</code> and the identifier reference with <code>id-ref</code>:

```html
This implements <insert type="param" id-ref="pm-9_prm_1"/> as required to address organizational changes.
```

The same string in Markdown is represented as follows:

```markdown
This implements {{ insert: param, pm-9_prm_1 }} as required to address organizational changes.
```

#### Specialized Character Mapping

The following characters have special handling in their HTML and/or Markdown forms.

| Character                                      | XML HTML                             | (plain) Markdown | Markdown in JSON | Markdown in YAML |
| ---                                            | ---                                  | ---              | ---              | ---              |
| &amp; (ampersand)                              | &amp;amp;                            | &amp;            | &amp;            | &amp;            |
| &lt; (less-than sign or left angle bracket)    | &amp;lt;                             | &lt;             | &lt;             | &lt;             |
| &gt; (greater-than sign or right angle bracket) | &gt; **or** &amp;gt;                 | &gt;             | &gt;             | &gt;             |
| &#34; (straight double quotation mark)         | &#34; **or** &amp;quot;              | \\&#34;          |  \\\\&#34;       | \\\\&#34;        |
| &#39; (straight apostrophe)                    | &#39; **or** &amp;apos;              | \\&#39;          | \\\\&#39;        | \\\\&#39;        |
| \* (asterisk)                                  | \*                                   | \\\*             | \\\\\*           | \\\\\*           |
| &#96; (grave accent or back tick mark)         | &#96;                                | \\&#96;          | \\\\&#96;        | \\\\&#96;        |
| ~ (tilde)                                      | ~                                    | \\~              | \\\\~            | \\\\~            |
| ^ (caret)                                      | ^                                    | \\^              | \\\\^            | \\\\^            |

While the characters ``*`~^`` are valid for use unescaped in JSON strings and YAML double quoted strings, these characters have special meaning in Markdown markup. As a result, when these characters appear as literals in a Markdown representation, they must be escaped to avoid them being parsed as Markdown to indicate formatting. The escaped representation indicates these characters are to be represented as characters, not markup, when the Markdown is mapped to HTML.

Because the character "\\" (back slash or reverse solidus) must be escaped in JSON, note that those characters that require a back slash to escape them in Markdown, such as "\*" (appearing as "\\\*"), must be *double escaped* (as "\\\\\*") to represent the escaped character in JSON or YAML. In conversion, the JSON or YAML processor reduces these to the simple escaped form, again permitting the Markdown processor to recognize them as character contents, not markup.

Since these characters are not markup delimiters in XML, they are safe to use there without special handling. The XML open markup delimiters "&lt;" and "&amp;", when appearing in XML contents, must as always be escaped as named entities or numeric character references, if they are to be read as literal characters not markup.

### markup-multiline

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

#### Paragraphs

Additionally, the use of `p` tags in HTML is mapped to Markdown as two double, escaped newlines within a JSON or YAML string (i.e., "\\\\n\\\\n"). This allows Markdown text to be split into paragraphs when this data type is used.

#### Tables

Tables are also supported by `markup-multiline` which are mapped from Markdown to HTML as follows:

- The first row in a Markdown table is considered a header row, with each cell mapped as a &lt;th&gt;.
- The alignment formatting (second) row of the Markdown table is not converted to HTML. Formatting is currently ignored.
- Each remaining row is mapped as a cell using the &lt;td&gt; tag.
- HTML `colspan` and `rowspan` are not supported by Markdown, and so are excluded from use.

Simple tables are mainly supported due to the prevalence of tables in legacy data sets. However, producers of Metaschema data should note that when they have tabular information, these are frequently semantic structures or matrices that can be described directly in model-based structures as named parts and properties or as parts, sub-parts and paragraphs. This ensures that their nominal or represented semantics are accessible for processing when this information would be lost in plain table cells. Table markup should be used only as a fallback option when stronger semantic labeling is not possible.

Tables are mapped from HTML to Markdown as follows:

* Only a single header row &lt;tr&gt;&lt;th&gt; is supported. This row is mapped to the Markdown table header, with header cells preceded, delimited, and terminated by `|`.
* The second row is given as a sequence of `---`, as many as the table has columns, delimited by single `|`. In Markdown, a simple syntax here can be used to indicate the alignment of cells; the HTML binding does not support this feature.
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


#### Line feeds in Markdown

Additionally, line feed (LF) characters must be escaped as "\\n" when appearing in string contents in JSON and (depending on placement) in YAML. In Markdown, the line feed is used to delimit paragraphs and other block elements, represented using markup (tagging) in the XML version. When transcribed into JSON, these LF characters must also appear as "\\n".
