<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0"
   xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
   xmlns:xs="http://www.w3.org/2001/XMLSchema"
   xmlns="http://www.w3.org/1999/xhtml"
   xpath-default-namespace="http://csrc.nist.gov/ns/oscal/metaschema/1.0"
   xmlns:m="http://csrc.nist.gov/ns/oscal/metaschema/1.0"
   exclude-result-prefixes="#all">

   <!-- Assumes HTML with sections and indexes these by their names as presented  -->
   
   <xsl:mode on-no-match="shallow-copy"/>
   
   <xsl:param name="index-page"       as="xs:string">json/index</xsl:param>
   <xsl:param name="reference-page"   as="xs:string">json/reference</xsl:param>
   <xsl:param name="definitions-page" as="xs:string">json/definitions</xsl:param>
   
   <!-- writes '../' times the number of steps in $outline-page  -->
   <xsl:variable name="path-to-common">
      <xsl:for-each select="tokenize($index-page,'/')">../</xsl:for-each>
   </xsl:variable>
   <xsl:variable name="reference-link"   select="$path-to-common || $reference-page"/>
   <xsl:variable name="definitions-link" select="$path-to-common || $definitions-page"/>
   
   <xsl:variable name="all-objects" select="//*[exists(@_tree-json-id)]"/>
   
   <xsl:template match="/*">
      <div class="json-index">
         <xsl:for-each-group expand-text="true" select="$all-objects" group-by="@key">
            <xsl:sort select="upper-case(current-grouping-key()) => replace('^\p{P}','')"/>
            <section class="named-object-group">
            <h1 class="toc1" id="/{ current-grouping-key() }">{ current-grouping-key() }</h1>
               <ul>
                  <xsl:apply-templates select="current-group()" mode="listing"/>
               </ul>
            </section>
         </xsl:for-each-group>
      </div>
   </xsl:template>
   
   <xsl:template match="*" expand-text="true" mode="listing">
      <li>
         <span class="pathlink">
            <xsl:apply-templates select="." mode="linked-path"/>
         </span>
         <xsl:text> - </xsl:text>
         <span class="formal-name">
            <a href="{ $definitions-link }#{ @_metaschema-json-id }">
               <xsl:text>{ formal-name }</xsl:text>
               <xsl:if test="empty(formal-name)" expand-text="true">{ name() }</xsl:if>
            </a>
         </span>
      </li>
   </xsl:template>
   
   <xsl:template match="." mode="linked-path">
      <xsl:apply-templates select="parent::*" mode="linked-path"/>
      <xsl:apply-templates select="@key" mode="linked-path"/>
   </xsl:template>

   <xsl:template match="@key" mode="linked-path" expand-text="true">
      <xsl:text>/</xsl:text>
      <a href="{ $reference-link }#{ ../@_tree-json-id }">{ string(.) }</a>
   </xsl:template>
   
</xsl:stylesheet>
