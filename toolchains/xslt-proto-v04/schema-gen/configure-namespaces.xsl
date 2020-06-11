<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:math="http://www.w3.org/2005/xpath-functions/math"
    xmlns:m="http://csrc.nist.gov/ns/oscal/metaschema/1.0"
    xpath-default-namespace="http://csrc.nist.gov/ns/oscal/metaschema/1.0"
    exclude-result-prefixes="xs math m"
    version="2.0"
    
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">

    <xsl:output indent="yes"/>

    <!-- Including XSD namespace for post process -->
    <xsl:strip-space elements="METASCHEMA define-assembly define-field define-flag model choice allowed-values remarks xs:*"/>
    
    <xsl:variable name="target-namespace" select="string(/xs:schema/@targetNamespace)"/>
    
    <xsl:variable name="declaration-prefix" select="string(/*/xs:annotation/xs:appinfo/short-name)"/>
    
    <xsl:param name="debug" select="'no'"/>
    
    <xsl:template match="/">
        <xsl:apply-templates mode="wire-ns"/>
    </xsl:template>
    
    <!-- Mode 'wire-ns' wires up namespaces, bringing the prose module into the same namespace as the main
     schema, and cleaning up declarations and names as it goes. -->
    <xsl:template match="comment()" mode="wire-ns">
        <xsl:copy-of select="."/>
    </xsl:template>
    
    <xsl:template match="*" mode="wire-ns">
        <xsl:copy copy-namespaces="no"> 
            <xsl:call-template name="namespace-fixup"/>
            <xsl:copy-of select="@*"/>
            <xsl:apply-templates mode="#current"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="m:*" mode="wire-ns" xmlns:m="http://csrc.nist.gov/ns/oscal/metaschema/1.0">
        <xsl:element name="m:{local-name()}">
            <xsl:call-template name="namespace-fixup"/>
            <xsl:copy-of select="@*"/>
            <xsl:apply-templates mode="#current"/>
        </xsl:element>
    </xsl:template>

    <xsl:template name="namespace-fixup">
        <xsl:namespace name="m">http://csrc.nist.gov/ns/oscal/metaschema/1.0</xsl:namespace>
        <xsl:namespace name="{$declaration-prefix}" select="$target-namespace"/>
        <xsl:namespace name="oscal-prose" select="$target-namespace"/>
    </xsl:template>
    
    <xsl:template match="xs:documentation//text() | m:*//text()" mode="wire-ns">
        <xsl:copy-of select="."/>
    </xsl:template>
    
    <xsl:template match="text()" mode="wire-ns"/>
        
</xsl:stylesheet>