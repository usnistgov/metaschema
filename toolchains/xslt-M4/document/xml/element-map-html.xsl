<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
   xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns="http://www.w3.org/1999/xhtml" version="3.0"
   xpath-default-namespace="http://csrc.nist.gov/ns/oscal/metaschema/1.0"
   xmlns:m="http://csrc.nist.gov/ns/oscal/metaschema/1.0"
   exclude-result-prefixes="#all">

   <xsl:param as="xs:string" name="model-label">oscal-catalog-xml</xsl:param>

   <xsl:variable as="xs:string" name="path-to-docs" select="'../xml-schema/'"/>

   <xsl:output indent="yes" method="html"/>

   <xsl:template match="/" mode="make-page">
      <html lang="en">
         <head>
            <xsl:call-template name="css"/>
         </head>
         <body>
            <xsl:call-template name="make-map"/>
         </body>
      </html>
   </xsl:template>
   
   <xsl:template match="/" name="make-map">
      <div class="OM-map">
         <xsl:apply-templates select="/*"/>
      </div>
   </xsl:template>
   
   <xsl:template name="css">
      <style type="text/css">
body, html {  font-family: monospace; font-weight: bold } 

div.OM-map { margin-top: 1ex; margin-bottom: 0ex; margin-left: 2em }

div.OM-choice, div.OM-map { border-left: thin solid darkgrey; margin-top: 1ex; margin-bottom: 0ex; margin-left: 0ex; padding-left: 1em  }
         
.OM-entry { margin: 0.5ex }

div.OM-map p { margin: 0ex }

.OM-lit, .OM-cardinality, .OM-datatype { font-family: sans-serif; font-size: 80%; font-weight: normal }

.OM-datatype { font-style: italic; font-size: 70% }

.OM-cardinality  { font-size: 80% }

.OM-map a { color: inherit; text-decoration: none }

.OM-map a:hover { text-decoration: underline }

            </style>
   </xsl:template>

   <xsl:template match="m:element[empty(* except m:flag)]">
      <xsl:variable name="contents">
         <xsl:apply-templates select="." mode="contents"/>
      </xsl:variable>
      <p class="OM-entry">
         <xsl:call-template name="line-marker"/>
         <xsl:text> &lt;</xsl:text>
         <a class="OM-name" href="{ $path-to-docs }#{ $model-label}_{ @name }">
            <xsl:value-of select="@name"/>
         </a>
         <xsl:apply-templates select="m:attribute" mode="as-attribute"/>
         <xsl:if test="not(matches($contents,'\S'))">/</xsl:if>
         <xsl:text>></xsl:text>
         <xsl:if test="matches($contents,'\S')">
            <xsl:sequence select="$contents"/>
            <xsl:text>&lt;/</xsl:text>
            <xsl:value-of select="@name"/>
            <xsl:text>></xsl:text>
         </xsl:if>
         <xsl:call-template name="cardinality-note"/>
      </p>
   </xsl:template>
   
   <xsl:template name="line-marker">
      <!-- bullet --><span class="OM-lit"> &#x25AA; </span>
       <!--em dash --><!--<span class="OM-lit">— </span>-->
      <!--<span class="OM-lit">&#x25AC; </span>-->
   </xsl:template>
   
   
   <xsl:template match="m:element">
      <!--<xsl:variable name="contents">
         <xsl:apply-templates select="." mode="contents"/>
      </xsl:variable>-->
      <details class="OM-entry">
         <summary>
            <xsl:text>&lt;</xsl:text>
            <a class="OM-name" href="{ $path-to-docs }#{ $model-label}_{ @name }">
               <xsl:value-of select="@name"/>
            </a>
            <xsl:apply-templates select="m:attribute" mode="as-attribute"/>
            <xsl:text>&gt;</xsl:text>
            <xsl:call-template name="cardinality-note"/>
         </summary>
         <xsl:apply-templates select="." mode="contents"/>
         <p>
            <xsl:text>&lt;/</xsl:text>
            <xsl:value-of select="@name"/>
            <xsl:text>></xsl:text>
         </p>
      </details>
   </xsl:template>
   
   <xsl:template match="m:attribute" mode="as-attribute">
      <xsl:text> </xsl:text>
      <a class="OM-name" href="{ $path-to-docs }#{ $model-label}_{ @link }">
         <xsl:value-of select="@name"/>
      </a>
      <xsl:text>="</xsl:text>
      <span class="OM-datatype">
         <xsl:value-of select="(@as-type,'string')[1]"/>
      </span>
      <xsl:text>"</xsl:text>
   </xsl:template>
   
   
   <xsl:template priority="5" match="m:attribute"/>
   
   <xsl:template priority="5" mode="contents" match="m:element[exists(* except m:flag)]">
      <div class="OM-map">
         <xsl:apply-templates/>
      </div>
   </xsl:template>
   
   <xsl:template match="m:choice">
      <div class="OM-choices">
         <p class="OM-lit">
            <xsl:call-template name="line-marker"/>
            <xsl:text>A choice:</xsl:text>
         </p>
         <xsl:apply-templates/>
      </div>
   </xsl:template>
   
   <xsl:template match="m:choice/*" priority="5">
      <div class="OM-choice">
         <xsl:next-match/>
      </div>
   </xsl:template>
   
   <!-- We don't have to do flags here since they are promoted into attribute syntax. -->
   <xsl:template priority="3" match="m:block-sequence">
      <xsl:call-template name="describe-prose"/>
   </xsl:template>
   
   <xsl:template priority="2" mode="contents" match="m:element[empty(* except m:flag)]"/>
   
   <xsl:template priority="3" mode="contents" match="m:element[matches(@as-type,'\S')][empty(* except m:flag)]">
      <span class="OM-datatype">
         <xsl:value-of select="@as-type"/>
      </span>
   </xsl:template>
   
   <xsl:template priority="4" mode="contents" match="m:element[@as-type='markup-line']">
      <span class="OM-datatype">Text and inline markup including <code>&lt;em></code>, <code>&lt;strong></code>, <code>&lt;code></code> and the like</span>
   </xsl:template>
   
   <xsl:template mode="contents" match="m:element[matches(@as-type,'\S')]">
      <span class="OM-datatype">
         <xsl:value-of select="@as-type"/>
      </span>
   </xsl:template>


   <xsl:template name="describe-prose">
      <i class="OM-datatype">(<a href="../../datatypes/#markup-multiline">markup-multiline</a>) — block elements including <code>&lt;p></code>, <code>&lt;ul></code>, <code>&lt;table></code> etc.</i>
   </xsl:template>

   <xsl:template name="cardinality-note">
      <xsl:text> </xsl:text>
      <span class="OM-cardinality">
         <xsl:apply-templates select="." mode="occurrence-code"/>
      </span>
   </xsl:template>

   <xsl:template mode="occurrence-code" match="*">
      <xsl:variable name="minOccurs" select="(@min-occurs,'0')[1]"/>
      <xsl:variable name="maxOccurs" select="(@max-occurs,'1')[1] ! (if (. eq 'unbounded') then '&#x221e;' else .)"/>
      <xsl:text>[</xsl:text>
      <xsl:choose>
         <xsl:when test="$minOccurs = $maxOccurs" expand-text="true">{ $minOccurs }</xsl:when>
         <xsl:when test="number($maxOccurs) = number($minOccurs) + 1" expand-text="true">{ $minOccurs } or { $maxOccurs }</xsl:when>
         <xsl:otherwise expand-text="true">{ $minOccurs } to { $maxOccurs }</xsl:otherwise>
      </xsl:choose>
      <xsl:text>]</xsl:text>
   </xsl:template>


</xsl:stylesheet>
