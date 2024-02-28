---
title: "Metapath Expression Language"
description: ""
weight: 60
---

# Metapath Expression Language

Metaschema includes support for an expression language called *Metapath*, which allows for selecting and evaluating Metaschema modules and data instances that conform to a Metaschema module. A Metapath can be used to query all Metaschema supported formats (i.e., JSON, YAML, XML) using a common, Metaschema module-bound syntax. This means a Metapth can be used to query the same data regardless of the underlying format used, as long as that data is bound to a Metaschema module. This provides consistent portability of Metapath expressions against multiple serialization forms for the same data set.

Metapath is a customization of the [XML Path Language (XPath) 3.1](https://www.w3.org/TR/2017/REC-xpath-31-20170321/), which has been adjusted to work with a Metaschema module based model. This means the underlying [XML Data model](https://www.w3.org/TR/xpath-datamodel-31/) used by XPath, which exposes element and attribute nodes, is replaced with the Metaschema data model, which exposes flag, field, and assembly nodes.

XPath was chosen as a basis for Metapath because it provides for both *selection* of nodes and logical *evaluation* of node values, the later of which is required for supporting Metaschema module [constraints](/specification/syntax/constraints). Other path languages (e.g., [JSON Path](https://goessner.net/articles/JsonPath/), [JSON Pointer](https://www.rfc-editor.org/rfc/rfc6901.html)) were not chosen, due to limitations in *evaluation* capabilities and because their syntax was specific to JSON.

Note: Not all XPath features are supported by Metapath, the specifics of which will be documented in an updated version of this page in the future.
