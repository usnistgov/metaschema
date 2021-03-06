<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc" xmlns:c="http://www.w3.org/ns/xproc-step"
  version="1.0" xmlns:metaschema="http://csrc.nist.gov/ns/metaschema/1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" type="metaschema:make-all-metaschema-docs"
  name="make-all-metaschema-docs">

  <!--
    
    docs rework punchlist
      o review specs for link targets
      o review pipelines for possible improvements
      o expand pipelines to produce (8 pp total):
        x maps x2
        x references (full tree) x2
        o definitions x2
          o spin from Metaschema directly (no explosion)
          o revise/reduce old json-docs-hugo-uswds.xsl
        x index - with pointers to reference page x2
        
        o link everything up
          maps to reference
          index to reference
          defs to index? defs to reference?
          
      o replicate new JSON logic to XML
      o update all anchors and linking
      
  -->

  <!-- &&& &&& &&& &&& &&& &&& &&& &&& &&& &&& &&& &&& &&& &&& &&& &&& &&& &&& -->
  <!-- Ports -->

  <p:input port="source" primary="true"/>
  
  <p:input port="parameters" kind="parameter"/>

  <p:option name="metaschema-id" select="'oscal'"/>
  
  <p:serialization port="JSON-object-outline-div" indent="true"/>
  <p:output        port="JSON-object-outline-div" primary="false">
    <p:pipe        port="result"               step="make-json-model-map"/>
  </p:output>
  
  <p:serialization port="JSON-object-reference-div" indent="true"/>
  <p:output        port="JSON-object-reference-div" primary="false">
    <p:pipe        port="result"                     step="render-json-object-reference"/>
  </p:output>
  
  <p:serialization port="JSON-object-index-div" indent="true"/>
  <p:output        port="JSON-object-index-div" primary="false">
    <p:pipe        port="result"                 step="render-json-object-index"/>
  </p:output>
  
  <p:serialization port="JSON-definitions-div" indent="true"/>
  <p:output        port="JSON-definitions-div" primary="false">
    <p:pipe        port="result"                step="render-json-definitions"/>
  </p:output>

  <p:serialization port="XML-element-outline-div" indent="true"/>
  <p:output        port="XML-element-outline-div" primary="false">
    <p:pipe        port="result"               step="make-xml-model-map"/>
  </p:output>
  
  <p:serialization port="XML-element-reference-div" indent="true"/>
  <p:output        port="XML-element-reference-div" primary="false">
    <p:pipe        port="result"               step="render-xml-element-reference"/>
  </p:output>
  
  <p:serialization port="XML-element-index-div" indent="true"/>
  <p:output        port="XML-element-index-div" primary="false">
    <p:pipe        port="result"               step="render-xml-element-index"/>
  </p:output>
  
  <p:serialization port="XML-definitions-div" indent="true"/>
  <p:output        port="XML-definitions-div" primary="false">
    <p:pipe        port="result"               step="render-xml-definitions"/>
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
  <p:xslt name="annotate-composition">
    <p:input port="stylesheet">
      <p:document href="compose/annotate-composition.xsl"/>
    </p:input>
  </p:xslt>
  
  <p:xslt name="make-abstract-map">
    <p:input port="stylesheet">
      <p:document href="compose/make-model-map.xsl"/>
    </p:input>
  </p:xslt>
  
<!-- next step unfolds map (making groups into wrappers)
     and expands identifiers -->
  <p:xslt name="unfold-instance-map">
    <p:input port="stylesheet">
      <p:document href="compose/unfold-model-map.xsl"/>
    </p:input>
  </p:xslt>
  
  <p:xslt name="annotate-instance-map">
    <p:input port="stylesheet">
      <p:document href="compose/annotate-model-map.xsl"/>
    </p:input>
  </p:xslt>
  
   <!--Making the XML model map -->
   <p:xslt name="make-xml-element-tree">
    <!--<p:input port="source">
      <p:pipe port="result" step="unfold-model-map"/>
    </p:input>-->
    <p:input port="stylesheet">
      <p:document href="document/xml/element-tree.xsl"/>
    </p:input>
  </p:xslt>
  
  <p:xslt name="make-xml-model-map">
    <p:input port="stylesheet">
      <p:document href="document/xml/element-map-html.xsl"/>
    </p:input>
    <!--<p:with-param name="reference-page" select="$metaschema-id || '-xml-reference.html'"/>-->
  </p:xslt>
  
  <p:xslt name="style-xml-model-map">
    <p:input port="stylesheet">
      <p:document href="document/hugo-css-emulator.xsl"/>
    </p:input>
    <p:with-param name="with-toc" select="'no'"/>
    <p:with-param name="metaschema-code" select="$metaschema-id"/>
  </p:xslt>
  <!-- Done with that. -->
  <p:sink/>
  
  <p:xslt name="render-xml-element-reference">
    <p:input port="source">
      <p:pipe port="result" step="make-xml-element-tree"/>
    </p:input>
    <p:input port="stylesheet">
      <p:document href="document/xml/element-reference-html.xsl"/>
    </p:input>
    <!--<p:with-param name="json-reference-page" select="$metaschema-id || '-json-reference.html'"/>
    <p:with-param name="xml-map-page" select="$metaschema-id || '-xml-outline.html'"/>-->
  </p:xslt>
  
  <!--  Wrapping this up to write and view locally/standalone if wanted -->
  <p:xslt name="style-xml-element-reference">
    <p:input port="stylesheet">
      <p:document href="document/hugo-css-emulator.xsl"/>
    </p:input>
    <p:with-param name="metaschema-code" select="$metaschema-id"/>
  </p:xslt>
  
  <p:sink/>
  <!-- The JSON object index is produced from the full blown out instance tree
       as already rendered into HTML   -->
  <p:xslt name="render-xml-element-index">
    <p:input port="source">
      <p:pipe port="result" step="make-xml-element-tree"/>
    </p:input>
    <!--<p:with-option name="initial-mode" select="QName('','make-page')"/>-->
    <p:input port="stylesheet">
      <p:document href="document/xml/element-index-html.xsl"/>
    </p:input>
    <!--<p:with-param name="reference-page" select="$metaschema-id || '-xml-reference.html'"/>-->
  </p:xslt>
  
  <p:xslt name="style-xml-element-index">
    <!--<p:with-option name="initial-mode" select="QName('','make-page')"/>-->
    <p:input port="stylesheet">
      <p:document href="document/hugo-css-emulator.xsl"/>
    </p:input>
    <p:with-param name="metaschema-code" select="$metaschema-id"/>
  </p:xslt>
  
  <p:sink/>
  

  <!-- For the straight-up definitions directory we go back to the composed metaschema before explosion -->
  <p:xslt name="render-xml-definitions">
    <p:input port="source">
      <p:pipe port="result" step="composed"/>
    </p:input>
    <p:input port="stylesheet">
      <!-- XXX fix up / reduce this XSLT (from RC2) -->
      <p:document href="document/xml/xml-definitions.xsl"/>
    </p:input>
    <!--<p:with-param name="xml-reference-page" select="$metaschema-id || '-xml-reference.html'"/>    
    <p:with-param name="json-definitions-page" select="$metaschema-id || '-json-definitions.html'"/>-->
  </p:xslt>
  
  <p:xslt name="style-xml-definitions">
    <p:input port="stylesheet">
      <p:document href="document/hugo-css-emulator.xsl"/>
    </p:input>
    <p:with-param name="metaschema-code" select="$metaschema-id"/>
  </p:xslt>
  
  <p:sink/>
  
  
  <!--  JSON pipelines start here -->
  <!--  A representation of the JSON object tree is rendered out from the unfolded blown out model map -->
  <p:xslt name="make-json-object-tree">
    <p:input port="source">
      <p:pipe port="result" step="annotate-instance-map"/>
    </p:input>
    <p:input port="stylesheet">
      <p:document href="document/json/object-tree.xsl"/>
    </p:input>
  </p:xslt>

  <!-- From this, we first make the model map (ready to inject into the web build) -->
  <p:xslt name="make-json-model-map">
    <p:input port="stylesheet">
      <p:document href="document/json/object-map-html.xsl"/>
    </p:input>
    <!--<p:with-param name="reference-page" select="$metaschema-id || '-json-reference.html'"/>-->
  </p:xslt>

  <!--  Next we wrap this up to write and view locally/standalone if wanted -->
  <p:xslt name="style-json-model-map">
    <!--<p:with-option name="initial-mode" select="QName('','make-page')"/>-->
    <p:input port="stylesheet">
      <p:document href="document/hugo-css-emulator.xsl"/>
    </p:input>
    <p:with-param name="with-toc"        select="'no'"/>
    <p:with-param name="metaschema-code" select="$metaschema-id"/>
    <p:with-param name="format"          select="'json'"/>
  </p:xslt>

  <!-- Done with that. -->
  <p:sink/>


  <!--Next, picking up from the object tree we make the main reference document -->

  <!-- Making page contents for site -->
  <p:xslt name="render-json-object-reference">
    <p:input port="source">
      <p:pipe port="result" step="make-json-object-tree"/>
    </p:input>
    <!--<p:with-option name="initial-mode" select="QName('','make-page')"/>-->
    <p:input port="stylesheet">
      <p:document href="document/json/object-reference-html.xsl"/>
    </p:input>
    <!--<p:with-param name="xml-reference-page" select="$metaschema-id || '-xml-reference.html'"/>
    <p:with-param name="json-map-page" select="$metaschema-id || '-json-outline.html'"/>-->
  </p:xslt>

  <!--  Wrapping this up to write and view locally/standalone if wanted -->
  <p:xslt name="style-json-object-reference">
    <p:input port="stylesheet">
      <p:document href="document/hugo-css-emulator.xsl"/>
    </p:input>
    <p:with-param name="metaschema-code" select="$metaschema-id"/>
    <p:with-param name="format"          select="'json'"/>
  </p:xslt>

  <p:sink/>

  <!-- The JSON object index is produced from the full blown out instance tree
       as already rendered into HTML   -->
  <p:xslt name="render-json-object-index">
    <!--<p:with-option name="initial-mode" select="QName('','make-page')"/>-->
    <p:input port="source">
      <p:pipe port="result" step="make-json-object-tree"/>
    </p:input>
    <p:input port="stylesheet">
      <p:document href="document/json/object-index-html.xsl"/>
    </p:input>
    <!--<p:with-param name="reference-page" select="$metaschema-id || '-json-reference.html'"/>-->
  </p:xslt>
  
  <p:xslt name="style-json-object-index">
    <p:input port="stylesheet">
      <p:document href="document/hugo-css-emulator.xsl"/>
    </p:input>
    <p:with-param name="metaschema-code" select="$metaschema-id"/>
    <p:with-param name="format"          select="'json'"/>
  </p:xslt>
  
  <p:sink/>
  
  <!-- For the straight-up definitions directory we go back to the composed metaschema before explosion -->
  <p:xslt name="render-json-definitions">
    <p:input port="source">
      <p:pipe port="result" step="composed"/>
    </p:input>
    <p:input port="stylesheet">
      <!-- XXX fix up / reduce this XSLT (from RC2) -->
      <p:document href="document/json/json-definitions.xsl"/>
    </p:input>
    <!--<p:with-param name="xml-definitions-page" select="$metaschema-id || '-xml-definitions.html'"/>
    <p:with-param name="json-reference-page" select="$metaschema-id || '-json-reference.html'"/>-->
  </p:xslt>

  <p:xslt name="style-json-definitions">
    <p:input port="stylesheet">
      <p:document href="document/hugo-css-emulator.xsl"/>
    </p:input>
    <p:with-param name="metaschema-code" select="$metaschema-id"/>
    <p:with-param name="format"          select="'json'"/>
  </p:xslt>

  <p:sink/>

  
</p:declare-step>