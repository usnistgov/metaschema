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

A data type can be specified in a metaschema definition within a `define-field` or `define-flag` component definition using the `@as-type` attribute. Metaschema allows for a variety of [data types](datatypes/).

## Enumerated values

Additionally, flags may be constrained to a set of known values listed in advance.

This restriction can be either strict (values must be in the list for document validity) or loose (i.e. for documentation only, no effect in schemas).

Use the `valid-values` element to restrict the permissible values for a flag. Set its attribute `allow-other='yes'` if the list is not exclusive.

Within it `valid-values`, a `value` element's `@name` attribute assigns the permissible value, while its data content provides documentation. For example:

```xml
<define-flag name="algorithm" datatype="string">
    <formal-name>Hash algorithm</formal-name>
    <description>Method by which a hash is derived</description>
    <valid-values allow-other="yes">
      <value name="SHA-224"/>
      <value name="SHA-256"/>
      <value name="SHA-384"/>
      <value name="SHA-512"/>
      <value name="RIPEMD-160"/>
    </valid-values> ...
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

