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
  
  <xsl:import href="lib/metaschema-metaprocess.xsl"/>
  
  <!-- The $transformation-sequence declares transformations to be applied in order. -->
  <xsl:variable name="produce-json-converter">
    <!-- first compose the metaschema -->
    <nm:transform version="3.0">compose/metaschema-collect.xsl</nm:transform>
    <nm:transform version="3.0">compose/metaschema-reduce1.xsl</nm:transform>
    <!--<nm:transform version="3.0">compose/metaschema-reduce2.xsl</nm:transform>-->
    <nm:transform version="3.0">compose/metaschema-digest.xsl</nm:transform>
    
    <!-- next produce definition map -->
    <nm:transform version="3.0">compose/make-model-map.xsl</nm:transform>
    <nm:transform version="3.0">compose/unfold-model-map.xsl</nm:transform>
    <nm:transform version="3.0">compose/reduce-map.xsl</nm:transform>
    
    <nm:transform version="3.0">converter-gen/produce-json-converter.xsl</nm:transform>
    <!--<nm:transform version="3.0">package-json-converter.xsl</nm:transform>-->
  </xsl:variable>
  
  <xsl:variable name="metaschema-source" select="/"/>
  
  <xsl:template match="/">
    <xsl:variable name="json-converter">
      <xsl:call-template name="nm:process-pipeline">
        <xsl:with-param name="sequence" select="$produce-json-converter"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:apply-templates select="$json-converter" mode="package-converter"/>
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
      <xsl:comment> JSON to XML conversion: pipeline </xsl:comment>
      <xsl:copy-of select="$transformation-architecture"/>
      
      <xsl:comment> JSON to XML conversion: object filters </xsl:comment>
      
      <xsl:text>&#xA;</xsl:text>
      <xsl:apply-templates mode="#current"/>
      
      <!--  from the mardown to markup converter, we grab all the templates in all the modes;
           but not unmoded templates (intended for pipeline use) or named templates apart from 'parse'-->
      <xsl:text>&#xA;</xsl:text>
      <xsl:comment> JSON to XML conversion: Markdown to markup inferencing </xsl:comment>
      
      <xsl:copy-of select="document('markdown-to-supermodel-xml-converter.xsl')/xsl:*/
        ( xsl:call-template[@name='parse'] | xsl:*[@mode] | xsl:variable[not(matches(@name,'example'))] )"/>
      
      
      <xsl:text>&#xA;</xsl:text>
      <xsl:comment> JSON to XML conversion: Supermodel serialization as XML </xsl:comment>
      <xsl:apply-templates mode="package-converter" select="document('supermodel-to-xml.xsl')/xsl:*/( xsl:* except xsl:output )"/>
    </xsl:copy>
  </xsl:template>
 
  <xsl:template mode="package-converter"
    match="xsl:template[value/@as-type=('markup-line','markup-multiline')][@mode='get-value-property']">
    <xsl:message>boo!</xsl:message>
    <XSLT:template match="{ @match }" mode="get-value-property">
      <value as-type="markup-multiline" in-json="string">
        <XSLT:call-template name="parse-markdown">
          <XSLT:with-param name="markdown-str" select="string(.)"/>
        </XSLT:call-template>
      </value>
    </XSLT:template>
  </xsl:template>
  
  <xsl:template mode="package-converter"
    match="xsl:template[@mode=('write-xml','cast-prose')]/xsl:element/@namespace">
    <xsl:attribute name="namespace" select="$metaschema-source/*/namespace" xpath-default-namespace="http://csrc.nist.gov/ns/oscal/metaschema/1.0"/>
  </xsl:template>
  
  
  
 <!--<xsl:template match=""-->
  <xsl:variable name="transformation-architecture">
    <xsl:text>&#xA;</xsl:text>
    <xsl:comment> Processing architecture </xsl:comment>
    <XSLT:param name="file" as="xs:string"/>
    <XSLT:param name="produce" as="xs:string">xml</XSLT:param><!-- set to 'supermodel' to produce supermodel intermediate -->
    
    <XSLT:template name="from-json">
      <XSLT:if test="not(unparsed-text-available($file))" expand-text="true">
        <nm:ERROR>No file found at { $file }</nm:ERROR>
      </XSLT:if>
      <XSLT:call-template name="from-xdm-json-xml">
        <XSLT:with-param name="source">
          <XSLT:try select="unparsed-text($file) ! json-to-xml(.)" xmlns:err="http://www.w3.org/2005/xqt-errors">
            <XSLT:catch>
              <nm:ERROR code="{{ $err:code }}">{{ $err:description }}</nm:ERROR>
            </XSLT:catch>
          </XSLT:try>
        </XSLT:with-param> 
      </XSLT:call-template>
    </XSLT:template>
    
    <XSLT:template match="/" name="from-xdm-json-xml" expand-text="true">
      <!-- Take source to be JSON in XPath 3.1 (XDM) representation -->
      <XSLT:param name="source">
        <XSLT:choose>
          <xsl:comment> evaluating { $file } as URI relative to nominal source directory</xsl:comment>
          <XSLT:when test="exists($file)">
            <XSLT:try select="$file ! document(.,/)" xmlns:err="http://www.w3.org/2005/xqt-errors">
              <XSLT:catch>
                <nm:ERROR code="{{ $err:code }}">{ $err:description }</nm:ERROR>
              </XSLT:catch>
            </XSLT:try>    
          </XSLT:when>
          <XSLT:otherwise>
            <XSLT:sequence select="/"/>
          </XSLT:otherwise>
        </XSLT:choose>
      </XSLT:param>
      <XSLT:if test="$source/j:map" expand-text="true">
        <nm:ERROR>No XPath (XML) JSON found at { $file } - syntax of http://www.w3.org/2005/xpath-functions</nm:ERROR>
      </XSLT:if>
      <!-- first step produces supermodel from input JSON including Markdown to markup conversion -->
      <XSLT:variable name="supermodel">
        <XSLT:apply-templates select="$source"/>
      </XSLT:variable>
      <XSLT:choose>
        <XSLT:when test="$produce = 'supermodel'">
          <XSLT:sequence select="$supermodel"/>
        </XSLT:when>
        <XSLT:otherwise>
          <XSLT:apply-templates select="$supermodel" mode="write-xml"/>
        </XSLT:otherwise>
      </XSLT:choose>   
    </XSLT:template>
  </xsl:variable>
  
</xsl:stylesheet>