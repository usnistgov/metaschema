<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc"
  xmlns:c="http://www.w3.org/ns/xproc-step" version="1.0"
  xmlns:oscal="http://csrc.nist.gov/ns/oscal/1.0"
  type="oscal:profile-resolve-and-display" name="profile-resolve-and-display">
  
<!-- Executes metaschema composition calling the *old* implementation.
     For comparison of results with the new version. -->
  <p:input port="source" primary="true"/>
  <p:input port="parameters" kind="parameter"/>
  
  <p:output port="_0_input" primary="false">
    <p:pipe port="result" step="input"/>
  </p:output>
  <p:output port="final" primary="true">
    <p:pipe port="result" step="final"/>
  </p:output>
  
  <p:serialization port="final" indent="true"  method="xml"/>
  
  <p:identity name="input"/>
  
  <p:xslt name="compose">
    <p:input port="stylesheet">
      <p:document href="lib/metaschema-compose.xsl"/>
    </p:input>
  </p:xslt>
  
  <p:identity name="final"/>
 
</p:declare-step>