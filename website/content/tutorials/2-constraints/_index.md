---
title: "Using Constraints"
description: ""
---

# Using Constraints

## Introduction

In [the previous tutorial](/tutorials/1-getting-started/), we incrementally designed, implemented, and refactored a computer model and conforming document instances. We learned how to compose elements (flags and fields) into structures (assemblies). We used the type system for simple constraints on element values (i.e. must be an integer number, a string, a date). We refactored the models to reduce repetition (i.e. each computer part having a `vendor`, not just the computer itself, and the model developer defines it only once). But what do when we need to be more precise with values?

To more precisely control values, a model developer can use constraints, which we will examine in the tutorial below.

## Constraints

Elements in the document instances will often require more precise values than the minimum and maximum requirements of a type (i.e. a value must be `green` or `red` but no other value, even if it is still a string). We can require such precision in our models with [constraints](/specification/syntax/constraints/). There are several constraint types, each with their own unique functionality. Let's review our current model and document instances to first understand how to constrain field and flag values with precise, specific values using an `allowed-values` constraint.

We will begin where we left off in the previous tutorial, with the model and conforming document instances below.

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
      <define-field name="website" as-type="uri" min-occurs="1" max-occurs="1">
        <formal-name>Vendor Website</formal-name>
        <description>A public website made by the vendor documenting their parts as used in the computer.</description>
      </define-field>
    </model>
  </define-assembly>
  <define-field name="product-name" as-type="string">
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
              <field ref="product-name" min-occurs="1" max-occurs="1"/>
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
              <field ref="product-name" min-occurs="1" max-occurs="1"/>
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
              <field ref="product-name" min-occurs="1" max-occurs="1"/>
              <define-field name="byte-size" as-type="positive-integer" min-occurs="1" max-occurs="1">
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
              <field ref="product-name" min-occurs="1" max-occurs="1"/>
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
        <website>https://example.com/isacorp/</website>
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

## `allowed-values`

### Required values with `allow-other="no"`

We have been successful with the Metaschema module above and the Metaschema-enabled tooling that leverages it. However, we must address a new business requirement from the stakeholders for that model. Specific, approved architecture types must be used to identify the CPU of a given computer. Below is the table with the currently approved values.

| Architecture Type | Description                                         |
|-------------------|-----------------------------------------------------|
| amd64             | Intel 64-bit systems, also known as x86-64 or em64t |
| armhf             | Arm v7 32-bit systems                               |
| arm64             | Arm v8 64-bit systems                               |
| x86               | Intel 32-bit x86 systems, for 686 class or newer    |

To implement such a requirement, we cannot rely on type system alone. We must use an [`<allowed-values>` constraint](/specification/syntax/constraints#enumerated-values) to make an explicit list of only supported values. For a field like architecture in the model, we can define it inside the field like below where the change is highlighted. The `allow-other="no"` declaration means a valid, conforming document instance can use only of those values in the architecture field of the CPU and no other value. The constraint definition is inside the architecture field so it is the current context for evaluation focus of the [target](/specification/syntax/constraints#target). The declaration `target="."` makes it explicit.

```xml {linenos=table,hl_lines=["59-70"]}
<?xml version="1.0" encoding="UTF-8"?>
<?xml-model href="https://raw.githubusercontent.com/usnistgov/metaschema/develop/schema/xml/metaschema.xsd" type="application/xml" schematypens="http://www.w3.org/2001/XMLSchema"?>
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
      <define-field name="website" as-type="uri" min-occurs="1" max-occurs="1">
        <formal-name>Vendor Website</formal-name>
        <description>A public website made by the vendor documenting their parts as used in the computer.</description>
      </define-field>
    </model>
  </define-assembly>
  <define-field name="product-name" as-type="string">
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
              <field ref="product-name" min-occurs="1" max-occurs="1"/>
              <define-field name="architecture" as-type="string" min-occurs="1" max-occurs="1">
                <formal-name>CPU Architecture</formal-name>
                <description>The Instruction Set Architecture (ISA) approved by module stakeholders.</description>
                <constraint>
                    <allowed-values target="." allow-other="no">
                        <enum value="amd64">Intel 64-bit systems, also known as x86-64 or em64t</enum>
                        <enum value="armhf">Arm v7 32-bit systems</enum>
                        <enum value="arm64">Arm v8 64-bit systems</enum>
                        <enum value="x86">Intel 32-bit x86 systems, for 686 class or newer</enum>
                    </allowed-values>
                </constraint>
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
              <field ref="product-name" min-occurs="1" max-occurs="1"/>
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
              <field ref="product-name" min-occurs="1" max-occurs="1"/>
              <define-field name="byte-size" as-type="positive-integer" min-occurs="1" max-occurs="1">
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
              <field ref="product-name" min-occurs="1" max-occurs="1"/>
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

After updating the model, the examples above are no longer valid. A Metaschema processor will throw a validation error for the CPU architecture field. We need to edit the CPU architecture field with the required value that reflects the same information, `arm64`.

{{< tabs JSON XML YAML >}}
{{% tab %}}
{{< highlight json "linenos=table,hl_lines=27" >}}
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
        "architecture": "arm64",
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
{{< highlight xml "linenos=table,hl_lines=23" >}}
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
        <website>https://example.com/isacorp</website>
      </vendor>
      <product-name>Superchip Model 1 4-core Processor</product-name>
      <architecture>arm64</architecture>
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
{{< highlight yaml "linenos=table,hl_lines=23" >}}
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
      architecture: arm64
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

### Recommended values with `allow-other="yes"`

The updated model with approved values for CPU architecture was a success with stakeholders. It allowed those using Metaschema-enabled tools to exchange more consistent, accurate data. Now the computer model stakeholders have a new requirement. For the ATA socket type for the motherboard of a computer, stakeholders want to have a set of approved values. Unlike the CPU architecture type, the stakeholders want to maintain flexibility for emerging socket technologies without implementations or names at present. At a minimum, they want the preferred values in the table below to be recommended, but allow alternatives as they emerge.

| ATA Socket Type   | Description                                                                        |
|-------------------|------------------------------------------------------------------------------------|
| pata              | Parallel ATA buses also known as AT-Attachment and IDE                             |
| sata              | Serial ATA buses supporting Advanced Host Controller Interface or legacy IDE modes |
| esata             | External Serial ATA buses for pluggable external devices using SATA                |
| esatap            | External Serial ATA buses supporting SATA traffic and device power                 |

To implement such a requirement, we must use an [`<allowed-values>` constraint](/specification/syntax/constraints#enumerated-values) to make a list of optional, recommended values. For a field like architecture in the model, we can define it inside the field like below where the change is highlighted. The `allow-other="yes"` declaration means a valid, conforming document instance can use a recommended value from the list, or any other as new types emerge. The constraint definition is inside the architecture field so it is the current context for evaluation focus of the [target](/specification/syntax/constraints#target). The declaration `target="."` makes it explicit.

```xml {linenos=table,hl_lines=["143-154"]}
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
          <define-field name="website" as-type="uri" min-occurs="1" max-occurs="1">
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
              <define-field name="website" as-type="uri" min-occurs="1" max-occurs="1">
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
                  <define-field name="website" as-type="uri" min-occurs="1" max-occurs="1">
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
                  <define-field name="website" as-type="uri" min-occurs="1" max-occurs="1">
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
                <description>The type of ATA socket on the motherboard with approved (but optional) values recommended by model stakeholders.</description>
                <constraint>
                  <allowed-values target="." allow-other="yes">
                    <enum value="pata">Parallel ATA buses also known as AT-Attachment and IDE</enum>
                    <enum value="sata">Serial ATA buses supporting Advanced Host Controller Interface or legacy IDE modes</enum>
                    <enum value="esata">External Serial ATA buses for pluggable external devices using SATA</enum>
                    <enum value="esatap">External Serial ATA buses supporting SATA traffic and device power</enum>
                  </allowed-values>
                </constraint>
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
                  <define-field name="website" as-type="uri" min-occurs="1" max-occurs="1">
                    <formal-name>Vendor Website</formal-name>
                    <description>A public website made by the vendor documenting their parts as used in the computer.</description>
                  </define-field>
                </model>
              </define-assembly>
              <define-field name="product-name" as-type="string" min-occurs="1" max-occurs="1">
                <formal-name>Product Name</formal-name>
                <description>The product name from the vendor of the computer part.</description>
              </define-field>
              <define-field name="byte-size" as-type="positive-integer" min-occurs="1" max-occurs="1">
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
                  <define-field name="website" as-type="uri" min-occurs="1" max-occurs="1">
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

The previous versions of conforming example document instances are still valid. Using a new value for ATA socket's type will not throw a validation error. Moreover, new example document instances conforming to the module in the the updated Metaschema module for a ATA socket using Serial Attached SCSI with value `sas`. Below are these example document instances.

{{< tabs JSON XML YAML >}}
{{% tab %}}
{{< highlight json "linenos=table,hl_lines=38" >}}
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
        "architecture": "arm64",
        "speed": "4.7 gigahertz"
      },
      "ata-socket": {
        "vendor": {
          "id": "vendor2",
          "name": "ISA Corp",
          "address": "2000 K Street NW Washington, DC 20002",
          "website": "https://example.com/isacorp/"
        },    
        "product-name": "AwesomeSAS Model 1 Storage Socket",
        "type": "sas"
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
{{< highlight xml "linenos=table,hl_lines=33" >}}
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
        <website>https://example.com/isacorp/</website>
      </vendor>
      <product-name>Superchip Model 1 4-core Processor</product-name>
      <architecture>arm64</architecture>
      <speed>4.7 gigahertz</speed>
    </cpu>
    <ata-socket>
      <vendor id="vendor2">
        <name>ISA Corp</name>
        <address>2000 K Street NW Washington, DC 20002</address>
        <website>https://example.com/isacorp/</website>
      </vendor>
      <product-name>AwesomeSAS Model 1 Storage Socket</product-name>
      <type>sas</type>
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
{{< highlight yaml "linenos=table,hl_lines=33" >}}
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
      architecture: arm64
      product-name: Superchip Model 1 4-core Processor
      speed: 4.7 gigahertz
    ata-socket:
      vendor:
        id: vendor2
        name: ISA Corp
        address: 2000 K Street NW Washington, DC 20002
        website: https://example.com/isacorp/
      product-name: AwesomeSAS Model 1 Storage Socket
      type: sas
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

## Conclusion

In this tutorial, we examined an example of a real-world information model in a domain and how we would model it with a community of stakeholders. We incrementally improved a Metaschema module to add more precision to values for field and flag elements with the use of constraints.
