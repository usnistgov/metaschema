<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc"
  xmlns:c="http://www.w3.org/ns/xproc-step" version="1.0"
  xmlns:metaschema="http://csrc.nist.gov/ns/metaschema/1.0"
  type="metaschema:make-metaschema-xsd" name="make-metaschema-xsd">
  
  <!-- &&& &&& &&& &&& &&& &&& &&& &&& &&& &&& &&& &&& &&& &&& &&& &&& &&& &&& -->
  <!-- Ports -->
  
  <p:input port="source" primary="true"/>
  <p:input port="parameters" kind="parameter"/>
  
  <p:serialization port="a.echo-input"      indent="true"  method="xml"/>
  <p:output port="a.echo-input" primary="false">
    <p:pipe port="result" step="input"/>
  </p:output>
  
  <p:serialization port="b.composed"        indent="true"  method="xml"/>
  <p:output port="b.composed" primary="false">
    <p:pipe port="result" step="composed"/>
  </p:output>
  
  <p:serialization port="c.json-schema-xml" indent="true"  method="xml"/>
  <p:output port="c.json-schema-xml" primary="false">
    <p:pipe port="result" step="make-json-schema-xml"/>
  </p:output>
  
  <p:serialization port="f.json-schema"     indent="true"  method="text" omit-xml-declaration="false"/>
  <p:output port="f.json-schema" primary="true">
    <p:pipe port="result" step="serialize-json"/>
  </p:output>
  
  <!-- &&& &&& &&& &&& &&& &&& &&& &&& &&& &&& &&& &&& &&& &&& &&& &&& &&& &&& -->
  <!-- Import (subpipeline) -->
  
  <p:import href="compose/metaschema-compose.xpl"/>
  
  <!-- &&& &&& &&& &&& &&& &&& &&& &&& &&& &&& &&& &&& &&& &&& &&& &&& &&& &&& -->
  <!-- Pipeline -->
  
  <p:identity name="input"/>
  
  <metaschema:metaschema-compose name="compose"/>
  
  <p:identity name="composed"/>
  
  <!--<p:identity name="make-json-schema-xml"/>-->
  <p:xslt name="make-json-schema-xml">
    <p:input port="stylesheet">
      <p:document href="schema-gen/make-json-schema-metamap.xsl"/>
    </p:input>
  </p:xslt>
  
  <!--<p:identity name="serialize-json"/>-->
  <p:xslt name="serialize-json">
    <p:input port="stylesheet">
      <p:document href="util/xpath-json-to-json.xsl"/>
    </p:input>
  </p:xslt>

</p:declare-step>