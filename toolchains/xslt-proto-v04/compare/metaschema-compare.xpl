<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc"
  xmlns:c="http://www.w3.org/ns/xproc-step" version="1.0"
  xmlns:m="http://csrc.nist.gov/ns/oscal/metaschema/1.0"
  type="m:metaschema-compare" name="metaschema-compare">
  
  
  <p:option name="old.site" select="'https://raw.githubusercontent.com/usnistgov/OSCAL/v1.0.0-milestone2'"/>
  
  <p:option name="new.site" select="'https://raw.githubusercontent.com/usnistgov/OSCAL/master'"/>
  
  <p:option name="schema.path" select="'/src/metaschema/oscal_ssp_metaschema.xml'"/>
  
  <p:option name="old.location" select="$old.site || $schema.path"/>
  <p:option name="new.location" select="$new.site || $schema.path"/>
  
  <p:option name="new.label" select="'Milestone 3 [M3]'"/>
  <p:option name="old.label" select="'Milestone 2 [M2]'"/>
  
  <p:input port="null" primary="true">
    <p:empty/>
  </p:input>
  
  <p:input port="parameters" kind="parameter"/>
  
  <p:output port="a.composed_new" primary="false">
    <p:pipe port="result" step="new.composed"/>
  </p:output>
  <p:serialization port="a.composed_new"     indent="true"/>
  
  <p:output port="a.composed_old" primary="false">
    <p:pipe port="result" step="old.composed"/>
  </p:output>
  <p:serialization port="a.composed_old"     indent="true"/>
  
  <p:output port="b.grouped" primary="false">
    <p:pipe port="result" step="grouped"/>
  </p:output>
  <p:serialization port="b.grouped"     indent="true"/>
  
  <p:output port="c.comparing" primary="true">
    <p:pipe port="result" step="compared"/>
  </p:output>
  <p:serialization port="c.comparing"     indent="true"/>
  
  <!--<p:output port="markdown" primary="false">
    <p:pipe port="result" step="Markdown"/>
  </p:output>-->
  
  <!--<p:serialization port="final"        indent="true"  method="xml"
    doctype-public="-//W3C//DTD XHTML 1.1//EN"
    doctype-system="http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd"
   />-->
  <!--<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.1//EN" 
   "http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd">-->
  
  
  <p:load name="echo.new.metaschema">
    <p:with-option name="href" select="$new.location"/>
  </p:load>
  
  <p:xslt name="new.composed">
    <p:input port="stylesheet">
      <p:document href="metaschema-compose.xsl"/>
    </p:input>
  </p:xslt>
  
  <p:sink/>
  
  <p:load name="echo.old.metaschema">
    <p:with-option name="href" select="$old.location"/>
  </p:load>
  
  
  <p:xslt name="old.composed">
    <p:input port="stylesheet">
      <p:document href="metaschema-compose.xsl"/>
    </p:input>
  </p:xslt>
  
  <p:pack name="grouped">
    <p:input port="source">
      <p:pipe port="result" step="new.composed"/>
    </p:input>
    <p:input port="alternate">
      <p:pipe port="result" step="old.composed"/>
    </p:input>
    <p:with-option name="wrapper" select="xs:QName('m:compare')"/>
  </p:pack>
  
  <p:xslt name="compared" version="3.0">
    <p:input port="stylesheet">
      <p:document href="compare-metaschemas.xsl"/>
    </p:input>
    <p:with-param name="new-label" select="$new.label"/>
    <p:with-param name="old-label" select="$old.label"/>
  </p:xslt>

  <!--
  <p:xslt name="rendered" version="1.0">
    <p:input port="stylesheet">
      <!-\-<p:document href="../XSLT/HTML/oscal-basic-display.xsl"/>-\->
      <p:document href="../XSLT/oscal-with-nav-display.xsl"/>
    </p:input>
  </p:xslt>
  
  <!-\- Last chance for comments, PIs etc. -\->
  <p:xslt name="final">
    <p:with-param name="xslt-process" select="' OSCAL PROFILE RESOLUTION AND RENDERING pipeline -profile-resolve-and-display.xpl- '"/>
    <p:input port="stylesheet">
      <p:document href="../XSLT/html-finalize.xsl"/>
    </p:input>
    <!-\-<p:input port="parameters" kind="parameter"/>-\->
      
  </p:xslt>-->
  
 
</p:declare-step>