<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc"
  xmlns:c="http://www.w3.org/ns/xproc-step" version="1.0"
  xmlns:metaschema="http://csrc.nist.gov/ns/metaschema/1.0"
  type="metaschema:make-metaschema-xsd" name="make-metaschema-xsd">
  
  
  <p:input port="source" primary="true"/>
  <p:input port="parameters" kind="parameter"/>
  
  <p:output port="a.echo-input" primary="false">
    <p:pipe port="result" step="input"/>
  </p:output>
  <p:output port="b.composed" primary="false">
    <p:pipe port="result" step="composed"/>
  </p:output>
  <p:output port="c.json-schema-xml" primary="false">
    <p:pipe port="result" step="make-json-schema-xml"/>
  </p:output>
  <p:output port="f.json-schema" primary="true">
    <p:pipe port="result" step="serialize-json"/>
  </p:output>
  
  <p:serialization port="a.echo-input"      indent="true"  method="xml"/>
  <p:serialization port="b.composed"        indent="true"  method="xml"/>
  <p:serialization port="c.json-schema-xml" indent="true"  method="xml"/>
  <p:serialization port="f.json-schema"     indent="true"  method="text" omit-xml-declaration="false"/>
  
  <p:import href="metaschema-compose.xpl"/>
  
  <p:identity name="input"/>
  
  <metaschema:metaschema-compose name="compose"/>
  
  <p:identity name="composed"/>
  
  <p:xslt name="make-json-schema-xml">
    <p:input port="stylesheet">
      <p:document href="schema_gen/json-schema-metamap.xsl"/>
    </p:input>
  </p:xslt>
  
  <!--<p:identity name="serialize-json"/>-->
  
  <p:xslt name="serialize-json">
    <p:input port="stylesheet">
      <p:document href="schema_gen/serialize-json-schema.xsl"/>
    </p:input>
  </p:xslt>

</p:declare-step>