<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc"
  xmlns:c="http://www.w3.org/ns/xproc-step" version="1.0"
  xmlns:metaschema="http://csrc.nist.gov/ns/metaschema/1.0"
  type="metaschema:make-abstract-map" name="make-abstract-map">
  
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
  
  <p:serialization port="c.definitions-map" indent="true"/>
  <p:output        port="c.definitions-map" primary="false">
    <p:pipe        port="result" step="reduce-map"/>
  </p:output>
  
  <!-- &&& &&& &&& &&& &&& &&& &&& &&& &&& &&& &&& &&& &&& &&& &&& &&& &&& &&& -->
  <!-- Import (subpipeline) -->
  
  <p:import href="compose/metaschema-compose.xpl"/>
  
  <!-- &&& &&& &&& &&& &&& &&& &&& &&& &&& &&& &&& &&& &&& &&& &&& &&& &&& &&& -->
  <!-- Pipeline -->
  
  <p:identity name="input"/>
  
  <metaschema:metaschema-compose name="compose"/>
  
  <p:identity name="composed"/>
  
  <p:xslt name="make-model-map">
    <p:input port="stylesheet">
      <p:document href="compose/make-model-map.xsl"/>
    </p:input>
  </p:xslt>
  <p:xslt name="unfold-model-map">
    <p:input port="stylesheet">
      <p:document href="compose/unfold-model-map.xsl"/>
    </p:input>
  </p:xslt>
  <p:xslt name="reduce-map">
    <p:input port="stylesheet">
      <p:document href="compose/reduce-map.xsl"/>
    </p:input>
  </p:xslt>
  
  <p:identity name="final"/>
 
</p:declare-step>