<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc"
  xmlns:c="http://www.w3.org/ns/xproc-step" version="1.0"
  xmlns:oscal="http://csrc.nist.gov/ns/oscal/1.0"
  type="oscal:profile-resolve-and-display" name="profile-resolve-and-display">
  
  
  <p:input port="source" primary="true"/>
  <p:input port="parameters" kind="parameter"/>
  
  <p:output port="_0_main-module" primary="false">
    <p:pipe port="result" step="input"/>
  </p:output>
  <p:output port="_1_collected" primary="false">
    <p:pipe port="result" step="collect"/>
  </p:output>
  <p:output port="_2_reduced" primary="false">
    <p:pipe port="result" step="reduce"/>
  </p:output>
  <p:output port="_3_digested" primary="false">
    <p:pipe port="result" step="digest"/>
  </p:output>
  <p:output port="_4_XSD-pre" primary="false">
    <p:pipe port="result" step="digest"/>
  </p:output>
  <p:output port="_5_XSD" primary="false">
    <p:pipe port="result" step="digest"/>
  </p:output>
  <p:output port="final" primary="true">
    <p:pipe port="result" step="final"/>
  </p:output>
  
  <p:serialization port="_1_collected" indent="true"  method="xml"/>
  <p:serialization port="_2_reduced"   indent="true"  method="xml"/>
  <p:serialization port="_3_digested"  indent="true"  method="xml"/>
  <p:serialization port="_4_XSD-pre"  indent="true"  method="xml"/>
  <p:serialization port="_5_XSD"  indent="true"  method="xml"/>
  <p:serialization port="final"        indent="true"  method="xml"/>
  
  <p:identity name="input"/>
  
  <p:xslt name="collect">
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
  </p:xslt>
  
  <p:xslt name="make-xsd">
    <p:input port="stylesheet">
      <p:document href="schema_gen/produce-xsd-OLD.xsl"/>
    </p:input>
  </p:xslt>
  
  <p:identity name="rewire-xsd"/>
  <!--<p:xslt name="rewire-xsd">
    <p:input port="stylesheet">
      <p:document href="schema_gen/configure-namespaces.xsl"/>
    </p:input>
  </p:xslt>-->
  
  <p:identity name="final"/>
 
</p:declare-step>