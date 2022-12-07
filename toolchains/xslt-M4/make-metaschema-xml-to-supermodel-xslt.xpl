<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc"
  xmlns:c="http://www.w3.org/ns/xproc-step" version="1.0"
  xmlns:metaschema="http://csrc.nist.gov/ns/metaschema/1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  type="metaschema:make-metaschema-xml-to-supermodel-xslt"
  name="make-metaschema-xml-to-supermodel-xslt">
  
  <!-- Purpose: Produces a single converter XSLT (for debugging) -->
  <!-- Input: A valid and correct OSCAL Metaschema instance linked to its modules (also valid and correct) -->
  <!-- Output: Port exposes a converter XSLT but does not run it -->
  
  <!-- &&& &&& &&& &&& &&& &&& &&& &&& &&& &&& &&& &&& &&& &&& &&& &&& &&& &&& -->
  <!-- Ports -->
  
  <p:input port="source"     primary="true"/>
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
    <p:pipe        port="result"               step="make-model-map"/>
  </p:output>
  
  <p:serialization port="d.unfolded-model-map" indent="true"/>
  <p:output        port="d.unfolded-model-map" primary="false">
    <p:pipe        port="result"               step="unfold-model-map"/>
  </p:output>
  
  <p:serialization port="A.definition-map" indent="true"/>
  <p:output        port="A.definition-map" primary="false">
    <p:pipe        port="result"           step="definition-map"/>
  </p:output>
  
  <p:serialization port="C.xml-converter" indent="true"/>
  <p:output        port="C.xml-converter" primary="false">
    <p:pipe        port="result"          step="make-xml-converter"/>
  </p:output>
  
  <!-- &&& &&& &&& &&& &&& &&& &&& &&& &&& &&& &&& &&& &&& &&& &&& &&& &&& &&& -->
  <!-- Import (subpipeline) -->
  
  <p:import href="compose/metaschema-compose.xpl"/>
  
  <!-- &&& &&& &&& &&& &&& &&& &&& &&& &&& &&& &&& &&& &&& &&& &&& &&& &&& &&& -->
  <!-- Pipeline -->
  
  <p:identity name="input"/>
  
  <metaschema:metaschema-compose name="compose"/>
  
  <p:identity name="composed"/>
  
  <!--<p:identity  name="make-model-map"/>-->
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
    <p:input port="stylesheet">
      <p:document href="compose/reduce-map.xsl"/>
    </p:input>
  </p:xslt>
  
  <!--<p:identity name="make-xml-converter"/>-->
  
  <p:xslt name="make-xml-converter">
    <p:input port="stylesheet">
      <p:document href="converter-gen/produce-xml-converter.xsl"/>
    </p:input>
  </p:xslt>
  
</p:declare-step>