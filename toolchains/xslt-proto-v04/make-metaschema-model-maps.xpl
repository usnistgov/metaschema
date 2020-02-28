<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc"
  xmlns:c="http://www.w3.org/ns/xproc-step" version="1.0"
  xmlns:metaschema="http://csrc.nist.gov/ns/metaschema/1.0"
  type="metaschema:make-xml-map" name="make-xml-map">
  
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
  
  <p:serialization port="c.abstract-model-map" indent="true"/>
  <p:output        port="c.abstract-model-map" primary="false">
    <p:pipe        port="result" step="build-model-map"/>
  </p:output>
  
  <p:serialization port="d.exploded-model-map" indent="true"/>
  <p:output        port="d.exploded-model-map" primary="false">
    <p:pipe        port="result" step="explode-model-map"/>
  </p:output>
  
  <p:serialization port="e.xml-element-tree" indent="true"/>
  <p:output        port="e.xml-element-tree" primary="false">
    <p:pipe        port="result" step="make-xml-element-tree"/>
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
  
  <p:xslt name="build-model-map">
    <p:input port="stylesheet">
      <p:document href="document/build-model-map.xsl"/>
    </p:input>
  </p:xslt>
  
  <p:xslt name="explode-model-map">
    <p:input port="stylesheet">
      <p:document href="document/explode-model-map.xsl"/>
    </p:input>
  </p:xslt>
  
  <p:xslt name="make-xml-element-tree">
    <p:input port="stylesheet">
      <p:document href="document/xml-element-tree.xsl"/>
    </p:input>
  </p:xslt>
  
  <p:xslt name="render-xml-model-map">
    <p:input port="stylesheet">
      <p:document href="document/xml-element-map-html.xsl"/>
    </p:input>
  </p:xslt>
  
  <p:identity name="final"/>
 
</p:declare-step>