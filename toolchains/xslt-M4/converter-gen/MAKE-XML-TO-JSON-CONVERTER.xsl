<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:nm="http://csrc.nist.gov/ns/metaschema"
  exclude-result-prefixes="#all"
  version="3.0">
  
  <xsl:output indent="yes"/>
  
    <xsl:output indent="yes"/>

<!-- 
    From a metaschema
    Produces a single XSLT with simple interfaces
      named shortname=xml-to-json-converter.xsl
      -source - XML to be converted to JSON
      produce='json' (default) emit serialized JSON
      produce='supermodel' emit supermodel notation
      produce='xdm-json-xml' emit XPath XML notation JSON
    
      
    stylesheet sequence
    
    source: metaschema
      pipeline through external calls to
        compose
        produce definition map
        produce XML converter
      result is XML converter: stitch that into a result XSLT
        XML converter + supermodel JSON serializer
          producing optional intermediate results
      
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
    <!-- composed metaschema -->
    
    <!-- definition map -->
    <!--<nm:transform version="3.0">produce-xml-converter.xsl</nm:transform>-->
    <!--<nm:transform version="3.0">package-xml-converter.xsl</nm:transform>-->
  </xsl:variable>
</xsl:stylesheet>