<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc"
  xmlns:c="http://www.w3.org/ns/xproc-step" version="1.0"
  xmlns:m="http://csrc.nist.gov/ns/oscal/metaschema/1.0"
  type="m:dataset-analyze" name="dataset-analyze">
  
  
  <p:input port="input" primary="true">
    <p:empty/>
  </p:input>
  
  <!--<p:option name="document-collection" select="'file:/C:/Users/wap1/Documents/usnistgov/OSCAL/content/nist.gov/SP800-53/rev4/xml/NIST_SP-800-53_rev4_catalog.xml'"/>
  -->
  <p:option name="document-collection" select="'https://raw.githubusercontent.com/HistoryAtState/frus/master/volumes/frus1865p3.xml'"/>
  
  
  <p:input port="parameters" kind="parameter"/>
  
  <p:output port="a.abstract-tree" primary="false">
    <p:pipe port="result" step="abstract-tree"/>
  </p:output>
  <p:serialization port="a.abstract-tree" indent="true"/>
  
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
  
  
  <p:xslt name="abstract-tree">
    <p:input port="stylesheet">
      <p:document href="abstract-dataset.xsl"/>
    </p:input>
    <p:with-param name="collection" select="$document-collection"/>
  </p:xslt>
  
  <p:xslt name="analyze" version="3.0">
    <p:input port="stylesheet">
      <p:document href="analyze-abstract-tree.xsl"/>
    </p:input>
  </p:xslt>
 
</p:declare-step>