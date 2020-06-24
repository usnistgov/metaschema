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
  
  <!--<p:serialization port="c.abstract-model-map" indent="true"/>
  <p:output        port="c.abstract-model-map" primary="false">
    <p:pipe        port="result" step="make-model-map"/>
  </p:output>
  
  <p:serialization port="d.unfolded-model-map" indent="true"/>
  <p:output        port="d.unfolded-model-map" primary="false">
    <p:pipe        port="result" step="unfold-model-map"/>
  </p:output>-->
  
  <p:serialization port="X.xml-docs" indent="true"/>
  <p:output        port="X.xml-docs" primary="false">
    <p:pipe        port="result" step="produce-xml-docs"/>
  </p:output>
  
  <p:serialization port="J.json-docs" indent="true"/>
  <p:output        port="J.json-docs" primary="false">
    <p:pipe        port="result" step="produce-json-docs"/>
  </p:output>
  
  <!-- &&& &&& &&& &&& &&& &&& &&& &&& &&& &&& &&& &&& &&& &&& &&& &&& &&& &&& -->
  <!-- Import (subpipeline) -->
  
  <p:import href="metaschema-compose.xpl"/>
  
  <!-- &&& &&& &&& &&& &&& &&& &&& &&& &&& &&& &&& &&& &&& &&& &&& &&& &&& &&& -->
  <!-- Pipeline -->
  
  <p:identity name="input"/>
  
  <metaschema:metaschema-compose name="compose"/>
  
  <p:identity name="composed"/>
  
  <!--<p:identity  name="render-xml-model-map"/>-->
  <!--<p:xslt name="make-model-map">
    <p:input port="source">
      <p:pipe port="result" step="composed"/>
    </p:input>
    <p:input port="stylesheet">
      <p:document href="compose/make-model-map.xsl"/>
    </p:input>
  </p:xslt>-->
  
  <!--<p:xslt name="unfold-model-map">
    <p:input port="stylesheet">
      <p:document href="compose/unfold-model-map.xsl"/>
    </p:input>
  </p:xslt>
  
  <p:xslt name="make-xml-element-tree">
    <p:input port="stylesheet">
      <p:document href="document/xml/element-tree.xsl"/>
    </p:input>
  </p:xslt>-->
  
  <p:xslt name="produce-xml-docs">
    <!--<p:with-option name="initial-mode" select="QName('','make-page')"/>-->
    <p:input port="stylesheet">
      <p:document href="document/xml/xml-docs-hugo-uswds.xsl"/>
    </p:input>
    
  </p:xslt>
  
  <p:sink/>
  
  
  <p:xslt name="produce-json-docs">
    <!--<p:with-option name="initial-mode" select="QName('','make-page')"/>-->    
    <p:input port="source">
      <p:pipe port="result" step="composed"/>
    </p:input>
    <p:input port="stylesheet">
      <p:document href="document/json/json-docs-hugo-uswds.xsl"/>
    </p:input>
  </p:xslt>

</p:declare-step>