---
title: "Getting Started with Metaschema"
Description: ""
heading: Getting Started with Metaschema
toc:
  enabled: true
---

## Understanding the Domain and Designing the Model

Metaschema is a framework for consistently organizing information into machine-readable data formats. For example, if we want to build tools to exchange information about computers, how do we represent a computer in a data format? How do we design it to be consistent and reusable across different software? How do we benefit from the right amount of structured information about computers in that format?

To start organizing this information consistently, we need to consider our mental model of what a computer is. We have to think of the different parts of a computer, sub-parts, and how to compose those parts into a whole. Let's consider a computer such as one visualized below.

!["Exploded view of a personal computer, unlabeled" from Wikipedia, as created by Gustavb, and published under the Creative Commons Attribution-Share Alike 3.0 Unported license](/img/computer.svg)

Source: [Wikipedia](https://commons.wikimedia.org/wiki/File:Personal_computer,_exploded_5,_unlabeled.svg)

In Metaschema terms, this design process is making an [information model](/specification/concepts/terminology/#information-model) for a [managed object](/specification/concepts/terminology/#managed-object), the computer, into [a data model](/specification/concepts/terminology/#data-model) within the [domain](/specification/concepts/terminology/#domain) of computing. And once we understand the required information structure for the computer in this domain, how do we specify a model in Metaschema and what are the benefits?

## Metaschema Concepts

Metaschema helps developers to define models once, in a Metaschema definition. The definition specifies the model of information for the managed object in supported machine-readable data formats. A document in such a format is an instance of that definition. A schema can be used to check the instance is well-formed and valid against the definition's specification. Such schemas can be derived deterministically and programmatically from a Metaschema definition (or "metaschema").

{{<mermaid>}}

erDiagram

  "Metaschema definition" }|..|{ "instance" : "must specify model of"
  "Metaschema tool" }|..|{ "Metaschema definition" : "must parse"
  "Metaschema tool" }|..|{ "instance" : "can parse"
  "Metaschema tool" }|..|{ "schema" : "can generate"
  "schema" }|..|{ "instance" : "must validate"

{{</mermaid>}}

## Basic Modeling and Basic Metaschema Defintions

We start with an empty Metaschema definition, like the one below, saved in a file called `computer_metaschema.xml`.

```xml
<?xml version="1.0" encoding="UTF-8"?>
<METASCHEMA xmlns="http://csrc.nist.gov/ns/oscal/metaschema/1.0">
</METASCHEMA>
```

Metschema definitions, like the one above, are in XML. A definition begins and ends with capitalized `METASCHEMA` tags. This definition is an empty file, and it is not a valid, well-formed defintion. It is simply the base we will start with. Within those beginning and ending tags, we want to add useful metadata for both developers and Metaschema-enabled tools to consume this definition, as below.

```xml
<?xml version="1.0" encoding="UTF-8"?>
<METASCHEMA xmlns="http://csrc.nist.gov/ns/oscal/metaschema/1.0">
  <schema-name>Computer Model</schema-name>
  <schema-version>0.0.1</schema-version>
  <short-name>computer</short-name>
  <namespace>http://example.com/ns/computer</namespace>
  <json-base-uri>http://example.com/ns/computer</json-base-uri>
  <define-assembly name="computer"/>
</METASCHEMA>
```

The metadata above provides useful information to us Metaschema developers and our tools that parse Metaschema definitions. The `schema-name` is the long-form, descriptive name of the computer model. The `schema-version` is to give the model itself a version number, for either developers or their tools to use. The `short-name` is the shortened form of the `schema-name`. Normally, Metaschema-enabled tools will parse or generate data with this name `computer`, not `Computer Model`. The `namespace` is a URI used to identify the model and its parts as belonging to a single scope for XML data and schemas. Similarly, the `json-base-uri` serves a similar purpose for JSON data and schemas.

It is important to note this definition is just a starting point. This definition is the most minimally viable definition possible: it is well-formed and valid against [the XML Schema for the Metaschema syntax itself](), but our Metaschema-enabled tools should consider this an empty definition. We have not yet declared a `root-name` and there is no data model yet, so let's start one. We will begin by designing a computer object to have just an identifier. 

We will now add to the [`assembly`](/specification/concepts/terminology/#assembly) for a computer itself and give it an identifier `flag`.

```xml
<?xml version="1.0" encoding="UTF-8"?>
<METASCHEMA xmlns="http://csrc.nist.gov/ns/oscal/metaschema/1.0">
  <schema-name>Computer Model</schema-name>
  <schema-version>0.0.2</schema-version>
  <short-name>computer</short-name>
  <namespace>http://example.com/ns/computer</namespace>
  <json-base-uri>http://example.com/ns/computer</json-base-uri>
  <define-assembly name="computer">
    <formal-name>Computer Assembly</formal-name>
    <description>A container object for a computer, its parts, and its sub-parts.</description>
    <root-name>computer</root-name>
    <define-flag name="id" as-type="string" required="yes">
        <formal-name>Computer Identifier</formal-name>
        <description>An identifier for classifying a unique make and model of computer.</description>
    </define-flag>
  </define-assembly>
</METASCHEMA>
```

With the definition of the first `assembly` our Metaschema definition takes shape. Firstly, we now add the `root-name` element to identify for Metaschema-enabled tools this `assembly`, whether there are one or more top-level ones defined, is the root element of our data models. This will come in handy later. In the `assembly` declaration, we have defined a `computer` that must have an `id`, the value of which must be `string`. With Metaschema-enabled tooling, we can have information about a computer like below in their respective JSON, XML, and YAML data formats.

An instance for the model above is below in JSON, XML, and YAML data formats.

{{< tabs JSON XML YAML >}}
{{% tab %}}
{{< highlight json >}}
{
  "computer": {
    "id": "awesomepc1"
  }
}
{{< /highlight >}}
{{% /tab %}}
{{% tab %}}
{{< highlight xml >}}
<?xml version="1.0" encoding="UTF-8"?>
<computer xmlns="http://example.com/ns/computer" id="awesomepc1"/>
{{< /highlight >}}
{{% /tab %}}
{{% tab %}}
{{< highlight yaml >}}
---
computer:
  id: awesomepc1
{{< /highlight >}}
{{% /tab %}}
{{< /tabs >}}


At this point, we have our first functional and complete Metaschema definition. When we write Metaschema-enabled tools, they ought to be able to parse this definition and use it to parse one or more instances in JSON, XML, or YAML, as specified in that definition. All three instances above are to be equivalent.

## Assemblies, Fields, and Flags

It is important to have a computer with an identifier, but our stakeholders want far more. We can add `field`s and `flag`s for simple key-value properties on a computer and assemblies for more complex objects. We need to continue our design work to understand and specify our information and data models with Metaschema, so we return to modeling once again.

Let's return to the diagram of the computer before, but now consider how we model the parts of a computer, the sub-parts, and their relationships. Our stakeholders provided us this diagram, and these are the key data points they need our software to process and store.

!["Exploded view of a personal computer" from Wikipedia, as created by Gustavb, and published under the Creative Commons Attribution-Share Alike 3.0 Unported license](/img/computer_numbered.svg)

Source: [Wikipedia](https://upload.wikimedia.org/wikipedia/commons/1/13/Personal_computer%2C_exploded_4.svg)

Below are the parts and sub-parts we want in our information model of a computer in that diagram that our stakeholders require.

1. Display
1. Motherboard
1. CPU
1. ATA socket
1. Memory
1. Expansion card(s)
1. CD/DVD drive
1. Power supply unit
1. Hard disk
1. Keyboard
1. Mouse

When we consider the parts and sub-parts, we recognize some hierarchical relationships that we arrange into outline form.

- Display
- Motherboard
  - CPU
  - ATA socket
  - Memory
  - Expansion cards
- CD/DVD drive
- Power supply unit
- Hard disk
- Keyboard
- Mouse

After discussion with stakeholders of these new data formats, the different stakeholders agree we need to structure additional information about computers, parts, and sub-parts as well.

- **Computer**
  - **Vendor information:** incorporation name; office address; product website
  - **Display:** product name; display type
  - **Motherboard**: product name; type
    - **CPU:** product name; architecture; clock speed
    - **ATA socket:** product name; ATA socket type
    - **Memory:** product name; size in bytes
    - **Expansion cards:** product name; type
  - **CD/DVD drive:** product name; type
  - **Power supply unit:** product name; wattage; type
  - **Hard disk:** product name; capacity; type
  - **Keyboard:** product name; type
  - **Mouse:** product name; type

With this outline, we acknowledge there is a hierarchy, and it is important to how we design the managed objects of a computer, especially the motherboard. How can we use Metaschema to encode these hierarchies across data formats? We use assemblies, and within those assemblies, fields and flags in a particular order.

With an `assembly`, we can specify a complex named object, not just a simple key-value pair. We can annotate this complex named object itself with `flag`s. The object we specify in the assembly can have optional key-values, which we define with `field`s. With these Metaschema concepts, we can enhance the `computer` model to include an `assembly` for a motherboard and include its sub-parts like so.

```xml
<?xml version="1.0" encoding="UTF-8"?>
<METASCHEMA xmlns="http://csrc.nist.gov/ns/oscal/metaschema/1.0">
  <schema-name>Computer Model</schema-name>
  <schema-version>0.0.3</schema-version>
  <short-name>computer</short-name>
  <namespace>http://example.com/ns/computer</namespace>
  <json-base-uri>http://example.com/ns/computer</json-base-uri>
  <define-assembly name="computer">
    <formal-name>Computer Assembly</formal-name>
    <description>A container object for a computer, its parts, and its sub-parts.</description>
    <root-name>computer</root-name>
    <define-flag name="id" as-type="string" required="yes">
        <formal-name>Computer Identifier</formal-name>
        <description>An identifier for classifying a unique make and model of computer.</description>
    </define-flag>
    <model>
      <define-assembly name="vendor">
        <formal-name>Vendor Information</formal-name>
        <description>Information about a vendor of a computer part.</description>
        <define-flag name="id" as-type="string" required="yes">
          <formal-name>Vendor Identifier</formal-name>
          <description>An identifier for classifying a unique computer parts vendor.</description>
        </define-flag>
        <model>
          <define-field name="name" min-occurs="1" max-occurs="1">
            <formal-name>Vendor Name</formal-name>
            <description>The registered company name of the vendor.</description>
          </define-field>
          <define-field name="address" min-occurs="1" max-occurs="1">
            <formal-name>Vendor Address</formal-name>
            <description>The physical address of an office location for the vendor.</description>
          </define-field>
          <define-field name="website" min-occurs="1" max-occurs="1">
            <formal-name>Vendor Website</formal-name>
            <description>A public website made by the vendor documenting their parts as used in the computer.</description>
          </define-field>
        </model>
      </define-assembly>
      <define-assembly name="motherboard">
        <formal-name>Motherboard Assembly</formal-name>
        <description>A container object for a motherboard in a computer and its sub-parts.</description>
        <model>
          <define-field name="product-name" as-type="string" min-occurs="1" max-occurs="1">
            <formal-name>Product Name</formal-name>
            <description>The product name from the vendor of the computer part.</description>
          </define-field>
          <define-field name="type" as-type="string" min-occurs="1" max-occurs="1">
            <formal-name>Motherboard Type</formal-name>
            <description>The type motherboard layout, <code>at</code>, <code>atx</code>, <code>mini-itx</code> or an alternative.</description>
          </define-field>
          <define-assembly name="cpu">
            <formal-name>Motherboard Central Processing Unit (CPU)</formal-name>
            <description>The model number of the CPU on the motherboard of a computer.</description>
            <model>
              <define-field name="product-name" as-type="string" min-occurs="1" max-occurs="1">
                <formal-name>Product Name</formal-name>
                <description>The product name from the vendor of the computer part.</description>
              </define-field>
              <define-field name="architecture" as-type="string" min-occurs="1" max-occurs="1">
                <formal-name>CPU Architecture</formal-name>
                <description>The Instruction Set Architecture (ISA) of the processor, <code>x86</code>, <code>x86-64</code>, <code>arm</code>, or an alternative.</description>
              </define-field>
              <define-field name="speed" as-type="string" min-occurs="1" max-occurs="1">
                <formal-name>CPU Speed</formal-name>
                <description>The clock speed of the CPU in megahertz or gigahertz.</description>
              </define-field>
            </model>
          </define-assembly>
          <define-assembly name="ata-socket">
            <formal-name>Motherboard Advanced Technology Attachment (ATA) Socket</formal-name>
            <description>The model number of ATA socket on the motherboard of a computer. There will only be one socket on any motherboard.</description>
            <model>
              <define-field name="product-name" as-type="string" min-occurs="1" max-occurs="1">
                <formal-name>Product Name</formal-name>
                <description>The product name from the vendor of the computer part.</description>
              </define-field>
              <define-field name="type" as-type="string" min-occurs="1" max-occurs="1">
                <formal-name>ATA Socket Type</formal-name>
                <description>The type of ATA socket on the motherboard , <code>pata</code> (parallel ATA), <code>sata</code> (Serial ATA), or an alternative.</description>
              </define-field>
            </model>
          </define-assembly>
          <define-assembly name="memory" min-occurs="1" max-occurs="unbounded">
            <formal-name>Motherboard Random Access Memory (RAM) Module(s)</formal-name>
            <description>Random access memory hardware installed on the motherboard of a computer.</description>
            <group-as name="memory-modules" in-json="ARRAY"/>
            <model>
              <define-field name="product-name" as-type="string" min-occurs="1" max-occurs="1">
                <formal-name>Product Name</formal-name>
                <description>The product name from the vendor of the computer part.</description>
              </define-field>
              <define-field name="byte-size" as-type="positiveInteger" min-occurs="1" max-occurs="1">
                <formal-name>Memory Module Size</formal-name>
                <description>Size of the memory module in binary, not SI base-10 units, meaning a kilobyte is 1024 bytes, not 1000 bytes.</description>
              </define-field>
            </model>
          </define-assembly>
          <define-assembly name="expansion-card" min-occurs="0" max-occurs="unbounded">
            <formal-name>Motherboard Expansion Card</formal-name>
            <description>The model number of an expansion card connected to the motherboard of a computer.</description>
            <group-as name="expansion-cards" in-json="ARRAY"/>
            <model>
              <define-field name="product-name" as-type="string" min-occurs="1" max-occurs="1">
                <formal-name>Product Name</formal-name>
                <description>The product name from the vendor of the computer part.</description>
              </define-field>
              <define-field name="type" as-type="string" min-occurs="1" max-occurs="1">
                <formal-name>Expansion Card Type</formal-name>
                <description>The type of expansion card on a motherboard of a computer, such as <code>pci</code> (PCI, e.g. Peripheral Component Interconnect), <code>pcie</code> (PCI Express), or an alternative.</description>
              </define-field>
            </model>
          </define-assembly>
        </model>
      </define-assembly>
    </model>
  </define-assembly>
</METASCHEMA>
```

We now have a nested motherboard `assembly` in a computer `assembly` with assorted `flag`s and `field`s to present the important hierarchy of information in the motherboard. With a more detailed model, we can have our Metaschema-enabled tools parse or generate instances.

An instance for the model above is below in JSON, XML, and YAML data formats.

{{< tabs JSON XML YAML >}}
{{% tab %}}
{{< highlight json >}}
{
  "computer": {
    "id": "awesomepc1",
    "vendor": {
      "id": "vendor1",
      "name": "AwesomeComp Incorportated",
      "address": "1000 K Street NW Washington, DC 20001",
      "website": "https://example.com/awesomecomp/awesomepc1/details"
    },
    "motherboard": {
      "product-name": "ISA Corp Magestic Model M-Ultra Motherboard",
      "type": "atx",
      "cpu": {
        "product-name": "ISA Corp Superchip Model 1 4-core Processor",
        "architecture": "x86-64",
        "speed": "4.7 gigahertz"
      },
      "ata-socket": {
        "product-name": "ISA Corp SuperSATA Model 2 Storage Socket",
        "type": "sata"
      },
      "memory-modules": [
        {
          "product-name": "Massive Memory Corp Model 3 DDR4-3200 8GB (Module 1)",
          "byte-size": 8589934592
        },
        {
          "product-name": "Massive Memory Corp Model 3 DDR4-3200 8GB (Module 2)",
          "byte-size": 8589934592
        }
      ]
    }
  }
}
{{< /highlight >}}
{{% /tab %}}
{{% tab %}}
{{< highlight xml >}}
<?xml version="1.0" encoding="UTF-8"?>
<computer xmlns="http://example.com/ns/computer" id="awesomepc1">
  <vendor id="vendor1">
    <name>AwesomeComp Incorportated</name>
    <address>1000 K Street NW Washington, DC 20001</address>
    <website>https://example.com/awesomecomp/awesomepc1/details</website>
  </vendor>
  <motherboard>
    <product-name>ISA Corp Magestic Model M-Ultra Motherboard</product-name>
    <type>atx</type>
    <cpu>
      <product-name>ISA Corp Superchip Model 1 4-core Processor</product-name>
      <architecture>x86-64</architecture>
      <speed>4.7 gigahertz</speed>
    </cpu>
    <ata-socket>
      <product-name>ISA Corp SuperSATA Model 2 Storage Socket</product-name>
      <type>sata</type>
    </ata-socket>
    <memory>
      <product-name>Massive Memory Corp Model 3 DDR4-3200 8GB (Module 1)</product-name>
      <byte-size>8589934592</byte-size>
    </memory>
    <memory>
      <product-name>Massive Memory Corp Model 3 DDR4-3200 8GB (Module 2)</product-name>
      <byte-size>8589934592</byte-size>
    </memory>
  </motherboard>
</computer>
{{< /highlight >}}
{{% /tab %}}
{{% tab %}}
{{< highlight yaml >}}
---
computer:
  id: awesomepc1
  vendor:
    id: vendor1
    name: AwesomeComp Incorportated
    address: 1000 K Street NW Washington, DC 20001
    website: https://example.com/awesomecomp/awesomepc1/details
  motherboard:
    product-name: ISA Corp Magestic Model M-Ultra Motherboard
    type: atx
    cpu:
      product-name: ISA Corp Superchip Model 1 4.7 GHz 4-core Processor
      architecture: x86-64
      speed: 4.7 gigahertz
    ata-socket:
      product-name: ISA Corp SuperATA Model 2 Socket for SATA Drive
      type: sata
    memory-modules:
    - product-name: Massive Memory Corp Model 3 8GB DDR4-3200 (Module 1)
      size: 8589934592
    - product-name: Massive Memory Corp Model 3 8GB DDR4-3200 (Module 2)
      size: 8589934592
{{< /highlight >}}
{{% /tab %}}
{{< /tabs >}}

With the expressive power of assemblies, flags, and fields, we can specify complex managed objects and control the structure of the intended information model in the resulting data formats.

Our Metaschema-enabled tools can parse and generate the different data formats. We specify flags on the `computer` assembly, but all else we define in the `model` of the `assembly`. And within that model, we can define the motherboard `assembly` inline with its own `flag` and `model`. These abstract definitions, along with information we provide with them such as names of groups, enables a Metaschema-enabled tool to sort out and distinguish the data points as we wish them to appear differently in a different syntax. A JSON schema can describe a JSON format that is idiomatic in JSON, while an XML Schema can do the same in XML with the same Metaschema model. As this example demonstrates, Metaschema allows developers to render the data independent of the notation used to represent it, and convert into any other notation their tools to support.

We define the data types for different Metaschema fields and flags. Our Metaschema-enabled tools can leverage pre-compiled schemas or generate their own to enforce `field` and `flag` values that are valid for their type. For example, our Metaschema-enabled tools should accept a valid URI for the `website` field of the vendor `assembly`, but not any arbitrary string. For `byte-size`, they should only accept positive integer values greater than 0, not a decimal point number or string. Metaschema facilitates consistent enforcement of data typing so we developers do not have to.

We also define the minimum and maximum number of elements for the different assemblies, flags, and field with `min-occurs` and `max-occurs` declarations. In our example, we have an optional `expansion-card` field in the motherboard `assembly`. Our Metaschema-enabled tools will parse or generate instances as valid with optional fields missing. On the other hand, a motherboard `assembly` missing the CPU `field` should throw errors, as should parsing or generating instances with one that one CPU `field` in the JSON, XML, or YAML format.

## Refactoring Metaschema Definitions and Deduplicating Code

We now have a robust information model for a computer we can express in JSON, XML, and YAML data models. But what if we want to enhance the information model? Can we add more information but also refactor to be more expressive while reducing redundancy? With Metaschema, yes we can.

Our stakeholders determine supply chain information is very important. We need to know vendor information for all the different parts of the computer, specifically a company name and where the company is headquartered. This information should be maintained for not just the computer, but all parts and sub-parts. How can we add this to the Metaschema definition?

For now, we can copy-paste vendor `assembly` into all relevent assemblies, not just the top-level computer assembly.

```xml
<?xml version="1.0" encoding="UTF-8"?>
<METASCHEMA xmlns="http://csrc.nist.gov/ns/oscal/metaschema/1.0">
  <schema-name>Computer Model</schema-name>
  <schema-version>0.0.4</schema-version>
  <short-name>computer</short-name>
  <namespace>http://example.com/ns/computer</namespace>
  <json-base-uri>http://example.com/ns/computer</json-base-uri>
  <define-assembly name="computer">
    <formal-name>Computer Assembly</formal-name>
    <description>A container object for a computer, its parts, and its sub-parts.</description>
    <root-name>computer</root-name>
    <define-flag name="id" as-type="string" required="yes">
        <formal-name>Computer Identifier</formal-name>
        <description>An identifier for classifying a unique make and model of computer.</description>
    </define-flag>
    <model>
      <define-assembly name="vendor">
        <formal-name>Vendor Information</formal-name>
        <description>Information about a vendor of a computer part.</description>
        <define-flag name="id" as-type="string" required="yes">
          <formal-name>Vendor Identifier</formal-name>
          <description>An identifier for classifying a unique computer parts vendor.</description>
        </define-flag>
        <model>
          <define-field name="name" min-occurs="1" max-occurs="1">
            <formal-name>Vendor Name</formal-name>
            <description>The registered company name of the vendor.</description>
          </define-field>
          <define-field name="address" min-occurs="1" max-occurs="1">
            <formal-name>Vendor Address</formal-name>
            <description>The physical address of an office location for the vendor.</description>
          </define-field>
          <define-field name="website" min-occurs="1" max-occurs="1">
            <formal-name>Vendor Website</formal-name>
            <description>A public website made by the vendor documenting their parts as used in the computer.</description>
          </define-field>
        </model>
      </define-assembly>
      <define-assembly name="motherboard">
        <formal-name>Motherboard Assembly</formal-name>
        <description>A container object for a motherboard in a computer and its sub-parts.</description>
        <model>
          <define-assembly name="vendor">
            <formal-name>Vendor Information</formal-name>
            <description>Information about a vendor of a computer part.</description>
            <define-flag name="id" as-type="string" required="yes">
              <formal-name>Vendor Identifier</formal-name>
              <description>An identifier for classifying a unique computer parts vendor.</description>
            </define-flag>
            <model>
              <define-field name="name" min-occurs="1" max-occurs="1">
                <formal-name>Vendor Name</formal-name>
                <description>The registered company name of the vendor.</description>
              </define-field>
              <define-field name="address" min-occurs="1" max-occurs="1">
                <formal-name>Vendor Address</formal-name>
                <description>The physical address of an office location for the vendor.</description>
              </define-field>
              <define-field name="website" min-occurs="1" max-occurs="1">
                <formal-name>Vendor Website</formal-name>
                <description>A public website made by the vendor documenting their parts as used in the computer.</description>
              </define-field>
            </model>
          </define-assembly>
          <define-field name="product-name" as-type="string" min-occurs="1" max-occurs="1">
            <formal-name>Product Name</formal-name>
            <description>The product name from the vendor of the computer part.</description>
          </define-field>
          <define-field name="type" as-type="string" min-occurs="1" max-occurs="1">
            <formal-name>Motherboard Type</formal-name>
            <description>The type motherboard layout, <code>at</code>, <code>atx</code>, <code>mini-itx</code> or an alternative.</description>
          </define-field>
          <define-assembly name="cpu">
            <formal-name>Motherboard Central Processing Unit (CPU)</formal-name>
            <description>The model number of the CPU on the motherboard of a computer.</description>
            <model>
              <define-assembly name="vendor">
                <formal-name>Vendor Information</formal-name>
                <description>Information about a vendor of a computer part.</description>
                <define-flag name="id" as-type="string" required="yes">
                  <formal-name>Vendor Identifier</formal-name>
                  <description>An identifier for classifying a unique computer parts vendor.</description>
                </define-flag>
                <model>
                  <define-field name="name" min-occurs="1" max-occurs="1">
                    <formal-name>Vendor Name</formal-name>
                    <description>The registered company name of the vendor.</description>
                  </define-field>
                  <define-field name="address" min-occurs="1" max-occurs="1">
                    <formal-name>Vendor Address</formal-name>
                    <description>The physical address of an office location for the vendor.</description>
                  </define-field>
                  <define-field name="website" min-occurs="1" max-occurs="1">
                    <formal-name>Vendor Website</formal-name>
                    <description>A public website made by the vendor documenting their parts as used in the computer.</description>
                  </define-field>
                </model>
              </define-assembly>
              <define-field name="product-name" as-type="string" min-occurs="1" max-occurs="1">
                <formal-name>Product Name</formal-name>
                <description>The product name from the vendor of the computer part.</description>
              </define-field>
              <define-field name="architecture" as-type="string" min-occurs="1" max-occurs="1">
                <formal-name>CPU Architecture</formal-name>
                <description>The Instruction Set Architecture (ISA) of the processor, <code>x86</code>, <code>x86-64</code>,, <code>arm</code>, or an alternative.</description>
              </define-field>
              <define-field name="speed" as-type="string" min-occurs="1" max-occurs="1">
                <formal-name>CPU Speed</formal-name>
                <description>The clock speed of the CPU in megahertz or gigahertz.</description>
              </define-field>
            </model>
          </define-assembly>
          <define-assembly name="ata-socket">
            <formal-name>Motherboard Advanced Technology Attachment (ATA) Socket</formal-name>
            <description>The model number of ATA socket on the motherboard of a computer. There will only be one socket on any motherboard.</description>
            <model>
              <define-assembly name="vendor">
                <formal-name>Vendor Information</formal-name>
                <description>Information about a vendor of a computer part.</description>
                <define-flag name="id" as-type="string" required="yes">
                  <formal-name>Vendor Identifier</formal-name>
                  <description>An identifier for classifying a unique computer parts vendor.</description>
                </define-flag>
                <model>
                  <define-field name="name" min-occurs="1" max-occurs="1">
                    <formal-name>Vendor Name</formal-name>
                    <description>The registered company name of the vendor.</description>
                  </define-field>
                  <define-field name="address" min-occurs="1" max-occurs="1">
                    <formal-name>Vendor Address</formal-name>
                    <description>The physical address of an office location for the vendor.</description>
                  </define-field>
                  <define-field name="website" min-occurs="1" max-occurs="1">
                    <formal-name>Vendor Website</formal-name>
                    <description>A public website made by the vendor documenting their parts as used in the computer.</description>
                  </define-field>
                </model>
              </define-assembly>              
              <define-field name="product-name" as-type="string" min-occurs="1" max-occurs="1">
                <formal-name>Product Name</formal-name>
                <description>The product name from the vendor of the computer part.</description>
              </define-field>
              <define-field name="type" as-type="string" min-occurs="1" max-occurs="1">
                <formal-name>ATA Socket Type</formal-name>
                <description>The type of ATA socket on the motherboard , <code>pata</code> (parallel ATA), <code>sata</code> (Serial ATA), or an alternative.</description>
              </define-field>
            </model>
          </define-assembly>
          <define-assembly name="memory" min-occurs="1" max-occurs="unbounded">
            <formal-name>Motherboard Random Access Memory (RAM) Module(s)</formal-name>
            <description>Random access memory hardware installed on the motherboard of a computer.</description>
            <group-as name="memory-modules" in-json="ARRAY"/>
            <model>
              <define-assembly name="vendor">
                <formal-name>Vendor Information</formal-name>
                <description>Information about a vendor of a computer part.</description>
                <define-flag name="id" as-type="string" required="yes">
                  <formal-name>Vendor Identifier</formal-name>
                  <description>An identifier for classifying a unique computer parts vendor.</description>
                </define-flag>
                <model>
                  <define-field name="name" min-occurs="1" max-occurs="1">
                    <formal-name>Vendor Name</formal-name>
                    <description>The registered company name of the vendor.</description>
                  </define-field>
                  <define-field name="address" min-occurs="1" max-occurs="1">
                    <formal-name>Vendor Address</formal-name>
                    <description>The physical address of an office location for the vendor.</description>
                  </define-field>
                  <define-field name="website" min-occurs="1" max-occurs="1">
                    <formal-name>Vendor Website</formal-name>
                    <description>A public website made by the vendor documenting their parts as used in the computer.</description>
                  </define-field>
                </model>
              </define-assembly>
              <define-field name="product-name" as-type="string" min-occurs="1" max-occurs="1">
                <formal-name>Product Name</formal-name>
                <description>The product name from the vendor of the computer part.</description>
              </define-field>
              <define-field name="byte-size" as-type="positiveInteger" min-occurs="1" max-occurs="1">
                <formal-name>Memory Module Size</formal-name>
                <description>Size of the memory module in binary, not SI base-10 units, meaning a kilobyte is 1024 bytes, not 1000 bytes.</description>
              </define-field>
            </model>
          </define-assembly>
          <define-assembly name="expansion-card" min-occurs="0" max-occurs="unbounded">
            <formal-name>Motherboard Expansion Card</formal-name>
            <description>The model number of an expansion card connected to the motherboard of a computer.</description>
            <group-as name="expansion-cards" in-json="ARRAY"/>
            <model>
              <define-assembly name="vendor">
                <formal-name>Vendor Information</formal-name>
                <description>Information about a vendor of a computer part.</description>
                <define-flag name="id" as-type="string" required="yes">
                  <formal-name>Vendor Identifier</formal-name>
                  <description>An identifier for classifying a unique computer parts vendor.</description>
                </define-flag>
                <model>
                  <define-field name="name" min-occurs="1" max-occurs="1">
                    <formal-name>Vendor Name</formal-name>
                    <description>The registered company name of the vendor.</description>
                  </define-field>
                  <define-field name="address" min-occurs="1" max-occurs="1">
                    <formal-name>Vendor Address</formal-name>
                    <description>The physical address of an office location for the vendor.</description>
                  </define-field>
                  <define-field name="website" min-occurs="1" max-occurs="1">
                    <formal-name>Vendor Website</formal-name>
                    <description>A public website made by the vendor documenting their parts as used in the computer.</description>
                  </define-field>
                </model>
              </define-assembly>
              <define-field name="product-name" as-type="string" min-occurs="1" max-occurs="1">
                <formal-name>Product Name</formal-name>
                <description>The product name from the vendor of the computer part.</description>
              </define-field>
              <define-field name="type" as-type="string" min-occurs="1" max-occurs="1">
                <formal-name>Expansion Card Type</formal-name>
                <description>The type of expansion card on a motherboard of a computer, such as <code>pci</code> (PCI, e.g. Peripheral Component Interconnect), <code>pcie</code> (PCI Express), or an alternative.</description>
              </define-field>
            </model>
          </define-assembly>
        </model>
      </define-assembly>
    </model>
  </define-assembly>
</METASCHEMA>
```

An instance for the model above is below in JSON, XML, and YAML data formats.

{{< tabs JSON XML YAML >}}
{{% tab %}}
{{< highlight json >}}
{
  "computer": {
    "id": "awesomepc1",
    "vendor": {
      "id": "vendor1",
      "name": "AwesomeComp Incorportated",
      "address": "1000 K Street NW Washington, DC 20001",
      "website": "https://example.com/awesomecomp/"
    },
    "motherboard": {
      "vendor": {
        "id": "vendor2",
        "name": "ISA Corp",
        "address": "2000 K Street NW Washington, DC 20002",
        "website": "https://example.com/isacorp/"
      },
      "product-name": "Magestic Model M-Ultra Motherboard",
      "type": "atx",
      "cpu": {
        "vendor": {
          "id": "vendor2",
          "name": "ISA Corp",
          "address": "2000 K Street NW Washington, DC 20002",
          "website": "https://example.com/isacorp/"
        },
        "product-name": "Superchip Model 1 4-core Processor",
        "architecture": "x86-64",
        "speed": "4.7 gigahertz"
      },
      "ata-socket": {
        "vendor": {
          "id": "vendor2",
          "name": "ISA Corp",
          "address": "2000 K Street NW Washington, DC 20002",
          "website": "https://example.com/isacorp/"
        },    
        "product-name": "SuperSATA Model 2 Storage Socket",
        "type": "sata"
      },
      "memory-modules": [
        {
          "vendor": {
            "id": "vendor3",
            "name": "Massive Memory Corp",
            "address": "3000 K Street NW Washington, DC 20003",
            "website": "https://example.com/massive-memory-corp/"
          },
          "product-name": "Model 3 DDR4-3200 8GB (Module 1)",
          "byte-size": 8589934592
        },
        {
          "vendor": {
            "id": "vendor3",
            "name": "Massive Memory Corp",
            "address": "3000 K Street NW Washington, DC 20003",
            "website": "https://example.com/massive-memory-corp/"
          },
          "product-name": "Model 3 DDR4-3200 8GB (Module 2)",
          "byte-size": 8589934592
        }
      ]
    }
  }
}
{{< /highlight >}}
{{% /tab %}}
{{% tab %}}
{{< highlight xml >}}
<?xml version="1.0" encoding="UTF-8"?>
<computer xmlns="http://example.com/ns/computer" id="awesomepc1">
  <vendor id="vendor1">
    <name>AwesomeComp Incorportated</name>
    <address>1000 K Street NW Washington, DC 20001</address>
    <website>https://example.com/awesomecomp/</website>
  </vendor>
  <motherboard>
    <vendor id="vendor2">
      <name>ISA Corp</name>
      <address>2000 K Street NW Washington, DC 20002</address>
      <website>https://example.com/isacorp/</website>
    </vendor>
    <product-name>Magestic Model M-Ultra Motherboard</product-name>
    <type>atx</type>
    <cpu>
      <vendor id="vendor2">
        <name>ISA Corp</name>
        <address>2000 K Street NW Washington, DC 20002</address>
        <website>https://example.com/isacorp/>
      </vendor>
      <product-name>Superchip Model 1 4-core Processor</product-name>
      <architecture>x86-64</architecture>
      <speed>4.7 gigahertz</speed>
    </cpu>
    <ata-socket>
      <vendor id="vendor2">
        <name>ISA Corp</name>
        <address>2000 K Street NW Washington, DC 20002</address>
        <website>https://example.com/isacorp/</website>
      </vendor>
      <product-name>SuperSATA Model 2 Storage Socket</product-name>
      <type>sata</type>
    </ata-socket>
    <memory>
      <vendor id="vendor3">
        <name>Massive Memory Corp</name>
        <address>3000 K Street NW Washington, DC 20003</address>
        <website>https://example.com/massive-memory-corp/</website>
      </vendor>
      <product-name>Model 3 DDR4-3200 8GB (Module 1)</product-name>
      <byte-size>8589934592</byte-size>
    </memory>
    <memory>
      <vendor id="vendor3">
        <name>Massive Memory Corp</name>
        <address>3000 K Street NW Washington, DC 20003</address>
        <website>https://example.com/massive-memory-corp/</website>
      </vendor>
      <product-name>Model 3 DDR4-3200 8GB (Module 2)</product-name>
      <byte-size>8589934592</byte-size>
    </memory>
  </motherboard>
</computer>
{{< /highlight >}}
{{% /tab %}}
{{% tab %}}
{{< highlight yaml >}}
---
computer:
  id: awesomepc1
  vendor:
    id: vendor1
    name: AwesomeComp Incorportated
    address: 1000 K Street NW Washington, DC 20001
    website: https://example.com/awesomecomp/
  motherboard:
    vendor:
      id: vendor2
      name: ISA Corp
      address: 2000 K Street NW Washington, DC 20002
      website: https://example.com/isacorp/
    product-name: Magestic Model M-Ultra Motherboard
    type: atx
    cpu:
      vendor:
        id: vendor2
        name: ISA Corp
        address: 2000 K Street NW Washington, DC 20002
        website: https://example.com/isacorp/
      architecture: x86-64
      product-name: Superchip Model 1 4-core Processor
      speed: 4.7 gigahertz
    ata-socket:
      vendor:
        id: vendor2
        name: ISA Corp
        address: 2000 K Street NW Washington, DC 20002
        website: https://example.com/isacorp/
      product-name: SuperSATA Model 2 Storage Socket
      type: sata
    memory-modules:
    - vendor:
        id: vendor3
        name: Massive Memory Corp
        address: 3000 K Street NW Washington, DC 20003
        website: https://example.com/massive-memory-corp/
      product-name: Model 3 DDR4-3200 8GB (Module 1)
      byte-size: 8589934592
    - byte-size: 8589934592
      product-name: Model 3 DDR4-3200 8GB (Module 2)
      vendor:
        address: 3000 K Street NW Washington, DC 20003
        id: vendor3
        name: Massive Memory Corp
        website: https://example.com/massive-memory-corp/
{{< /highlight >}}
{{% /tab %}}
{{< /tabs >}}


We have updated our model to meet stakeholder needs, but the model itself is significantly more verbse. Fortunately, we can use Metaschema syntax to define an `assembly`, `field`, or `flag` once and reuse the definition elsewhere by references with `ref` keyword. We can refactor our definition and do this with the vendor `assembly` and product name `field` in the definition below.

```xml
<?xml version="1.0" encoding="UTF-8"?>
<METASCHEMA xmlns="http://csrc.nist.gov/ns/oscal/metaschema/1.0">
  <schema-name>Computer Model</schema-name>
  <schema-version>0.0.5</schema-version>
  <short-name>computer</short-name>
  <namespace>http://example.com/ns/computer</namespace>
  <json-base-uri>http://example.com/ns/computer</json-base-uri>
  <define-assembly name="vendor">
    <formal-name>Vendor Information</formal-name>
    <description>Information about a vendor of a computer part.</description>
    <define-flag name="id" as-type="string" required="yes">
      <formal-name>Vendor Identifier</formal-name>
      <description>An identifier for classifying a unique computer parts vendor.</description>
    </define-flag>
    <model>
      <define-field name="name" min-occurs="1" max-occurs="1">
        <formal-name>Vendor Name</formal-name>
        <description>The registered company name of the vendor.</description>
      </define-field>
      <define-field name="address" min-occurs="1" max-occurs="1">
        <formal-name>Vendor Address</formal-name>
        <description>The physical address of an office location for the vendor.</description>
      </define-field>
      <define-field name="website" min-occurs="1" max-occurs="1">
        <formal-name>Vendor Website</formal-name>
        <description>A public website made by the vendor documenting their parts as used in the computer.</description>
      </define-field>
    </model>
  </define-assembly>
  <define-field name="product-name" as-type="string" min-occurs="1" max-occurs="1">
    <formal-name>Product Name</formal-name>
    <description>The product name from the vendor of the computer part.</description>
  </define-field>
  <define-assembly name="computer">
    <formal-name>Computer Assembly</formal-name>
    <description>A container object for a computer, its parts, and its sub-parts.</description>
    <root-name>computer</root-name>
    <define-flag name="id" as-type="string" required="yes">
        <formal-name>Computer Identifier</formal-name>
        <description>An identifier for classifying a unique make and model of computer.</description>
    </define-flag>
    <model>
      <define-assembly name="motherboard">
        <formal-name>Motherboard Assembly</formal-name>
        <description>A container object for a motherboard in a computer and its sub-parts.</description>
        <model>
          <assembly ref="vendor"/>
          <define-field name="type" as-type="string" min-occurs="1" max-occurs="1">
            <formal-name>Motherboard Type</formal-name>
            <description>The type motherboard layout, <code>at</code>, <code>atx</code>, <code>mini-itx</code> or an alternative.</description>
          </define-field>
          <define-assembly name="cpu">
            <formal-name>Motherboard Central Processing Unit (CPU)</formal-name>
            <description>The model number of the CPU on the motherboard of a computer.</description>
            <model>
              <assembly ref="vendor"/>
              <field ref="product-name"/>
              <define-field name="architecture" as-type="string" min-occurs="1" max-occurs="1">
                <formal-name>CPU Architecture</formal-name>
                <description>The Instruction Set Architecture (ISA) of the processor, <code>x86</code>, <code>x86-64</code>, <code>arm</code>, or an alternative.</description>
              </define-field>
              <define-field name="speed" as-type="string" min-occurs="1" max-occurs="1">
                <formal-name>CPU Speed</formal-name>
                <description>The clock speed of the CPU in megahertz or gigahertz.</description>
              </define-field>
            </model>
          </define-assembly>
          <define-assembly name="ata-socket">
            <formal-name>Motherboard Advanced Technology Attachment (ATA) Socket</formal-name>
            <description>The model number of ATA socket on the motherboard of a computer. There will only be one socket on any motherboard.</description>
            <model>
              <assembly ref="vendor"/>        
              <field ref="product-name"/>
              <define-field name="type" as-type="string" min-occurs="1" max-occurs="1">
                <formal-name>ATA Socket Type</formal-name>
                <description>The type of ATA socket on the motherboard , <code>pata</code> (parallel ATA), <code>sata</code> (Serial ATA), or an alternative.</description>
              </define-field>
            </model>
          </define-assembly>
          <define-assembly name="memory" min-occurs="1" max-occurs="unbounded">
            <formal-name>Motherboard Random Access Memory (RAM) Module(s)</formal-name>
            <description>Random access memory hardware installed on the motherboard of a computer.</description>
            <group-as name="memory-modules" in-json="ARRAY"/>
            <model>
              <assembly ref="vendor"/>
              <field ref="product-name"/>
              <define-field name="byte-size" as-type="positiveInteger" min-occurs="1" max-occurs="1">
                <formal-name>Memory Module Size</formal-name>
                <description>Size of the memory module in binary, not SI base-10 units, meaning a kilobyte is 1024 bytes, not 1000 bytes.</description>
              </define-field>
            </model>
          </define-assembly>
          <define-assembly name="expansion-card" min-occurs="0" max-occurs="unbounded">
            <formal-name>Motherboard Expansion Card</formal-name>
            <description>The model number of an expansion card connected to the motherboard of a computer.</description>
            <group-as name="expansion-cards" in-json="ARRAY"/>
            <model>
              <assembly ref="vendor"/>
              <define-field name="product-name" as-type="string" min-occurs="1" max-occurs="1">
                <formal-name>Product Name</formal-name>
                <description>The product name from the vendor of the computer part.</description>
              </define-field>
              <define-field name="type" as-type="string" min-occurs="1" max-occurs="1">
                <formal-name>Expansion Card Type</formal-name>
                <description>The type of expansion card on a motherboard of a computer, such as <code>pci</code> (PCI, e.g. Peripheral Component Interconnect), <code>pcie</code> (PCI Express), or an alternative.</description>
              </define-field>
            </model>
          </define-assembly>
        </model>
      </define-assembly>
    </model>
  </define-assembly>
</METASCHEMA>
```

We lifted the `assembly` definition for vendor and the definition of the product name `field` to outside the computer `assembly`. Because we have a `root-name` previously defined for the computer `assembly`, Metaschema-enabled tools will work just as before, generating and parsing the same instances with the computer `assembly` as the root, even with multiple top-level elements defined. At the same time, we reduced repeat copy-pasted code, and we can continue to add other requirements from our stakeholders and reuse their definitions across different elements of the model and maintain the original definition once.

## Conclusion

In this tutorial, we examined an example of a real-world object in a domain and how we would model it with a community of stakeholders. We created and incrementally improved a Metaschema definition, using it to our advantage for refactoring and modification. In doing so, we learned key Metaschema concepts and their benefits in application. Learning and applying these concepts will prepare us to explore more advanced topics in the following tutorials.
