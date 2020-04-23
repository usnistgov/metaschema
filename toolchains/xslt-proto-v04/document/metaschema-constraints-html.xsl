<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:math="http://www.w3.org/2005/xpath-functions/math"
    xmlns:m="http://csrc.nist.gov/ns/oscal/metaschema/1.0"
    xmlns="http://www.w3.org/1999/xhtml"
    xpath-default-namespace="http://csrc.nist.gov/ns/oscal/metaschema/1.0"
    exclude-result-prefixes="#all">
    
    <!-- For standalone use on a metaschema. The transformation polls
    the metaschema instance and reports on any constraint definitions
    it finds, including settings and documentation. -->
    
    <xsl:import href="../metapath/parse-metapath.xsl"/>
    
    <xsl:output indent="yes"/>

    <xsl:strip-space elements="METASCHEMA define-assembly define-field define-flag model choice allowed-values remarks"/>
    
    <xsl:variable name="target-namespace" select="string(/METASCHEMA/namespace)"/>
    
    <xsl:variable name="declaration-prefix" select="string(/METASCHEMA/short-name)"/>
    
    <xsl:variable name="metaschema" select="/"/>
    
<xsl:template match="/" name="start">
    <html>
        <head></head>
        <body>
            <xsl:apply-templates select="//constraint"/>
        </body>
    </html>
</xsl:template>
    
    <xsl:template match="require" priority="100">
        <xsl:apply-templates/>  
    </xsl:template>
    
    <xsl:template match="constraint//*" priority="99">
        <div class="constraint">
            <xsl:next-match/>  
        </div>
    </xsl:template>
    
    <xsl:template match="matches | has-cardinality | index | index-has-key | is-unique | allowed-values | expect" priority="10">
        <h3 xsl:expand-text="yes">{ local-name() }{ @id ! ('[@id=''' || . || ''']' )}</h3>
        
        <xsl:next-match/>
    </xsl:template>
    
    <xsl:template match="matches/* |
        has-cardinality/* | index/* |
        index-has-key/* | is-unique/* |
        allowed-values/* | expect/*" priority="100">
        
    </xsl:template>
    
    
</xsl:stylesheet>