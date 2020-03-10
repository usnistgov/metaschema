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
    <p:pipe        port="result" step="make-model-map"/>
  </p:output>
  
  <p:serialization port="d.unfolded-model-map" indent="true"/>
  <p:output        port="d.unfolded-model-map" primary="false">
    <p:pipe        port="result" step="unfold-model-map"/>
  </p:output>
  
  <p:serialization port="X1.xml-element-tree" indent="true"/>
  <p:output        port="X1.xml-element-tree" primary="false">
    <p:pipe        port="result" step="make-xml-element-tree"/>
  </p:output>
  
  <p:serialization port="X2.xml-model-html" indent="false" method="xml" omit-xml-declaration="false"/>
  <p:output        port="X2.xml-model-html" primary="false">
    <p:pipe        port="result" step="render-xml-model-map"/>
  </p:output>
  
  <p:serialization port="J1.json-object-tree" indent="true"/>
  <p:output        port="J1.json-object-tree" primary="false">
    <p:pipe        port="result" step="make-json-object-tree"/>
  </p:output>
  
  <p:serialization port="J2.json-model-html" indent="false" method="xml" omit-xml-declaration="false"/>
  <p:output        port="J2.json-model-html" primary="false">
    <p:pipe        port="result" step="render-json-model-map"/>
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
  <p:xslt name="make-model-map">
    <p:input port="source">
      <p:pipe port="result" step="composed"/>
    </p:input>
    <p:input port="stylesheet">
      <p:document href="compose/make-model-map.xsl"/>
    </p:input>
  </p:xslt>
  
  <p:xslt name="unfold-model-map">
    <p:input port="stylesheet">
      <p:document href="compose/unfold-model-map.xsl"/>
    </p:input>
  </p:xslt>
  
  <p:xslt name="make-xml-element-tree">
    <p:input port="stylesheet">
      <p:document href="document/xml/element-tree.xsl"/>
    </p:input>
  </p:xslt>
  
  <p:xslt name="render-xml-model-map">
    <p:with-option name="initial-mode" select="QName('','make-page')"/>
    <p:input port="stylesheet">
      <p:document href="document/xml/element-map-html.xsl"/>
    </p:input>
    
  </p:xslt>
  
  <p:sink/>
  
  <p:xslt name="make-json-object-tree">
    <p:input port="source">
      <p:pipe port="result" step="unfold-model-map"/>
    </p:input>
    <p:input port="stylesheet">
      <p:document href="document/json/object-tree.xsl"/>
    </p:input>
  </p:xslt>
  
  <p:xslt name="render-json-model-map">
    <p:with-option name="initial-mode" select="QName('','make-page')"/>    
    <p:input port="stylesheet">
      <p:document href="document/json/object-map-html.xsl"/>
    </p:input>
  </p:xslt>

</p:declare-step>