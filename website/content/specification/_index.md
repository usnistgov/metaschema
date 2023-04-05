---
title: "Metaschema Specification"
Description: "Metaschema specification"
suppresstopiclist: true
menu:
  primary:
    name: Specification
toc:
  enabled: true
  includeHtml: true
  headingselectors: h1,h2,h3,h4,h5
  collapsedepth: 4
weight: 10
aliases:
- /specification/concepts/
- /specification/concepts/architecture-mermaid/
- /specification/syntax/
---

# Overview

The *Metaschema Modeling Framework* provides a means to represent an [*information model*](/specification/terminology/#information-model), consisting of many [*information elements*](/specification/terminology/#information-element), in a format neutral form. By abstracting information modeling away from format specific forms, the Metaschema Modeling Framework provides a means to consistently and sustainably maintain a model, while avoiding the need to maintain each derivative format individually. By consolidating model maintenance into a single format, significant time can be saved over other approaches that require each format to be maintained individually.

A Metaschema-based model, called a [*Metaschema module*](/specification/terminology/#metaschema-module) represents implementations of the individual data elements of the information model using [*definitions*](/specification/terminology/#definition). These definitions are bound tightly to representational forms in each supported derivative data format, unifying representations for a given information model.

The Metaschema framework currently supports XML, JSON, and YAML data formats. Support for YAML is limited to the subset of YAML that aligns with JSON representations.

The tight binding to supported derivative data formats has many advantages.

1. **Automated Schema Generation:** Schema representations for a given supported data format can be automatically generated from a Metaschema module. Generated schemas can be used to validate that data is conformant to the associated format(s), ensuring that data is conformant to the model defined by the Metaschema module. When the model is changed, an updated schema representation can be automatically generated.
1. **Automated Translation of Content:** Data represented in a given supported data format can be automatically translated into an alternate supported data format. This allows data to be maintained in a single data format, which can be easily converted into all of the other supported formats.
1. **Automated Documentation Generation:** Data format specific documentation can be automatically generated that is aligned with the concepts used in a given format. This can be used to provide a format-specific view of a model.
1. **Automated Parsing Code Generation:** Programming language specific parsing and content generation code can also be automatically generated using a Metaschema module supporting data deserialization and serialization code capable of reading and writing data in each supported format. This generative approach allows application developers to focus right away on business logic and user interface features instead of building the basic common data structures needed for all applications that work with information from a given domain.

The following illustrates the Metaschema Framework architecture as described above.

```mermaid
graph TB
  ms[Metaschema module] -- generate --> schema[XML and JSON Schema]
  ms -- generate --> doc[HTML-based Documentation]
  ms -- generate --> code[Parsing Code]
  ms -- support --> conv[Conversion between formats]

classDef metasch fill:#dfe1e2,stroke:grey,stroke-width:4px,stroke-opacity:0.2
classDef usecase fill:#f0f0f0,stroke:grey,stroke-width:4px,stroke-opacity:0.2

class ms metasch
class code,schema,doc,conv usecase
```

These Metaschema-based capabilities, which can be applied to any information domain, serve both the needs of developers who need to support multiple data formats for a given domain, or that need to choose a format specific technology stack that is well-suited to their application. In either case, use of the generative capabilities supported by the Metaschema Framework, further reduces the time required to maintain format-specific documentation, schemas, data, and parsing code in multiple formats.

This specification provides a basis for the development of interoperable toolchains supporting the generative capabilities of the Metaschema Framework. This specification is also intended to serve as a reference for information modelers producing Metaschema-based information models.

## Design Goals

The design of the Metaschema modeling approach addresses the following needs:

1. **Ease Maintenance:** Reduce the implementation burden of supporting multiple formats, along with documentation, schemas, data, and related tooling.
1. **Ease Format Adoption Costs:** Reduce the cost of adopting a new supported data format.
1. **Unified Format Support:** Unify support for compatible data descriptions in multiple formats, such as XML, JSON, YAML and potentially others over time.
1. **Ease Production of Format Documentation:** Produce schema documentation from the same source as schema files and tools.
1. **Promote Model Experimentation:** Enable distributed, semi-coordinated experimentation with the format(s) and related tools supported by a given Metaschema module.

## Design Approach

The Metaschema provides a reduced, lightweight modeling language with constraints that apply at the level of the information model abstraction.

The following philosophy was used in the current design:
- **Mediate Format Structural Differences:** Mediate between the structural differences in the XML, JSON, and YAML data formats by providing format-specific tailoring capabilities that improve the expression and conciseness of Metaschema-based data in a given format. This has the added benefit of making Metaschema easier to learn and use over learning the idiosyncrasies of each data format.
- **Capitalize on Format Features:** To the extent possible, maximize the use of data format specific features, while still aligning modeling functionality across all supported data formats. In some cases, support for specific data format and schema features may be reduced where these features do not align well across all supported data format. 
- **Unify Information Modeling Across Formats:** Use modeling constructs that map cleanly into features offered by XML and JSON schema technologies. This ensures that all information can be preserved, without data loss in bidirectional conversion.
- **Reduce Runtime Complexities:** Eliminate the need for additional inputs, reliance on arbitrary conventions, or runtime settings to reliably produce correspondent XML, JSON or YAML from any other supported format.
- **Focus on Running Code:** Focus on the production of a rich specification that facilitates running code supporting automated generation of schemas, documentation, tooling, and other model-related artifacts consistent with the model defined and documented by a given Metaschema module.

# Information Modeling

The following diagram illustrates the relationships between information modeling concepts and the core structures provided by the Metaschema Framework.

![Information model / Metaschema module relationship](im-module.svg)

An [*information model*](terminology/#information-model) is an abstract representation of information from a given information [*domain*](terminology/#domain). An *information model* is composed of a set of semantically well-defined information structures that each represent an [*information element*](terminology/#information-element) in the information domain.

The primary purpose of the Metaschema Framework is to support the structured expression of an information model, which is represented as a [*Metaschema module*](terminology/#metaschema-module). A Metaschema module is used to represent the whole or a part of a information model for a given information domain in an information-centric, format-neutral form.

A Metaschema module contains a collection of reusable [*definitions*](terminology/#definition) that each represent a given information element in an information model. Each definition contains documentation about the meaning (semantics), structure (syntax), and use of a given information element.


# Definitions, Instances, and Local Definitions

Metaschema uses 3 types of definitions to represent information elements with different structural shapes. These different types of definitions are: [`define-flag`](#top-level-define-flag), [`define-field`](#top-level-define-field), or [`define-assembly`](#top-level-define-assembly). These definition types are used as building blocks of a Metaschema-based model.

Flag and assembly definitions have child instances, which represent an edge between the containing definition and another definition. Thus, an *instance* makes use of another definition, typically by reference.

Both field and assembly definitions optionally allow the inclusion of one or more child *flag instances*.

An assembly definition also has a model which contains a sequence of *model instances*. A model instance is an instance of a field or assembly.

{{<callout>}}
Within a Metaschema module, the information model implementation is composed of assemblies, each of which are composed of more assemblies and field instances. 

Field instances represent edge nodes, while assembly instances represent groupings of multiple information elements.

Flag instances may exist on fields and assemblies, providing identifying or characterizing data about their containing definition.

The following example illustrates the use of each type of definition, and the use of flag and model instances.

```mermaid
graph TD
  subgraph asmb-def-1[Assembly Definition: asmb-def-1]
      flg-inst-1[Flag Instance: flg-inst-1]
      asmb-def-1-model
  end
  subgraph asmb-def-1-model[Model]
      fld-inst-1[Field Instance: fld-inst-1]
      asmb-inst-1[Assembly Instance: asmb-inst-1]
  end
  subgraph fld-def-1[Field Definition: fld-def-1]
      flg-inst-2[Flag Instance: flg-inst-2]
  end
  flg-def-1[Flag Definition: flg-def-1]
  asmb-def-2[Assembly Definition asmb-def-2]
  fld-inst-1-->fld-def-1
  flg-inst-1-->flg-def-1
  flg-inst-2-->flg-def-1
  asmb-inst-1-->asmb-def-2

classDef definition fill:#dfe1e2,stroke:grey,stroke-width:4px,stroke-opacity:0.2
classDef model fill:#f0f0f0,stroke:grey,stroke-width:4px,stroke-opacity:0.2
classDef instance fill:#d9e8f6,stroke:grey,stroke-width:4px,stroke-opacity:0.2

class asmb-def-1,asmb-def-2,fld-def-1,flg-def-1 definition
class asmb-def-1-model model
class flg-inst-1,flg-inst-2,fld-inst-1,asmb-inst-1 instance
```

The example above declares 4 distinct object definitions, along with their instances.

- The flag definition `flg-def-1` represents a reusable flag.
- The field definition `fld-def-1` represents a reusable field.
- The assembly definitions `asmb-def-1` and `asmb-def-2` represent reusable assemblies.

In the example above, the assembly definition `asmb-def-1` and the field definition `fld-def-1` both instantiate the flag defined as `flg-def-1`. These instances, `flg-inst-1` and `flg-inst-2` respectively, are examples of *flag instances*.

Furthermore, the assembly definition `asmb-def-1` has a model that instantiates the assembly definition `asmb-def-2`, as `asmb-inst-1`, and the field definition `fld-def-1`, as `fld-inst-1`. These are examples of *model instances*.
{{</callout>}}

Assemblies and fields also allow *inline definitions* to be declared which represent a single use definition that is also an instance. In these cases the inline `<define-flag>`, `<define-field>`, and `<define-assembly>` elements are used. 

# Metaschema Module

A Metaschema module instance is represented using the top-level XML element `<METASCHEMA>`.

For example:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<METASCHEMA xmlns="http://csrc.nist.gov/ns/oscal/metaschema/1.0">
  <schema-name>Computer Model</schema-name>
  <schema-version>0.0.5</schema-version>
  <short-name>computer</short-name>
  <namespace>http://example.com/ns/computer</namespace>
  <json-base-uri>http://example.com/ns/computer</json-base-uri>
  <remarks>
    <p>This is an example model to describe the components of a computer.</p>
    <p>The "computer" element is the root element of this model.</p>
  </remarks>
  <!-- followed by a series of imports, then a series of definitions -->
</METASCHEMA>
```

Attributes:

| Attribute | Data Type | Use      | Default Value | Section |
|:---       |:---       |:---      |:---           |:---      |
| [`@abstract`](#abstract-modules) | `yes` or `no` | optional | `no` | Header: [Abstract Module](#abstract-modules) |

Elements:

| Element | Data Type | Use      | Section |
|:---       |:---       |:---      |:---      |
| [`<schema-name>`](#schema-name) | [`markup-line`](/specification/datatypes/#markup-line) | 1 | Header: [Documentation](#module-documentation) |
| [`<schema-version>`](#schema-version) | version ([`string`](/specification/datatypes/#string)) | 1 | Header: [Documentation](#module-documentation) |
| [`<short-name>`](#short-name) | [`token`](/specification/datatypes/#token) | 1 | Header: [Documentation](#module-documentation) |
| [`<namespace>`](#xml-namespace) | [`uri`](/specification/datatypes/#uri) | 1 | Header: [XML Namespace](#xml-namespace) |
| [`<json-base-uri>`](#json-base-uri) | [`uri`](/specification/datatypes/#uri) | 1 | Header: [JSON Base URI](#json-base-uri) |
| [`<remarks>`](#remarks) | special | 0 or 1 | Header: [Documentation](#module-documentation) |
| [`<import>`](#module-imports) | special | 0 to ∞ | [Module Imports](#module-imports) |
| [`<define-assembly>`](#top-level-define-assembly),<br/>[`<define-field>`](#top-level-define-field), and<br/>[`<define-flag>`](#top-level-flag) | special | 0 to ∞ | [Module Definitions](#definitions) |

The first set of elements in a Metaschema module represent the *header*, which contains information about the instance as a whole. The remainder of this section discusses use of these elements.

{{<callout>}}
**Note:** There is no explicit separation between the header and the definitions. The header ends where the `<import>`, `<define-assembly>`, `<define-field>`, and `<define-flag>` elements first appear.
{{</callout>}}

## Module Documentation

Top level documentation for the Metaschema module appears at the beginning of the header section.

{{<callout>}}
The documentation within the Metaschema module's header applies to the whole Metaschema module. Each child object definition will also have associated documentation that appears within that object definition.
{{</callout>}}

A Metaschema module's header may include the following elements, in order:

### `<schema-name>`

The required `schema-name` is a line of [structured markup](/specification/datatypes/#markup-line) that provides a human-readable name, suitable for display, for the information model represented by this Metaschema module.

For example:

```xml
<schema-name>Computer Model</schema-name>
```

### `<schema-version>`

A required, unique string literal value indicating the distinct version assigned to the Metaschema module.

This version provides a means to distinctly identify a given revision of the Metaschema module in a series of revisions.

{{<callout>}}
Use of [semantic versioning](https://semver.org/), also referred to as "semver", in a `<schema-version>` is encouraged, since semver provides a standardized set of rules for how version numbers are assigned and incremented.
{{</callout>}}

For example:

```xml
<schema-version>0.0.5</schema-version>
```

This example defines a semantic version with a major version of `0`, a minor version of `0`, and a patch version of `5`.

### `<short-name>`

A required, unique string literal value that identifies a series of revisions of the Metaschema module. Each revision in the series will have the same `<short-name>`.

For example:

```xml
<short-name>computer</short-name>
```

Together, the `<short-name>` and `<schema-version>` provide an identification pair that unqiuely identifies a given Metaschema module revision. This pair of values is intended to be associated with any schemas, code, tools, or other derivative artifacts produced from the Metaschema module, providing for clear identification of the Metaschema module revision an artifact is derived from.

### `<remarks>`

An optional sequence of [multiline markup](/specification/datatypes/#markup-multiline) used to provide additional supporting notes related to the Metaschema module.

A `<remarks>` element is typically used to including explanatory commentary of any kind.

For example:

```xml
<remarks>
  <p>This is an example model to describe the components of a computer.</p>
  <p>The "computer" element is the root element of this model.</p>
</remarks>
```

{{<callout>}}
As a general purpose element, the `remarks` element is also permitted to appear elsewhere in the Metaschema module model. Its scope of application is tied to the location of use in the document. Thus, the top-level remarks describe the entire metaschema, while remarks on an object definition describe the object definition.
{{</callout>}}

## XML `<namespace>`

The required `<namespace>` element is a [uniform resource identifier](https://www.rfc-editor.org/rfc/rfc3986) (URI) that identifies the [XML Namespace](https://www.w3.org/TR/xml-names/#sec-namespaces) to use for XML instances of the model.

All information objects defined in the Metaschema module will be assigned to this namespace when handling related XML data.

{{<callout>}}
Note: Information objects defined in an [imported Metaschema module](#metaschema-definition-imports), will be assigned the namespace declared in that module's header. This makes it possible to use object definitions defined with different namespaces.
{{</callout>}}

The XML namespace defined using this element will be the target namespace used in an XML schema generated from this Metaschema module.

## `<json-base-uri>`

The required `<json-base-uri>` element is a [uniform resource identifier](https://www.rfc-editor.org/rfc/rfc3986) (URI) that identifies the URI used in the [`$schema` keyword](https://datatracker.ietf.org/doc/html/draft-handrews-json-schema-01#section-7) in JSON Schemas generated from this Metaschema module.

## Abstract Modules

A Metaschema module may be declared as *abstract* using the `@abstract` attribute. This indicates that the Metaschema module is not intended to be used on its own. Instead, the Metaschema module is intended to be only *imported* by other Metaschema modules.

For example:

```xml {linenos=table,hl_lines=[3]}
<?xml version="1.0" encoding="UTF-8"?>
<METASCHEMA xmlns="http://csrc.nist.gov/ns/oscal/metaschema/1.0"
  abstract="yes">
  <!-- ... other content ... -->
</METASCHEMA>
```

# Definitions

Following the `METASCHEMA/remarks`, any number of definitions may follow. These describe the set of reusable [*information element*](terminology/#information-element) implementations within a Metaschema module.

The 3 types of definitions are [`<define-flag>`](#top-level-define-flag), [`<define-field>`](#top-level-define-field), and [`<define-assembly>`](#top-level-define-assembly).

The following subsections describe the syntax that is [common to all definition types](#common-definition-metadata), as well as each type of definition.

## Common Definition Metadata

The `define-assembly`, `define-field`, and `define-flag` child elements share a common syntax comprised of the following XML attributes and elements.

Attributes:

| Attribute | Data Type | Use      | Default Value |
|:---       |:---       |:---      |:---           |
| [`@deprecated`](#deprecated-version) | version ([`string`](/specification/datatypes/#string)) | optional | *(no default)* |
| [`@name`](#name) | [`token`](/specification/datatypes/#token) | required | *(no default)* |
| [`@scope`](#scope) | `local` or `global` | optional | `global` |

Elements:

| Element | Data Type | Use      |
|:---       |:---       |:---      |
| [`<formal-name>`](#formal-name) | [`string`](/specification/datatypes/#string) | 0 or 1 |
| [`<description>`](#description) | [`markup-line`](/specification/datatypes/#markup-line) | 0 or 1 |
| [`<prop>`](#prop) | special | 0 to ∞ |
| [`<use-name>`](#naming-and-use-name) | [`token`](/specification/datatypes/#token) | 0 or 1 |
| [`<remarks>`](#remarks) | special | 0 or 1 |
| [`<example>`](#example) | special | 0 to ∞ |

These attributes and elements are described in the following subsections.

### `@deprecated` Version

The optional deprecated attribute communicates that the given information element implemented by the definition represents a data object who's use is intended to be discontinued starting with the specified version.

This version is a reference to the [`<schema-version>`](#schema-version) declared in the module header.

{{<callout>}}
Use of `@deprecated` is intended to support communication with content creators about avoiding use of the data object. Supporting this use case, this annotation can be used in documentation generation and in Metaschema-aware tools that provide context around using the definition.
{{</callout>}}

For example, deprecating the flag named `flag-name` starting with the model version `1.1.0` would be represented as follows.

```xml {linenos=table,hl_lines=[3]}
<define-flag
  name="flag-name"
  deprecated="1.1.0">
```

### `@name`

The `@name` attribute provides the definition's identifier, which can be used in other parts of a module, or in an importing module, to reference the definition.

The names of flags, fields, and assemblies are expected to be maintained as separate identifier sets. This allows a flag, field, and an assembly definition to each have the same name in a given Metaschema module.

### `@scope`

The optional `@scope` attribute is used to communicate the intended visibility of the definition when accessed by another module through an [`<import>`](#module-imports) element.

- `global` (default) - Indicates that the definition MUST be made available for reference within importing modules. Definitions in the same and importing modules can reference it.
- `local` - Indicates that the definition MUST NOT be made available for reference within importing modules. Only definitions in the same module can reference it.

Note: References to definitions in the same module are always possible regardless of scope.

### `<formal-name>`

The optional `<formal-name>` element provides a human-readable, short string label for the definition for use in documentation.

{{<callout>}}
The `<formal-name>` label is intended to provide an easy to recognize, meaningful name for the definition.

While not required, it is best practice to include a `<formal-name>`.
{{</callout>}}

### `<description>`

The optional `<description>` element is a [single line of markup](/specification/datatypes/#markup-line) that describes the semantic meaning and use of the definition.

{{<callout>}}
The description ties the definition to the related information element concept in the information domain that the definition is representing. This information is ideal for use in documentation.

While not required, it is best practice to include a `<description>`.
{{</callout>}}

### `<prop>`

The optional `<prop>` element provides a structure for declaring arbitrary properties, which consist of a `@namespace`, `@name`, and `@value`.

| Attribute | Data Type | Use      | Default Value |
|:---       |:---       |:---      |:---           |
| `@namespace` | [`uri`](/specification/datatypes/#uri) | optional | `http://csrc.nist.gov/ns/oscal/metaschema/1.0` |
| `@name` | [`token`](/specification/datatypes/#token) | required | *(no default)* |
| `@value` |  [`token`](/specification/datatypes/#token) | required | *(no default)* |

The `@name` and `@namespace` is used in combination to define a semantically unique name, represented by the `@name` attribute, within the managed namespace defined by the `@namespace` attribute. If the `@namespace` attribute is omitted, the `@name` MUST be considered in the `http://csrc.nist.gov/ns/oscal/metaschema/1.0` namespace.

The `@value` attribute represents the lexical value assignment for the semantically unique name represented by the combination of the `@name` and `@namespace`. The lexical values of the `@value` attribute may be restricted for the specific semantically unique name, but such restrictions are not enforced directly in this model.

{{<callout>}}
A property on a definition is useful for annotating a definition with additional information that might describe, in a structured way, the semantics, use, nature, or other significant information related to the definition. In many cases, a property might be used to tailor generated documentation or to support an experimental, non-standardized feature in Metaschema.
{{</callout>}}

### Naming and `<use-name>`

The optional `<use-name>` changes the *effective name* to use for the information element in a data model.

The `<use-name>` element is optional and may occur multiple times.

By default the *effective name* of the information element in a data model is taken from the `@name` attribute. The `<use-name>` value overrides this behavior.

{{<callout>}}
Use of a `<use-name>` frees the module maintainer allowing them to use a sensible `@name` for the definition, while providing control over the name used in an instance of the definition in a data model.
{{</callout>}}

The first matching condition determines the *effective name* for the definition:

1. A `<use-name>` is provided on the definition. The *effective name* is the value of the `<use-name>` element.
1. No `<use-name>` is provided on the definition. The *effective name* is the value of the `@name` attribute.

For example:

```xml
<define-field name="field">
  <define-flag name="flag-a">
    <use-name>flag-b</use-name>
  </define-flag>
</define-field>
```

In the example above, the *effective name* of the definition is `name-b`. If the `<use-name>` was omitted, the *effective name* would be `name-a`.

The following content would is valid to the model above.

{{< tabs JSON YAML XML >}}
{{% tab %}}
```json
{
  "field": {
    "flag-b": "value"
  }
}
```
{{% /tab %}}
{{% tab %}}
```yaml
---
field:
  flag-b: "value"
```
{{% /tab %}}
{{% tab %}}
```xml
<field flag-b="value"/>
```
{{% /tab %}}
{{% /tabs %}}

### `<remarks>`

The optional `<remarks>` element provides a place to add notes related to the use of the definition. Remarks can be used to clarify the semantics of the definition in specific conditions, or to better describe how the definition may be more fully utilized within a model. 

The `<remarks>` element is optional and may occur multiple times.

### `<example>`

The optional `<example>` element is used to provide inline examples, which are intended to illustrate the use the information element implemented by the definition. Examples are provided in XML, which can then be automatically converted into other formats.

The `example` element is optional and may occur multiple times.

## Top Level `<define-flag>`

A flag definition, represented by the `<define-flag>` element, is used to declare a reusable [flag](/specification/terminology/#flag) within a Metaschema module.

A flag definition provides the means to implement a simple, named [*information element*](terminology/#information-element) with a value.

{{<callout>}}
Flag definitions are the primary leaf nodes in a Metaschema-based model. Flags are intended to represent granular particles of identifying and qualifying information.
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
| [`@scope`](#scope) | `local` or `global` | optional | `global` |

Elements:

| Element | Data Type | Use      |
|:---       |:---       |:---      |
| [`<formal-name>`](#formal-name) | [`string`](/specification/datatypes/#string) | 0 or 1 |
| [`<description>`](#description) | [`markup-line`](/specification/datatypes/#markup-line) | 0 or 1 |
| [`<prop>`](#prop) | special | 0 to ∞ |
| [`<use-name>`](#naming-and-use-name) | [`token`](/specification/datatypes/#token) | 0 or 1 |
| [`<constraint>`](#define-flag-constraints) | special | 0 or 1 |
| [`<remarks>`](#remarks) | special | 0 or 1 |
| [`<example>`](#example) | special | 0 to ∞ |

The attributes and elements specific to the `<define-flag>` are described in the following subsections. The elements and attributes common to all definitions are [defined earlier](#common-definition-metadata) in this specification.

### `@as-type`

The `@as-type` attribute declares the type of the flag's value. If not provided, the default value is `string`.

The `@as-type` attribute must have a value that corresponds to one of the [simple data types](#simple-data-types). As a result, markup in flag values is not permitted.

### `@default`

The `@default` attribute specifies the default value for the flag. When a flag is specified as an optional child of a `<define-field>` or `<define-assembly>`, this value should be considered set for a content instance if the flag is omitted in that instance.

### `<constraint>`

Constraints are [covered later](#define-flag-constraints) in this specification.

## Top Level `<define-field>`

A field definition, represented by the `<define-field>` element, is used to declare a reusable [field](/specification/terminology/#field) within a metaschema module.

A field definition provides the means to implement a complex named [*information element*](terminology/#information-element) with a value and an optional set of [*flag*](#flag) instances.

{{<callout>}}
A field is an edge node in a Metaschema-based model. Fields are typically used to provide supporting information for a containing [*assembly*](#assembly). The flag instances, typically characterize or identify the fields value. With optional use of flags, a field can be more or less complex, depending on the modeling need.
{{</callout>}}

The field's value is strongly typed using one of the built in [simple data types](/specification/datatypes/#simple-data-types) or [markup data types](/specification/datatypes/#markup-data-types) identified by the `@as-type` attribute.identified by the `@as-type` attribute.


Attributes:

| Attribute | Data Type | Use      | Default Value |
|:---       |:---       |:---      |:---           |
| [`@as-type`](#as-type) | [`token`](/specification/datatypes/#token) | optional | [`string`](/specification/datatypes/#string) |
| [`@collapsible`](#collapsible) | `yes` or `no` | optional | `no` |
| [`@default`](#default-1) | [`string`](/specification/datatypes/#string) | optional | *(no default)* |
| [`@deprecated`](#deprecated-version) | version ([`string`](/specification/datatypes/#string)) | optional | *(no default)* |
| [`@name`](#name) | [`token`](/specification/datatypes/#token) | required | *(no default)* |
| [`@scope`](#scope) | `local` or `global` | optional | `global` |

Elements:

| Element | Data Type | Use      |
|:---       |:---       |:---      |
| [`<formal-name>`](#formal-name) | [`string`](/specification/datatypes/#string) | 0 or 1 |
| [`<description>`](#description) | [`markup-line`](/specification/datatypes/#markup-line) | 0 or 1 |
| [`<prop>`](#prop) | special | 0 to ∞ |
| [`<use-name>`](#naming-and-use-name) | [`token`](/specification/datatypes/#token) | 0 or 1 |
| [`json-key`](#) | special | 0 or 1 |
| [`json-value-key`](#json-value-key) or<br/>[`json-value-key-flag`](#json-value-key-flag) | special | 0 or 1 |
| [`flag`](#flag-instance-children) or<br/>[`define-flag`](#define-flag-inline-definition) | special | 0 or ∞ |
| [`<constraint>`](#define-flag-constraints) | special | 0 or 1 |
| [`<remarks>`](#remarks) | special | 0 or 1 |
| [`<example>`](#example) | special | 0 to ∞ |

The attributes and elements specific to the `<define-flield>` are described in the following subsections. The elements and attributes common to all definitions are [defined earlier](#common-definition-metadata) in this specification.

### `@as-type`

The optional `@as-type` attribute declares the type of the field's value. If not provided, the default value is `string`.

The `@as-type` attribute must have a value that corresponds to one of the built in [simple data types](/specification/datatypes/#simple-data-types) or [markup data types](/specification/datatypes/#markup-data-types).

### `@collapsible`

The optional `@collapsible` attribute controls a JSON and YAML specific behavior that allows multiple fields having the same set of flag values to be collapsed into a single object with a value property that is an array of values. This makes JSON and YAML formatted data more concise.

If `@collapsible` is not specified, the default value is `no`.

The following behavior is required to be used for each value of `@collapsible`:

- `no` - Do not collapse. This is the default.
- `yes` - Collapse values that have flags with equivalent values.

A flag value is equivalent if the value, or default value if not provided, is an exact match. A non-default flag is considered to have no value and will match the same flag on another instance that has no value.

Note: Collapsing may affect the relative ordering of field instances. If two field instances are non-adjacent and their flags match, then the later field instance will be moved to be adjacent to the first. **Do not use the collapsible feature if maintaining field sequences is important to your use.**

An example a collapsible field definition might look like the following.

```xml
<define-assembly name="assembly">
  <root-name>assembly</root-name>
  <model>
    <define-field name="field" max-occurs="unbounded" collapsible="yes">
      <group-as name="fields" in-json="ARRAY"/>
      <define-flag name="flag-default-a" default="a"/>
      <define-flag name="flag-required" required="yes"/>
      <define-flag name="flag-optional"/>
    </define-field>
  </model>
</define-assembly>
```

An example set of content instances follow. XML is provided first to illustrate the use of uncollapsed fields, since this feature applies to JSON and YAML only. The JSON and YAML collapsed versions follow.

```xml {linenos=table,hl_lines=[2,4]}
<assembly>
  <field flag-required="required 1">field-value-1</field>
  <field flag-required="required 2">field-value-2</field>
  <field flag-default-a="a" flag-required="required 1">field-value-3</field>
</assembly>
```

The XML example above illustrates 2 fields, on lines 3 and 4, which will be collapsed together in the resulting JSON and YAML conversion. This is because they have the same flag values: `a` for the flag named `flag-default-a`, `required 1` for the flag named `flag-required`, and no value for the flag named `flag-optional`.

When converted to JSON or YAML, these fields will be collapsed, resulting in the following content instances.

{{< tabs JSON YAML >}}
{{% tab %}}
```json {linenos=table,hl_lines=["4-7"]}
{
"assembly": {
  "fields": [
    {
      "flag-required": "required 1",
      "STRVALUE": [ "field-value-1", "field-value-3"]
    },
    {
      "flag-required": "required 2",
      "STRVALUE": "field-value-2"
    }
  ]
}
```
{{% /tab %}}
{{% tab %}}
```yaml {linenos=table,hl_lines=["4-7"]}
---
assembly:
  fields:
  - flag-required: "required 1"
    STRVALUE:
    - "field-value-1"
    - "field-value-3"
  - flag-required: "required 2"
    STRVALUE: "field-value-2"
```
{{% /tab %}}
{{% /tabs %}}

If the JSON or YAML instance is converted back to XML, the sequencing of the fields will change due to use of the collapsible feature as follows.

```xml {linenos=table,hl_lines=["2-3"]}
<assembly>
  <field flag-required="required 1">field-value-1</field>
  <field flag-required="required 1">field-value-3</field>
  <field flag-required="required 2">field-value-2</field>
</assembly>
```

This is because the resulting JSON and YAML instance has no way of indicating the original sequencing.

### `@default`

The `@default` attribute specifies the default value for the field. When a flag is specified as an optional child of a `<define-field>` or `<define-assembly>`, this value should be considered set for a content instance if the field is omitted in that instance.

A `@default`value MUST only be provided when the data type specified by the `@as-type` is a [simple data types](#simple-data-types). Specifying a `@default` value for a [markup data type](/specification/datatypes/#markup-data-types) MUST result in a Metaschema format error.

Implementations when writing content instances MAY omit writing default values in order to produce a more concise expression of the content.

### `<flag>` Instance Children

A field may have zero or more flag instance children.

See [flag instances](#flag-instances)

### `<define-flag>` Inline Definition

See [inline `<define-flag>`](#inline-define-flag).

### `<json-key>`

TODO: Specify this. Note assembly points to this section.

### JSON Value Keys

TODO: discuss use only when flags may be present.

In XML, the value of a field appears as the text child of the field's element. In JSON and YAML, a property name is needed for the value. The `<json-value-key>` and `<json-value-key-flag>` elements provide a means to control the behavior of how this value is represented.

If no `<json-value-key>` or `<json-value-key-flag>` element is declared, a property name value will be chosen based on the data type as follows:
  - If the field's `@as-type` is `markup-line`, then the property name will be `RICHTEXT`.
  - If the field's `@as-type` is `markup-multiline`, then the property name will be `prose`.
  - Otherwise, the property name will be `STRVALUE`.

This logic may result in less than ideal property names. Metaschema provides the <json-value-key>` and `<json-value-key-flag>` elements to override this behavior. Use of these elements are mutually exclusive.

The following subsections describe the use of these elements.

#### `<json-value-key>`

The `<json-value-key>` element can be declared to set the property name for the field's value. Its text value child MUST be used as the property name for the field's value.

For example:

```xml {linenos=table,hl_lines=[5]}
<define-assembly name="assembly">
  <root-name>assembly</root-name>
  <model>
    <define-field name="field" max-occurs="unbounded">
      <json-value-key>value</json-value-key>
      <group-as name="fields" in-json="ARRAY"/>
      <define-flag name="flag-default-a" default="a"/>
    </define-field>
  </model>
</define-assembly>
```

Would allow the following content in JSON and YAML.

{{< tabs JSON YAML >}}
{{% tab %}}
```json {linenos=table,hl_lines=[6]}
{
  "assembly": {
    "fields": [
      {
        "flag-default-a": "b",
        "value": "value1"
      }
    ]
  }
}
```
{{% /tab %}}
{{% tab %}}
```yaml {linenos=table,hl_lines=[5]}
---
assembly:
  fields:
  - flag-default-a: "b"
    value: "value1"
```
{{% /tab %}}
{{% /tabs %}}

#### `<json-value-key-flag>`

The `<json-value-key>` element can be declared to use the value of specific flag on the field as the property name for the field's value.

The `@flag-name` attribute MUST reference the [name](#name) of a flag on the field whose value is to be used as the property name.

This results in a property that is a combination of the referenced flag's value and the field's value.

For example:

TODO: complete this example.

## Top Level `<define-assembly>`

The top level `<define-assembly>` element represents a *flag definition* that defines a reusable [flag](terminology/#flag).

An assembly is similar to a field, except it contains structured content (objects or elements), not text or unstructured "rich text". The contents permitted in a particular (type of) assembly are indicated in its `model` element.

An `@as-type` attribute is not permitted on an assembly definition.

### `flag` Instances

### Model Instances

This element is used to reference the `field` and `assembly` components that compose the assembly's model. A `choice` element is also provided to define mutually exclusive model members.

#### Using cardinalities and `group-as`


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

#### `assembly`

Used to reference an `assembly-definition` who's `@name` matches the value of the `@ref` attribute.
#### `field`

- see `in-xml` in `define-field`


Used to reference a `field-definition` who's `@name` matches the value of the `@ref` attribute.

#### `choice`

#### Inline Definitions

- do not allow `use-name` or `scope`

#### `any`

### Root Assemblies

## `<json-key>`

Use of `<json-key>` for a `<define-assembly>` is the same as for a `<define-field>`. See [`<json-key>`](#json-key).

## `@deprecated` version

# Inline Definitions

## Inline `<define-flag>`

## Inline `<define-field>`

## Inline `<define-assembly>`

# Object Instance Syntax

redefine formal-name

Figure out how best to handle instances
## Redefining the `description`

The optional `description` element of the child `field` and `assembly` elements can be used to provide a different description for when the referenced component is used in the specified model context.


## `flag` Instance


### XML Representational Form

In XML, a flag instance is represented as an [attribute](https://www.w3.org/TR/xml/#attdecls).

```xml
<field-or-assembly @flag-name="flag value"/>
```

### JSON Representational Form

In JSON a flag instance is represented as an [object member](https://datatracker.ietf.org/doc/html/rfc8259#section-2) (also called a "[property]()") with an associated value.

```json
{
  "flag-name": "flag value"
}
```

### YAML Representational Form

The YAML representation is similar to JSON, where a [tagged value](https://yaml.org/spec/1.2.2/#24-tags) is used to represent a flag.

```yaml
flag-name: flag value
```


# Data Types

A data type can be specified in a metaschema definition within a `define-field` or a `define-flag`object definition using the `@as-type` attribute.

Metaschema built in data types a covered in the [data type section](/specification/datatypes/) of this specification.

# Module Imports

The `<import>` element is used to import the components defined in another metaschema definition into this metaschema definition.

TODO: Discuss name shadowing.

# Constraints

## Common Metadata

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

---
# Extra Content

TODO: Integrate or remove.


A [field](../terminology/#field) is declared as a **field definition**, defined by the [`<define-field>`](#define-field-object-definition) element, represents a named element with a value child.

A field may also have number of child flags.

A field is an edge node within a metaschema model, which has a value leaf node and may also have flag leaf nodes.

In XML, a field is represented in two possible ways:

1. As an XML element.

   ```xml
   <field-name>field value</field-name>
   ```

   or

   ```xml
   <field-name flag="flag1 value">field value</field-name>
   ```

   The form immediately above is used when the field has a child flag instance.

1. As a text value in an [unwrapped form]().

   ```xml
   <some-assembly>field value</some-assembly>
   ```

   This form is only allowed when a field has no child flags.


The representational form of a field varies based on the presence of child flags.



Field definitions and assembly definitions are used to represent compound objects. To do so, the field and assembly definitions compose a more complex model by declaring zero or more *instances*.

An **instance** represents an edge between the containing definition and another definition.

A field definition may have zero or more **flag instances**.

Similar to a field definition, an assembly definition allows for zero or more **flag instances**. Additionally, an assembly definition has a model that supports zero or more **model instances** that instantiate a field or assembly definition.

- Redefinition of descriptions
- Name/Use name precedence

# Old Spec

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

