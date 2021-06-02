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
   <xsl:param name="json-definitions-page">json/definitions</xsl:param>
   
   <xsl:variable name="datatype-page" as="xs:string">../../../datatypes</xsl:variable>
   
   <xsl:template match="metadata/namespace"/>
   
   <xsl:template match="short-name" mode="schema-link" expand-text="true">
      <p>
         <span class="usa-tag">JSON Schema</span>
         <a href="https://pages.nist.gov/OSCAL/artifacts/json/schema/oscal_{$file-map(.)}_schema.json">oscal_{$file-map(string(.))}_schema.json</a>
      </p>
   </xsl:template>
   
   <xsl:template match="short-name" mode="converter-link" expand-text="true">
      <p>
         <span class="usa-tag">XML to JSON converter</span>
         <a href="https://pages.nist.gov/OSCAL/artifacts/json/convert/oscal_{$file-map(.)}_xml-to-json-converter.xsl">oscal_{$file-map(string(.))}_xml-to-json-converter.xsl</a> <a href="https://github.com/usnistgov/OSCAL/tree/master/json#converting-oscal-xml-content-to-json">(How do I use the converter to convert OSCAL XML to JSON?)</a>
      </p>
   </xsl:template>
   
   <xsl:template name="remarks-group">
      <xsl:for-each-group select="remarks[not(@class = 'xml')]" group-by="true()">
         <div class="remarks-group usa-prose">
            <details open="open">
               <summary class="subhead">Remarks</summary>
               <xsl:apply-templates select="current-group()" mode="produce"/>
            </details>
         </div>
      </xsl:for-each-group>
   </xsl:template>
   
   
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
   

<!-- Map traversal -->
   <xsl:template match="*[exists(@key)]" expand-text="true">
      <xsl:param tunnel="true" name="constraints" select="()"/>
      <xsl:variable name="level" select="count(ancestor-or-self::*[exists(@key)])"/>
      <xsl:variable name="grouped-object" select="(self::array | self::singleton-or-array)/*"/>
      <xsl:variable name="me" select="($grouped-object,.)[1]"/>
      <div class="definition { tokenize($me/@_metaschema-json-id,'/')[2] }">
         <xsl:variable name="class" expand-text="true">{ if (exists(parent::map)) then 'definition' else 'instance' }-header</xsl:variable>
         <div class="{ $class }">
            <!-- generates h1-hx headers picked up by Hugo toc -->
            <xsl:element expand-text="true" name="h{ $level }" namespace="http://www.w3.org/1999/xhtml">
               <xsl:attribute name="id" select="@_tree-json-id"/>
               <xsl:attribute name="class">toc{ $level} head</xsl:attribute>
               <xsl:text>{ @key }</xsl:text>
            </xsl:element>
            <p class="type">
               <xsl:apply-templates select="." mode="metaschema-type"/>
            </p>
            <xsl:if test="empty(parent::map)">
               <p class="occurrence">
                  <xsl:apply-templates select="." mode="occurrence-code"/>
               </p>
            </xsl:if>
            <xsl:call-template name="crosslink-to-xml"/>
            <xsl:apply-templates select="formal-name" mode="produce"/>
         </div>
         <!-- only arrays or singleton-or-array get array headers -->
         <xsl:apply-templates mode="for-array-member"/>
         
         <xsl:apply-templates select="description" mode="produce"/>
         <xsl:call-template name="remarks-group"/>
      
         <xsl:variable name="mine" select="$me / (child::* except (formal-name|description | remarks))"/>
         <xsl:for-each-group select="$mine" group-by="true()">
         <details class="properties" open="open">
            <summary>
               <xsl:text expand-text="true">Properties ({ count( $mine )})</xsl:text>
            </summary>
            <xsl:apply-templates select="$mine">
            <xsl:with-param tunnel="true" name="constraints" select="constraint"/>
            <!-- for later when constraint allocation is working: -->
            <!--<xsl:with-param tunnel="true" name="constraints" select="$constraints, constraint"/>-->
         </xsl:apply-templates>
         </details>
         </xsl:for-each-group>
         
      </div>
   </xsl:template>
   
   <xsl:template mode="for-array-member" match="*"/>
   
   <xsl:template mode="for-array-member" match="array/*">
      <div class="array-header">
         <p class="array-member">(array member)</p>
         <p class="type">
            <xsl:apply-templates select="." mode="metaschema-type"/>
         </p>
         <p class="occurrence">
            <xsl:apply-templates select="." mode="occurrence-code"/>
         </p>
         <xsl:apply-templates select="formal-name" mode="produce"/>
      </div>
      
      <xsl:apply-templates select="description" mode="produce"/>
      <xsl:call-template name="remarks-group"/>
   </xsl:template>
   
   <xsl:template match="singleton-or-array/*" mode="for-array-member">
      <div class="array-header">
         <p class="array-member">(array member or singleton)</p>
         <p class="type">
            <xsl:apply-templates select="." mode="metaschema-type"/>
         </p>
         <p class="occurrence">
            <xsl:apply-templates select="." mode="occurrence-code"/>
         </p>
         <xsl:apply-templates select="formal-name" mode="produce"/>
      </div>
      
      <xsl:apply-templates select="description" mode="produce"/>
      <xsl:call-template name="remarks-group"/>
   </xsl:template>
   
   <xsl:template mode="metaschema-type" match="*">
      <xsl:value-of select="local-name()"/>
      <xsl:if test="@scope='global'">
         <xsl:text> </xsl:text>
         <a href="{ $json-definitions-page}#{ @_metaschema-json-id }">(global definition)</a>
      </xsl:if>
   </xsl:template>
   
   <xsl:template mode="metaschema-type" match="*[exists(@as-type)]" expand-text="true">
      <a href="{$datatype-page}/#{(lower-case(@as-type))}">{ @as-type }</a>
   </xsl:template>
   
   <xsl:template match="formal-name | description | remarks | constraint"/>
   
   <!--<xsl:template match="array" mode="produce-header" expand-text="true">
      <xsl:variable name="array-of" select="*[1]"/>
      <p>An array of { $array-of/formal-name } { $array-of/name()}s</p>
      <!-\-<p class="occurrence">
         <xsl:apply-templates select="." mode="occurrence-code"/>
      </p>-\->
   </xsl:template>
   
   <xsl:template match="object" mode="produce-header" expand-text="true">
      <xsl:variable name="array-of" select="*[1]"/>
      <p>An object { formal-name } { $array-of/name()}s</p>
      <!-\-<p class="occurrence">
         <xsl:apply-templates select="." mode="occurrence-code"/>
      </p>-\->
   </xsl:template>
   
   <xsl:template match="string | number | boolean | *" mode="produce-header" expand-text="true">
      <xsl:variable name="array-of" select="*[1]"/>
      <p>A { name(.) } { formal-name }</p>
      <!-\-<p class="occurrence">
         <xsl:apply-templates select="." mode="occurrence-code"/>
      </p>-\->
   </xsl:template>-->
   
   <!--<xsl:template match="*" mode="produce" expand-text="true">
      <xsl:param tunnel="true" name="constraints" select="()"/>
      <div class="obj-desc">
         <!-\- target for cross-link -\->
         <xsl:copy-of select="@id"/>
         <div class="obj-matrix">
            <p class="obj-name">
               <xsl:value-of select="formal-name"/>
               <xsl:if test="empty(formal-name)">
                  <xsl:text>{ name(.) => replace('^define\-','')  } of </xsl:text>
                  <xsl:for-each select="*/child::formal-name">
                  <span class="formal-name">
                     <xsl:apply-templates/>
                  </span>
               </xsl:for-each>
               </xsl:if>
            </p>
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
         
         <!-\-<xsl:variable name="potential-constraints" select="$constraints,constraint"/>-\->
         
         <!-\- Visiting the constraints passed down from above, with $apply-to as the node applying -\->
         <!-\-<xsl:apply-templates select="$potential-constraints" mode="produce-matching-constraints">
            <xsl:with-param name="applying-to" select="."/>
         </xsl:apply-templates>-\->
         
         <xsl:if test="exists(remarks)">
            <details open="open" class="remarks-group">
               <summary>Remarks</summary>
               <xsl:apply-templates mode="#current" select="remarks"/>
            </details>
         </xsl:if>
      </div>
   </xsl:template>-->


   <xsl:import href="../common-reference.xsl"/>

   <xsl:template name="crosslink-to-xml">
      <div class="crosslink">
         <a href="{$xml-reference-link}#{@_tree-xml-id}">
            <button class="schema-link">Switch to XML</button>
         </a>
      </div>
   </xsl:template>
   
</xsl:stylesheet>
