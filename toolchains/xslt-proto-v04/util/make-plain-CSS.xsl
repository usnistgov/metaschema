<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns="http://www.w3.org/1999/xhtml"
  xmlns:m="http://csrc.nist.gov/ns/oscal/metaschema/1.0"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xpath-default-namespace="http://csrc.nist.gov/ns/oscal/metaschema/1.0"
  exclude-result-prefixes="#all">
  
<!-- 
    Run on a metaschema or metaschema fragment
  -->
  <xsl:output method="text"/>
  
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
  
  
  <xsl:function name="m:use.name">
    <xsl:param name="who" as="element()"/>
    <xsl:value-of select="$who/(root-name,use-name,@name)[1]"/>
  </xsl:function>
  
  <xsl:template match="/">
    <xsl:text>@namespace "http://csrc.nist.gov/ns/oscal/1.0";</xsl:text>
    
    <xsl:apply-templates/>
  </xsl:template>
  
  <xsl:template match="METASCHEMA">
    <xsl:apply-templates select="* except (define-assembly|define-field|define-flag)"></xsl:apply-templates>
    <xsl:text
  expand-text="true">&#xA;&#xA;{ $divs ! m:use.name(.) => string-join(', ') } {{ display: block }}</xsl:text>
    <xsl:apply-templates select="define-assembly">
      <xsl:sort select="m:use.name(.)"/>
    </xsl:apply-templates>
    <xsl:apply-templates select="define-field">
      <xsl:sort select="m:use.name(.)"/>
    </xsl:apply-templates>
  </xsl:template>
  
  <xsl:template match="METASCHEMA/*">
    <xsl:text
  expand-text="true">&#xA;/* { . } */</xsl:text>
  </xsl:template>
  
  <xsl:template priority="2" match="METASCHEMA/import"/>
  
  <xsl:template priority="2" match="define-assembly | define-field">
    <xsl:text>&#xA;&#xA;</xsl:text>
    <xsl:text
  expand-text="true">{ m:use.name(.) } {{ }} // { substring-after(local-name(),'define-')}{ if (exists(root-name)) then ' (root)' else '' }</xsl:text>
  </xsl:template>
    
</xsl:stylesheet>