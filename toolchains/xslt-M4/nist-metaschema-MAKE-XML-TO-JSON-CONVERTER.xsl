<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:nm="http://csrc.nist.gov/ns/metaschema"
  xmlns="http://csrc.nist.gov/ns/oscal/metaschema/1.0/supermodel"
  xpath-default-namespace="http://csrc.nist.gov/ns/oscal/metaschema/1.0/supermodel"
  xmlns:XSLT="http://csrc.nist.gov/ns/oscal/metaschema/xslt-alias"
  exclude-result-prefixes="#all"
  version="3.0">


    <xsl:output indent="yes"/>

  <xsl:namespace-alias stylesheet-prefix="XSLT" result-prefix="xsl"/>
  
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
  
  <xsl:mode name="package-converter" on-no-match="shallow-copy"/>
  
  <xsl:param name="trace" as="xs:string">off</xsl:param>
  <xsl:variable name="louder" select="$trace = 'on'"/>
  
  <xsl:variable name="xslt-base" select="document('')/document-uri()"/>
  
  <xsl:import href="lib/metaschema-metaprocess.xsl"/>
  
  <!-- The $transformation-sequence declares transformations to be applied in order. -->
  <xsl:variable name="produce-xml-converter">
    <!-- first compose the metaschema -->
    <nm:transform version="3.0">compose/metaschema-collect.xsl</nm:transform>
    <nm:transform version="3.0">compose/metaschema-reduce1.xsl</nm:transform>
    <nm:transform version="3.0">compose/metaschema-reduce2.xsl</nm:transform>
    <nm:transform version="3.0">compose/metaschema-digest.xsl</nm:transform>
    
    <!-- next produce definition map -->
    <nm:transform version="3.0">compose/make-model-map.xsl</nm:transform>
    <nm:transform version="3.0">compose/unfold-model-map.xsl</nm:transform>
    <nm:transform version="3.0">compose/reduce-map.xsl</nm:transform>
    
    <!--<nm:transform version="3.0">produce-xml-converter.xsl</nm:transform>-->
  </xsl:variable>
  
  <xsl:variable name="metaschema-source" select="/"/>
  
  <xsl:template match="/">
    <xsl:variable name="converter">
      <xsl:call-template name="nm:process-pipeline">
        <xsl:with-param name="sequence" select="$produce-xml-converter"/>
      </xsl:call-template>
    </xsl:variable>
    
    <xsl:apply-templates select="$converter" mode="package-converter"/>
  </xsl:template>
  
<!-- 'package-converter' enhances the code produced from the metaschema-json-converter pipeline:
       adds interfaces for handling json inputs ($transformation-architecture)
       provides pipeline infrastructure for supermodel production and serialization
       provides templates from utility filters (Markdown to markup; XML writing)
  -->

  <!-- nb since by default the json converter passes markdown through, in mode 'package-converter'
       we also rewrite its templates for producing contents of markup-line and markup-multiline,
       hitting the 'parse-markdown' template from the markdown processor. -->
  

  <xsl:template match="xsl:stylesheet | xsl:transform" mode="package-converter">
    <xsl:copy copy-namespaces="true">
      <xsl:copy-of select="@*"/>
      <xsl:text>&#xA;</xsl:text>
      <xsl:comment> XML to JSON conversion: pipeline </xsl:comment>
      <xsl:copy-of select="$transformation-architecture"/>
      
      <xsl:comment> XML to JSON conversion: object filters </xsl:comment>
      
      <xsl:text>&#xA;</xsl:text>
      <xsl:apply-templates mode="#current"/>
      
      <xsl:text>&#xA;</xsl:text>
      <xsl:comment> XML to JSON conversion: Supermodel serialization as JSON
        including markdown production </xsl:comment>
      <xsl:apply-templates mode="package-converter" select="document('supermodel-to-json.xsl')/xsl:*/( xsl:variable | xsl:template )"/>
    </xsl:copy>
  </xsl:template>
 
  <xsl:variable name="transformation-architecture">
    <xsl:text>&#xA;</xsl:text>
    <xsl:comment> Supports either of two interfaces:
      simply handle the XML as source (easier), producing the JSON as output, or
      use arguments (equivalent to): -it from-xml produce=json file=[file] (mirrors the JSON converter interface) </xsl:comment>
    <xsl:text>&#xA;</xsl:text>
    <xsl:comment> Parameter 'produce' supports acquiring outputs other than JSON:
      produce=xpath produces XPath JSON (an XML syntax)
      produce=supermodel produces intermediate (internal) 'supermodel' format</xsl:comment>
    <xsl:text>&#xA;</xsl:text>
    <xsl:comment> Parameter setting 'json-indent=yes' produces JSON indented using the internal serializer</xsl:comment>
    <XSLT:param name="file" as="xs:string"/>
    <XSLT:param name="produce" as="xs:string">json</XSLT:param>
    <!-- set to 'xdm-json-xml' or 'xpath' for XPath JSON XML
                'supermodel' to produce supermodel intermediate -->
    <XSLT:param name="json-indent" as="xs:string">no</XSLT:param>
    
    <XSLT:output omit-xml-declaration="true"/>
    
    <XSLT:variable name="write-options" as="map(*)">
      <XSLT:map>
        <XSLT:map-entry key="'indent'" expand-text="true">{ $json-indent='yes' }</XSLT:map-entry>
      </XSLT:map>
    </XSLT:variable>
    
    <XSLT:template match="/" name="from-xml">
      <!-- Take source to be JSON in XPath 3.1 (XDM) representation -->
      <XSLT:param name="source">
        <XSLT:choose>
          <xsl:comment> evaluating $file as URI relative to nominal source directory </xsl:comment>
          <XSLT:when test="exists($file)">
            <XSLT:try select="$file ! document(.,/)" xmlns:err="http://www.w3.org/2005/xqt-errors">
              <XSLT:catch expand-text="true">
                <nm:ERROR code="{{ $err:code }}">{ $err:description }</nm:ERROR>
              </XSLT:catch>
            </XSLT:try>    
          </XSLT:when>
          <XSLT:otherwise>
            <XSLT:sequence select="/"/>
          </XSLT:otherwise>
        </XSLT:choose>
      </XSLT:param>
      <!-- first step produces supermodel from input XML -->
      <XSLT:variable name="supermodel">
        <XSLT:apply-templates select="$source"/>
      </XSLT:variable>
      <XSLT:choose>
        <XSLT:when test="$produce = 'supermodel'">
          <XSLT:sequence select="$supermodel"/>
        </XSLT:when>
        <XSLT:otherwise>
          <XSLT:variable name="new-json-xml">
            <XSLT:apply-templates select="$supermodel" mode="write-json"/>
          </XSLT:variable>
          <XSLT:when test="matches($produce,('xpath|xdm|xml')'">
            <XSLT:sequence select="$new-json-xml"/>
          </XSLT:when>
          <XSLT:otherwise>
            <XSLT:try select="xml-to-json($new-json-xml,$write-options)" xmlns:err="http://www.w3.org/2005/xqt-errors">
              <XSLT:catch>
                <nm:ERROR code="{{ $err:code }}">{ $err:description }</nm:ERROR>
              </XSLT:catch>
            </XSLT:try>  
          </XSLT:otherwise>
        </XSLT:otherwise>
      </XSLT:choose>   
    </XSLT:template>
  </xsl:variable>
  
</xsl:stylesheet>