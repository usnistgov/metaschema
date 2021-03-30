<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
   xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns="http://www.w3.org/1999/xhtml" version="3.0"
   xpath-default-namespace="http://csrc.nist.gov/ns/oscal/metaschema/1.0"
   xmlns:m="http://csrc.nist.gov/ns/oscal/metaschema/1.0"
   exclude-result-prefixes="#all">

   <xsl:param as="xs:string" name="model-label">oscal-catalog-xml</xsl:param>

   <xsl:variable as="xs:string" name="path-to-docs" select="'../xml-schema/'"/>

   <xsl:output omit-xml-declaration="true" indent="no"/>

   <xsl:variable name="datatype-page">../../../datatypes</xsl:variable>
   
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
      <!--<call-template name="legend"/>-->
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
   
   <xsl:template match="m:string">
      <xsl:variable name="last-appearing" select="position() eq last()"/>
      <div class="OM-entry">
         <p class="OM-line">  <!-- OM-flex -->
            <!--<span class="sq card">
                  <xsl:call-template name="cardinality-note"/>
               </span>
               <span class="sq">-->
                  <xsl:apply-templates select="." mode="json-key"/>
                  <xsl:call-template name="cardinality-note"/>
                  <xsl:text>: </xsl:text>
                  <xsl:apply-templates select="." mode="inline-link-to"/>
                  <xsl:if test="not(position() eq last())">
                     <span class="OM-lit">,</span>
                  </xsl:if>
               <!--</span>-->
         </p>
      </div>
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
            <!-- <div class="OM-flex">-->
            <!-- <span class="sq card">
                  <xsl:call-template name="cardinality-note"/>
               </span>-->
            <!--<span class="sq">-->
                  <xsl:apply-templates select="." mode="json-key"/>
                  <xsl:call-template name="cardinality-note"/>
                  <xsl:text>: </xsl:text>
                  <span class="OM-lit">
                     <xsl:text>{</xsl:text>
                     <span class="show-closed">
                        <xsl:text> &#8230; }</xsl:text>
                        <xsl:if test="not(position() eq last())">, </xsl:if>
                     </span>
                  <!--</span>-->
               </span>
               
            <!--</div>-->
         </summary>
         <div class="OM-map">
         <xsl:apply-templates select="." mode="contents"/>
         <p>
            <span class="OM-lit">
               <xsl:text> }</xsl:text>
               <xsl:if test="not(position() eq last())">, </xsl:if>
            </span>
         </p>
         </div>
      </details>
   </xsl:template>
   
   <xsl:template match="@formal-name" expand-text="true">
      <span class="frmname">{ . }</span>
   </xsl:template>
   
   <xsl:template match="m:array/m:object | m:singleton-or-array/m:object | m:object[empty(*)]">
      <div class="OM-entry">
         <p>
            <xsl:apply-templates select="." mode="json-key"/>
            <xsl:text> </xsl:text>
            <xsl:call-template name="cardinality-note"/>
            <xsl:if test="not(empty(*))">
               <span class="OM-lit"> { </span>
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
            <!--<div class="OM-flex">
               <span class="sq card">
                  <xsl:call-template name="cardinality-note"/>
               </span>-->
               <span class="sq">
                  <xsl:apply-templates select="." mode="json-key"/>
                  <xsl:call-template name="cardinality-note"/>
                  <xsl:text>: </xsl:text>

                  <xsl:apply-templates select="." mode="open-delimit">
                     <xsl:with-param name="has-subsequent" select="not(position() eq last())"/>
                  </xsl:apply-templates>
               </span>
            <!--</div>-->
         </summary>
         <!--<div class="OM-map">
         -->   
         <xsl:apply-templates select="." mode="contents"/>
         <p>
            <span class="OM-lit">
               <xsl:apply-templates select="." mode="close-delimit"/>
               <xsl:if test="not(position() eq last())">, </xsl:if>
            </span>
         </p>
         <!--</div>-->
           
      </details>
   </xsl:template>
   
   <xsl:template match="*[exists(@id)]" mode="json-key">
      <a class="OM-name" href="{ $path-to-docs }#{ @id }">
         <xsl:value-of select="(@key,@name)[1]"/>
      </a>
   </xsl:template>
   
   <xsl:template match="*" mode="json-key">
      <xsl:value-of select="(@key,@name)[1]"/>
   </xsl:template>
   
   <xsl:template priority="3" match="m:array/*" mode="json-key">
      <span class="OM-lit">
         <xsl:text>An array of </xsl:text>
         <xsl:next-match/>
         <xsl:text expand-text="true"> { local-name() }{ if (@max-occurs != '1') then 's' else '' }</xsl:text>
      </span>
   </xsl:template>
   
   <xsl:template priority="3" match="m:singleton-or-array/*" mode="json-key" expand-text="true">
         <span class="OM-lit">
            <xsl:text>Array members, or a singleton </xsl:text>
            <span class="OM-name">
               <xsl:value-of select="(@key,use-name,@name)[1]"/>
            </span>
            <xsl:text expand-text="true"> { local-name() }</xsl:text>
         </span>
   </xsl:template>
   
   <xsl:template priority="2" match="*[exists(@json-key-flag)]"  mode="json-key" expand-text="true">
      <span class="OM-lit">
         <xsl:next-match/>
         <xsl:text> { local-name()}s </xsl:text>
         <xsl:text>, keyed by their </xsl:text>
         <span class="OM-name">{ @json-key-flag }</span>
         <xsl:text> values:</xsl:text>
      </span>
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
   
   <xsl:template priority="2" mode="inline-link-to" match="m:string" expand-text="true">
      <span class="OM-datatype"><a href="{$datatype-page}/#{lower-case(@as-type)}">{ @as-type }</a></span>
   </xsl:template>
   
   
   <xsl:template mode="contents" match="m:array | m:object | m:singleton-or-array | m:group-by-key">
      <div class="OM-map">
         <xsl:apply-templates select="*"/>
      </div>
   </xsl:template>
   
   <xsl:template name="datatype-link">
      <xsl:text expand-text="true">{ if (matches(@as-type,'^(a|e|i|o|A|E|I|O|NC)')) then 'An ' else 'A '}</xsl:text>
      <xsl:apply-templates select="." mode="inline-link-to"/>
      <xsl:text> value</xsl:text>
   </xsl:template>
   
   <xsl:template mode="contents" match="m:string">
      <xsl:param name="with-comma" select="false()"/>
      <p class="OM-map-name OM-lit">
         <!--<xsl:apply-templates select="@formal-name"/>
         <xsl:text>: </xsl:text>-->
         <xsl:call-template name="datatype-link"/>
         <!--<xsl:apply-templates select="." mode="content-gloss"/>-->
         <xsl:if test="$with-comma">,</xsl:if>
      </p>
   </xsl:template>
   
   <xsl:template match="*" mode="content-gloss">
      <xsl:text> value, expressed as a string</xsl:text>
   </xsl:template>
  
   <xsl:template mode="content-gloss" match="m:string[@as-type=('string','boolean')]">
      <p> value</p>
   </xsl:template>
   
   <xsl:template mode="content-gloss" match="m:string[@as-type=('integer','positiveInteger','nonNegativeInteger')]">
         <xsl:text> value, expressed as a number</xsl:text>
   </xsl:template>
   
   
   <xsl:template mode="content-gloss" match="m:string[@as-type='markup-line']">
      <xsl:text> value (text with formatting expressed as inline Markdown notation, including inline links and emphasis)</xsl:text>
   </xsl:template>
   
   <xsl:template mode="content-gloss" match="m:string[@as-type='markup-multiline']">
      <xsl:text> value (text with formatting expressed as block-level Markdown notation, including paragraphs and lists)</xsl:text>
   </xsl:template>
   
   <xsl:template name="cardinality-note">
      <xsl:text> </xsl:text>
      <span class="OM-cardinality">
         <xsl:apply-templates select="." mode="occurrence-code"/>
      </span>
      <!--<xsl:text> </xsl:text>-->
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
