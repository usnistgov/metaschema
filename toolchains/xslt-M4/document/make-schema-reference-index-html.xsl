<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0"
   xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
   xmlns:xs="http://www.w3.org/2001/XMLSchema"
   xmlns="http://www.w3.org/1999/xhtml"
   xpath-default-namespace="http://www.w3.org/1999/xhtml"
   xmlns:m="http://csrc.nist.gov/ns/oscal/metaschema/1.0"
   exclude-result-prefixes="#all">

   <!-- Assumes HTML with sections and indexes these by their names as presented  -->
   
   <xsl:mode on-no-match="shallow-copy"/>
   
   <xsl:param name="reference-page">../reference</xsl:param>
   
   <xsl:template match="/*">
      <xsl:copy>
         <xsl:copy-of select="@*"/>
         <xsl:for-each-group expand-text="true" select="//section[@class=('json-obj','xml-element','xml-attribute')]" group-by="*[1]/string(.)">
            <xsl:sort/>
            <section class="named-object-group" id="/index/{current-grouping-key()}">
            <h1 class="toc1" id="{ *[1]/@id }">{ current-grouping-key() }</h1>
               <ul>
                  <xsl:apply-templates select="current-group()"/>
               </ul>
            </section>
         </xsl:for-each-group>
      </xsl:copy>
   </xsl:template>
   
   <xsl:template match="section" expand-text="true">
      <xsl:variable name="head"        select="*[1]"/>
      <xsl:for-each select="child::div[@class='obj-desc']/div[@class='obj-matrix']">
         <xsl:variable name="formal-name" select="p[@class='obj-name']"/>
         <xsl:variable name="path"        select="p[@class='path']"/>
         <li><a href="{ $reference-page }#{ $head/@id }"><code>{ $path }</code></a> - <b>{ $formal-name }</b>
            <xsl:for-each select="$head/../parent::section"> - inside <code>{ child::*[1] }</code></xsl:for-each>
         </li>
      </xsl:for-each>
   </xsl:template>
   
   
</xsl:stylesheet>
