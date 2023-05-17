<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0"
   xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
   xmlns:xs="http://www.w3.org/2001/XMLSchema"
   xmlns="http://www.w3.org/1999/xhtml"
   xpath-default-namespace="http://csrc.nist.gov/ns/oscal/metaschema/1.0"
   xmlns:m="http://csrc.nist.gov/ns/oscal/metaschema/1.0"
   exclude-result-prefixes="#all">

   <xsl:output indent="true"/>
   <!-- produces an HTML 'stub' to be inserted into Hugo -->
   
   <xsl:param name="json-reference-page">json/reference</xsl:param>
   <xsl:param name="xml-reference-page">xml/reference</xsl:param>
   <xsl:param name="json-map-page">json/outline</xsl:param>
   <xsl:param name="json-definitions-page">json/definitions</xsl:param>
   
   <xsl:variable name="datatype-page" as="xs:string">/reference/datatypes</xsl:variable>
   
   <xsl:template match="metadata/namespace"/>
   
   <xsl:template name="remarks-group">
      <xsl:param name="these-remarks" select="remarks"/>
         <xsl:for-each-group select="$these-remarks[not(contains-token(@class,'xml'))]" group-by="true()">
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
      <xsl:variable name="level" select="count(ancestor-or-self::*[exists(@key)])"/>
      <xsl:variable name="header-tag" select="if ($level le 6) then ('h' || $level) else 'p'"/>
      <xsl:variable name="grouped-object" select="(self::array | self::singleton-or-array)/*"/>
      <xsl:variable name="me" select="($grouped-object,.)[1]"/>

      <div class="model-entry definition { tokenize($me/@_metaschema-json-id,'/')[2] }">
         <xsl:variable name="header-class" expand-text="true">{ if (exists(parent::map)) then 'definition' else 'instance' }-header</xsl:variable>
         <div class="{ $header-class }">
            <!-- ===!!! generates h1-hx headers picked up by Hugo toc !!!=== -->
            <xsl:element name="a" namespace="http://www.w3.org/1999/xhtml">

               <xsl:attribute name="href">#{@_tree-json-id}</xsl:attribute>
               <xsl:attribute name="class">no-anchor-xslt toc{$level} name</xsl:attribute>
               <xsl:attribute name="title">Focus on {@key} details</xsl:attribute>

               <xsl:element expand-text="true" name="{ $header-tag }" namespace="http://www.w3.org/1999/xhtml">
                  <xsl:attribute name="id" select="@_tree-json-id"/>
                  <xsl:attribute name="class">no-anchor-xslt toc{$level} name </xsl:attribute>
                  <xsl:text>{ @key }</xsl:text>
               </xsl:element>

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
         <xsl:apply-templates mode="array-header"/>
            
         <xsl:where-populated>
            <div class="body">
               <xsl:apply-templates select="$me/description" mode="produce"/>
               <xsl:call-template name="remarks-group">
                  <xsl:with-param name="these-remarks" select="$me/remarks"/>
               </xsl:call-template>

               <!--<xsl:variable name="mine" select="$me / (array | singleton-or-array | object | string | number | boolean)"/>-->
               <xsl:variable name="mine"
                  select="$me/(child::* except (formal-name | description | remarks | constraint | value))"/>
               <xsl:variable name="my-constraints"
                  select="$me/constraint/(descendant::allowed-values | descendant::matches | descendant::has-cardinality | descendant::is-unique | descendant::index-has-key | descendant::index)"/>
               <xsl:if test="exists($my-constraints)">
                  <details class="constraints" open="open">
                     <summary>
                        <xsl:text expand-text="true">{ if ( count($my-constraints) gt 1) then 'Constraints' else 'Constraint' } ({ count($my-constraints) })</xsl:text>
                     </summary>
                     <xsl:apply-templates select="$my-constraints" mode="produce-constraint"/>
                  </details>
               </xsl:if>
               <xsl:for-each-group select="$mine" group-by="true()">
                  <!--<xsl:message expand-text="true">$mine includes { $mine/name() }</xsl:message>-->
                  <details class="properties" open="open">
                     <summary>
                        <xsl:text expand-text="true">{ if (count($mine) gt 1) then 'Properties' else 'Property' } ({ count( $mine )})</xsl:text>
                     </summary>
                     <xsl:apply-templates select="$mine"/>
                  </details>
               </xsl:for-each-group>

            </div>
         </xsl:where-populated>
      </div>
   </xsl:template>
   
   <xsl:template mode="array-header" match="*"/>
   
   <xsl:template mode="array-header" match="array/*">
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
   </xsl:template>
   
   <xsl:template match="singleton-or-array/*" mode="array-header">
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
   
   <xsl:template match="formal-name | description | remarks | constraint"/>

   <xsl:template mode="metaschema-type" match="*">
      <xsl:value-of select="local-name()"/><br />
      <xsl:if test="@scope='global'">
         <xsl:text> </xsl:text>
         <a class="definition-link" href="{$path-to-common || $json-definitions-page }#{ @_metaschema-json-id }">(global definition)</a>
      </xsl:if>
   </xsl:template>
   
   <xsl:template mode="metaschema-type" match="*[exists(@as-type)]" expand-text="true">
      <a href="{$datatype-page}/#{(lower-case(@as-type))}">{ @as-type }</a>
   </xsl:template>
   
   <xsl:template match="*" mode="report-context" expand-text="true">
      <xsl:for-each select="@target[matches(.,'\S')][not(.=('.','value()')) ]">
         <xsl:text>  for </xsl:text>
         <code class="path">{ . }</code>
      </xsl:for-each>
   </xsl:template>
   

   <xsl:import href="../common-reference.xsl"/>

   <xsl:template name="crosslink-to-xml">
      <div class="crosslink">
         <a class="usa-button" href="{$xml-reference-link}#{@_tree-xml-id}">Switch to XML</a>
      </div>
   </xsl:template>
   
</xsl:stylesheet>
