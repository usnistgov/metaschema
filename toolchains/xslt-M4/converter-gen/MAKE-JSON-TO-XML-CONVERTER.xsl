<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:nm="http://csrc.nist.gov/ns/metaschema"
    exclude-result-prefixes="#all"
    version="3.0">

    <xsl:output indent="yes"/>

<!-- 
    From a metaschema
    Produces a single XSLT with simple interfaces
      named shortname=json-to-xml-converter.xsl
      -initial-template 'from-json' or 'from-xdm-json-xml'
      -'file' parameter indicates file name
      -produce=xml is default
      -produce=supermodel produces supermodel (intermediate)

    stylesheet sequence
    
    source: metaschema
      pipeline through external calls to
        compose
        produce definition map
        produce JSON converter
      result is JSON converter: stitch that into a result XSLT
        i:'from-json'
          JSON parsing 'file'
        i:'from=xdm-json-xml'
          reading XML source directly
        JSON converter +
        post-process supermodel results with XML serializer code
      
      output XSLT performs a three step:
        convert (or read) JSON in
        convert to supermodel
        convert to XML
    -->
  
  <xsl:output method="xml" indent="yes"/>
  
  <!-- Turning $trace to 'on' will
         - emit runtime messages with each transformation, and
         - retain nm:ERROR and nm:WARNING messages in results. -->
  
  <xsl:param name="trace" as="xs:string">off</xsl:param>
  <xsl:variable name="louder" select="$trace = 'on'"/>
  
  <xsl:variable name="xslt-base" select="document('')/document-uri()"/>
  
  <xsl:import href="../lib/metaschema-metaprocess.xsl"/>
  
  <!-- The $transformation-sequence declares transformations to be applied in order. -->
  <xsl:variable name="transformation-sequence">
    <nm:transform version="3.0">../compose/metaschema-collect.xsl</nm:transform>
    <nm:transform version="3.0">../compose/metaschema-reduce1.xsl</nm:transform>
    <nm:transform version="3.0">../compose/metaschema-reduce2.xsl</nm:transform>
    <nm:transform version="3.0">../compose/metaschema-digest.xsl</nm:transform>
    
    <nm:transform version="3.0">produce-json-converter.xsl</nm:transform>
    <nm:transform version="3.0">package-json-converter.xsl</nm:transform>
  </xsl:variable>
</xsl:stylesheet>