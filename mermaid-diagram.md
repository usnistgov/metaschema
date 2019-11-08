graph LR
sub1[submodule] -.-> Main
sub2[submodule] -.-> Main
Main[Main module] --> M
M(Composed metaschema) -->|Explode| S(Supermodel)
S --> xmlmap[XML syntax map]
S --> xmldocs[XML docs]
S --> xmlinout[XML i/o converters]
S --> xsd[XSD]
S --> schematron[Schematron]
S --> jsonschema[JSON Schema]
S --> jsoninout[JSON i/o converters]
S --> jsondocs[Object Notation docs]
S --> jsonmap[JSON/YAML syntax map]

style sub1 fill:skyblue
style sub2 fill:yellow
style Main fill:yellow

style M fill:yellow,stroke:#333,stroke-width:3px, stroke-dasharray: 2,2;
style S fill:pink,stroke:#333,stroke-width:3px, stroke-dasharray: 2,2;
