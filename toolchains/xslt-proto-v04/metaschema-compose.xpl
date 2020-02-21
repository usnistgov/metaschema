<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc"
  xmlns:c="http://www.w3.org/ns/xproc-step" version="1.0"
  xmlns:metaschema="http://csrc.nist.gov/ns/metaschema/1.0"
  type="metaschema:metaschema-compose" name="metaschema-compose">

  <!-- &&& &&& &&& &&& &&& &&& &&& &&& &&& &&& &&& &&& &&& &&& &&& &&& &&& &&& -->
  <!-- Ports -->
  
  <p:input port="source" primary="true"/>
  <p:input port="parameters" kind="parameter"/>

  <p:serialization port="_0_main-module" indent="true"/>
  <p:output        port="_0_main-module" primary="false">
    <p:pipe port="result" step="input"/>
  </p:output>

  <p:serialization port="_1_collected" indent="true"/>
  <p:output        port="_1_collected" primary="false">
    <p:pipe port="result" step="collect"/>
  </p:output>

  <p:serialization port="_2_reduced1" indent="true"/>
  <p:output        port="_2_reduced1" primary="false">
    <p:pipe port="result" step="reduce1"/>
  </p:output>

  <p:serialization port="_3_reduced2" indent="true"/>
  <p:output        port="_3_reduced2" primary="false">
    <p:pipe port="result" step="reduce2"/>
  </p:output>

  <p:serialization port="_4_digested" indent="true"/>
  <p:output port="_4_digested" primary="false">
    <p:pipe port="result" step="digest"/>
  </p:output>
  
  <p:serialization port="final"  indent="true"/>
  <p:output        port="final" primary="true">
    <p:pipe port="result" step="final"/>
  </p:output>

  <!-- &&& &&& &&& &&& &&& &&& &&& &&& &&& &&& &&& &&& &&& &&& &&& &&& &&& &&& -->
  <!-- Pipeline -->
  
  <p:identity name="input"/>
  
  <p:xslt name="collect">
    <p:input port="stylesheet">
      <p:document href="compose/metaschema-collect.xsl"/>
    </p:input>
  </p:xslt>
  
  <p:xslt name="reduce1">
    <p:input port="stylesheet">
      <p:document href="compose/metaschema-reduce1.xsl"/>
    </p:input>
  </p:xslt>
  
  <p:xslt name="reduce2">
    <p:input port="stylesheet">
      <p:document href="compose/metaschema-reduce2.xsl"/>
    </p:input>
  </p:xslt>
  
  <p:xslt name="digest">
    <p:input port="stylesheet">
      <p:document href="compose/metaschema-digest.xsl"/>
    </p:input>
  </p:xslt>
  
  <p:identity name="final"/>
 
</p:declare-step>