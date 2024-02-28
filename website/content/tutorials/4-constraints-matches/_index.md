---
title: "Tutorial #4: Complex Constraints: matches"
description: ""
---

# Complex Constraints

## Introduction

In the previous tutorial, we refined a computer model and learned how to to precisely control the structure of values without knowledge of an exhaustive, predetermined list. We used this capability for logical value testing and deprecation warnings.

We will begin where we left off in the previous tutorial, with the model and conforming document instances below.

```xml
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
                <define-field name="byte-size" as-type="positive-integer" min-occurs="1" max-occurs="1" deprecated="0.0.9">
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
              <expect id="memory-divisible-two" level="ERROR" target="./byte-size" test="(. mod 2) = 0">
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
          <expect id="memory-same-byte-size" level="ERROR" target="." test="if (count(./memory/byte-size) > 0) then (sum(./memory/byte-size) mod ./memory/byte-size[1]) = 0 else (sum(./memory/size) mod ./memory/size[1]) = 0">
              <message>All memory modules SHOULD be the same size or byte-size for a computer.</message>
          </expect>
        </constraint>
      </define-assembly>
    </model>
  </define-assembly>
</METASCHEMA>
```

{{< tabs JSON XML YAML >}}
{{% tab %}}
{{< highlight json "linenos=table" >}}
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
{{< highlight xml "linenos=table" >}}
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
{{< highlight yaml "linenos=table" >}}
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

## Type subsets with matches constraints

After previous success with complex constraints, our stakeholders want to propose a more ambitious change to the consortium. The stakeholders want flexible metadata for computer document instances, but also want precise validation for certain consortium or vendor-specific metadata on a case-by-case basis. They approach us with a specific example. Prior to the use of our modeling tools, the stakeholders used a document management system with a flexible key-value metadata structure. Different records had additional fields, but despite that, every record at least had the two fields as described below in our stakeholders' requirements document.

| Key             | Value Description | Valid Value | Invalid Value |
|-----------------|-------------------|---------------------|-----------------------|
|  release-status | A description of the current release status for this model of computer: "unknown", "not-applicable", "in-development", "public", "obsolete" | `public` | `READY` |
|  release-date   | A date with year month day and timezone for when the last release status information was updated | `2024-01-01-04:00` |  `January 1` |

Our stakeholders want to know if we can enhance our models to define and enforce these requirements for specific key-value pairs, but flexibly permit others. Fortunately for us, we know we can achieve this `matches` constraints.

To meet these requirements, we will add a `property` assembly to our model. Each property will require a name, a value, and a namespace to identify the organization that maintains the meaning of specific key-value pairs. We can then define `matches` constraints.

```xml {linenos=table,hl_lines=["9-25","61-63"]}
<?xml version="1.0" encoding="UTF-8"?>
<?xml-model href="https://raw.githubusercontent.com/usnistgov/metaschema/develop/schema/xml/metaschema.xsd" type="application/xml" schematypens="http://www.w3.org/2001/XMLSchema"?>
<METASCHEMA xmlns="http://csrc.nist.gov/ns/oscal/metaschema/1.0">
  <schema-name>Computer Model</schema-name>
  <schema-version>0.0.10</schema-version>
    <short-name>computer</short-name>
  <namespace>http://example.com/ns/computer</namespace>
  <json-base-uri>http://example.com/ns/computer</json-base-uri>
  <define-assembly name="property">
    <formal-name>Computer Property</formal-name>
    <description>A property is a key-value pair of metadata about the computer, not its parts.</description>
    <define-flag name="key" as-type="token" required="yes"/>
    <define-flag name="value" as-type="string" required="yes"/>
    <define-flag name="ns" as-type="uri" required="yes" default="http://example-consortium.org"/>
    <constraint>
      <allowed-values id="consortium-property-release-status" level="ERROR" target=".[@key='release-status']/@value">
        <enum value="unknown"/>
        <enum value="not-applicable"/>
        <enum value="in-development"/>
        <enum value="public"/>
        <enum value="obsolete"/>
      </allowed-values>
      <matches id="consortium-property-release-date" level="ERROR" target=".[@ns='http://example-consortium.org' and @key='release-date']/@value" datatype="date-with-timezone"/>
    </constraint>
  </define-assembly>
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
      <assembly ref="property" min-occurs="0" max-occurs="unbounded">
        <group-as name="properties" in-json="ARRAY" />
      </assembly>
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
                <define-field name="byte-size" as-type="positive-integer" min-occurs="1" max-occurs="1" deprecated="0.0.9">
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
              <expect id="memory-divisible-two" level="ERROR" target="./byte-size" test="(. mod 2) = 0">
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
          <expect id="memory-same-byte-size" level="ERROR" target="." test="if (count(./memory/byte-size) > 0) then (sum(./memory/byte-size) mod ./memory/byte-size[1]) = 0 else (sum(./memory/size) mod ./memory/size[1]) = 0">
              <message>All memory modules SHOULD be the same size or byte-size for a computer.</message>
          </expect>
        </constraint>
      </define-assembly>
    </model>
  </define-assembly>
</METASCHEMA>
```

With this model, we are able to define properties to meet our stakeholders' requirements. Many consortium members already use the release status and release date as common key-value pairs in metadata, so our stakeholders are ready to use our updated model and propose it be standard in the consortium information model in an upcoming meeting. However, our stakeholders still want the flexibility to use occasional fields specific to their use cases, and the use of a custom namespace, with the `ns` flag for a shorthand name, facilitates this. Developers and their tools can use the default value of a URI for the consortium (e.g. `http://example-consoritum.org`) for these keys maintained by the consortium's requirements and another vendor-specific namespace for our organization or others to identify the specific context for our own use cases. Our developers and others in the consortium must use only the allowed values with the consortium namespace, or choose another for properties in their document instances. This way our model and tools prevent collisions from the beginning.

With only this design and no constraints, the value of a property with key `release-date`, and all others where the implied type is more than just a string, would poses a challenge. A base `as-type` of `string` is flexible and defining the type for the `value` flag as any other base `as-type` makes it too strict and inflexible. We could have made a different assembly for `property-` with special suffixes for each different base data type on a case-by-case basis, but using it in document instances seems redundant and error-prone. Fortunately, with `matches` constraints, we can meet the stakeholders demands in the general case, and for specific cases. For the property with a key of `release-date` where the string is really a date, we can define `datatype="date-with-timezone"` only for this key and not others. This approach allows compact definition and flexibility, but the same precision in controlling values we have with the full range of `constraint` types.

To test this updated model, we can create positive test examples, like those below.

{{< tabs JSON XML YAML >}}
{{% tab %}}
{{< highlight json "linenos=table,hl_lines=4-20" >}}
{
  "computer": {
    "id": "awesomepc1",
    "properties": [
      {
        "ns": "http://example-consortium.org",
        "key": "release-status",
        "value": "public"
      },
      {
        "ns": "http://specific-vendor.com",
        "key": "release-status",
        "value": "custom"
      },      
      {
        "ns": "http://example-consortium.org",
        "key": "release-date",
        "value": "2024-01-01Z"
      }
    ],
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
            "count": 7,
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
{{< highlight xml "linenos=table,hl_lines=3-5" >}}
<?xml version="1.0" encoding="UTF-8"?>
<computer xmlns="http://example.com/ns/computer" id="awesomepc1">
  <property ns="http://example-consortium.org" key="release-status" value="public"/>
  <property ns="http://specific-vendor.com" key="release-status" value="custom"/>
  <property ns="http://example-consortium.org" key="release-date" value="2024-01-01Z"/>
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
{{< highlight yaml "linenos=table,hl_lines=4-13" >}}
---
computer:
  id: awesomepc1
  properties:
  - ns: http://example-consortium.org
    key: release-status
    value: public
  - ns: http://specific-vendor.com
    key: release-status
    value: custom    
  - ns: http://example-consortium.org
    key: release-date
    value: 2024-01-01Z
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

We can also make example negative test like those below. Our model-based tools should report errors for the first `release-status` property not using a value from consortium allowed values list, and the `release-date` property for not being a valid date with timezone, despite it being a string as required by the generic property's definition.

{{< tabs JSON XML YAML >}}
{{% tab %}}
{{< highlight json "linenos=table,hl_lines=5-9 15-19" >}}
{
  "computer": {
    "id": "awesomepc1",
    "properties": [
      {
        "ns": "http://example-consortium.org",
        "key": "release-status",
        "value": "bad"
      },
      {
        "ns": "http://specific-vendor.com",
        "key": "release-status",
        "value": "custom"
      },      
      {
        "ns": "http://example-consortium.org",
        "key": "release-date",
        "value": "January 1"
      }
    ],
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
            "count": 7,
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
{{< highlight xml "linenos=table,hl_lines=3 5" >}}
<?xml version="1.0" encoding="UTF-8"?>
<computer xmlns="http://example.com/ns/computer" id="awesomepc1">
  <property ns="http://example-consortium.org" key="release-status" value="bad"/>
  <property ns="http://specific-vendor.com" key="release-status" value="custom"/>
  <property ns="http://example-consortium.org" key="release-date" value="January 1"/>
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
{{< highlight yaml "linenos=table,hl_lines=5-7 11-13" >}}
---
computer:
  id: awesomepc1
  properties:
  - ns: http://example-consortium.org
    key: release-status
    value: bad
  - ns: http://specific-vendor.com
    key: release-status
    value: custom    
  - ns: http://example-consortium.org
    key: release-date
    value: January 1
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

## Regular expression subsets with matches constraints

Our stakeholders are pleased with the recent additions and they reported a lot of positive feedback from consortium members, especially with how small model changes could be propagated and immediately adopted by developers from other member organizations that use this model-based tooling. Our stakeholders are now enthusiastic to introduce more complex changes to benefit our group and the consortium. They approach us with a change they believe is complex, but much simpler than the previous request. They want to better track the firmware for the CPUs in their computers. Specifically, they want to include a version for the firmware and one or more hashes for supported algorithms to confirm a correct and functioning version of that firmware is flashed on the chip if technicians want to check a system from its inventory records.

We know we can easily meet these requirements with a `matches` constraint by using the `regex` flag. We update the model like below to support this new requirement.

```xml {linenos=table,hl_lines=["52-79","108"]}
<?xml version="1.0" encoding="UTF-8"?>
<?xml-model href="https://raw.githubusercontent.com/usnistgov/metaschema/develop/schema/xml/metaschema.xsd" type="application/xml" schematypens="http://www.w3.org/2001/XMLSchema"?>
<METASCHEMA xmlns="http://csrc.nist.gov/ns/oscal/metaschema/1.0">
  <schema-name>Computer Model</schema-name>
  <schema-version>0.0.11</schema-version>
    <short-name>computer</short-name>
  <namespace>http://example.com/ns/computer</namespace>
  <json-base-uri>http://example.com/ns/computer</json-base-uri>
  <define-assembly name="property">
    <formal-name>Computer Property</formal-name>
    <description>A property is a key-value pair of metadata about the computer, not its parts.</description>
    <define-flag name="key" as-type="token" required="yes"/>
    <define-flag name="value" as-type="string" required="yes"/>
    <define-flag name="ns" as-type="uri" required="yes" default="http://example-consortium.org"/>
    <constraint>
      <allowed-values  target=".[@ns='http://example-consortium.org' and @key='release-status']/@value">
        <enum value="unknown"/>
        <enum value="not-applicable"/>
        <enum value="in-development"/>
        <enum value="public"/>
        <enum value="obsolete"/>
      </allowed-values>
      <matches target=".[@ns='http://example-consortium.org' and @key='release-date']/@value" datatype="date-with-timezone"/>
    </constraint>
  </define-assembly>
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
  <define-assembly name="firmware">
    <formal-name>CPU Firmware</formal-name>
    <description>Information about the firmware for a computer CPU.</description>
    <model>
      <define-field name="version" min-occurs="1" max-occurs="1" as-type="string">
        <formal-name>Firmware Version</formal-name>
        <description>An identifier that singles </description>
      </define-field>
      <define-field name="hash" min-occurs="1" max-occurs="1" as-type="string">
        <formal-name>Firmware Hash</formal-name>
        <description>A cryptographic hash with an approved algorithm of the firmware as flashed onto the chip.</description>
        <json-value-key>value</json-value-key>
        <define-flag name="algorithm">
          <formal-name>Hash Algorithm</formal-name>
          <constraint>
            <allowed-values>
              <enum value="sha256">The SHA-256 algorithm.</enum>
              <enum value="sha512">The SHA-512 algorithm.</enum>
            </allowed-values>
          </constraint>
        </define-flag>
        <constraint>
          <matches target=".[@algorithm='sha256']" regex="^[0-9a-fA-F]{64}$"/>
          <matches target=".[@algorithm='sha512']" regex="^[0-9a-fA-F]{128}$"/>
        </constraint>
      </define-field>
    </model>
  </define-assembly>
  <define-assembly name="computer">
    <formal-name>Computer Assembly</formal-name>
    <description>A container object for a computer, its parts, and its sub-parts.</description>
    <root-name>computer</root-name>
    <define-flag name="id" as-type="string" required="yes">
        <formal-name>Computer Identifier</formal-name>
        <description>An identifier for classifying a unique make and model of computer.</description>
    </define-flag>
    <model>
      <assembly ref="property" min-occurs="0" max-occurs="unbounded">
        <group-as name="properties" in-json="ARRAY" />
      </assembly>
      <assembly ref="vendor"/>
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
              <assembly ref="firmware"/>
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
                <define-field name="byte-size" as-type="positive-integer" min-occurs="1" max-occurs="1" deprecated="0.0.9">
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
              <expect id="memory-divisible-two" level="ERROR" target="./byte-size" test="(. mod 2) = 0">
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
          <expect id="memory-same-byte-size" level="ERROR" target="." test="if (count(./memory/byte-size) > 0) then (sum(./memory/byte-size) mod ./memory/byte-size[1]) = 0 else (sum(./memory/size) mod ./memory/size[1]) = 0">
              <message>All memory modules SHOULD be the same size or byte-size for a computer.</message>
          </expect>
        </constraint>
      </define-assembly>
    </model>
  </define-assembly>
</METASCHEMA>
```

As the hexadecimal representations of common cryptographic hash algorithms are string data types, but with certain character range and length restrictions, we use the `matches` constraint `regex` flag. With it, we can further constraint a hash value to be a string with only numeric characters from 0 to 9, lowercase letters from a to f, and uppercase letters A to F, inclusive. We will use the `algorithm` flag for this field to define one of the allowed hash algorithms and specify the length of the hexadecimal representation required for the specific algorithm, 64 or 128 characters respectively.

With this updated model, we can make positive test examples like those below.

{{< tabs JSON XML YAML >}}
{{% tab %}}
{{< highlight json "linenos=table,hl_lines=37-43" >}}
{
  "computer": {
    "id": "awesomepc1",
    "properties": [
      {
        "ns": "http://example-consortium.org",
        "key": "release-status",
        "value": "public"
      },
      {
        "ns": "http://specific-vendor.com",
        "key": "release-status",
        "value": "custom"
      },      
      {
        "ns": "http://example-consortium.org",
        "key": "release-date",
        "value": "2024-01-0Z"
      }
    ],
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
        "firmware": {
          "version": "1.2.1",
          "hash": {
            "algorithm": "sha512",
            "value": "7e9c54ef590b3e053495c253e135695eb55f4e966d49671e8739f5574d27f7809fefb8f75b998b1333a934bb59f4246928c11621e411286d77191a53ae362e3a"
          }
        },
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
            "count": 7,
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
{{< highlight xml "linenos=table,hl_lines=25-28" >}}
<?xml version="1.0" encoding="UTF-8"?>
<computer xmlns="http://example.com/ns/computer" id="awesomepc1">
  <property ns="http://example-consortium.org" key="release-status" value="bad"/>
  <property ns="http://specific-vendor.com" key="release-status" value="custom"/>
  <property ns="http://example-consortium.org" key="release-date" value="January 1"/>
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
    <type>atx</type>
    <cpu>
      <vendor id="vendor2">
        <name>ISA Corp</name>
        <address>2000 K Street NW Washington, DC 20002</address>
        <website>https://example.com/isacorp/</website>
      </vendor>
      <product-name>Superchip Model 1 4-core Processor</product-name>
      <firmware>
        <version>1.2.1</version>
        <hash algorithm="sha512">7e9c54ef590b3e053495c253e135695eb55f4e966d49671e8739f5574d27f7809fefb8f75b998b1333a934bb59f4246928c11621e411286d77191a53ae362e3a</hash>
      </firmware>
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
{{< highlight yaml "linenos=table,hl_lines=33-37" >}}
---
computer:
  id: awesomepc1
  properties:
  - ns: http://example-consortium.org
    key: release-status
    value: public
  - ns: http://specific-vendor.com
    key: release-status
    value: custom    
  - ns: http://example-consortium.org
    key: release-date
    value: 2024-01-01Z
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
      firmware:
        version: 1.2.1
        hash:
          algorithm: sha512
          value: 7e9c54ef590b3e053495c253e135695eb55f4e966d49671e8739f5574d27f7809fefb8f75b998b1333a934bb59f4246928c11621e411286d77191a53ae362e3a
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

We can also create negative test examples like those below.

{{< tabs JSON XML YAML >}}
{{% tab %}}
{{< highlight json "linenos=table,hl_lines=37-43" >}}
{
  "computer": {
    "id": "awesomepc1",
    "properties": [
      {
        "ns": "http://example-consortium.org",
        "key": "release-status",
        "value": "public"
      },
      {
        "ns": "http://specific-vendor.com",
        "key": "release-status",
        "value": "custom"
      },      
      {
        "ns": "http://example-consortium.org",
        "key": "release-date",
        "value": "2024-01-0Z"
      }
    ],
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
        "firmware": {
          "version": "1.2.1",
          "hash": {
            "algorithm": "sha512",
            "value": "1234cafe1234"
          }
        },
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
            "count": 7,
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
{{< highlight xml "linenos=table,hl_lines=25-28" >}}
<?xml version="1.0" encoding="UTF-8"?>
<computer xmlns="http://example.com/ns/computer" id="awesomepc1">
  <property ns="http://example-consortium.org" key="release-status" value="bad"/>
  <property ns="http://specific-vendor.com" key="release-status" value="custom"/>
  <property ns="http://example-consortium.org" key="release-date" value="January 1"/>
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
    <type>atx</type>
    <cpu>
      <vendor id="vendor2">
        <name>ISA Corp</name>
        <address>2000 K Street NW Washington, DC 20002</address>
        <website>https://example.com/isacorp/</website>
      </vendor>
      <product-name>Superchip Model 1 4-core Processor</product-name>
      <firmware>
        <version>1.2.1</version>
        <hash algorithm="sha512">1234cafe1234</hash>
      </firmware>
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
{{< highlight yaml "linenos=table,hl_lines=33-37" >}}
---
computer:
  id: awesomepc1
  properties:
  - ns: http://example-consortium.org
    key: release-status
    value: public
  - ns: http://specific-vendor.com
    key: release-status
    value: custom    
  - ns: http://example-consortium.org
    key: release-date
    value: 2024-01-01Z
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
      firmware:
        version: 1.2.1
        hash:
          algorithm: sha512
          value: 1234cafe1234
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

Because of the new `matches` constraints, our model-based tooling should report an error because the example hash, even if it is a hexadecimal string, because it is only twelve characters long, not 128 as required.

## Conclusion

In this tutorial, we examined advanced usage of constraints to precisely control the structure of values without knowledge of an exhaustive, predetermined list. We learned to use `matches` constraints with Metapath expressions to subset the data type for certain field and flag values based on the conditions of the `target`. We also learned how to use `matches` constraints to enforce field and flag values that conform to certain patterns with Metapath-based regular expressions.
