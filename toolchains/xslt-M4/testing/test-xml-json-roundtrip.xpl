<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc"
  xmlns:c="http://www.w3.org/ns/xproc-step" version="1.0"
  xmlns:metaschema="http://csrc.nist.gov/ns/metaschema/1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  type="metaschema:test-roundtrip-conversions" name="test-roundtrip-conversions">
  
  <!-- &&& &&& &&& &&& &&& &&& &&& &&& &&& &&& &&& &&& &&& &&& &&& &&& &&& &&& -->
  <!-- Ports -->
  
  <p:input port="metaschema-source" primary="true"/>
  <p:input port="testdata-xml"      primary="false"/>
  <p:input port="parameters" kind="parameter"/>
  
  <p:serialization port="composed-metaschema" indent="true"/>
  <p:output        port="composed-metaschema" primary="false">
    <p:pipe        port="result"       step="metaschema-composed"/>
  </p:output>
  
  <p:serialization port="definition-model" indent="true"/>
  <p:output        port="definition-model" primary="false">
    <p:pipe        port="result"           step="definition-map"/>
  </p:output>
  
  <p:serialization port="e.xml-supermodel-conversion" indent="true"/>
  <p:output        port="e.xml-supermodel-conversion" primary="false">
    <p:pipe        port="result"               step="make-xml-converter"/>
  </p:output>
  
  <p:serialization port="e.json-supermodel-conversion" indent="true"/>
  <p:output        port="e.json-supermodel-conversion" primary="false">
    <p:pipe        port="result"               step="make-json-converter"/>
  </p:output>
  
  <p:serialization port="f_testdata-xml-source" indent="true"/>
  <p:output        port="f_testdata-xml-source" primary="false">
    <p:pipe        port="testdata-xml"           step="test-roundtrip-conversions"/>
  </p:output>
  
  <p:serialization port="g_supermodel.1-is-from-xml-testdata" indent="true"/>
  <p:output        port="g_supermodel.1-is-from-xml-testdata" primary="false">
    <p:pipe        port="result"          step="convert-xml-testdata"/>
  </p:output>
  
  <p:serialization port="h_MIDWAY_supermodel.1-as-xml" indent="true"/>
  <p:output        port="h_MIDWAY_supermodel.1-as-xml" primary="false">
    <p:pipe        port="result" step="convert-supermodel.1-to-xml"/>
  </p:output>
  
  <p:serialization port="h_MIDWAY_supermodel.1-as-xpath-json" indent="true"/>
  <p:output        port="h_MIDWAY_supermodel.1-as-xpath-json" primary="false">
    <p:pipe        port="result"                step="convert-supermodel.1-to-json-xml"/>
  </p:output>
  
  <p:serialization port="h_MIDWAY_supermodel.1-as-json" indent="true" method="text"/>
  <p:output        port="h_MIDWAY_supermodel.1-as-json" primary="false">
    <p:pipe        port="result"                step="serialize-supermodel.1-as-json"/>
  </p:output>
  
  <p:serialization port="i1_raw-md-supermodel.2-is-from-MIDWAY-xpath-json" indent="true"/>
  <p:output        port="i1_raw-md-supermodel.2-is-from-MIDWAY-xpath-json" primary="false">
    <p:pipe        port="result" step="convert-jsonified-testdata"/>
  </p:output>
  
  <p:serialization port="i2_supermodel.2" indent="true"/>
  <p:output        port="i2_supermodel.2" primary="false">
    <p:pipe        port="result" step="convert-markdown-to-markup"/>
  </p:output>
  
  <p:serialization port="k_xml-from-supermodel.2" indent="true"/>
  <p:output        port="k_xml-from-supermodel.2" primary="false">
    <p:pipe        port="result" step="convert-json-supermodel-to-xml"/>
  </p:output>
 
  <!-- &&& &&& &&& &&& &&& &&& &&& &&& &&& &&& &&& &&& &&& &&& &&& &&& &&& &&& -->
  <!-- Import (subpipeline) -->
  
  <p:import href="../metaschema-compose.xpl"/>
  
  <!-- &&& &&& &&& &&& &&& &&& &&& &&& &&& &&& &&& &&& &&& &&& &&& &&& &&& &&& -->
  <!-- Pipeline -->
  
  <p:identity name="metaschema-source"/>
  
  <metaschema:metaschema-compose name="compose"/>
  
  <p:identity name="metaschema-composed"/>
  
  <!--<p:identity  name="make-model-map"/>-->
  <p:xslt name="make-model-map">
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
  
  <p:xslt name="make-xml-converter">
    <p:input port="stylesheet">
      <p:document href="../converter-gen/produce-xml-converter.xsl"/>
    </p:input>
  </p:xslt>
  
  <p:xslt name="convert-xml-testdata">
    <p:input port="source">
      <p:pipe port="testdata-xml" step="test-roundtrip-conversions"/>
    </p:input>
    <p:input port="stylesheet">
      <p:pipe step="make-xml-converter" port="result"/>
    </p:input>
  </p:xslt>
  
  <p:identity name="capture-supermodel.1"/>
  
  <!-- Now going back downhill to XML -->
  <p:xslt name="convert-supermodel.1-to-xml">
    <p:input port="stylesheet">
      <p:document href="../converter-gen/supermodel-to-xml.xsl"/>
    </p:input>
  </p:xslt>
  
  <p:sink/>
  
  <!-- Back downhill to JSON -->
  
  
  <!-- Now we map to XPath JSON -->
  <p:xslt name="convert-supermodel.1-to-json-xml">
    <p:input port="source">
      <p:pipe port="result" step="convert-xml-testdata"/>
    </p:input>
    <p:input port="stylesheet">
      <p:document href="../converter-gen/supermodel-to-json.xsl"/>
    </p:input>
  </p:xslt>
  
  <!-- Finally we serialize to ensure JSONness -->
  <!--<p:identity name="serialize-json"/>-->
  <p:xslt name="serialize-supermodel.1-as-json">
    <p:input port="stylesheet">
      <p:document href="../lib/xpath-json-to-json.xsl"/>
    </p:input>
  </p:xslt>
 
  <p:sink/>
 
  <!-- Now to test the JSON to XML conversion - back around -->
  
  <!-- Producing the JSON to supermodel converter -->
  <p:xslt name="make-json-converter">
    <p:input port="source">
      <p:pipe port="result" step="definition-map"/>
    </p:input>
    <p:input port="stylesheet">
      <p:document href="../converter-gen/produce-json-converter.xsl"/>
    </p:input>
  </p:xslt>
  
  <p:sink/>
  
  <!-- Applying the JSON converter, from the serialized JSON we produce the supermodel again -->
  <!--<p:identity name="convert-jsonified-testdata">
    <p:input port="source">
      <p:pipe step="make-json-converter" port="result"/>
    </p:input>
  </p:identity>-->
  <p:xslt name="convert-jsonified-testdata">
    <p:input port="source">
      <p:pipe port="result" step="convert-supermodel.1-to-json-xml"/>
    </p:input>
    <p:input port="stylesheet">
      <p:pipe step="make-json-converter" port="result"/>
    </p:input>
  </p:xslt>
  
  <!--<p:identity name="convert-markdown-to-markup"/>-->
  <p:xslt name="convert-markdown-to-markup">
    <p:input port="stylesheet">
      <p:document href="../converter-gen/markdown-to-supermodel-xml-converter.xsl"/>
    </p:input>
  </p:xslt>
  
  <!-- Go back down hill to XML -->
  <p:xslt name="convert-json-supermodel-to-xml">
    <p:input port="stylesheet">
      <p:document href="../converter-gen/supermodel-to-xml.xsl"/>
    </p:input>
  </p:xslt>

</p:declare-step>