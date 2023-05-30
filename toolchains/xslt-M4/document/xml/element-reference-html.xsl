<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0"
   xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
   xmlns:xs="http://www.w3.org/2001/XMLSchema"
   xmlns="http://www.w3.org/1999/xhtml"
   xpath-default-namespace="http://csrc.nist.gov/ns/oscal/metaschema/1.0"
   xmlns:m="http://csrc.nist.gov/ns/oscal/metaschema/1.0"
   exclude-result-prefixes="#all">

   <!-- produces an HTML 'stub' to be inserted into Hugo -->
   
   <xsl:param name="xml-reference-page">xml/reference</xsl:param>
   <xsl:param name="json-reference-page">json/reference</xsl:param>
   <xsl:param name="xml-map-page">xml/outline</xsl:param>
   <xsl:param name="xml-definitions-page">xml/definitions</xsl:param>
   
   <xsl:variable name="datatype-page" as="xs:string">/reference/datatypes</xsl:variable>
   
   <xsl:template match="metadata/json-base-uri"/>
      
   <xsl:template name="remarks-group">
      <xsl:param name="these-remarks" select="remarks"/>
      <xsl:for-each-group select="$these-remarks[not(contains-token(@class,'json'))]" group-by="true()">
         <div class="remarks-group usa-prose">
            <details open="open">
               <summary class="subhead">Remarks</summary>
               <xsl:apply-templates select="current-group()" mode="produce"/>
            </details>
         </div>
      </xsl:for-each-group>
   </xsl:template>
   
   <xsl:variable name="indenting" as="element()"
      xmlns:output="http://www.w3.org/2010/xslt-xquery-serialization">
      <output:serialization-parameters>
         <output:indent value="yes"/>
      </output:serialization-parameters>
   </xsl:variable>
   
   <!-- writes '../' times the number of steps in $outline-page  -->
   <xsl:variable name="path-to-common">
      <xsl:for-each select="tokenize($xml-reference-page,'/')">../</xsl:for-each>
   </xsl:variable>
   <xsl:variable name="json-reference-link" select="$path-to-common || $json-reference-page"/>
   <xsl:variable name="xml-map-link"        select="$path-to-common || $xml-map-page"/>
   
   <xsl:template match="/*">
       <div class="xml-reference">
         <xsl:apply-templates/>
       </div>
   </xsl:template>
   <!-- The Ancor-Template Generation that supposedly slows down the page response (for ALL MODLES especially) -->
   <xsl:template match="*[exists(@gi)]" expand-text="true">
      <xsl:variable name="level" select="count(ancestor-or-self::*[exists(@gi)])"/>
      <xsl:variable name="header-tag" select="if ($level le 6) then ('h' || $level) else 'p'"/>
      <div class="model-entry definition { tokenize(@_metaschema-xml-id,'/')[2] }">
         <xsl:variable name="header-class" expand-text="true">{ if (exists(parent::map)) then 'definition' else 'instance' }-header</xsl:variable>
         <div class="{ $header-class }">
            <!-- 
               Generate the proper class attribute to match a given HTML header from $header-tag (h1, h2,...h6) 
               to define the proper corresponding style (toc1, toc2,... toc6) as bound by toc{ $level } in Hugo.

               This build-time generation of anchor from template improves performance of website at load time 
               to decrease page time to responsiveness in the browser.
            -->
            <xsl:element name="a" namespace="http://www.w3.org/1999/xhtml">
               <xsl:attribute name="href">#{@_tree-xml-id}</xsl:attribute>
               <xsl:attribute name="class">reference-element-anchor toc{ $level } name </xsl:attribute>
               <xsl:attribute name="title">Focus on {@gi} details</xsl:attribute>

               <xsl:element expand-text="true" name="{ $header-tag }" namespace="http://www.w3.org/1999/xhtml">
                  <xsl:attribute name="id" select="@_tree-xml-id"/>
                  <xsl:attribute name="class">reference-element-anchor toc{ $level} name</xsl:attribute>
                  <xsl:text>{ @gi }</xsl:text>
               </xsl:element>

            </xsl:element>

            <!-- Only assign the @id here if there is a value and the type is not markup-multiline, since in the other cases it
                 is assigned to the header in the containing div -->
            <p class="type">
               <xsl:if test="exists(value[not(@as-type='markup-multiline')])">
                  <xsl:attribute name="id">{ value/@_tree-xml-id }</xsl:attribute>
               </xsl:if>
               <xsl:apply-templates select="." mode="metaschema-type"/>
            </p>
            <xsl:if test="empty(parent::map)">
               <p class="occurrence">
                  <xsl:apply-templates select="." mode="occurrence-code"/>
               </p>
            </xsl:if>
            <xsl:call-template name="crosslink-to-json"/>
            <xsl:apply-templates select="formal-name" mode="produce"/>
         </div>
         <xsl:where-populated>
            <div class="body">
               <xsl:apply-templates select="description" mode="produce"/>
               <xsl:apply-templates select="value" mode="produce"/>
               <xsl:call-template name="remarks-group"/>
               
               <xsl:variable name="my-constraints"
                  select="constraint/( descendant::allowed-values | descendant::matches | descendant::has-cardinality | descendant::is-unique | descendant::index-has-key | descendant::index )"/>
               <xsl:if test="exists($my-constraints)">
                  <details class="constraints" open="open">
                     <summary>
                        <xsl:text expand-text="true">{ if ( count($my-constraints) gt 1) then 'Constraints' else 'Constraint' } ({ count($my-constraints) })</xsl:text>
                     </summary>
                     <xsl:apply-templates select="$my-constraints" mode="produce-constraint"/>
                  </details>
               </xsl:if>
               <xsl:for-each-group select="attribute" group-by="true()">
                  <details class="properties attributes" open="open">
                     <summary>
                        <xsl:text expand-text="true">{ if (count(current-group()) gt 1) then 'Attributes' else 'Attribute' } ({ count(current-group()) })</xsl:text>
                     </summary>
                     <xsl:apply-templates select="current-group()"/>
                  </details>
               </xsl:for-each-group>
               <xsl:for-each-group select="element | choice[exists(child::element)]  | value[@as-type='markup-multiline']" group-by="true()">
                  <xsl:variable name="elements" select="current-group()/ (self::element | self::choice/child::element)"/>
                  <details class="properties elements" open="open">
                     <summary>
                        <xsl:text expand-text="true">{ if (count($elements) gt 1) then 'Elements' else 'Element' } ({ count($elements) }{ current-group()/self::value/'+' })</xsl:text>
                     </summary>
                     <xsl:apply-templates select="current-group()"/>
                  </details>
               </xsl:for-each-group>
               
            </div>
         </xsl:where-populated>
      </div>
   </xsl:template>
   
   <xsl:template match="value[empty(@gi)][@as-type='markup-multiline']" expand-text="true">
      <xsl:variable name="level" select="count(ancestor-or-self::*[exists(@gi)])"/>
      <xsl:variable name="header-tag" select="if ($level le 6) then ('h' || $level) else 'p'"/>
      <div class="model-entry definition { tokenize(@_metaschema-xml-id,'/')[2] }">
         <xsl:variable name="header-class" expand-text="true">{ if (exists(parent::map)) then 'definition' else 'instance' }-header</xsl:variable>
         <div class="{ $header-class }">
            <!-- generates h1-hx headers picked up by Hugo toc -->

            <!-- ===!!! Anchor hard wrap-around of Headers 1-6 [see logic above with ($level le 6)] !!!=== -->               
            <xsl:element expand-text="true" name="a" namespace="http://www.w3.org/1999/xhtml">
               <xsl:attribute name="href">#{@_tree-xml-id}</xsl:attribute>
               <xsl:attribute name="class">anchor-xslt toc{ $level} name  Elem-Ref-Html--Xsl</xsl:attribute>
               <xsl:attribute name="title">Get {@_tree-xml-id} details</xsl:attribute>

               <!-- ===!!! The Headers 1-6 that are being wrapped around !!!=== --> 
               <xsl:element expand-text="true" name="{ $header-tag }" namespace="http://www.w3.org/1999/xhtml">
                  <xsl:attribute name="id" select="@_tree-xml-id" />
                  <xsl:attribute name="class">toc{ $level} name </xsl:attribute>
                  <xsl:text>(unwrapped)               </xsl:text>
               </xsl:element>
            </xsl:element>
            <p class="type">
               <xsl:apply-templates select="." mode="metaschema-type"/>
            </p>
            <p class="occurrence">[0 to &#x221e;]</p>
            <!--<xsl:call-template name="crosslink-to-json"/>-->
            <!--<xsl:apply-templates select="formal-name" mode="produce"/>-->
         </div>
         <div class="body">
            <p><xsl:text>This use of the </xsl:text><a href="{$datatype-page}/#markup-multiline">markup-multiline</a><xsl:text> type permits unwrapped block-level markup.</xsl:text></p>
         </div>
      </div>
   </xsl:template>
   
   
   <xsl:template match="formal-name | description | remarks | constraint"/>
   
   <xsl:template match="value" mode="produce"/>

<!--   
   <xsl:template match="value" mode="produce" expand-text="true">
      <div class="value" id="{ @_tree-xml-id }">
         <p>
            <xsl:text>Value: { if (matches(@as-type,'^[aeiou]','i')) then 'An ' else 'A '} </xsl:text>
            <xsl:apply-templates mode="metaschema-type"/>
            <xsl:text> value.</xsl:text>
         </p>
      </div>
   </xsl:template>
-->

   <xsl:template match="value[@as-type='markup-multiline']" mode="produce">
      <!-- no @id here as it is assigned to the header in the containing div -->
   </xsl:template>
   
   <xsl:template mode="metaschema-type" match="*">
      <xsl:value-of select="local-name()"/><br />
      <xsl:if test="@scope='global'">
         <xsl:text> </xsl:text>
         <a class="definition-link" href="{$path-to-common || $xml-definitions-page }#{ @_metaschema-xml-id }">(global definition)</a>
      </xsl:if>
   </xsl:template>
   
   <xsl:template mode="metaschema-type" match="*[exists(@as-type)]" expand-text="true">
      <a href="{$datatype-page}/#{(lower-case(@as-type))}">{ @as-type }</a>
   </xsl:template>
   
   <xsl:import href="../common-reference.xsl"/>
   
   <xsl:template name="crosslink-to-json">
      <div class="crosslink">
         <a class="usa-button" href="{$json-reference-link}#{@_tree-json-id}">Switch to JSON</a>
      </div>
   </xsl:template>
   
  
</xsl:stylesheet>
