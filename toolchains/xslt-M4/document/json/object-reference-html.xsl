<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0"
   xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
   xmlns:xs="http://www.w3.org/2001/XMLSchema"
   xmlns="http://www.w3.org/1999/xhtml"
   xpath-default-namespace="http://csrc.nist.gov/ns/oscal/metaschema/1.0"
   xmlns:m="http://csrc.nist.gov/ns/oscal/metaschema/1.0"
   exclude-result-prefixes="#all">

   <!-- produces an HTML 'stub' to be inserted into Hugo -->
   
   <xsl:param name="json-reference-page">json/reference</xsl:param>
   <xsl:param name="xml-reference-page">xml/reference</xsl:param>
   <xsl:param name="json-map-page">json/outline</xsl:param>
   
   <!-- writes '../' times the number of steps in $outline-page  -->
   <xsl:variable name="path-to-common">
      <xsl:for-each select="tokenize($xml-reference-page,'/')">../</xsl:for-each>
   </xsl:variable>
   <xsl:variable name="xml-reference-link" select="$path-to-common || $xml-reference-page"/>
   <xsl:variable name="json-map-link"        select="$path-to-common || $json-map-page"/>
   
   
   <xsl:variable name="indenting" as="element()"
      xmlns:output="http://www.w3.org/2010/xslt-xquery-serialization">
      <output:serialization-parameters>
         <output:indent value="yes"/>
      </output:serialization-parameters>
   </xsl:variable>
   
   <xsl:template match="/*">
      <div class="json-reference">
         <xsl:apply-templates/>
      </div>
   </xsl:template>
   
   <xsl:template match="schema-name"/>
   
   <xsl:template match="schema-version" expand-text="true">
      <p><span class="usa-tag">Schema version:</span> { . }</p>
   </xsl:template>
   
   <xsl:template match="*[exists(@key)]" expand-text="true">
      <xsl:param tunnel="true" name="constraints" select="()"/>
      <xsl:variable name="level" select="count(ancestor-or-self::*[exists(@key)])"/>
      <section class="json-obj">
         <div class="header">
            <div>
            <!-- generates h1-hx headers picked up by Hugo toc -->
            <xsl:element namespace="http://www.w3.org/1999/xhtml" name="h{ $level }" expand-text="true">
               <xsl:attribute name="id" select="@_tree-json-id"/>
               <xsl:attribute name="class">toc{ $level} head</xsl:attribute>
               <xsl:text>{ @key }</xsl:text>
            </xsl:element>
            <xsl:apply-templates select="." mode="produce-header"/>
            <xsl:call-template name="crosslink-to-xml"/>
            </div>
         </div>
         <xsl:sequence expand-text="true">
            <p>See <a href="{ $json-map-link }#{ @_tree-json-id }">{ @_tree-json-id }</a> in the object map.</p>
         </xsl:sequence>
         
         <xsl:apply-templates select="." mode="produce"/>
         
         <xsl:apply-templates>
            <xsl:with-param tunnel="true" name="constraints" select="$constraints, constraint"/>
         </xsl:apply-templates>
         
      </section>
   </xsl:template>

   <xsl:template match="formal-name | description | remarks | constraint"/>
   
   <xsl:template match="array" mode="produce-header" expand-text="true">
      <xsl:variable name="array-of" select="*[1]"/>
      <p>An array of { $array-of/formal-name } { $array-of/name()}s</p>
      <p class="occurrence">
         <xsl:apply-templates select="." mode="occurrence-code"/>
      </p>
      <xsl:apply-templates select="$array-of" mode="produce"/>
   </xsl:template>
   
   <xsl:template match="*" mode="produce" expand-text="true">
      <xsl:param tunnel="true" name="constraints" select="()"/>
      <div class="obj-desc">
         <!-- target for cross-link -->
         <xsl:copy-of select="@id"/>
         <div class="obj-matrix">
            <p class="obj-name">{ name(.) => replace('^define\-','')  } { formal-name }</p>
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
         
         <!--<xsl:variable name="potential-constraints" select="$constraints,constraint"/>-->
         
         <!-- Visiting the constraints passed down from above, with $apply-to as the node applying -->
         <!--<xsl:apply-templates select="$potential-constraints" mode="produce-matching-constraints">
            <xsl:with-param name="applying-to" select="."/>
         </xsl:apply-templates>-->
         
         <xsl:if test="exists(remarks)">
            <details open="open" class="remarks-group">
               <summary>Remarks</summary>
               <xsl:apply-templates mode="#current" select="remarks"/>
            </details>
         </xsl:if>
      </div>
   </xsl:template>
   

   <xsl:include href="../common-reference.xsl"/>
   
  
   
   
   
   <xsl:template name="crosslink-to-xml">
      <div class="crosslink">
         <a href="{$xml-reference-link}#{@_tree-xml-id}">
            <button class="schema-link">Switch to XML</button>
         </a>
      </div>
   </xsl:template>
   

   
</xsl:stylesheet>
