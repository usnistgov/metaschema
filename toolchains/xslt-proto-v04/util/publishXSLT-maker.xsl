<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:XSLT="http://github.com/wendellpiez/XMLjellysandwich"
  xpath-default-namespace="http://csrc.nist.gov/ns/oscal/metaschema/1.0"
  version="2.0"
  exclude-result-prefixes="#all">
  
  <!-- Originally adapted from https://github.com/wendellpiez/XMLjellysandwich/blob/master/lib/starterXSLT-maker.xsl -->
  
  <xsl:namespace-alias stylesheet-prefix="XSLT" result-prefix="xsl"/>
  
  <xsl:output indent="yes"/>
  
  <!-- Set $xsl-version to 1.0 and you get an XSLT that will run in any old browser. -->
  <xsl:param name="xsl-version">1.0</xsl:param>
  
  <!-- Include the XSLT utility functions -->
  <xsl:param as="xs:string" name="functions-wanted">no</xsl:param>
  
  <!-- The assumption is, elements in the input data sample will fall into
    three classes:
    'wrappers' are elements that never contain text directly, only elements.
    So blocks, divs, sections and other content structures are likely to be wrappers.
    'inlines' are those that appear next to content, such as 'italics' and 'bold' and
    what not, unless they are already wrappers. (Wrappers will remain wrappers.)
    'paras' (paragraphs) are those that contain text children, such as p and td, but
    do not appear next to text (so they are not inlines).
    'divs' are all elements except inlines and paragraphs, which amounts to $wrappers.
       -->

  
  
<!--<xsl:variable name="element-analysis">
  <xsl:for-each-group select="//*" group-by="name()">
    <element name="{current-grouping-key()}"
      has-text-children="{ exists(current-group()/text()[matches(.,'\S')]) }"
      has-text-siblings="{ exists(current-group()/../text()[matches(.,'\S')]) }"/>
  </xsl:for-each-group>
</xsl:variable>
-->      
  <xsl:variable name="lf"> <xsl:text>&#xA;</xsl:text></xsl:variable>
  <xsl:variable name="lf2"><xsl:text>&#xA;&#xA;</xsl:text></xsl:variable>
  
  <xsl:variable name="element-analysis" select="()"/>
  
  
  
  <!-- We only need to match the following; $wrappers are determined only to help determine the others. -->
  
  <xsl:variable name="paras"    select="//define-field[not(@as-type='markup-multiline')]"/>
  <!-- Since $divs is everything but $paras and $inlines, this amounts to $wrappers -->
  <xsl:variable name="divs"     select="//define-assembly |
    //define-field[@as-type='markup-multiline']"/>
  
  <xsl:template match="/">
    <XSLT:stylesheet version="{$xsl-version}">
      <xsl:namespace name="xs">http://www.w3.org/2001/XMLSchema</xsl:namespace>
      
        <xsl:attribute name="xpath-default-namespace">
          <xsl:value-of select="/METASCHEMA/namespace"/>
        </xsl:attribute>
      
      <!--<xsl:copy-of select="$element-analysis"/>-->
      
      <xsl:copy-of select="$lf2"/>
      <xsl:comment> XSLT produced from Metaschema ... </xsl:comment>
      <xsl:copy-of select="$lf2"/>
      
      <!--<import href="oscal_control-common_metaschema.xml"/>-->
      <xsl:for-each select="/*/import">
        <XSLT:import href="{replace(@href,'metaschema\.xml$','html.xsl')}"/>
      </xsl:for-each>
      
      <xsl:for-each-group select="$divs" group-by="@name">
        <xsl:copy-of select="$lf2"/>
        <XSLT:template mode="asleep" match="{current-grouping-key()}">
          <div class="{current-grouping-key()}">
            <XSLT:apply-templates/>
          </div>
        </XSLT:template>
      </xsl:for-each-group>
      <xsl:for-each-group select="$paras" group-by="@name">
        <xsl:copy-of select="$lf2"/>
        <XSLT:template mode="asleep" match="{current-grouping-key()}">
          <p class="{current-grouping-key()}">
            <XSLT:apply-templates/>
          </p>
        </XSLT:template>
      </xsl:for-each-group>
      
      
      <xsl:copy-of select="$lf2"/>
      
      <XSLT:template name="css">
        <style type="text/css">
          <xsl:text>
html, body { font-size: 10pt }
div { margin-left: 1rem }
.tag { color: green; font-family: sans-serif; font-size: 80%; font-weight: bold }
.UNKNOWN { color: red; font-family: sans-serif; font-size: 80%; font-weight: bold }
.UNKNOWN .tag { color: darkred }
</xsl:text>
          <xsl:for-each-group select="//assembly | //field" group-by="@ref | @name">
            <xsl:text>&#xA;&#xA;.</xsl:text>
            <xsl:value-of select="current-grouping-key()"/>
            <xsl:text> {  }</xsl:text>
          </xsl:for-each-group>
          <xsl:text>&#xA;&#xA;</xsl:text>
        </style>
      </XSLT:template>
      
      <xsl:copy-of select="$lf2"/>
      
      <xsl:if test="exists($divs)">
        <xsl:copy-of select="$lf2"/>
        <XSLT:template priority="-0.4" match="{ string-join($divs/@name,' | ')}">
          <div class="{{name()}}">
            <div class="tag"><XSLT:value-of select="name()"/>: </div>
            <XSLT:apply-templates/>
          </div>
        </XSLT:template>
      </xsl:if>
      
        <xsl:if test="exists($paras)">
          <xsl:copy-of select="$lf2"/>
          <XSLT:template priority="-0.4" match="{ string-join($paras/@name,' | ')}">
            <p class="{{name()}}">
              <span class="tag"><XSLT:value-of select="name()"/>: </span>
              <XSLT:apply-templates/>
            </p>
          </XSLT:template>
        </xsl:if>
        
      <XSLT:template match="*">
        <p class="UNKNOWN {{name()}}">
          <span class="tag"><XSLT:value-of select="name()"/>: </span>
          <XSLT:apply-templates/>
        </p>
      </XSLT:template>
      
      <xsl:if test="not($xsl-version = '1.0') and ($functions-wanted='yes')">
        <xsl:copy-of select="$lf2"/>
        <xsl:copy-of select="$lf2"/>
        <XSLT:function name="XSLT:classes">
          <XSLT:param name="who" as="element()"/>
          <XSLT:sequence select="tokenize($who/@class, '\s+') ! lower-case(.)"/>
        </XSLT:function>

        <xsl:copy-of select="$lf2"/>
        <XSLT:function name="XSLT:has-class">
          <XSLT:param name="who" as="element()"/>
          <XSLT:param name="ilk" as="xs:string"/>
          <XSLT:sequence select="$ilk = XSLT:classes($who)"/>
        </XSLT:function>
      </xsl:if>
      
    </XSLT:stylesheet>
  </xsl:template>
  
</xsl:stylesheet>