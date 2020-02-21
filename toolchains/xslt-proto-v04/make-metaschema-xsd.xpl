<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc"
  xmlns:c="http://www.w3.org/ns/xproc-step" version="1.0"
  xmlns:metaschema="http://csrc.nist.gov/ns/metaschema/1.0"
  type="metaschema:make-metaschema-xsd" name="make-metaschema-xsd">
  
  <!-- &&& &&& &&& &&& &&& &&& &&& &&& &&& &&& &&& &&& &&& &&& &&& &&& &&& &&& -->
  <!-- Ports -->
  
  <p:input port="source" primary="true"/>
  <p:input port="parameters" kind="parameter"/>
  
  <p:serialization port="a.echo-input" indent="true"/>
  <p:output        port="a.echo-input" primary="false">
    <p:pipe        port="result"       step="input"/>
  </p:output>
  
  <p:serialization port="b.composed" indent="true"/>
  <p:output        port="b.composed" primary="false">
    <p:pipe        port="result"     step="composed"/>
  </p:output>
  
  <p:serialization port="c0.pre-XSD" indent="true"/>
  <p:output        port="c0.pre-XSD" primary="false">
    <p:pipe        port="result" step="make-xsd"/>
  </p:output>
  
  <p:serialization port="c1.XSD" indent="true"/>
  <p:output        port="c1.XSD" primary="false">
    <p:pipe        port="result" step="rewire-xsd"/>
  </p:output>
  
  <p:serialization port="f.final" indent="true" method="xml" omit-xml-declaration="false"/>
  <p:output        port="f.final" primary="true">
    <p:pipe        port="result" step="final"/>
  </p:output>
  
  <!-- &&& &&& &&& &&& &&& &&& &&& &&& &&& &&& &&& &&& &&& &&& &&& &&& &&& &&& -->
  <!-- Import (subpipeline) -->
  
  <p:import href="metaschema-compose.xpl"/>
  
  <!-- &&& &&& &&& &&& &&& &&& &&& &&& &&& &&& &&& &&& &&& &&& &&& &&& &&& &&& -->
  <!-- Pipeline -->
  
  <p:identity name="input"/>
  
  <metaschema:metaschema-compose name="compose"/>
  
  <p:identity name="composed"/>
  
  <p:xslt name="make-xsd">
    <p:input port="stylesheet">
      <p:document href="schema_gen/make-metaschema-xsd.xsl"/>
    </p:input>
  </p:xslt>
  
  <p:xslt name="rewire-xsd">
    <p:input port="stylesheet">
      <p:document href="schema_gen/configure-namespaces.xsl"/>
    </p:input>
  </p:xslt>
  
  <p:identity name="final"/>
 
</p:declare-step>