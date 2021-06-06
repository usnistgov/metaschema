<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc"
  xmlns:c="http://www.w3.org/ns/xproc-step" version="1.0"
  xmlns:metaschema="http://csrc.nist.gov/ns/metaschema/1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  type="metaschema:make-metaschema-converters" name="make-metaschema-converters">
  
  <!-- &&& &&& &&& &&& &&& &&& &&& &&& &&& &&& &&& &&& &&& &&& &&& &&& &&& &&& -->
  <!-- Ports -->
  
  <p:input port="metaschema-source" primary="true"/>
  
  <p:input port="parameters" kind="parameter"/>
  
  <p:serialization port="a.composed-metaschema" indent="true"/>
  <p:output        port="a.composed-metaschema" primary="false">
    <p:pipe        port="result"       step="composed"/>
  </p:output>
  
  <p:serialization port="b.initial-model-map" indent="true"/>
  <p:output        port="b.initial-model-map" primary="false">
    <p:pipe        port="result"           step="make-model-map"/>
  </p:output>
  
  <p:serialization port="c.unfolded-model-map" indent="true"/>
  <p:output        port="c.unfolded-model-map" primary="false">
    <p:pipe        port="result"           step="unfold-model-map"/>
  </p:output>
  
  <p:serialization port="d.definition-model" indent="true"/>
  <p:output        port="d.definition-model" primary="false">
    <p:pipe        port="result"           step="definition-map"/>
  </p:output>
  
  <p:serialization port="E.xml-supermodel-converter" indent="true"/>
  <p:output        port="E.xml-supermodel-converter" primary="false">
    <p:pipe        port="result"               step="make-xml-converter"/>
  </p:output>
  
  <p:serialization port="E.json-supermodel-converter" indent="true"/>
  <p:output        port="E.json-supermodel-converter" primary="false">
    <p:pipe        port="result"               step="make-json-converter"/>
  </p:output>
  
  <!-- &&& &&& &&& &&& &&& &&& &&& &&& &&& &&& &&& &&& &&& &&& &&& &&& &&& &&& -->
  <!-- Import (subpipeline) -->
  
  <p:import href="compose/metaschema-compose.xpl"/>
  
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
  
  <p:xslt name="definition-map">
    <p:input port="source">
      <p:pipe port="result" step="unfold-model-map"/>
    </p:input>
    <p:input port="stylesheet">
      <p:document href="compose/reduce-map.xsl"/>
    </p:input>
  </p:xslt>
  
  <p:xslt name="make-xml-converter">
    <p:input port="stylesheet">
      <p:document href="converter-gen/produce-xml-converter.xsl"/>
    </p:input>
  </p:xslt>
  
  <p:sink/>
  
  <p:xslt name="make-json-converter">
    <p:input port="source">
      <p:pipe port="result" step="definition-map"/>
    </p:input>
    <p:input port="stylesheet">
      <p:document href="converter-gen/produce-json-converter.xsl"/>
    </p:input>
  </p:xslt>
  

</p:declare-step>