<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0"
   xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
   xmlns:xs="http://www.w3.org/2001/XMLSchema"
   xmlns="http://www.w3.org/1999/xhtml"
   xpath-default-namespace="http://csrc.nist.gov/ns/oscal/metaschema/1.0"
   xmlns:m="http://csrc.nist.gov/ns/oscal/metaschema/1.0"
   exclude-result-prefixes="#all">

   <!-- produces an HTML 'stub' to be inserted into Hugo -->
   
   <xsl:param name="xml-reference-page">../../xml/reference</xsl:param>
   <xsl:param name="json-map-page"     >../outline</xsl:param>
   
   <xsl:variable name="indenting" as="element()"
      xmlns:output="http://www.w3.org/2010/xslt-xquery-serialization">
      <output:serialization-parameters>
         <output:indent value="yes"/>
      </output:serialization-parameters>
   </xsl:variable>
   
   <xsl:template match="/*">
      <div>
         <xsl:apply-templates/>
      </div>
   </xsl:template>
   
   <xsl:template match="schema-name"/>
   
   <xsl:template match="schema-version" expand-text="true">
      <h2><span class="usa-tag">Schema version:</span> { . }</h2>
   </xsl:template>
   
   <xsl:template match="*[exists(@key)]" expand-text="true">
      <xsl:variable name="level" select="count(ancestor-or-self::*[exists(@key)])"/>
      <section class="json-obj">
         <!-- generates h1-hx headers picked up by Hugo toc -->
         
         <xsl:element namespace="http://www.w3.org/1999/xhtml" name="h{ $level }" expand-text="true">
            <xsl:attribute name="id" select="@_json-path"/>
            <xsl:attribute name="class">toc{ $level}</xsl:attribute>
            <xsl:text>{ @key }</xsl:text>
         </xsl:element>
         <xsl:sequence expand-text="true">
            <p>See <a href="{ $json-map-page }#{ @_json-path }">{ @_json-path }</a> in the object map.</p>
         </xsl:sequence>
         
         <xsl:apply-templates select="." mode="produce-for-object"/>
         
         <xsl:apply-templates/>
      </section>
   </xsl:template>

   <xsl:template match="formal-name | description | remarks | constraint"/>
   
   <xsl:template match="array" mode="produce-for-object" expand-text="true">
      <xsl:variable name="array-of" select="*[1]"/>
      <p>An array of { $array-of/formal-name } { $array-of/name()}s</p>
      <p class="occurrence">
         <xsl:apply-templates select="." mode="occurrence-code"/>
      </p>
      <xsl:call-template name="report-also-named"/>
      <xsl:apply-templates select="$array-of" mode="produce-for-object"/>
   </xsl:template>
   
   <xsl:template name="crosslink-to-xml">
      <div class="crosslink">
         <a href="{$xml-reference-page}#{@id}">
            <button class="schema-link">Switch to XML</button>
         </a>
      </div>
   </xsl:template>
   
   <xsl:template match="*" mode="produce-for-object" expand-text="true">
      <xsl:call-template name="crosslink-to-xml"/>
      <div class="obj-desc">
         <!-- target for cross-link -->
         <xsl:copy-of select="@id"/>
         <div class="obj-matrix">
            <p class="obj-name"> { formal-name }</p>
            <p class="occurrence">
               <xsl:apply-templates select="." mode="occurrence-code"/>
            </p>
            <p>
               <xsl:text>{ if (matches(name(),'^[aeiou]','i')) then 'An ' else 'A '}{ name() } </xsl:text>
               <xsl:if test="exists(@as-type)">of type <a href="link.to.{@as-type}">{ @as-type }</a></xsl:if>
               <xsl:choose>
                  <xsl:when test="exists(@key)"> with key <code>{ @key }</code>.</xsl:when>
                  <xsl:otherwise> member of array <code>{ ../@key }</code>.</xsl:otherwise>
               </xsl:choose>
            </p>
            <p class="path">/{ ancestor-or-self::*/@key => string-join('/') }</p>
         </div>
         <xsl:apply-templates mode="#current" select="description"/>
         <xsl:call-template name="report-also-named"/>
         <xsl:if test="exists(remarks)">
            <details open="open" class="remarks-group">
               <summary>Remarks</summary>
               <xsl:apply-templates mode="#current" select="remarks"/>
            </details>
         </xsl:if>
         <details><summary>XML</summary>
         <pre>
            <xsl:value-of select="serialize(.,$indenting)"/>
         </pre></details>
      </div>
   </xsl:template>
   
   <xsl:template name="report-also-named">
      <!-- report - other occurrences of this (same) definition?
                    other definitions assigned this key? in use? -->
   </xsl:template>

  <xsl:key name="by-key" match="*[exists(@key)]" use="@key"/>
   
   <xsl:template match="description" mode="produce-for-object">
      <p class="description">
         <xsl:apply-templates/>
      </p>
   </xsl:template>
   
   <xsl:template match="remarks" mode="produce-for-object">
      <div class="remarks{ @class ! (' ' || .)}">
         <xsl:if test="@class='in-use'"><p class="nb">(In use)</p></xsl:if>
         <xsl:apply-templates/>
      </div>
   </xsl:template>
   
   <xsl:template match="description//* | remarks//*">
      <xsl:element name="{ local-name() }" namespace="http://www.w3.org/1999/xhtml">
         <xsl:apply-templates/>
      </xsl:element>
   </xsl:template>
   
   <xsl:template mode="occurrence-code" match="*">
      <xsl:param name="require-member" select="false()"/>
      <xsl:variable name="minOccurs" as="xs:string">
         <xsl:choose>
            <xsl:when expand-text="true" test="$require-member">{ (@min-occurs[not(.='0')], '1')[1] }</xsl:when>
            <xsl:otherwise expand-text="true"                  >{ (@min-occurs, '0')[1] }</xsl:otherwise>
         </xsl:choose>
      </xsl:variable>
      <xsl:variable name="maxOccurs" as="xs:string">
         <xsl:choose>
            <xsl:when test="@max-occurs = 'unbounded'">&#x221e;</xsl:when>
            <xsl:otherwise expand-text="true">{ (@max-occurs, '1')[1] }</xsl:otherwise>
         </xsl:choose>
      </xsl:variable>
      <span class="cardinality">
         <xsl:text>[</xsl:text>
         <xsl:choose>
            <xsl:when test="$minOccurs = $maxOccurs" expand-text="true">{ $minOccurs }</xsl:when>
            <xsl:when test="number($maxOccurs) = number($minOccurs) + 1" expand-text="true">{ $minOccurs } or { $maxOccurs }</xsl:when>
            <xsl:otherwise expand-text="true">{ $minOccurs } to { $maxOccurs }</xsl:otherwise>
         </xsl:choose>
         <xsl:text>]</xsl:text>
      </span>
   </xsl:template>
   
   
</xsl:stylesheet>
