---
title: "Instances"
Description: ""
weight: 30
---

# Instances

In a Metaschema module, complex information elements are created through composition. Through composition, an information element can be built by indicating which other information elements are used as its constituent parts.

An *instance* is used to declare an information element *child* within a *parent* information element. In a Metaschema module, the parent information element is a definition, either a *field definition* or an *assembly definition*. The instance is a *flag instance*, *field instance*, or *assembly instance*, which in turn either references an existing [*top-level definition*](/specification/syntax/definitions/) by name or provides a [*inline definition*](/specification/syntax/inline-definitions/) as part of the instance declaration.

## Common Instance Data

The [`<assembly>`](#assembly-instances), [`<field>`](#field-instances), and [`<flag>`](#flag-instances) child elements share a common syntax comprised of the following XML attributes and elements.

Attributes:

| Attribute | Data Type | Use      | Default Value |
|:---       |:---       |:---      |:---           |
| [`@deprecated`](#deprecated-version) | version ([`string`](/specification/datatypes/#string)) | optional | *(no default)* |
| [`@ref`](#ref) | [`token`](/specification/datatypes/#token) | required | *(no default)* |

Elements:

| Element | Data Type | Use      |
|:---       |:---       |:---      |
| [`<formal-name>`](#formal-name) | [`string`](/specification/datatypes/#string) | 0 or 1 |
| [`<description>`](#description) | [`markup-line`](/specification/datatypes/#markup-line) | 0 or 1 |
| [`<prop>`](#prop) | special | 0 to ∞ |
| [`<use-name>`](#naming-and-use-name) | [`token`](/specification/datatypes/#token) | 0 or 1 |
| [`<remarks>`](#remarks) | special | 0 or 1 |

These attributes and elements are described in the following subsections.

### `@deprecated` Version

The optional `@deprecated` attribute communicates that a given compositional use of the referenced information element is intended to be discontinued starting with the specified version.

This version is a reference to the [`<schema-version>`](/specification/syntax/module/#schema-version) declared in the module header.

If both the definition and the instance declare a `@deprecated` version, the value provided by the instance MUST override the value provided by the definition.

{{<callout>}}
Declaring the `@deprecated` attribute communicates to content creators that the use of a given instance of the information element is to be avoided. This is more fine-grained than deprecating all uses of the information element, which is supported by the [`@deprecated`](#deprecated-version) attribute on the referenced definition.

This annotation can be used in documentation generation and in Metaschema-aware tools that provide context around use of the instance.
{{</callout>}}

For example, deprecating the use of the flag named `id` within the `computer` assembly starting with the model version `1.1.0` would be represented as follows.

```xml {linenos=table,hl_lines=[6]}
<define-flag name="id"/>
<define-assembly name="computer">
  <root-name>computer</root-name>
  <flag ref="id"
    required="yes"
    deprecated="1.1.0"/>
</define-assembly>
```

### `@ref`

The `@ref` attribute declares the top-level definition that the instance represents through composition. The name indicated by the `@ref` attribute must be a definition of the corresponding type declared in the containing module or a globally scoped definition in an imported module. See [Definition Name Resolution](/specification/syntax/module/#definition-name-resolution).

The instance type corresponds with the definition type as follows.

| Instance Type | Top-Level Definition Type |
|:---       |:---       |
| [`<flag>`](#flag-instances) | [`<define-flag>`](/specification/syntax/definitions/#top-level-define-flag) |
| [`<field>`](#field-instances) | [`<define-field>`](/specification/syntax/definitions/#top-level-define-field) |
| [`<assembly>`](#assembly-instances) | [`<define-assembly>`](/specification/syntax/definitions/#top-level-define-assembly) |

**Note:** The names of flags, fields, and assemblies are expected to be maintained as separate identifier sets. This allows a flag, field, and an assembly definition to each have the same name in a given Metaschema module.

### `<formal-name>`

The optional `<formal-name>` element provides a human-readable, short string label for the instance for use in documentation.

If provided, this formal name MUST override the `<formal-name>` declared on the corresponding definition, if a `<formal-name>` is declared there. If not provided, the effective formal name of the instance MUST be the `<formal-name>` declared on the definition. If neither the instance or the definition provide a `<formal-name>`, then the instance MUST NOT have a declared formal name.

{{<callout>}}
The `<formal-name>` label is intended to provide an easy to recognize, meaningful name for the instance. This element can be used when the formal name of the instance differs in use from the formal name declared by the referenced definition.

While not required, it is best practice to include a `<formal-name>` when the use case of the instance is more specialized than the intended use described by the definition.
{{</callout>}}

### `<description>`

The optional `<description>` element is a [single line of markup](/specification/datatypes/#markup-line) that describes the semantic meaning and use of the instance. This information is ideal for use in documentation.

If provided, this description MUST override the `<description>` declared on the corresponding definition, if a `<description>` is declared there. If not provided on an instance, the effective description of the instance MUST be the `<description>` declared on the definition. If neither the instance or the definition provide a `<description>`, then the instance MUST NOT have a declared description.

{{<callout>}}
The description ties the instance to the related information element concept in the information domain that the instance is representing. This element can be used when the description of the instance differs in use from the description declared by the referenced definition.

While not required, it is best practice to include a `<description>` when the use case of the instance is more specialized than the intended use described by the definition.
{{</callout>}}

### `<prop>`

The optional `<prop>` element provides a structure for declaring arbitrary properties, which consist of a `@namespace`, `@name`, and `@value`.

This data element uses the same syntax as the [`<prop>` allowed on a definition](/specification/syntax/definitions/#prop). When used on an instance, the set of properties MUST apply only to the instance.

Properties declared on the definition MAY be inherited by the instance. Metaschema does not define any general rules for how to handle overlapping and conflicting properties. How to handle these cases SHOULD be defined and documented for each property.

{{<callout>}}
A property is useful for annotating an instance with additional information that might describe, in a structured way, the semantics, use, nature, or other significant information related to the instance. In many cases, a property might be used to tailor generated documentation or to support an experimental, non-standardized feature in Metaschema.
{{</callout>}}

### Naming and `<use-name>`

Similar to the [`<use-name>`](/specification/syntax/definitions/#naming-and-use-name) allowed on the referenced definition, the optional `<use-name>` on a instance changes the *effective name* to use for the information element in a compositional data model.

The `<use-name>` element is optional and MAY only occur once.

By default the *effective name* of the information element in a data model is taken from the [*effective name* of the definition](/specification/syntax/definitions/#naming-and-use-name). The `<use-name>` value overrides this behavior for the instance only.

{{<callout>}}
Use of a `<use-name>` frees the module maintainer allowing them to use a sensible *effective name* for the instance in a data model.
{{</callout>}}

The first matching condition determines the *effective name* for the definition:

1. A `<use-name>` is provided on the instance. The *effective name* is the value of the `<use-name>` element on the instance.
1. A `<use-name>` is provided on the definition. The *effective name* is the value of the `<use-name>` element on the definition.
1. No `<use-name>` is provided on the definition. The *effective name* is the value of the `@name` attribute on the definition.

For example:

```xml
<define-flag name="flag-a">
  <use-name>flag-b</use-name>
</define-flag>
<define-field name="field">
  <flag ref="flag-a">
    <use-name>flag-c</use-name>
  </flag>
</define-field>
```

In the example above, the *effective name* of the definition is `flag-c`. If the `<use-name>` was omitted on the instance, the *effective name* would be `flag-b`. If the `<use-name>` was also omitted on the definition, the *effective name* would be `flag-a`.

The following content is valid to the model above.

{{< tabs JSON YAML XML >}}
{{% tab %}}
```json
{
  "field": {
    "flag-c": "value"
  }
}
```
{{% /tab %}}
{{% tab %}}
```yaml
---
field:
  flag-c: "value"
```
{{% /tab %}}
{{% tab %}}
```xml
<field flag-c="value"/>
```
{{% /tab %}}
{{% /tabs %}}

### `<remarks>`

The optional `<remarks>` element provides a place to add notes related to the use of the instance. Remarks can be used to clarify the semantics of the instance in specific conditions, or to better describe how the instance may be more fully utilized within a model. 

The `<remarks>` element is optional and may occur multiple times.

## `<flag>` Instances

A *flag instance* is used to declare that a top-level flag is part of the model of a field or assembly definition.

Attributes:

| Attribute | Data Type | Use      | Default Value |
|:---       |:---       |:---      |:---           |
| [`@deprecated`](#deprecated-version) | version ([`string`](/specification/datatypes/#string)) | optional | *(no default)* |
| [`@ref`](#ref) | [`token`](/specification/datatypes/#token) | required | *(no default)* |
| [`@required`](#required) | `yes` or `no` | optional | `no` |

Elements:

| Element | Data Type | Use      |
|:---       |:---       |:---      |
| [`<formal-name>`](#formal-name) | [`string`](/specification/datatypes/#string) | 0 or 1 |
| [`<description>`](#description) | [`markup-line`](/specification/datatypes/#markup-line) | 0 or 1 |
| [`<prop>`](#prop) | special | 0 to ∞ |
| [`<use-name>`](#naming-and-use-name) | [`token`](/specification/datatypes/#token) | 0 or 1 |
| [`<remarks>`](#remarks) | special | 0 or 1 |

The attributes and elements specific to a `<flag>` instance are described in the following subsections. The elements and attributes common to all instance types are [defined earlier](#common-instance-data) in this specification.

For example:

```xml {linenos=table,hl_lines=[4]}
<define-flag name="id"/>
<define-assembly name="computer">
  <root-name>computer</root-name>
  <flag ref="id" required="yes"/>
</define-assembly>
```

### `@required`

The optional `@required` attribute declares if the flag is required to be provided in an associated content instance.

The following behaviors are REQUIRED to be used for each value of `@required`.

- `no` - Do not require the flag to be present in content. This is the default behavior when `@required` is not declared.
- `yes` - Require the flag to be present in content. Content missing the flag and its value will be considered invalid.

## Model Instances

A *model instance* is used to declare a relationship to other information elements in an assembly definition's model.

There are 5 kinds of model instances, which can be declared as part of the assembly's model.

- `<field>` - Instantiates a globally defined [field definition](/specification/syntax/definitions/#top-level-define-field) as a model instance.
- `<define-field>` - Defines a [single use field](/specification/syntax/inline-definitions/#inline-define-field) for use as a model instance.
- `<assembly>` - Instantiates a globally defined [assembly definition](/specification/syntax/definitions/#top-level-define-assembly) as a model instance.
- `<define-assembly>` - Defines a [single use assembly](/specification/syntax/inline-definitions/#inline-define-assembly) for use as a model instance.
- `<choice>` - Declares a [mutually exclusive selection](#choice-selections) of child model instances.
- `<any>` - Declares a [placeholder for extra content](#any) that is not described by an assembly definition's model.

The `<field>`, `<define-field>`, `<assembly>`, `<define-assembly>` model instance types are considered [*named model instances*](#named-model-instances), since they all instantiate either a [top-level](/specification/syntax/definitions/) or [inline](/specification/syntax/inline-definitions/) definition that represent a named information element within an assembly's model.

The `<choice>` and `<any>` elements represent special constructs which differ significantly in their semantics from the named model instances.

These different types of model instances are discussed in the following subsections.

## Named Model Instances

The `<field>`, `<define-field>`, `<assembly>`, `<define-assembly>` model instance types are considered [*named model instances*](#named-model-instances), which instantiate a definition within an assembly's model.

The `<field>` and `<assembly>` elements are used to instantiate a referenced [top-level definition](/specification/syntax/definitions/).

The `<define-field>` and `<define-assembly>` elements are used to both declare a single use [inline definition](/specification/syntax/inline-definitions/) and also instantiate the declared definition.

### Common Named Model Instance Data

All named model instances share a common common syntax comprised of the following XML attributes and elements. This syntax builds on the [common syntax and semantics](#common-instance-data) shared by all instance types.

Attributes:

| Attribute | Data Type | Use      | Default Value |
|:---       |:---       |:---      |:---           |
| [`@deprecated`](#deprecated-version) | version ([`string`](/specification/datatypes/#string)) | optional | *(no default)* |
| [`@ref`](#ref) | [`token`](/specification/datatypes/#token) | required | *(no default)* |
| [`@max-occurs`](#ref) | [`positive-integer`](/specification/datatypes/#non-negative-integer) or `unbounded` | optional | 1 |
| [`@min-occurs`](#ref) | [`non-negative-integer`](/specification/datatypes/#non-negative-integer) | optional | 0 |

Elements:

| Element | Data Type | Use      |
|:---       |:---       |:---      |
| [`<formal-name>`](#formal-name) | [`string`](/specification/datatypes/#string) | 0 or 1 |
| [`<description>`](#description) | [`markup-line`](/specification/datatypes/#markup-line) | 0 or 1 |
| [`<prop>`](#prop) | special | 0 to ∞ |
| [`<use-name>`](#naming-and-use-name) | [`token`](/specification/datatypes/#token) | 0 or 1 |
| [`<group-as>`](#group-as) | special | 0 or 1 |
| [`<remarks>`](#remarks) | special | 0 or 1 |

The following subsections describe the XML attributes and elements that are specific to named model instances.

#### `@max-occurs`

The optional `@max-occurs` attribute declares the maximum cardinality bound for the named model instance, which defaults to `1`.

This value can be either:

- a [`positive-integer`](/specification/datatypes/#non-negative-integer) value, representing a bounded maximum cardinality; or
- the `unbounded` value, representing a maximum cardinality with no upper bound.

#### `@min-occurs`

The optional `@min-occurs` attribute declares the minimum cardinality bound for the named model instance as a [`non-negative-integer`](/specification/datatypes/#non-negative-integer) value, which defaults to `0`.

#### `<group-as>`

The `<group-as>` element is required if the `@max-occurs` attribute has a value greater than '1' or is `unbounded`. This element provides additional information about how to handle the collection of data.

The `group-as` element has the following set of attributes:


| Attribute | Data Type | Use      | Default Value |
|:---       |:---       |:---      |:---           |
| `@in-json` |  `ARRAY`, `SINGLETON_OR_ARRAY`, or `BY_KEY` | optional | `SINGLETON_OR_ARRAY` |
| `@in-xml` |  `GROUPED`, `UNGROUPED` | optional | `UNGROUPED` |
| `@name` | [`token`](/specification/datatypes/#token) | required | *(no default)* |

##### `@in-json`

The optional `@in-json` attribute controls the representation form of the instance in JSON and YAML.

When no attribute and value is provided for the `@in-json` attribute, the value MUST default to `SINGLETON_OR_ARRAY`.

One of the following behaviors MUST be used based on the provided, or default value when no attribute and value is provided.

| Value | JSON and YAML Behavior |
|:--- |:--- |
| `ARRAY` | The child value MUST be represented as an array of values. |
| `SINGLETON_OR_ARRAY` | If a single value is provided, then the child value MUST be that value; otherwise, for multiple values, the child values MUST be represented as an array of values. |
| `BY_KEY` | The child value MUST be an intermediate object based on the `<json-key>`. See [json keys](#using-json-key).

##### `@in-xml`
- `@in-xml` (type: special, use: optional, default: UNGROUPED): 

| Value | XML Behavior |
|:--- |:--- |
| GROUPED | The child elements will be placed within a wrapper element with a local name equal to the value of the `@name` attribute. Each child element's local name will be the `@name` of the referenced component. |
| UNGROUPED | In XML, the components will appear without a grouping (wrapper) element with their own effective names; the `group-as/@name is ignored. |

##### `@name`

`@name`(type: NCName, use: required): The grouping name to use in JSON, YAML and XML (when exposed). Use of this name is further clarified by the `@in-xml` attribute, when used.

#### Using `json-key`


### `<field>` Instances

- see `in-xml` in `define-field`

Used to reference a `field-definition` who's `@name` matches the value of the `@ref` attribute.

### `<define-field>` Instances

### `<assembly>` Instances

Used to reference an `assembly-definition` who's `@name` matches the value of the `@ref` attribute.

### `<define-assembly>` Instances



## `<choice>` Selections

## `<any>`
