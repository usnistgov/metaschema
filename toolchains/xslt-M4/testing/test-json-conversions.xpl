<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc"
  xmlns:c="http://www.w3.org/ns/xproc-step" version="1.0"
  xmlns:metaschema="http://csrc.nist.gov/ns/metaschema/1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  type="metaschema:test-metaschema-json-conversion" name="test-metaschema-json-conversion">
  
  <!-- &&& &&& &&& &&& &&& &&& &&& &&& &&& &&& &&& &&& &&& &&& &&& &&& &&& &&& -->
  <!-- Ports -->
  
  <p:input port="metaschema-source" primary="true"/>
  <p:input port="testdata-json-xml"      primary="false"/>
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
  
  <p:serialization port="C.json-converter" indent="true"/>
  <p:output        port="C.json-converter" primary="false">
    <p:pipe        port="result"          step="make-json-converter"/>
  </p:output>
  
  <p:serialization port="Q.testdata-json-xml-source" indent="true"/>
  <p:output        port="Q.testdata-json-xml-source" primary="false">
    <p:pipe port="testdata-json-xml" step="test-metaschema-json-conversion"/>
  </p:output>
  
  <p:serialization port="S.testdata-supermodel" indent="true"/>
  <p:output        port="S.testdata-supermodel" primary="false">
    <p:pipe        port="result"                step="capture-supermodel"/>
  </p:output>
  
  <p:serialization port="_J1.testdata-json-xml-result" indent="true"/>
  <p:output        port="_J1.testdata-json-xml-result" primary="false">
    <p:pipe        port="result" step="convert-supermodel-to-json-xml"/>
  </p:output>
   
  <p:serialization port="_J2.testdata-json-result" indent="true" method="text"/>
  <p:output        port="_J2.testdata-json-result" primary="false">
    <p:pipe        port="result" step="serialize-json"/>
  </p:output>

  <p:serialization port="_X1.testdata-xml-result" indent="true"/>
  <p:output        port="_X1.testdata-xml-result" primary="false">
    <p:pipe        port="result" step="convert-supermodel-to-xml"/>
  </p:output>
  
  <!-- &&& &&& &&& &&& &&& &&& &&& &&& &&& &&& &&& &&& &&& &&& &&& &&& &&& &&& -->
  <!-- Import (subpipeline) -->
  
  <p:import href="../compose/metaschema-compose.xpl"/>
  
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
      <p:document href="../compose/make-model-map.xsl"/>
    </p:input>
  </p:xslt>
  
  <p:xslt name="unfold-model-map">
    <p:input port="stylesheet">
      <p:document href="../compose/unfold-model-map.xsl"/>
    </p:input>
  </p:xslt>
  
  <p:xslt name="definition-map">
    <p:input port="stylesheet">
      <p:document href="../compose/reduce-map.xsl"/>
    </p:input>
  </p:xslt>
  
  <!--<p:identity name="make-json-converter"/>-->
  <p:xslt name="make-json-converter">
    <p:input port="stylesheet">
      <p:document href="../converter-gen/produce-json-converter.xsl"/>
    </p:input>
  </p:xslt>
  
  <!--<p:identity name="convert-json-testdata"/>-->
  <p:xslt name="convert-json-testdata">
    <p:input port="source">
      <p:pipe port="testdata-json-xml" step="test-metaschema-json-conversion"/>
    </p:input>
    <p:input port="stylesheet">
      <p:pipe step="make-json-converter" port="result"/>
    </p:input>
  </p:xslt>
  
  <!-- Now going back downhill to JSON -->
  <p:identity name="convert-supermodel-to-json-xml"/>
  <!--<p:xslt name="convert-supermodel-to-json-xml">
    <p:input port="stylesheet">
      <p:document href="../converter-gen/supermodel-to-json-xml.xsl"/>
    </p:input>
  </p:xslt>-->
  
  <!--<p:identity name="serialize-json"/>-->
  <p:identity name="serialize-json"/>
  <!--<p:xslt name="serialize-json">
    <p:input port="stylesheet">
      <p:document href="../lib/xpath-json-to-json.xsl"/>
    </p:input>
  </p:xslt>-->
  
  <p:sink/>
  
  <!-- The supermodel: extra step for debuggability -->
  <p:identity name="capture-supermodel">
    <p:input port="source">
      <p:pipe port="result" step="convert-json-testdata"/>
    </p:input>
  </p:identity>
  
  <!-- Back downhill to XML -->
  <!--<p:identity  name="convert-supermodel-to-xml"/>-->
  <p:xslt name="convert-supermodel-to-xml">
    <p:input port="stylesheet">
      <p:document href="../converter-gen/supermodel-to-xml.xsl"/>
    </p:input>
  </p:xslt>
  
</p:declare-step>