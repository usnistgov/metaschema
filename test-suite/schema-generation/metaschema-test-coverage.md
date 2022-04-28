
## What we are testing explicitly

Following checklist applies to work in the `schema-generation` folder.

### Flag definitions

### Datatypes

### Allowed values

### Markdown and character representation

A full suite of markdown conversion tests is probably in order.

### Grouping

JSON behaviors but not yet much on XML behaviors. Could use more thorough coverage.

## ALL FEATURES

Checked if started - may be partial coverage

- [x] `METASCHEMA`: Root element of an OSCAL Metaschema metaschema. Defines a family of data structures.
- [x] `METASCHEMA/@root`
- [ ] `define-assembly`: An element with structured element content in XML; in JSON, an object with properties.
- [x] `define-assembly/@name`
- [x] `model`
- [x] `define-field`: In JSON, an object with a nominal string value (potentially with internal inline - not fully structured - markup). In XML, an element with string or mixed content.
- [x] `define-field/@as-type`
  - [ ] `define-field/@collapsible`
- [x] `define-field/@name`
- [x] `json-key`: In the XML, produces an attribute with the given name, whose value is used as a key value (aka object property name) in the JSON, enabling objects to be 'lifted' out of arrays when such values are distinct. Implies that siblings will never share values. Overloading with datatype 'ID' and naming the key 'id' is legitimate and useful. Even without ID validation, uniqueness of these values among siblings is validable.
- [x] `json-key/@flag-name`
- [x] `group-as`: When a given referenced field or assembly must be wrapped in an outer grouping, these settings apply, including a name for the group, and how to express the grouping in the respective formats. Not necessary when a field or assembly has max-occurs='1'
- [x] `group-as/@name`
- [x] `group-as/@in-json`: How to represent a grouping in JSON
  - [ ] `group-as/@in-xml`: Whether to represent a grouping explicitly in XML
- [x] `json-value-key`: Used inside a field definition, designates a flag to be used as a label (key) to be used for the field value in the JSON on the field being defined. When a flag-name is provided, indicates that the value of the field is to be labeled in the JSON with the value of the flag.
- [x] `json-value-key/@flag-name`
- [x] `define-flag`: A data point to be expressed as an attribute in the XML or a name/value pair in the JSON. A flag may also be defined implicitly with the assembly or field to which it applies.
- [x] `define-flag/@name`
- [x] `define-flag/@as-type`
- [x] `formal-name`: A formal name for the data construct, to be presented in documentation. It is permissible for a formal name to provide nothing but an expanson of what is already given by a tag (for example, this element could have formal name "Formal name") but it should at the very least confirm the intended semantics for the user, not confuse them.
- [x] `namespace`: The XML namespace governing the names of elements in XML documents, which expect to be conformant to the schemas expressed by this metaschema. By using this namespace, documents and document fragments used in mixed-format environments may be distinguished from neighbor XML formats using other namespaces. NB this is only for the convenience of XML users; this value is not reflected in OSCAL JSON, and OSCAL applications should not rely on namespaces alone to disambiguate or resolve semantics.
- [x] `description`: A short description of the data construct, to be inserted into documentation. Unlike 'formal-name' this should not simply repeat what is readily discernible from a tag (element name or JSON label), but say a little more about it.
- [x] `remarks`: Any explanatory or helpful information to be provided in the documentation of an assembly, field or flag.
  - [ ] `remarks/@class`: Mark as 'XML' for XML-only or 'JSON' for JSON-only remarks.
- [x] `schema-name`: The name of the information model to be represented by derived schemas.
- [x] `schema-version`: The version of the information model to be represented by derived schemas.
- [x] `short-name`: A short (code) name to be used for the metaschema, for example as a constituent of names assigned to derived artifacts such as schemas and conversion utilities.
- [ ] `import`: To import a set of declarations from an out-of-line schema, supporting reuse of common information structures.
  - [ ] `import/@href`: A relative or absolute URI for retrieving an out-of-line metaschema module.
- [x] `assembly`: Referencing an assembly definition to include an assembly or assemblies of a given type in a model.
- [x] `assembly/@ref`
  - [ ] `assembly/@min-occurs`: Minimum occurrence of assemblies within a valid model. The default value is 0, for an optional occurrence.
  - [ ] `assembly/@max-occurs`: Maximum occurrence of assemblies within a valid model. The default value is 1, for a single occurrence. 'unbounded' permits any number of assemblies of the designated type.
- [x] `field`: Referencing a field definition to include a field or fields of a given type in a model.
- [x] `field/@ref`
  - [ ] `field/@min-occurs`: Minimum occurrence of assemblies within a valid model. The default value is 0, for an optional occurrence.
  - [ ] `field/@max-occurs`: Maximum occurrence of assemblies within a valid model. The default value is 1, for a single occurrence. 'unbounded' permits any number of assemblies of the designated type.
  - [ ] `field/@in-xml`: A field with assigned datatype 'markup-multiline' may be designated for representation with or without a containing (wrapper) element in XML.
- [x] `allowed-values`: With in-xml='UNWRAPPED', a field contents will be represented in the XML with no wrapper. The field itself will be implicit, to be inferred from the presence of the contents. Among sibling fields in a given model, only one of them may be designated as UNWRAPPED.
- [x] `enum`: An enumerated value for a flag or field. The value is indicated by the 'value' attribute while the element contents describe the intended semantics for documentation.
- [x] `enum/@value`: A value recognized for a flag or field.
- [x] `flag`
- [x] `flag/@as-type`
- [x] `flag/@name`
- [x] `flag/@ref`
- [x] `flag/@required`
- [ ] `choice`: Within a model, indicates that only one of a set of fields or assemblies, referenced in the choice, may occur in valid instances.
- [ ] `any`: Within a model, a foreign element may be permitted here..
- [ ] `example`
  - [ ] `example/@href`
  - [ ] `example/@path`
- [ ] `augment`: To augment a definition with localized documentation, when a definition from a separate metaschema module is used.
  - [ ] `augment/@name`
