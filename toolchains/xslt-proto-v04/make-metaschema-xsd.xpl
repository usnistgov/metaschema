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
  <p:output port="c1.XSD-pre" primary="false">
    <p:pipe port="result" step="make-xsd"/>
  </p:output>
  <p:output port="c2.XSD" primary="false">
    <p:pipe port="result" step="rewire-xsd"/>
  </p:output>
  <p:output port="f.final" primary="true">
    <p:pipe port="result" step="final"/>
  </p:output>
  
  <p:serialization port="a.echo-input" indent="true"  method="xml"/>
  <p:serialization port="b.composed"   indent="true"  method="xml"/>
  <p:serialization port="c1.XSD-pre"   indent="true"  method="xml"/>
  <p:serialization port="c2.XSD"       indent="true"  method="xml"/>
  <p:serialization port="f.final"      indent="true"  method="xml" omit-xml-declaration="false"/>
  
  <p:import href="metaschema-compose.xpl"/>
  
  <p:identity name="input"/>
  
  <metaschema:metaschema-compose name="compose"/>
  
  <p:identity name="composed"/>
  
  <!--<p:xslt name="collect">
    <p:input port="stylesheet">
      <p:document href="compose/metaschema-collect.xsl"/>
    </p:input>
  </p:xslt>
  
  <p:xslt name="reduce">
    <p:input port="stylesheet">
      <p:document href="compose/metaschema-reduce.xsl"/>
    </p:input>
  </p:xslt>
  
  <p:xslt name="digest">
    <p:input port="stylesheet">
      <p:document href="compose/metaschema-digest.xsl"/>
    </p:input>
  </p:xslt>-->
  
  <p:xslt name="make-xsd">
    <p:input port="stylesheet">
      <p:document href="schema_gen/make-metaschema-xsd.xsl"/>
    </p:input>
  </p:xslt>
  
  <!--<p:identity name="rewire-xsd"/>-->
  
  <p:xslt name="rewire-xsd">
    <p:input port="stylesheet">
      <p:document href="schema_gen/configure-namespaces.xsl"/>
    </p:input>
  </p:xslt>
  
  <p:identity name="final"/>
 
</p:declare-step>