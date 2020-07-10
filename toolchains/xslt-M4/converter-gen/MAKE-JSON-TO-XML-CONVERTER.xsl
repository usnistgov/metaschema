<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:nm="http://csrc.nist.gov/ns/metaschema"
  
  xmlns:XSLT="http://csrc.nist.gov/ns/oscal/metaschema/xslt-alias"
    exclude-result-prefixes="#all"
    version="3.0">


    <xsl:output indent="yes"/>

  <xsl:namespace-alias stylesheet-prefix="XSLT" result-prefix="xsl"/>
<!-- 
    From a metaschema
    Produces a single XSLT with simple interfaces
      named shortname=json-to-xml-converter.xsl
      -it initial-template 'from-json' or 'from-xdm-json-xml'
      -'file' parameter indicates file name f source data
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
  
  <xsl:mode name="package-converter" on-no-match="shallow-copy"/>
  
  <xsl:param name="trace" as="xs:string">off</xsl:param>
  <xsl:variable name="louder" select="$trace = 'on'"/>
  
  <xsl:variable name="xslt-base" select="document('')/document-uri()"/>
  
  <xsl:import href="../lib/metaschema-metaprocess.xsl"/>
  
  <!-- The $transformation-sequence declares transformations to be applied in order. -->
  <xsl:variable name="produce-json-converter">
    <!-- first compose the metaschema -->
    <nm:transform version="3.0">../compose/metaschema-collect.xsl</nm:transform>
    <nm:transform version="3.0">../compose/metaschema-reduce1.xsl</nm:transform>
    <nm:transform version="3.0">../compose/metaschema-reduce2.xsl</nm:transform>
    <nm:transform version="3.0">../compose/metaschema-digest.xsl</nm:transform>
    
    <!-- next produce definition map -->
    <nm:transform version="3.0">../compose/make-model-map.xsl</nm:transform>
    <nm:transform version="3.0">../compose/unfold-model-map.xsl</nm:transform>
    <nm:transform version="3.0">../compose/reduce-map.xsl</nm:transform>
    
    <nm:transform version="3.0">produce-json-converter.xsl</nm:transform>
    <!--<nm:transform version="3.0">package-json-converter.xsl</nm:transform>-->
  </xsl:variable>
  
  <xsl:template match="/">
    <xsl:variable name="json-converter">
      <xsl:call-template name="nm:process-pipeline">
        <xsl:with-param name="sequence" select="$produce-json-converter"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:apply-templates select="$json-converter" mode="package-converter"/>
  </xsl:template>
  
  <xsl:template match="xsl:stylesheet | xsl:transform" mode="package-converter">
    <xsl:copy>
      <xsl:copy-of select="@*"/>
      <xsl:text>&#xA;</xsl:text>
      <xsl:copy-of select="$transformation-architecture"/>
      <xsl:text>&#xA;</xsl:text>
      <xsl:apply-templates mode="#current"/>
    </xsl:copy>
  </xsl:template>
 
 
  <xsl:variable name="transformation-architecture">
    <xsl:text>&#xA;</xsl:text>
    <xsl:comment> Processing architecture </xsl:comment>
    <XSLT:param name="file" as="xs:string"/>
    <XSLT:param name="produce" as="xs:string">xml</XSLT:param><!-- set to 'supermodel' to produce supermodel intermediate -->
    
    <XSLT:template name="from-json">
      <XSLT:if test="not(unparsed-text-available($file))">
        <nm:ERROR>No file found at { $file }</nm:ERROR>
      </XSLT:if>
    </XSLT:template>
    
    <XSLT:template match="/" name="from-xdm-json-xml">
      <!-- Take source to be JSON in XPath 3.1 (XDM) representation -->
      <XSLT:param name="source" select="/"/>
      <XSLT:variable name="converted-rawmd">
        <XSLT:apply-templates select="$source"/>
      </XSLT:variable>
      <XSLT:variable name="supermodel">
        <XSLT:apply-templates select="$converted-rawmd" mode="convert-markdown"/>
      </XSLT:variable>
      <XSLT:choose>
        <XSLT:when test="$produce = 'supermodel'">
          <XSLT:sequence select="$supermodel"/>
        </XSLT:when>
        <XSLT:otherwise>
          <XSLT:apply-templates select="$supermodel" mode="make-xml"/>
        </XSLT:otherwise>
      </XSLT:choose>   
    </XSLT:template>
  </xsl:variable>
  
</xsl:stylesheet>