---
title: "Complex Constraints: has-cardinality"
description: ""
---

# Complex Constraints

## Introduction

In the previous tutorial, we enhanced the computer model and learned how to use constraints to customize specific fields' and flags' values by subsetting their data types or matching certain patterns with regular expressions. In previous tutorials about constraints, we have learned multiple techniques to precisely control the values of fields and flags. But how do we control the minimum and maximum number of occurrences for assemblies, fields, and flags in document instance(s) with logical conditions using their own identifiers and values? How do we do this with related assemblies, fields, and flags co-occurring these document instance(s)?

To control the minimum and maximum occurrence of different assemblies, fields, flags and/or their respective values, we can use `has-cardinality` constraints to meet this use case.

We will begin where we left off in the previous tutorial, with the model and conforming document instances below.

```xml
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
    <constraint>
      <has-cardinality id="atx-memory-count-allowed" level="ERROR" target="motherboard[type='atx']/memory" min-occurs="1" max-occurs="4"/>
      <has-cardinality id="atx-ata-sockets-count-allowed" level="ERROR" target="motherboard[type='atx']/ata-socket" min-occurs="0" max-occurs="1"/>
      <has-cardinality id="mini-itx-memory-count-allowed" level="ERROR" target="motherboard[type='mini-itx']/memory" min-occurs="1" max-occurs="2"/>
      <has-cardinality id="mini-itx-ata-sockets-count-allowed" level="ERROR" target="motherboard[type='mini-itx']/ata-socket" min-occurs="0" max-occurs="0"/>
    </constraint>
  </define-assembly>
</METASCHEMA>
```

{{< tabs JSON XML YAML >}}
{{% tab %}}
{{< highlight json >}}
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
{{< highlight xml >}}
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
{{< highlight yaml >}}
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

## Using has-cardinality constraints with identifiers

Given previous successes with our Metaschema model, our stakeholders are eager to consult us and add a new requirement to the model. They want to propose a new requirement to partners in the consortium: the consortium requires that computers of the standard ATX form factor must have between one and four ATA sockets and between one and four memory slots. The consortium also requires that Mini ATX computers have one or two memory modules and no ATA sockets.

Fortunately for us, this business requirement is easy to add to our Metaschema model using the `has-cardinality` constraint. We define Metapath expressions to count these fields and flags based upon their name. We then define the `min-occurs` and `max-occurs` specific to this use case.

```xml {linenos=table,hl_lines=["313-316"]}
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
          <has-cardinality id="atx-memory-count-allowed" level="ERROR" target="motherboard[@type='atx']/memory" min-occurs="1" max-occurs="4"/>
          <has-cardinality id="atx-ata-sockets-count-allowed" level="ERROR" target="motherboard[@type='atx']/ata-socket" min-occurs="1" max-occurs="4"/>
          <has-cardinality id="mini-itx-memory-count-allowed" level="ERROR" target="motherboard[@type='atx']/memory" min-occurs="1" max-occurs="2"/>
          <has-cardinality id="mini-itx-ata-sockets-count-allowed" level="ERROR" target="motherboard[@type='atx']/ata-socket" min-occurs="0" max-occurs="0"/>
        </constraint>
      </define-assembly>
    </model>
  </define-assembly>
</METASCHEMA>
```

## Using has-cardinality constraints with values

## Using complex has-cardinality constraints with both

## Conclusion
