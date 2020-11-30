<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
   xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns="http://www.w3.org/1999/xhtml" version="3.0"
   xpath-default-namespace="http://csrc.nist.gov/ns/oscal/metaschema/1.0"
   xmlns:m="http://csrc.nist.gov/ns/oscal/metaschema/1.0"
   exclude-result-prefixes="#all">

   <xsl:param as="xs:string" name="model-label">oscal-catalog-xml</xsl:param>

   <xsl:variable as="xs:string" name="path-to-docs" select="'../xml-schema/'"/>

   <xsl:output omit-xml-declaration="true"/>

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

.show-closed { display: none }

details:not([open]) .show-closed { display: inline }

            </style>
   </xsl:template>

   <xsl:template match="m:schema-name | m:schema-version"/>
   
   
<!-- string object singleton-or-array array group-by-key -->
   
   <xsl:template match="m:string">
      <p class="OM-entry">
         <xsl:call-template name="line-marker"/>
         <xsl:apply-templates select="." mode="json-key"/>
         <xsl:call-template name="cardinality-note"/>
         <xsl:text>: </xsl:text>
         <xsl:apply-templates select="." mode="contents"/>
         <xsl:if test="not(position() eq last())">
            <span class="OM-lit">,</span></xsl:if>
      </p>
   </xsl:template>
   
   <xsl:template name="line-marker">
      <!--<span class="OM-lit"> &#x25AA; </span>-->
      <!--<span class="OM-lit">- </span>-->
   </xsl:template>
   
   <xsl:template match="m:object">
      <details class="OM-entry">
         <xsl:for-each select="parent::m:map">
            <xsl:attribute name="open">open</xsl:attribute>
         </xsl:for-each>
         <summary>
            <xsl:apply-templates select="." mode="json-key"/>
            <xsl:call-template name="cardinality-note"/> 
            <xsl:text>: </xsl:text>
            <span class="OM-lit">
               <xsl:text>{</xsl:text>
               <span class="show-closed">
                  <xsl:text> &#8230; }</xsl:text>
                  <xsl:if test="not(position() eq last())">, </xsl:if>
               </span>
            </span>
         </summary>
         <xsl:apply-templates select="." mode="contents"/>
         <p>
            <span class="OM-lit">
               <xsl:text> }</xsl:text>
               <xsl:if test="not(position() eq last())">, </xsl:if>
            </span>
         </p>
      </details>
   </xsl:template>
   
   <xsl:template match="m:array/m:object | m:singleton-or-array/m:object | m:object[empty(*)]">
      <div class="OM-entry">
         <p>
            <xsl:apply-templates select="." mode="json-key"/>
            <xsl:call-template name="cardinality-note"/>
               <xsl:if test="not(empty(*))">
               <xsl:text>: </xsl:text>
               <span class="OM-lit"> { </span>
               <!--<span class="show-closed">
                  <xsl:text> &#8230; }</xsl:text>
                  <xsl:if test="not(position() eq last())">, </xsl:if>
               </span>-->
            </xsl:if>
         </p>
         <xsl:if test="not(empty(*))">
         <xsl:apply-templates select="." mode="contents"/>
         <p>
            <span class="OM-lit">
               <xsl:text> }</xsl:text>
               <xsl:if test="not(position() eq last())">, </xsl:if>
            </span>
         </p>
         </xsl:if>
      </div>
   </xsl:template>
   
   <xsl:template match="m:array | m:singleton-or-array">
      <details class="OM-entry">
         <summary>
            <xsl:apply-templates select="." mode="json-key"/>
            <xsl:call-template name="cardinality-note"/>
            <xsl:text>: </xsl:text>
            
            <xsl:apply-templates select="." mode="open-delimit">
               <xsl:with-param name="has-subsequent" select="not(position() eq last())"/>
            </xsl:apply-templates>
         </summary>
         <xsl:apply-templates select="." mode="contents"/>
         <p>
            <span class="OM-lit">
               <xsl:apply-templates select="." mode="close-delimit"/>
               <xsl:if test="not(position() eq last())">, </xsl:if>
            </span>
         </p>
      </details>
   </xsl:template>
   
   <xsl:template match="*" mode="json-key">
      <a class="OM-name" href="{ $path-to-docs }#{ $model-label}_{ (@link,@key,@name)[1] }">
         <xsl:value-of select="(@key,@name)[1]"/>
      </a>
   </xsl:template>
   
   <xsl:template match="m:array/* | m:singleton-or-array/*" mode="json-key" expand-text="true">
      <span class="OM-lit"><a href="{ $path-to-docs }#{ $model-label}_{ (@link,@key,@name)[1] }">{ (@key,use-name,@name)[1] }</a> { local-name() }</span>
   </xsl:template>
   
   <xsl:template priority="2" match="*[exists(@json-key-flag)]"  mode="json-key" expand-text="true">
      <span class="OM-lit"><a href="{ $path-to-docs }#{ $model-label}_{ (@link,@key,@name)[1] }">{ (@key,use-name,@name)[1] }</a> { local-name() }s, keyed by { @json-key-flag}</span>
   </xsl:template>
   
   <xsl:template match="m:object" mode="open-delimit">
      <xsl:variable as="xs:boolean" name="has-subsequent" select="false()"/>
      <span class="OM-lit">
         <xsl:text> { </xsl:text>
      <span class="show-closed">
         <xsl:text>&#8230; }</xsl:text>
         <xsl:if test="$has-subsequent">, </xsl:if>
      </span>
      </span>
   </xsl:template>
   <xsl:template match="m:object" mode="close-delimit">
      <xsl:text>}</xsl:text>
   </xsl:template>
   
   <xsl:template match="m:array | m:singleton-or-array" mode="open-delimit">
      <xsl:param as="xs:boolean" name="has-subsequent" select="false()"/>
      <span class="OM-lit">
         <xsl:text> [ </xsl:text>
         <span class="show-closed">
            <xsl:text>&#8230; ]</xsl:text>
            <xsl:if test="$has-subsequent">, </xsl:if>
         </span>
      </span>
   </xsl:template>
   
   <xsl:template match="m:array | m:singleton-or-array" mode="close-delimit">
      <xsl:text>]</xsl:text>
   </xsl:template>
   
   <xsl:template match="m:choice">
      <div class="OM-choices">
         <p class="OM-lit">
            <xsl:call-template name="line-marker"/>
            <xsl:text>A choice:</xsl:text></p>
         <xsl:apply-templates/>
      </div>
   </xsl:template>
   
   <xsl:template match="m:choice/*" priority="5">
      <div class="OM-choice">
         <xsl:next-match/>
      </div>
   </xsl:template>
   
   <xsl:template mode="contents" match="m:string[matches(@as-type,'\S')]" expand-text="true">
      <span class="OM-datatype"><a href="../../datatypes/#{@as-type}">"{ @as-type }"</a></span>
   </xsl:template>
   
   <xsl:variable name="unquoted-types" select="'boolean','integer','positiveInteger','nonNegativeInteger'"/>
   
   <xsl:template priority="2" mode="contents" match="m:string[@as-type=$unquoted-types]" expand-text="true">
      <span class="OM-datatype"><a href="../../datatypes/#{@as-type}">{ @as-type }</a></span>
   </xsl:template>
   
   <xsl:template mode="contents" match="m:string">
      <span class="OM-datatype">"string"</span>
   </xsl:template>
   
  <xsl:template mode="contents" match="m:array | m:object | m:singleton-or-array | m:group-by-key">
      <div class="OM-map">
         <xsl:apply-templates select="*"/>
      </div>
   </xsl:template>
   
   <xsl:template priority="4" mode="contents" match="m:string[@as-type='markup-line']">
      <span class="OM-datatype">Text and inline Markdown notation</span>
   </xsl:template>
   


   <xsl:template name="describe-prose">
      <i class="OM-datatype">(<a href="../../datatypes/#markup-multiline">markup-multiline</a>) — block level Markdown notation (paragraphs, lists, etc.)</i>
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
      <xsl:text>(</xsl:text>
      <xsl:choose>
         <xsl:when test="$minOccurs = $maxOccurs" expand-text="true">{ $minOccurs }</xsl:when>
         <xsl:when test="number($maxOccurs) = number($minOccurs) + 1" expand-text="true">{ $minOccurs } or { $maxOccurs }</xsl:when>
         <xsl:otherwise expand-text="true">{ $minOccurs } to { $maxOccurs }</xsl:otherwise>
      </xsl:choose>
      <xsl:text>)</xsl:text>
   </xsl:template>


</xsl:stylesheet>
