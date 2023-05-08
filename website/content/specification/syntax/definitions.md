---
title: "Definitions"
Description: ""
weight: 20
---

A *definition* in a *Metaschema module* declares a reusable [*information element*](/specification/glossary/#information-element) within an [*information model*](/specification/glossary/#information-model).

In graph theoretical terms, a *definition* provides a declaration of an graph *node* and any associated *edges* that form a given subgraph shape.

In object-oriented terms, a *definition* provides a declaration of a *class*, along with any associated *class members*.

The following subsections describe the [common syntax](#common-definition-metadata) for all *definition* types, followed by the semantic and syntax details of each type of *definition*. The 3 types of *definitions* are [`<define-flag>`](#top-level-define-flag), [`<define-field>`](#top-level-define-field), and [`<define-assembly>`](#top-level-define-assembly).

## Common Definition Metadata

All *definition* types share a common syntax comprised of the following XML attributes and elements.

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

The optional `@deprecated` attribute communicates that use of the given *information element* implemented by the *definition* is intended to be discontinued, starting with the *information model* revision indicated by the attribute's value.

This *information model* revision is a reference to the [`<schema-version>`](/specification/syntax/module/#schema-version) declared in the *Metaschema module* *header*.

{{<callout>}}
Declaring the `@deprecated` attribute communicates to content creators that all use of the annotated *information element* is to be avoided. 

This annotation can be used in documentation generation and in Metaschema-aware tools that provide context around use of the definition.
{{</callout>}}

The following example illustrates deprecating the flag named `flag-name` starting with the *information model* semantic version `1.1.0`.

```xml {linenos=table,hl_lines=[3]}
<define-flag
  name="flag-name"
  deprecated="1.1.0"/>
```

### `@name`

The `@name` attribute provides the definition's identifier, which can be used in other parts of a module, or in an importing *Metaschema module*, to reference the definition.

**Note:** The names of flags, fields, and assemblies are expected to be maintained as separate identifier sets. This allows a *flag definition*, a *field definition*, and an *assembly definition* to each have the same name in a given *Metaschema module*.

### `@scope`

The optional `@scope` attribute is used to communicate the intended visibility of the definition when accessed by another module through an [`<import>`](/specification/syntax/module/#import) element.

- `global` - Indicates that the definition MUST be made available for reference within importing modules. Definitions in the same and importing modules can reference it. This is the default behavior when `@scope` is not declared.
- `local` - Indicates that the definition MUST NOT be made available for reference within importing modules. Only definitions in the same module can reference it.

Note: References to definitions in the same module are always possible regardless of scope.

The scope of a definition affects how the [definition's name is resolved](/specification/syntax/module/#definition-name-resolution).

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

The optional [`<description>`](/specification/syntax/instances/#description) element of the child [`<flag>`](/specification/syntax/instances/#flag-instances), [`<field>`](/specification/syntax/instances/#field-instances) and [`<assembly>`](/specification/syntax/instances/#assembly-instances) elements can be used to provide a different description for when the referenced definition is used in a more specialized way for a given instance.

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
A property is useful for annotating a definition with additional information that might describe, in a structured way, the semantics, use, nature, or other significant information related to the definition. In many cases, a property might be used to tailor generated documentation or to support an experimental, non-standardized feature in Metaschema.
{{</callout>}}

### Naming and `<use-name>`

The optional `<use-name>` changes the *effective name* to use for the information element in a data model.

The `<use-name>` element is optional and MAY only occur once.

By default the *effective name* of the information element in a data model is taken from the `@name` attribute. The `<use-name>` value overrides this behavior.

{{<callout>}}
Use of a `<use-name>` frees the module maintainer allowing them to use a sensible `@name` for the definition, while providing control over the name used in an instance of the definition in a data model.
{{</callout>}}

The first matching condition determines the *effective name* for the definition:

1. A `<use-name>` is provided on the definition. The *effective name* is the value of the `<use-name>` element on the definition.
1. No `<use-name>` is provided on the definition. The *effective name* is the value of the `@name` attribute on the definition.

For example:

```xml {linenos=table,hl_lines=[2]}
<define-flag name="flag-a">
  <use-name>flag-b</use-name>
</define-flag>
```

In the example above, the *effective name* of the definition is `flag-b`. If the `<use-name>` was omitted, the *effective name* would be `flag-a`.

The following content is valid to the model above.

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

The optional `<example>` element is used to provide inline examples, which illustrate the use of the information element being defined. Examples are provided in XML, which can then be automatically converted into other formats.

The `example` element is optional and may occur multiple times.

## top-level `<define-flag>`

A flag definition, represented by the `<define-flag>` element, is used to declare a reusable [flag](/specification/glossary/#flag) within a Metaschema module.

A flag definition provides the means to implement a simple, named [*information element*](/specification/glossary/#information-element) with a value.

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
| [`<constraint>`](/specification/syntax/constraints/#define-flag-constraints) | special | 0 or 1 |
| [`<remarks>`](#remarks) | special | 0 or 1 |
| [`<example>`](#example) | special | 0 to ∞ |

The attributes and elements specific to the `<define-flag>` are described in the following subsections. The elements and attributes common to all definitions are [defined earlier](#common-definition-metadata) in this specification.

### `@as-type`

The `@as-type` attribute declares the type of the flag's value. If not provided, the default value is `string`.

The `@as-type` attribute must have a value that corresponds to one of the [simple data types](/specification/datatypes/#simple-data-types). As a result, markup in flag values is not permitted.

### `@default`

The `@default` attribute specifies the default value for the flag. When a flag is specified as an optional child of a `<define-field>` or `<define-assembly>`, this value should be considered set for a content instance if the flag is omitted in that instance.

### `<constraint>`

Constraints are [covered later](/specification/syntax/constraints/#define-flag-constraints) in this specification.

## top-level `<define-field>`

A field definition, represented by the `<define-field>` element, is used to declare a reusable [field](/specification/glossary/#field) within a metaschema module.

A field definition provides the means to implement a complex named [*information element*](/specification/glossary/#information-element) with a value and an optional set of [*flag*](/specification/syntax/instances/#flag-instances) instances.

{{<callout>}}
A field is an edge node in a Metaschema-based model. Fields are typically used to provide supporting information for a containing [*assembly*](/specification/syntax/definitions/#top-level-define-assembly). The flag instances, typically characterize or identify the fields value. With optional use of flags, a field can be more or less complex, depending on the modeling need.
{{</callout>}}

The field's value is strongly typed using one of the built in [simple data types](/specification/datatypes/#simple-data-types) or [markup data types](/specification/datatypes/#markup-data-types) identified by the `@as-type` attribute.identified by the `@as-type` attribute.


Attributes:

| Attribute | Data Type | Use      | Default Value |
|:---       |:---       |:---      |:---           |
| [`@as-type`](#as-type) | [`token`](/specification/datatypes/#token) | optional | [`string`](/specification/datatypes/#string) |
| [`@collapsible`](#collapsible) | `yes` or `no` | optional | `no` |
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
| [`json-key`](#json-key) | special | 0 or 1 |
| [`json-value-key`](#json-value-key) or<br/>[`json-value-key-flag`](#json-value-key-flag) | special | 0 or 1 |
| [`flag`](#flag-instance-children) or<br/>[`define-flag`](#define-flag-inline-definition) | special | 0 or ∞ |
| [`<constraint>`](/specification/syntax/constraints/#define-flag-constraints) | special | 0 or 1 |
| [`<remarks>`](#remarks) | special | 0 or 1 |
| [`<example>`](#example) | special | 0 to ∞ |

The attributes and elements specific to the `<define-field>` are described in the following subsections. The elements and attributes common to all definitions are [defined earlier](#common-definition-metadata) in this specification.

### `@as-type`

The optional `@as-type` attribute declares the type of the field's value. If not provided, the default type is `string`.

The `@as-type` attribute must have a value that corresponds to one of the built in [simple data types](/specification/datatypes/#simple-data-types) or [markup data types](/specification/datatypes/#markup-data-types).

### `@collapsible`

The optional `@collapsible` attribute controls a JSON and YAML specific behavior that allows multiple fields having the same set of flag values to be collapsed into a single object with a value property that is an array of values. This makes JSON and YAML formatted data more concise.

If `@collapsible` is not specified, the default value is `no`.

The following behaviors are REQUIRED to be used for each value of `@collapsible`.

- `no` - Do not collapse. This is the default behavior when `@collapsible` is not declared.
- `yes` - Collapse values that have flags with equivalent values.

A flag value is equivalent if the value, or default value if not provided, is an exact match. A non-default flag is considered to have no value and will match the same flag on another instance that has no value.

Field instances whose flags all match are considered to be in the same *collapse group*. Collapsing works by combining the values for all the instances in the the same *collapse group*.

When collapsing values in the same *collapse group* the ordering of the field values MUST be in the same order as their original field instances. The ordering of all *collapse groups* MUST follow the ordering of the first field instance added to the collapse group.

For example, given field instances in the sequence `{ A, B, C, D }`, if `{ A, C }` are a collapse group, and `{ B, D }` are a different collapse group. Then `{ A, C }` would be ordered before `{ B, D }`, since `A` is ordered before `B`.

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

The XML example above illustrates 2 fields, on lines 2 and 4, which will be collapsed together into the same *collapse group* in the resulting JSON and YAML conversion. This is because they have the same flag values: `a` for the flag named `flag-default-a`, `required 1` for the flag named `flag-required`, and no value for the flag named `flag-optional`. The field on line 3 would be in a second *collapse group*.

When converted to JSON or YAML, these fields will be collapsed based on their collapse grouping, resulting in the following content instances.

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

In the example above, the fields from the first *collapse group* would appear before the fields from the second *collapse group*. This is because the resulting JSON and YAML instance has no way of indicating the original sequencing, so it must rely on the sequencing provided by the ordering of the *collapse groups* and the values within each group.

### `@default`

The `@default` attribute specifies the default value for the field. When a flag is specified as an optional child of a `<define-field>` or `<define-assembly>`, this value should be considered set for a content instance if the field is omitted in that instance.

A `@default`value MUST only be provided when the data type specified by the `@as-type` is a [simple data types](/specification/datatypes/#simple-data-types). Specifying a `@default` value for a [markup data type](/specification/datatypes/#markup-data-types) MUST result in a Metaschema format error.

Implementations when writing content instances MAY omit writing default values in order to produce a more concise expression of the content.

### `<flag>` Instance Children

A field may have zero or more flag instance children.

See [flag instances](/specification/syntax/instances/#flag-instances)

### `<define-flag>` Inline Definition

See [inline `<define-flag>`](/specification/syntax/inline-definitions/#inline-define-flag).

### `<json-key>`

TODO: Specify this. Note assembly points to this section.


The property names of this intermediate object will be the value of the flag as specified by the `@json-key` attribute on the definition referenced by the `@ref` on the instance. The value of the intermediate object property will be an object or value , with property names equal to the value of the referenced `define-field` or `define-assembly` component's flag as specified by the `@json-key` attribute on that component. See [`@json-key`](#json-key).

### JSON Value Keys

TODO: discuss use only when flags may be present.

In XML, the value of a field appears as the textual data content of the field's element. In JSON and YAML, a property name is needed for the value. The `<json-value-key>` and `<json-value-key-flag>` elements provide a means to control the behavior of how this value is represented.

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

## top-level `<define-assembly>`

An assembly definition, represented by the `<define-assembly>` element, is used to declare a reusable [assembly](/specification/glossary/#assembly) within a Metaschema module.

An assembly definition provides the means to implement a complex, composite, named [*information element*](/specification/glossary/#information-element) that collects and organizes other information elements, with no value of its own. 

An assembly definition consists of an optional set of [*flags*](/specification/syntax/instances/#flag-instances) and an optional sequence of [model instances](/specification/syntax/instances/#model-instances).

{{<callout>}}
An assembly is a compositional node in a Metaschema-based model. Assemblies are typically used to represent complex data objects, combining multiple information elements together into a composite object representing a larger semantic concept. An assembly's flag instances will typically characterize or identify this composite object, while its model instances represent the information being composed.
{{</callout>}}

An assembly is similar to a field, except it contains structured content (objects or elements), not text or unstructured "rich text". The contents permitted in a particular (type of) assembly are indicated in its `model` element.

An assembly definition has no value, so the `@as-type` and `@default` attributes are not permitted.

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
| [`<use-name>`](#naming-and-use-name) or<br/>[`<root-name>`](#root-name)  | [`token`](/specification/datatypes/#token) | 0 or 1 |
| [`json-key`](#json-key) | special | 0 or 1 |
| [`json-value-key`](#json-value-key) or<br/>[`json-value-key-flag`](#json-value-key-flag) | special | 0 or 1 |
| [`flag`](#flag-instance-children-1) or<br/>[`define-flag`](#define-flag-inline-definition-1) | special | 0 or ∞ |
| [`<model>`](#model) | special | 0 or 1 |
| [`<constraint>`](/specification/syntax/constraints/#define-flag-constraints) | special | 0 or 1 |
| [`<remarks>`](#remarks) | special | 0 or 1 |
| [`<example>`](#example) | special | 0 to ∞ |

The attributes and elements specific to the `<define-assembly>` are described in the following subsections. The elements and attributes common to all definitions are [defined earlier](#common-definition-metadata) in this specification.

### `<root-name>`

Declares the name to use when using the assembly as a top-level information element. Indicates that the assembly is an allowable root.

For example:

```xml {linenos=table,hl_lines=[2]}
<define-assembly name="assembly">
  <root-name>assembly</root-name>
</define-assembly>
```

Would allow the following content in JSON, YAML, and XML.

{{< tabs JSON YAML XML >}}
{{% tab %}}
```json {linenos=table,hl_lines=[2]}
{
  "assembly": { }
}
```
{{% /tab %}}
{{% tab %}}
```yaml {linenos=table,hl_lines=[2]}
---
assembly: -
```
{{% /tab %}}
{{% tab %}}
```xml {linenos=table,hl_lines=[1]}
<assembly/>
```
{{% /tab %}}
{{% /tabs %}}

### `<flag>` Instance Children

An assembly may have zero or more flag instance children.

See [flag instances](/specification/syntax/instances/#flag-instances).

### `<define-flag>` Inline Definition

An assembly may have zero or more flag instance children, which can be inline definitions.

See [inline `<define-flag>`](/specification/syntax/inline-definitions/#inline-define-flag).

### `<model>`

The `<model>` element is used to establish the assembly's model. To do this, zero or more [model instances](/specification/syntax/instances/#model-instances) are declared.
