<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc"
  xmlns:c="http://www.w3.org/ns/xproc-step" version="1.0"
  xmlns:m="http://csrc.nist.gov/ns/oscal/metaschema/1.0"
  type="m:metaschema-analyze" name="metaschema-analyze">
  
  
  <p:input port="input" primary="true" sequence="false"/>
  
  <p:input port="parameters" kind="parameter"/>
  
  <p:output port="a.composed" primary="false">
    <p:pipe port="result" step="compose"/>
  </p:output>
  <p:serialization port="a.composed"     indent="true"/>
  
  <p:output port="c.analysis" primary="true">
    <p:pipe port="result" step="analyze"/>
  </p:output>
  <p:serialization port="c.analysis"     indent="true"/>
  
  <!--<p:output port="markdown" primary="false">
    <p:pipe port="result" step="Markdown"/>
  </p:output>-->
  
  <!--<p:serialization port="final"        indent="true"  method="xml"
    doctype-public="-//W3C//DTD XHTML 1.1//EN"
    doctype-system="http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd"
   />-->
  <!--<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.1//EN" 
   "http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd">-->
  
  
  <p:xslt name="compose">
    <p:input port="stylesheet">
      <p:document href="metaschema-compose.xsl"/>
    </p:input>
  </p:xslt>
  
  <p:xslt name="analyze" version="3.0">
    <p:input port="stylesheet">
      <p:document href="analyze-metaschema.xsl"/>
    </p:input>
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