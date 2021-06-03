<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet  version="3.0"
xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
xmlns:xs="http://www.w3.org/2001/XMLSchema"
xmlns:m="http://csrc.nist.gov/ns/oscal/metaschema/1.0"
xmlns="http://www.w3.org/1999/xhtml"

xpath-default-namespace="http://csrc.nist.gov/ns/oscal/metaschema/1.0"
exclude-result-prefixes="#all">

   <xsl:import href="../common-definitions.xsl"/>
    
   <xsl:param name="json-definitions-page">json/definitions</xsl:param>
   <xsl:param name="xml-definitions-page">xml/definitions</xsl:param>
   
   <xsl:template name="reference-class">
      <xsl:attribute name="class">json-definition</xsl:attribute>
   </xsl:template>
   
   <xsl:template name="mark-id">
      <xsl:attribute name="id" select="@_metaschema-json-id"/>
   </xsl:template>
    
   <!-- writes '../' times the number of steps in $outline-page  -->
   <xsl:variable name="path-to-common">
      <xsl:for-each select="tokenize($xml-definitions-page,'/')">../</xsl:for-each>
   </xsl:variable>
   <xsl:variable name="xml-definitions-link" select="$path-to-common || $xml-definitions-page"/>
   
   <xsl:template name="link-to-definition">
      <p class="definition-link">
         <a href="#{@_metaschema-json-id}">See definition</a>
      </p>
   </xsl:template>
   
   
   <!-- Crosslink heads to XML page  -->
   <xsl:template name="crosslink">
      <div class="crosslink">
         <a class="usa-button" href="{$xml-definitions-link}#{@_tree-xml-id}">Switch to XML</a>
      </div>
   </xsl:template>
   
   <xsl:template mode="metaschema-type" match="define-assembly | define-field | define-flag">
      <xsl:text expand-text="true">{ local-name() => replace('^define\-','') } definition</xsl:text><br class="br" />
      <xsl:variable name="definition" select="()"/>
      <xsl:if test="exists($definition)">
         <xsl:text> </xsl:text>
         <a class="definition-link" href="#{ @_metaschema-json-id }">(global definition)</a>
      </xsl:if>
   </xsl:template>
   
   <xsl:template mode="metaschema-type" match="assembly | field | flag">
      <xsl:value-of select="local-name()"/><br class="br"/>
      <xsl:variable name="definition" select="()"/>
      <xsl:if test="exists($definition)">
         <xsl:text> </xsl:text>
         <a class="definition-link" href="#{ @_metaschema-json-id }">(global definition)</a>
      </xsl:if>
   </xsl:template>
   
</xsl:stylesheet>