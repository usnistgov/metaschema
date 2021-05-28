<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0"
   xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
   xmlns:xs="http://www.w3.org/2001/XMLSchema"
   xmlns="http://www.w3.org/1999/xhtml"
   xpath-default-namespace="http://csrc.nist.gov/ns/oscal/metaschema/1.0"
   xmlns:m="http://csrc.nist.gov/ns/oscal/metaschema/1.0"
   exclude-result-prefixes="#all">

   <!-- produces an HTML 'stub' to be inserted into Hugo -->

   <xsl:variable name="indenting" as="element()"
      xmlns:output="http://www.w3.org/2010/xslt-xquery-serialization">
      <output:serialization-parameters>
         <output:indent value="yes"/>
      </output:serialization-parameters>
   </xsl:variable>
   
   <xsl:param name="xml-reference-page">xml/reference</xsl:param>
   <xsl:param name="json-reference-page">json/reference</xsl:param>
   <xsl:param name="xml-map-page">xml/outline</xsl:param>
   
   <!-- writes '../' times the number of steps in $outline-page  -->
   <xsl:variable name="path-to-common">
      <xsl:for-each select="tokenize($xml-reference-page,'/')">../</xsl:for-each>
   </xsl:variable>
   <xsl:variable name="json-reference-link" select="$path-to-common || $json-reference-page"/>
   <xsl:variable name="xml-map-link"        select="$path-to-common || $xml-map-page"/>
   
   <xsl:template match="/*">
       <div class="xml-reference">
          <!--<details><summary>XML source</summary>
             <pre>
         <xsl:value-of select="serialize(.,$indenting)"/>
      </pre>
          </details>-->
         <xsl:apply-templates/>
       </div>
   </xsl:template>
   
   <xsl:template match="schema-name"/>
   
   <xsl:template match="schema-version" expand-text="true">
      <h2><span class="usa-tag">Schema version:</span> { . }</h2>
   </xsl:template>
   
   
   <xsl:template match="*[exists(@gi)]" expand-text="true">
      <xsl:param tunnel="true" name="constraints" select="()"/>
      <xsl:variable name="level" select="count(ancestor-or-self::*[exists(@gi)])"/>
      <section class="xml-element">
         <div class="header">
            <xsl:call-template name="json-crosslink"/>
            
            <!-- generates h1-hx headers picked up by Hugo toc -->
            <xsl:element namespace="http://www.w3.org/1999/xhtml" name="h{ $level }" expand-text="true">
               <!--  XXX LINK HERE -->
               <xsl:attribute name="id" select="@_tree-xml-id"/>
               <xsl:attribute name="class">toc{ $level} head</xsl:attribute>
               <xsl:text>{ self::attribute/'@' || @gi }</xsl:text>
            </xsl:element>
         </div>
         <xsl:sequence expand-text="true">
            <p>See <a href="{$xml-map-link}#{@_tree-xml-id}">{ @_tree-xml-id }</a> in the element map.</p>
         </xsl:sequence>
         
         <xsl:apply-templates select="." mode="produce"/>
         
         <xsl:apply-templates>
            <xsl:with-param tunnel="true" name="constraints" select="constraint"/>
            <!-- for later when constraint allocation is working: -->
            <!--<xsl:with-param tunnel="true" name="constraints" select="$constraints, constraint"/>-->
         </xsl:apply-templates>
      </section>
   </xsl:template>
   
   <xsl:template match="formal-name | description | remarks | constraint"/>
   
   <xsl:template match="*" mode="produce" expand-text="true">
      <xsl:param tunnel="true" name="constraints" select="()"/>
      <div class="obj-desc">
         <!-- target for cross-linking -->
         <xsl:attribute name="id" select="@_tree-xml-id"/>
         <div class="obj-matrix">
            <p class="obj-name">{ (formal-name, name())[1] }</p>
            <!--<xsl:if test="empty(formal-name)">
               <xsl:message expand-text="true">{ name() } is missing formal-name</xsl:message>
            </xsl:if>-->
            <p class="occurrence">
               <xsl:apply-templates select="." mode="occurrence-code"/>
            </p>
            <p>
               <xsl:text>{ if (matches(name(),'^[aeiou]','i')) then 'An ' else 'A '}{ name() } </xsl:text>
               <xsl:if test="exists(@as-type)">of type <a href="link.to.{@as-type}">{ @as-type }</a></xsl:if>
               <!--<xsl:choose>
                  <xsl:when test="exists(@key)"> with key <code>{ @key }</code>.</xsl:when>
                  <xsl:otherwise> member of array <code>{ ../@key }</code>.</xsl:otherwise>
               </xsl:choose>-->
            </p>
            <!--<p class="path">{ @_tree-xml-id }</p>-->
         </div>
         
         <xsl:apply-templates mode="#current" select="description"/>
         <xsl:apply-templates mode="#current" select="value"/>
         
         <xsl:variable name="potential-constraints" select="$constraints,constraint"/>
         
         <!-- Visiting the constraints passed down from above, with $apply-to as the node applying -->
         <xsl:apply-templates select="$potential-constraints" mode="produce-matching-constraints">
            <xsl:with-param name="applying-to" select="."/>
         </xsl:apply-templates>
         
         <xsl:if test="exists(remarks)">
            <details open="open" class="remarks-group">
               <summary>Remarks</summary>
               <xsl:apply-templates mode="#current" select="remarks"/>
            </details>
         </xsl:if>
      </div>
   </xsl:template>
   
   <xsl:template match="value" mode="produce" expand-text="true">
      <div class="value" id="{ @tree-xml-id }">
         <p>Value: { if (matches(@as-type,'^[aeiou]','i')) then 'An ' else 'A '}{ @as-type } </p>
      </div>
   </xsl:template>
   
   <xsl:include href="../common-reference.xsl"/>
   
   
   <xsl:template name="json-crosslink">
      <div class="crosslink">
         <a href="{$json-reference-link}#{@_tree-json-id}">
            <button class="schema-link">Switch to JSON</button>
         </a>
      </div>
   </xsl:template>
   
  
</xsl:stylesheet>
