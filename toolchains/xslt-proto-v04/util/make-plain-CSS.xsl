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
    <xsl:value-of select="$who/(root-name,use-name,@name,@ref)[1]"/>
  </xsl:function>
  
  <xsl:template match="/">
    <style type="text/css">
      <xsl:text>@namespace "http://csrc.nist.gov/ns/oscal/1.0";</xsl:text>
      <xsl:apply-templates/>
    </style>
  </xsl:template>
  
  <xsl:template match="METASCHEMA">
    <xsl:apply-templates select="* except (define-assembly|define-field|define-flag)"/>
    <!--<xsl:text expand-text="true">{ $lf2 }{ $divs ! m:use.name(.) => string-join(', ') } {{ display: block }}</xsl:text>-->
    <xsl:apply-templates select="define-assembly" mode="display-rule">
      <xsl:sort select="m:use.name(.)"/>
    </xsl:apply-templates>
    <xsl:apply-templates select="define-field" mode="display-rule">
      <xsl:sort select="m:use.name(.)"/>
    </xsl:apply-templates>
    <xsl:apply-templates select="define-assembly" mode="prepend-label">
      <xsl:sort select="m:use.name(.)"/>
    </xsl:apply-templates>
    <xsl:apply-templates select="define-field" mode="prepend-label">
      <xsl:sort select="m:use.name(.)"/>
    </xsl:apply-templates>
    <xsl:text expand-text="true">
      
i, .i           {{ font-style: italic }}      
em, .em     {{ font-style: italic }}      
b, .b           {{ font-weight: bold }}
strong, .strong {{ font-weight: bold }}
u, .u           {{ text-decoration: underline }}

sub, .sub, sup, .sup {{ font-size: .83em }}
sub, .sub {{ vertical-align: sub }}
sup, .sup {{ vertical-align: super }}

q         {{ quotes: "“" "”" "‘" "’"; }}
q::before {{ content: open-quote; }}
q::after  {{ content: close-quote; }}

code, .code {{ font-family: monospace; font-size: 90% }}

p {{ display: block; margin-top: 1em }}

ul, ol {{
    display: block;
    margin-top: 1em;
    margin-bottom: 1em;
    padding-left: 1em;
}}

ol {{ list-style-type: decimal }}

li {{ display: list-item }}
      
tr {{ display: table-row }}
th, td {{ display: table-cell }}
    </xsl:text>
  </xsl:template>
  
  <xsl:template match="METASCHEMA/*">
    <xsl:text
  expand-text="true">&#xA;/* { . } */</xsl:text>
  </xsl:template>
  
  <xsl:template priority="2" match="METASCHEMA/import"/>
  
  <xsl:template priority="2" match="define-assembly | define-field" mode="display-rule">
    <xsl:text expand-text="true">{ $lf2 }</xsl:text>
    <xsl:call-template name="comment-rule"/>
    <xsl:text expand-text="true">{ $lf }{ m:use.name(.) }, .{m:use.name(.)}</xsl:text>
    <xsl:text expand-text="true">{ $lf } {{ display: block; margin-left: 1rem; padding-left: 1rem; border-left: thin solid grey }}</xsl:text>
  </xsl:template>
  
  <xsl:variable name="label.properties" expand-text="true">font-family: sans-serif; font-size: 0.83rem; font-weight: bold; background-color: midnightblue; color: white; padding: 0ex 0.4ex; margin: 0ex 0.3ex;</xsl:variable>
  
  <xsl:template priority="2" match="define-assembly | define-field" mode="prepend-label">
    <xsl:text expand-text="true">{ $lf2 }</xsl:text>
    <xsl:text expand-text="true">{ $lf }{ m:use.name(.) }:before, .{m:use.name(.)}:before</xsl:text>
    <xsl:text expand-text="true">{ $lf } {{ { $label.properties } content: '{ formal-name }' }}</xsl:text>
  </xsl:template>
  
  
  <xsl:template name="comment-rule">
    <xsl:variable name="name"     select="m:use.name(.)"/>
    <xsl:variable name="obj.type" select="replace(local-name(.),'^define-','')"/>
    <xsl:text expand-text="true">/* { $obj.type } { m:use.name(.) } { if (exists(root-name)) then ' (root)' else '' }</xsl:text>
    
    <xsl:for-each-group select="flag | define-flag" group-by="true()">
      <xsl:text>:</xsl:text>
      <xsl:text expand-text="true">{ current-group() ! ( ' attr(' || m:use.name(.) || ')' ) }</xsl:text>
    </xsl:for-each-group>
    <xsl:text> */</xsl:text>
  </xsl:template>
</xsl:stylesheet>