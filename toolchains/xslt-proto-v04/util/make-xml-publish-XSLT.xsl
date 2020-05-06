<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:XSLT="http://github.com/wendellpiez/XMLjellysandwich"
  xmlns="http://www.w3.org/1999/xhtml"
  xpath-default-namespace="http://csrc.nist.gov/ns/oscal/metaschema/1.0"
  version="2.0"
  exclude-result-prefixes="#all">
  
  <xsl:namespace-alias stylesheet-prefix="XSLT" result-prefix="xsl"/>
  
<!-- To do:
  
  * Provide strip-space for assemblies
  * Ungroup the templates; give each definition its own template, qualified by context
  * Add support for casting markup-line and markup-multiline contents into HTML
  
  -->
  <xsl:output indent="yes"/>
  
  <!-- Set $xsl-version to 1.0 and you get an XSLT that will run in any old browser. -->
  <xsl:param name="xsl-version">1.0</xsl:param>
  
  <!-- Include the XSLT utility functions -->
  <xsl:param as="xs:string" name="functions-wanted">no</xsl:param>
  
  <xsl:variable name="lf"> <xsl:text>&#xA;</xsl:text></xsl:variable>
  <xsl:variable name="lf2"><xsl:text>&#xA;&#xA;</xsl:text></xsl:variable>
  
  <xsl:variable name="paras"    select="//define-field[not(@as-type='markup-multiline')]"/>
  <!-- Since $divs is everything but $paras and $inlines, this amounts to $wrappers -->
  <xsl:variable name="divs"     select="//define-assembly |
    //define-field[@as-type='markup-multiline']"/>
  
  <xsl:variable name="prefix" select="/METASCHEMA/short-name/normalize-space(.)"/>
  
  <xsl:template match="/">
    <XSLT:stylesheet version="{$xsl-version}">
      <xsl:namespace name="{$prefix}" select="/METASCHEMA/namespace"/>
      <xsl:namespace name="">http://www.w3.org/1999/xhtml</xsl:namespace>
      <xsl:if test="not($xsl-version = '1.0')">
        <xsl:namespace name="xs">http://www.w3.org/2001/XMLSchema</xsl:namespace>
      </xsl:if>

      <xsl:copy-of select="$lf2"/>
      <xsl:comment> XSLT produced from Metaschema ... </xsl:comment>
      <xsl:copy-of select="$lf2"/>

      <!--<import href="oscal_control-common_metaschema.xml"/>-->
      <xsl:for-each select="/*/import">
        <XSLT:import href="{replace(@href,'metaschema\.xml$','html.xsl')}"/>
      </xsl:for-each>

      <XSLT:template match="/">
        <html>
          <head>
            <title>
              <xsl:value-of select="/METASCHEMA/schema-name"/>
              <xsl:text> [display]</xsl:text>
            </title>
            <XSLT:call-template name="css"/>
          </head>
          <body>
            <XSLT:apply-templates/>
          </body>
        </html>
      </XSLT:template>
      
      <xsl:for-each-group select="$divs" group-by="(root-name,use-name,@name)[1]">
        <xsl:copy-of select="$lf2"/>
        <XSLT:template mode="asleep" match="{string-join(($prefix,current-grouping-key()),':')}">
          <div class="{current-grouping-key()}">
            <XSLT:apply-templates/>
          </div>
        </XSLT:template>
      </xsl:for-each-group>

      <xsl:for-each-group select="$paras" group-by="@name">
        <xsl:copy-of select="$lf2"/>
        <XSLT:template mode="asleep" match="{string-join(($prefix,current-grouping-key()),':')}">
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
          <xsl:for-each-group select="//assembly | //field" group-by="@ref">
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
        <XSLT:template priority="-0.4" match="{ string-join($divs/($prefix || ':' || (root-name,use-name,@name)[1]),' | ')}">
          <div class="{{name()}}">
            <div class="tag"><XSLT:value-of select="name()"/>: </div>
            <XSLT:apply-templates/>
          </div>
        </XSLT:template>
      </xsl:if>

      <xsl:if test="exists($paras)">
        <xsl:copy-of select="$lf2"/>
        <XSLT:template priority="-0.4" match="{ string-join($paras/($prefix || ':' ||@name),' | ')}">
          <p class="{{name()}}">
            <span class="tag"><XSLT:value-of select="name()"/>: </span>
            <XSLT:apply-templates/>
          </p>
        </XSLT:template>
      </xsl:if>

      <xsl:for-each-group select="//define-field[@as-type = 'markup-multiline']" group-by="true()">
        <xsl:comment> mapping HTML subset permitted in markup-multiline elements </xsl:comment>
        <XSLT:template priority="1"
          match="{string-join(current-group()/@name ! ($prefix || ':' || . || '//*'),' | ')}">
          <XSLT:element name="{{local-name()}}" namespace="http://www.w3.org/1999/xhtml">
            <XSLT:copy-of select="@*"/>
            <XSLT:apply-templates/>
          </XSLT:element>
        </XSLT:template>

        <XSLT:template priority="2" match="{$prefix}:insert">
          <XSLT:text>[INSERT </XSLT:text>
          <XSLT:value-of select="@param-id"/>
          <XSLT:text>]</XSLT:text>
        </XSLT:template>

      </xsl:for-each-group>
      <xsl:comment> fallback logic catches strays </xsl:comment>
      <XSLT:template match="*">
        <p class="UNKNOWN {{name()}}">
          <span class="tag"><XSLT:value-of select="name()"/>: </span>
          <XSLT:apply-templates/>
        </p>
      </XSLT:template>

      <xsl:if test="not($xsl-version = '1.0') and ($functions-wanted = 'yes')">
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