<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
   xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns="http://www.w3.org/1999/xhtml" version="3.0"
   xpath-default-namespace="http://csrc.nist.gov/ns/oscal/metaschema/1.0"
   xmlns:m="http://csrc.nist.gov/ns/oscal/metaschema/1.0"
   exclude-result-prefixes="#all">

   <xsl:param as="xs:string" name="model-label">oscal-catalog-xml</xsl:param>

   <xsl:variable as="xs:string" name="path-to-docs" select="'../xml-schema/'"/>

   <xsl:output indent="yes" method="html"/>

   <xsl:template match="/">
      <html lang="en">
         <head>
            <xsl:call-template name="css"/>
         </head>
         <body>
            <xsl:apply-templates mode="html-render"/>
         </body>
      </html>
   </xsl:template>
   
   <xsl:template name="css">
      <style type="text/css">
         body, html {  font-family: monospace; font-weight: bold } 
div.OM-map { margin-top: 0ex; margin-bottom: 0ex; margin-left: 2em } 

.OM-entry { border: medium solid white }
.OM-entry:hover { border: medium solid steelblue }
.OM-entry.hide_me:hover { border: medium solid white }

div.OM-map p { margin: 0ex }

span.OM-lit, .OM-cardinality { font-family: serif; font-weight: normal; color: midnightblue }

span.OM-emph { font-weight: normal; font-style: italic }

.OM-cardinality  { color: blue }

.OM-map a { color: inherit; text-decoration: none }

.OM-map a:hover { text-decoration: underline }

.hide_me { display: none }
            </style>
   </xsl:template>

   <xsl:template match="m:element" mode="html-render">
      <xsl:variable name="contents">
         <xsl:apply-templates select="." mode="contents"/>
      </xsl:variable>
      <p class="OM-entry">
         <xsl:text>&#x25AA; </xsl:text>
         <xsl:text>&lt;</xsl:text>
         <a class="OM-name" href="{ $path-to-docs }#{ $model-label}_{ @name }">
            <xsl:value-of select="@name"/>
         </a>
         <xsl:apply-templates select="m:attribute" mode="attribute-render"/>
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
   
   <xsl:template match="m:element[exists(m:element|m:block-sequence)]" mode="html-render">
      <!--<xsl:variable name="contents">
         <xsl:apply-templates select="." mode="contents"/>
      </xsl:variable>-->
      <details class="OM-entry">
         <summary>
            <xsl:text>&lt;</xsl:text>
            <a class="OM-name" href="{ $path-to-docs }#{ $model-label}_{ @name }">
               <xsl:value-of select="@name"/>
            </a>
            <xsl:apply-templates select="m:attribute" mode="attribute-render"/>
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
   
   <xsl:template match="m:attribute" mode="attribute-render">
      <xsl:text> </xsl:text>
      <a class="OM-name" href="{ $path-to-docs }#{ $model-label}_{ @link }">
         <xsl:value-of select="@name"/>
      </a>
      <xsl:text>="</xsl:text>
      <span class="OM-emph">
         <xsl:value-of select="(@as-type,'string')[1]"/>
      </span>
      <xsl:text>"</xsl:text>
   </xsl:template>
   
   
   <xsl:template priority="5" mode="html-render" match="m:attribute"/>
   
      <xsl:template priority="5" mode="contents" match="m:element[exists(m:element|m:block-sequence)]">
         <div class="OM-map">
         <xsl:apply-templates mode="html-render"/>
      </div>
   </xsl:template>
   
   <!-- We don't have to do flags here since they are promoted into attribute syntax. -->
   <xsl:template priority="3" mode="html-render" match="m:block-sequence">
      <xsl:call-template name="describe-prose"/>
   </xsl:template>
   
   <xsl:template priority="2" mode="contents" match="m:element[empty(m:element|m:block-sequence)]"/>
   
   <xsl:template mode="contents" match="m:element[matches(@as-type,'\S')]">
      <span class="OM-emph">
         <xsl:value-of select="@as-type"/>
      </span>
   </xsl:template>


   <xsl:template name="describe-prose">
       <i class="OM-emph">(<a href="../../datatypes/#markup-multiline">markup-multiline</a>) — any recognized block element including <code>&lt;p></code>, <code>&lt;ul></code>, <code>&lt;table></code> etc.</i>
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
