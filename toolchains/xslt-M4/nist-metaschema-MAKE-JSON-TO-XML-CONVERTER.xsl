<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:nm="http://csrc.nist.gov/ns/metaschema"
  xmlns="http://csrc.nist.gov/ns/oscal/metaschema/1.0/supermodel"
  xpath-default-namespace="http://csrc.nist.gov/ns/oscal/metaschema/1.0/supermodel"
  xmlns:XSLT="http://csrc.nist.gov/ns/oscal/metaschema/xslt-alias"
  exclude-result-prefixes="#all"
  
  version="3.0">

  <!-- Purpose: Produce an XSLT transformation capable of converting a JSON format defined in a metaschema, into an XML JSON format capturing an equivalent data set -->
  <!-- Dependencies: This is a 'shell' XSLT and calls several steps in sequence, each implemented as an XSLT -->
  <!-- Input: A top-level metaschema; this XSLT also composes metaschema input so composition is not necessary -->
  <!-- Output: A standalone XSLT suitable for use or deployment, accepting JSON valid to the metaschema-defined constraints -->
  <!-- Note: see the result XSLT for information regarding its runtime interface -->
  <!-- Note: This XSLT uses the transform() function to execute a series of transformations (referenced out of line) over its input -->
  
  
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
    <nm:transform version="3.0">compose/metaschema-build-refs.xsl</nm:transform>
    <nm:transform version="3.0">compose/metaschema-trim-extra-modules.xsl</nm:transform>
    <nm:transform version="3.0">compose/metaschema-prune-unused-definitions.xsl</nm:transform>
    <nm:transform version="3.0">compose/metaschema-resolve-use-names.xsl</nm:transform>
    <nm:transform version="3.0">compose/metaschema-resolve-sibling-names.xsl</nm:transform>
    <nm:transform version="3.0">compose/metaschema-digest.xsl</nm:transform>
    <nm:transform version="3.0">compose/annotate-composition.xsl</nm:transform>
    
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
      <xsl:attribute name="xpath-default-namespace">http://csrc.nist.gov/ns/oscal/metaschema/1.0/supermodel</xsl:attribute>
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
      
      <xsl:apply-templates mode="package-converter" select="document('converter-gen/markdown-to-supermodel-xml-converter.xsl')/xsl:*/( xsl:* except (xsl:output | xsl:mode) )"/>
      
      <xsl:text>&#xA;</xsl:text>
      <xsl:comment> JSON to XML conversion: Supermodel serialization as XML </xsl:comment>
      <xsl:apply-templates mode="package-converter" select="document('converter-gen/supermodel-to-xml.xsl')/xsl:*/( xsl:* except xsl:output )"/>
    </xsl:copy>
  </xsl:template>
 
  <!--<xsl:template mode="package-converter"
    match="xsl:template[value/@as-type=('markup-line','markup-multiline')][@mode='get-value-property']">
    <!-\-<xsl:message>boo!</xsl:message>-\->
    <XSLT:template match="{ @match }" mode="get-value-property">
      <value as-type="markup-multiline" in-json="string">
        <XSLT:call-template name="parse-markdown">
          <XSLT:with-param name="markdown-str" select="string(.)"/>
        </XSLT:call-template>
      </value>
    </XSLT:template>
  </xsl:template>-->
  
  <xsl:template mode="package-converter"
    match="xsl:template[@mode=('write-xml','cast-prose')]/xsl:element/@namespace">
    <xsl:attribute name="namespace" select="$metaschema-source/*/namespace" xpath-default-namespace="http://csrc.nist.gov/ns/oscal/metaschema/1.0"/>
  </xsl:template>
  
  <xsl:template mode="package-converter" match="xsl:template[@name='run-tests']"/>
  <xsl:template mode="package-converter" match="xsl:variable[@name='examples']"/>
  
  <xsl:template mode="package-converter" match="xsl:template[@match=('value[@as-type=(''markup-line'')]','value[@as-type=(''markup-multiline'')]')]">
    <xsl:copy copy-namespaces="no">
      <xsl:attribute name="mode">cast-md</xsl:attribute>
      <xsl:attribute name="xpath-default-namespace">http://csrc.nist.gov/ns/oscal/metaschema/1.0/supermodel</xsl:attribute>
      <xsl:copy-of select="@*"/>
      <xsl:copy-of select="*"/>
    </xsl:copy>
  </xsl:template>
  
  
  <xsl:variable name="transformation-architecture">
    <XSLT:output indent="true"/>
    <xsl:text>&#xA;</xsl:text>
    <xsl:comment> Processing architecture </xsl:comment>
    <xsl:comment> $file should be a URI, absolute or relative to the XSLT transformation</xsl:comment>
    <XSLT:param name="file" as="xs:anyURI?"/>
    <xsl:comment> Pass in $produce=supermodel to produce OSCAL M4 supermodel intermediate format </xsl:comment>
    <XSLT:param name="produce" as="xs:string">xml</XSLT:param><!-- set to 'supermodel' to produce supermodel intermediate -->
  
<!--  -->
    <XSLT:template name="from-json">
      <XSLT:if test="not(unparsed-text-available($file))" expand-text="true">
        <nm:ERROR>No file found at { $file }</nm:ERROR>
      </XSLT:if>
      <XSLT:call-template name="from-xdm-json-xml">
        <XSLT:with-param name="source">
          <XSLT:try select="unparsed-text($file) ! json-to-xml(.)" xmlns:err="http://www.w3.org/2005/xqt-errors">
            <XSLT:catch expand-text="true">
              <nm:ERROR code="{{ $err:code }}">{{ $err:description }}</nm:ERROR>
            </XSLT:catch>
          </XSLT:try>
        </XSLT:with-param> 
      </XSLT:call-template>
    </XSLT:template>
    
    <XSLT:mode name="cast-md" on-no-match="shallow-copy"/>
    
    <XSLT:template match="/" name="from-xdm-json-xml" expand-text="true">
      <!-- Take source to be JSON in XPath 3.1 (XDM) representation -->
      <XSLT:param name="source">
        <XSLT:choose>
          <xsl:comment> evaluate { $file } as URI (absolute or relative to stylesheet)</xsl:comment>
          <XSLT:when test="exists($file)">
            <XSLT:try select="document($file)" xmlns:err="http://www.w3.org/2005/xqt-errors">
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
      <XSLT:if test="empty($source/j:map)" expand-text="true">
        <nm:ERROR>No XPath (XML) JSON found at { $file } - using syntax of http://www.w3.org/2005/xpath-functions</nm:ERROR>
      </XSLT:if>
      <!-- first step produces supermodel from input JSON except for Markdown to markup conversion -->
      <XSLT:variable name="near-supermodel">
        <XSLT:apply-templates select="$source/*"/>
      </XSLT:variable>
      
      <XSLT:variable name="supermodel">
        <XSLT:apply-templates select="$near-supermodel/*" mode="cast-md"/>
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
    
    <XSLT:template match="/j:map[empty(@key)]" priority="10">
      <XSLT:apply-templates/>
    </XSLT:template>
    
  </xsl:variable>
  
</xsl:stylesheet>