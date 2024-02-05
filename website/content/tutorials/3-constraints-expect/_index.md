---
title: "Complex Constraints: expect"
description: ""
---

# Complex Constraints

## Introduction

In [the previous tutorial](/tutorials/2-constraints/), we refined a computer model and learned how to restrict or recommend preferred values for fields and flags with allowed-values constraints. But what do we if our use case requires values to have a consistent style or structure, but there is no predetermined list of values our stakeholders know upfront? Additionally, what do we do if we have such requirements for field and flag values, but they must also correlate to related field or flag values in the same document instance, or maybe multiple related instances the software processes at the same time?

To precisely control the structure of values and their relationship to one another without a predetermined list of values, a model developer can use `expect` and `matches` constraints, which we will examine the tutorial below.

We will begin where we left off in the previous tutorial, with the model and conforming document instances below.

```xml
<?xml version="1.0" encoding="UTF-8"?>
<METASCHEMA xmlns="http://csrc.nist.gov/ns/oscal/metaschema/1.0">
  <schema-name>Computer Model</schema-name>
  <schema-version>0.0.7</schema-version>
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

## Logically testing values with `expect`

Given previous success with our recent rollout of new constraints, they provide us a new requirement. It is highly unusual for computer memory, regardless of form factor, to not be an even number divisible by two. Furthermore, per requirements from their computer manufacturing consortium and the information model you help maintain, best practice recommends that memory modules must be increments of 1 megabyte (1024 bytes) and all memory modules should be the same size in bytes if more than one memory module is present. Theoretically, we could amend the model to enumerate all possible numeric bytes values that could meet the first requirement, but the secondary best practice requirements cannot be expressed with `allowed-values`. Even so, we would make a very large model that performs very inefficiently if we considered it for the first requirement. However, We can use an `expect` constraint to meet all these requirements.

```xml {linenos=table,hl_lines=["156-163","203-207"]}
<?xml version="1.0" encoding="UTF-8"?>
<METASCHEMA xmlns="http://csrc.nist.gov/ns/oscal/metaschema/1.0">
  <schema-name>Computer Model</schema-name>
  <schema-version>0.0.8</schema-version>
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
            <constraint>
                <expect id="memory-divisible-two" level="CRITICAL" target="./byte-size" test="(. mod 2) = 0">
                    <message>All memory modules MUST have a byte divisible by two.</message>
                </expect>
                <expect id="memory-divisible-megabyte" level="WARNING" target="./byte-size" test="(. mod 1024) = 0">
                    <message>All memory modules SHOULD have a bite size divisible by one megabyte (1,024 bytes) .</message>
                </expect>                
            </constraint>
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
        <constraint>
          <expect id="memory-same-byte-size" level="WARNING" target="." test="(sum(./memory/byte-size) mod ./memory/byte-size[1]) = 0">
            <message>All memory modules SHOULD be the same byte size for a computer.</message>
          </expect>          
        </constraint>
      </define-assembly>
    </model>
  </define-assembly>
</METASCHEMA>
```

The three new `expect` constraints define one mandatory requirement and two optional best practice requirements without exhaustively defining every possible value. Each constraint has a unique `id` for us tool developers to identify the constraints during tool development and potentially use as inputs and outputs for Metaschema processor software itself. These constraints use the flexibility of Metapath to use different context focuses to make the `test` attribute more concise or intuitive for fellow developers.

The `level` attribute defines the impact and potential processing behavior for Metaschema processors during the analysis of document instances. The `level` of a constraint can be `INFORMATIONAL`, `WARNING`, `ERROR`, or `CRITICAL`. Given the new requirements from the stakeholder, failing the `memory-divisible-two` constraint indicates invalid data and necessarily an error condition, so it is an `ERROR`. The `memory-divisible-megabyte` and `memory-same-byte-size` do not encode mandatory requirements, but rather best practices. Therefore, their `level` is `WARNING`.

Our Metaschema processors must evaluate the `test` Metapath against the current context focus from evaluating the `target` (using the `.` operator in Metapath). That result becomes the current context focus in the `test` (the  value of `.` in this expression), and the processor must evaluate the Metapath expression and verify the result is boolean true or false.

The table below identifies the constraints and evaluations of the new constraints in the updated model against the previous sample document instances. Because we are able to control the `target` and `test` context relative to their definitions in the model's assemblies, fields, and flags, we process each result individually for the first two constraints, but process the sequence of all matches for the last constraint all at once. For the latter, we use the more advanced Metapath syntax in the `test` to query each matching assembly of the sequence, filter to only the specific fields' value , and sum them. The data in the table is truncated, but the processor will use process the full `memory` assemblies as the resulting match, and subsequently the `test` Metapath filters on the values of the `byte-size` of each dynamically to compute the sum, then perform the necessary modulo division by the first result (there must always be at least one, never zero, per our module `min-occurs="1"`).

| Constraint ID             | Evaluated Target                                                     | Evaluated Test               | Result |
|---------------------------|----------------------------------------------------------------------|------------------------------|--------|
| memory-divisible-two      | `<!-- 1st memory module -->`<br/>`<byte-size>8589934592</byte-size>` |  `(8589934592 mod 2) = 0`    | true   |
|                           | `<!-- 2nd memory module -->`<br/>`<byte-size>8589934592</byte-size>` |  `(8589934592 mod 2) = 0`    | true   |
| memory-divisible-megabyte | `<!-- 1st memory module -->`<br/>`<byte-size>8589934592</byte-size>` |  `(8589934592 mod 1024) = 0` | true   |
|                           | `<!-- 2nd memory module -->`<br/>`<byte-size>8589934592</byte-size>` |  `(8589934592 mod 1024) = 0` | true   |
| memory-same-byte-size     | Sequence of <br/> (`<memory>...<product-name>... (Module 1)</product-name><byte-size>8589934592</byte-size></memory>`, <br/>`<memory>...<product-name>... (Module 2)</product-name><byte-size>8589934592</byte-size></memory>`) | `(sum((8589934592, 8589934592)) mod 8589934592) = 0)` |  true |

If no constraint fails the `test` condition and the evaluation of every result evaluates to boolean true, our processors are not required to return any information. The document above has no failing result, so our processor does not need report any information about constraints.

If a document instance's data does fail any constraint, the processor most return information. For failing document instances, we can customize the specific information provided for each constraint with a custom `message` child element like we did in the updated model.

With our new constraints, previous sample document instances remain valid. However, we can intentionally create a sample document instance, like that below, that will all the new constraints.

{{< tabs JSON XML YAML >}}
{{% tab %}}
{{< highlight json "linenos=table,hl_lines=49" >}}
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
          "product-name": "Erroneous Model 3 DDR4-3200 8GB (Module 1)",
          "byte-size": 8589934591
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
{{< highlight xml "linenos=table,hl_lines=42" >}}
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
      <product-name>Erroneous Model 3 DDR4-3200 8GB (Module 1)</product-name>
      <byte-size>8589934591</byte-size>
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
{{< highlight yaml "linenos=table,hl_lines=49" >}}
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
        name: Erroneous Massive Memory Corp
        address: 3000 K Street NW Washington, DC 20003
        website: https://example.com/massive-memory-corp/
      product-name: Model 3 DDR4-3200 8GB (Module 1)
      byte-size: 8589934591
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

We can use the samples above to simulate a scenario where a developer or their tool define an invalid memory module configuration. The table below identifies constraints and their evaluation against the new sample. We can observe the processor should report on specific constraint errors for some fields, but not others.

| Constraint ID             | Evaluated Target                                                  | Evaluated Test            | Result |
|---------------------------|-------------------------------------------------------------------|---------------------------|--------|
| memory-divisible-two      | `<!-- 1st memory module -->`<br/>`<byte-size>8589934591</byte-size>` |  `(8589934591 mod 2) = 0`    | false  |
|                           | `<!-- 2nd memory module -->`<br/>`<byte-size>8589934592</byte-size>` |  `(8589934592 mod 2) = 0`    | true   |
| memory-divisible-megabyte | `<!-- 1st memory module -->`<br/>`<byte-size>8589934591</byte-size>` |  `(8589934591 mod 1024) = 0` | false  |
|                           | `<!-- 2nd memory module -->`<br/>`<byte-size>8589934592</byte-size>` |  `(8589934592 mod 1024) = 0` | true   |
| memory-same-byte-size     | Sequence of <br/> (`<memory>...<product-name>... (Module 1)</product-name><byte-size>8589934591</byte-size></memory>`, <br/>`<memory>...<product-name>... (Module 2)</product-name><byte-size>8589934592</byte-size></memory>`) | `(sum((8589934592, 8589934592)) mod 8589934592) = 0)` |  true |

## Deprecation warnings with `expect`

With our use of the `expect` constraint for logical value testing, our stakeholders were very pleased we can develop and test small model enhancements incrementally and quickly. However, the adoption of a standard information model and data formats have surfaced some problems and challenges they were unaware of, so they need our help. An important group in their consortium identified a risk around using `byte-size` with binary base-two number for memory or storage capacity. The use of [binary prefixes and units](https://en.wikipedia.org/wiki/Binary_prefix) are ambiguous in the new model. Some vendors use binary base-two sizes or decimal base-ten sizes, but this field in the model makes tooling inconsistent and document instances unclear. A majority in the consortium decided updates to documentation (sourced from our Metaschema modules) are not enough. There must be a way to identify size, its unit prefix (binary or decimal), and optionally a unit so developers and software do not need to compute the full byte size. Our stakeholders are very concerned because the consortium also wants to allow the old approach in our information model and mark this method as deprecated. The intent will be to remove after twelve to twenty four months.

Fortunately for us, this risk is worrisome to the stakeholders, but very relatable and easy to change for us Metaschema module developers. The `expect` constraints, paired with model changes with `choice` or other strategies, allow us to change the information model and data formats and standardize deprecation messaging across tools.

Given these new requirements we will add a new assembly, `size`. We will amend the model to allow using `bytes-size` like before or the new `size` assembly. And finally, we will amend the constraints to add a deprecation warning and recommend developers to transition software and existing documents to the new model structure.

```xml {linenos=table,hl_lines=["152-207","210-212","259-263"]}
<?xml version="1.0" encoding="UTF-8"?>
<?xml-model href="https://raw.githubusercontent.com/usnistgov/metaschema/develop/schema/xml/metaschema.xsd" type="application/xml" schematypens="http://www.w3.org/2001/XMLSchema"?>
<METASCHEMA xmlns="http://csrc.nist.gov/ns/oscal/metaschema/1.0">
  <schema-name>Computer Model</schema-name>
  <schema-version>0.0.9</schema-version>
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
              <choice>
                <define-field name="byte-size" as-type="positive-integer" min-occurs="1" max-occurs="1">
                  <formal-name>Memory Module Size</formal-name>
                  <description>Size of the memory module in binary, not SI base-10 units, meaning a kilobyte is 1024 bytes, not 1000 bytes.</description>
                </define-field>                
                <define-field name="size" as-type="positive-integer" min-occurs="1" max-occurs="1">
                  <formal-name>Memory Module Size</formal-name>
                  <description>Size of memory module in binary or SI base-10 units, optionally with a size unit. This does not require to be in bits or bytes. If no optional flags are used, it is required to process its value as a size as counted in bits (not bytes) in decimal base-ten form, with no unit prefix.</description>
                  <json-value-key>count</json-value-key>
                  <define-flag name="unit" required="no">
                    <formal-name>Memory Module Size Unit</formal-name>
                    <description>The unit size for a memory module can either be bytes (B) or bits (b).</description>
                    <constraint>
                      <allowed-values allow-other="no">
                        <enum value="B">bytes</enum>
                        <enum value="b">bits</enum>
                      </allowed-values>
                    </constraint>
                  </define-flag>
                  <define-flag name="base" required="no">
                    <formal-name>Memory Module Size Unit Prefix Base</formal-name>
                    <description>The prefix type of module size, binary or decimal. This is useful if you will not specify an optional unit or unit base.</description>
                    <constraint>
                      <allowed-values allow-other="no">
                        <enum value="binary"/>
                        <enum value="decimal"/>
                      </allowed-values>
                    </constraint>
                  </define-flag>
                  <define-flag name="prefix" required="no">
                    <formal-name>Memory Module Size Unit Prefix</formal-name>
                    <description>The optional prefix the of unit from a given system.</description>
                    <constraint>
                      <allowed-values allow-other="yes">
                        <enum value="Gi"/>
                        <enum value="Ki"/>
                        <enum value="Mi"/>
                        <enum value="G"/>
                        <enum value="k"/>
                        <enum value="M"/>
                      </allowed-values>
                    </constraint>
                  </define-flag>
                  <define-flag name="unit-system">
                    <formal-name>Memory Module Size Unit System</formal-name>
                    <description>An identifier for the organization associated with the specific usage of the unit with its prefix. If absent, the use of no unit is assumed with and the value is counted in bits.</description>
                    <constraint>
                      <allowed-values allow-other="yes">
                        <enum value="iec">The  International Electrotechnical Commission 60027-2 Amendment 2 Units</enum>
                        <enum value="jedec">JEDEC Solid State Technology Association Units</enum>
                        <enum value="si">International System of Units</enum>
                      </allowed-values>
                    </constraint>
                  </define-flag>
                </define-field>
            </choice>
            </model>
            <constraint>
              <expect id="memory-divisible-two" level="CRITICAL" target="./byte-size" test="(. mod 2) = 0">
                  <message>All memory modules MUST have a byte divisible by two.</message>
              </expect>
              <expect id="memory-divisible-megabyte" level="WARNING" target="./byte-size" test="(. mod 1024) = 0">
                  <message>All memory modules SHOULD have a bite size divisible by one megabyte (1,024 bytes) .</message>
              </expect>
              <expect id="memory-byte-size-deprecated" level="WARNING" target="." test="count(./byte-size) = 0">
                <message>All memory modules SHOULD use size because byte-size is now deprecated and byte-size will be removed.</message>
              </expect>
            </constraint>
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
        <constraint>
          <expect id="memory-same-byte-size" level="CRITICAL" target="." test="if (count(./memory/byte-size) > 0) then (sum(./memory/byte-size) mod ./memory/byte-size[1]) = 0 else (sum(./memory/size) mod ./memory/size[1]) = 0">
              <message>All memory modules SHOULD be the same size or byte-size for a computer.</message>
          </expect>
        </constraint>
      </define-assembly>
    </model>
  </define-assembly>
</METASCHEMA>
```

With our modifications to the model with the `choice` construct, we enabled our Metaschema-enabled tooling to support a field of `byte-size` or `size` where previously only the former was valid. For `size`, we added important constraints to its flag combinations to identify which unit (bits or bytes), unit prefix, unit system, and base (digital or binary) of the size's count. With the `byte-size` field, we add an `expect` constraint with a specific message to only present warning if information if model and tool developers use this deprecated field in document instances. Otherwise it can be ignored. Moreover, we refactored the previous size count constraints to check the logical constraint whether the developers use the deprecated field or the replacement field with the same logic using an `if` `else` expression.

With these changes, the example instances from the previous section we used for negative test cases are still invalid and all tools can return the validation messages as before and the new deprecation warning message.

We can use the following examples as new negative test cases that are not using the deprecated `byte-size` field, but `size` instead. All tools can return the same validation messages before without the deprecation warning message.

{{< tabs JSON XML YAML >}}
{{% tab %}}
{{< highlight json "linenos=table,hl_lines=42-48 58-64" >}}
{
  "computer": {
    "id": "awesomepc1",
    "motherboard": {
      "vendor": {
        "id": "vendor2",
        "name": "ISA Corp",
        "address": "2000 K Street NW Washington, DC 20002",
        "website": "https://example.com/isacorp/"
      },
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
          "product-name": "Erroneous Model 3 DDR4-3200 8GB (Module 1)",
          "size": {
            "count": 7,
            "prefix": "G",
            "unit": "B",
            "unit-system": "si",
            "base": "decimal"
          }
        },
        {
          "vendor": {
            "id": "vendor3",
            "name": "Massive Memory Corp",
            "address": "3000 K Street NW Washington, DC 20003",
            "website": "https://example.com/massive-memory-corp/"
          },
          "product-name": "Model 3 DDR4-3200 8GB (Module 2)",
          "size": {
            "count": 8,
            "prefix": "G",
            "unit": "B",
            "unit-system": "si",
            "base": "decimal"         
          }
        }
      ]
    }
  }
}
{{< /highlight >}}
{{% /tab %}}
{{% tab %}}
{{< highlight xml "linenos=table,hl_lines=42 51" >}}
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
      <product-name>Erroneous Model 3 DDR4-3200 8GB (Module 1)</product-name>
      <size prefix="G" unit="B" unit-system="si" base="decimal">7</size>
    </memory>
    <memory>
      <vendor id="vendor3">
        <name>Massive Memory Corp</name>
        <address>3000 K Street NW Washington, DC 20003</address>
        <website>https://example.com/massive-memory-corp/</website>
      </vendor>
      <product-name>Model 3 DDR4-3200 8GB (Module 2)</product-name>
      <size prefix="G" unit="B" unit-system="si" base="decimal">8</size>
    </memory>
  </motherboard>
</computer>
{{< /highlight >}}
{{% /tab %}}
{{% tab %}}
{{< highlight yaml "linenos=table,hl_lines=41-52" >}}
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
      product-name: Erroneous Model 3 DDR4-3200 8GB (Module 1)
      size:
        count: 7
        prefix: G
        unit: B
        unit-system: si
        base: decimal
    - size:
        count: 8
        prefix: G
        unit: B
        unit-system: si
        base: decimal
      product-name: Model 3 DDR4-3200 8GB (Module 2)
      vendor:
        address: 3000 K Street NW Washington, DC 20003
        id: vendor3
        name: Massive Memory Corp
        website: https://example.com/massive-memory-corp/        
{{< /highlight >}}
{{% /tab %}}
{{< /tabs >}}

We can also add positive test cases that validate and all of our Metaschema-enabled tool will not need to emit any of the defined messages.

{{< tabs JSON XML YAML >}}
{{% tab %}}
{{< highlight json "linenos=table,hl_lines=42-48 58-64" >}}
{
  "computer": {
    "id": "awesomepc1",
    "motherboard": {
      "vendor": {
        "id": "vendor2",
        "name": "ISA Corp",
        "address": "2000 K Street NW Washington, DC 20002",
        "website": "https://example.com/isacorp/"
      },
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
          "size": {
            "count": 8,
            "prefix": "G",
            "unit": "B",
            "unit-system": "si",
            "base": "decimal"
          }
        },
        {
          "vendor": {
            "id": "vendor3",
            "name": "Massive Memory Corp",
            "address": "3000 K Street NW Washington, DC 20003",
            "website": "https://example.com/massive-memory-corp/"
          },
          "product-name": "Model 3 DDR4-3200 8GB (Module 2)",
          "size": {
            "count": 8,
            "prefix": "G",
            "unit": "B",
            "unit-system": "si",
            "base": "decimal"         
          }
        }
      ]
    }
  }
}
{{< /highlight >}}
{{% /tab %}}
{{% tab %}}
{{< highlight xml "linenos=table,hl_lines=42 51" >}}
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
      <size prefix="G" unit="B" unit-system="si" base="decimal">8</size>
    </memory>
    <memory>
      <vendor id="vendor3">
        <name>Massive Memory Corp</name>
        <address>3000 K Street NW Washington, DC 20003</address>
        <website>https://example.com/massive-memory-corp/</website>
      </vendor>
      <product-name>Model 3 DDR4-3200 8GB (Module 2)</product-name>
      <size prefix="G" unit="B" unit-system="si" base="decimal">8</size>
    </memory>
  </motherboard>
</computer>
{{< /highlight >}}
{{% /tab %}}
{{% tab %}}
{{< highlight yaml "linenos=table,hl_lines=41-52" >}}
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
      size:
        count: 8
        prefix: G
        unit: B
        unit-system: si
        base: decimal
    - size:
        count: 8
        prefix: G
        unit: B
        unit-system: si
        base: decimal
      product-name: Model 3 DDR4-3200 8GB (Module 2)
      vendor:
        address: 3000 K Street NW Washington, DC 20003
        id: vendor3
        name: Massive Memory Corp
        website: https://example.com/massive-memory-corp/        
{{< /highlight >}}
{{% /tab %}}
{{< /tabs >}}

With the model, positive test case, and negative case development complete, we are able to present our quick model changes to our stakeholders and later on their consortium partners. All parties are pleased with the flexibility and robustness of the modeling tool, and all parties' developers are able to quickly integrate the changes with this Metaschema tooling.

## Conclusion

In this tutorial, we examined advanced usage of constraints to precisely control the structure of values without knowledge of an exhaustive, predetermined list. We learned to use `expect` constraints with Metapath expressions to logically test values without these predetermined lists. We also learned how to deprecate model features while adding new ones, using `expect` with more complex Metapath expressions to apply the same logical testing and facilitate tools with consistent messaging about these deprecations.
