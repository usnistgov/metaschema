<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc"
  xmlns:c="http://www.w3.org/ns/xproc-step" version="1.0"
  xmlns:metaschema="http://csrc.nist.gov/ns/metaschema/1.0"
  type="metaschema:make-metaschema-xsd" name="make-metaschema-xsd">
  
  
  <p:input port="source" primary="true"/>
  <p:input port="parameters" kind="parameter"/>
  
  <p:output port="_0_main-module" primary="false">
    <p:pipe port="result" step="input"/>
  </p:output>
  <p:output port="_1_composed" primary="false">
    <p:pipe port="result" step="composed"/>
  </p:output>
  <!--<p:output port="_2_reduced" primary="false">
    <p:pipe port="result" step="reduce"/>
  </p:output>
  <p:output port="_3_digested" primary="false">
    <p:pipe port="result" step="digest"/>
  </p:output>-->
  <p:output port="_4_XSD-pre" primary="false">
    <p:pipe port="result" step="make-xsd"/>
  </p:output>
  <p:output port="_5_XSD" primary="false">
    <p:pipe port="result" step="rewire-xsd"/>
  </p:output>
  <p:output port="final" primary="true">
    <p:pipe port="result" step="final"/>
  </p:output>
  
  <p:serialization port="_1_composed" indent="true"  method="xml"/>
  <!--<p:serialization port="_2_reduced"   indent="true"  method="xml"/>
  <p:serialization port="_3_digested"  indent="true"  method="xml"/>-->
  <p:serialization port="_4_XSD-pre"  indent="true"  method="xml"/>
  <p:serialization port="_5_XSD"  indent="true"  method="xml"/>
  <p:serialization port="final"        indent="true"  method="xml"/>
  
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