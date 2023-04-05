---
title: "Mapping to XML, JSON, and YAML"
Description: "Discussion of how Metaschema primatives map to XML, JSON, and YAML primatives"
weight: 90
---

XML, JSON, and YAML each use specialized terminology and format primatives. As a notation for an object-based data, YAML is fairly similar to JSON, while XML is quite different to the other two. While all data format describe tree structures (directed graphs), each format (with its implicit data model) has its peculiar design, which requires specification in detail.

For example, a data point represented as an attribute on an element in XML, for example, might be a string property on a data object in JSON. The metaschema moderates this distinction by providing rules regarding its own semantic constructs and how they are to be represented in the target format. As a result, a mapping between JSON and XML concepts is implicitly available through the corresponding metaschema.

Within Metaschema-based models, all constructs are optional unless marked otherwise.

| Metaschema | XML | JSON and YAML |
|------------------|-----|------|
| Assembly | An element with element content |  An object, either a property or a member of an array property |
| Field (with no flags) | A single element with text content | String property |
| Field with one or more flags | An element with text content, flags as attributes |   An object property with a designated property for its nominal string value as well as properties for its flags |
| Flag | Attribute | String property |
| Flag with designated data type | Attribute with lexical constraints per type | String property with lexical constraints per type, or typed property such as `number` or URI (per type) | 
| Field `as-type='simple-markup'`, no flags permitted | An element permitting mixed content inline | String property or map with string property, parseable as markdown (line only) |
| Field `as='complex-markup'`, flag(s) permitted | An element permitting mixed content inline | Object property with `RICHTEXT` String property or object with string property, parseable as markdown (full blocks) |

