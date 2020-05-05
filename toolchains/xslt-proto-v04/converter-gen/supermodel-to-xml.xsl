<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:math="http://www.w3.org/2005/xpath-functions/math"
    xpath-default-namespace="http://csrc.nist.gov/ns/oscal/metaschema/1.0/supermodel"
    exclude-result-prefixes="xs math"
    version="3.0">
    
    <xsl:output indent="true"/>
    <xsl:strip-space elements="*"/>
    <xsl:preserve-space elements="flag value"/>
    
    <xsl:variable name="ns" select="/*/@namespace"/>
    
    <xsl:template match="*[exists(@gi)]">
        <xsl:element name="{@gi}" namespace="{ $ns }">
            <!-- putting flags first in case of disarranged inputs -->
            <xsl:apply-templates select="flag, (* except flag)"/>
        </xsl:element>
    </xsl:template>
    
    <xsl:template match="value[@as-type='markup-line']">
        <xsl:apply-templates mode="cast-prose"/>
    </xsl:template>
    
    <xsl:template match="p | ul | ol | pre | h1 | h2 | h3 | h4 | h5 | h6 | table">
        <xsl:apply-templates select="." mode="cast-prose"/>
    </xsl:template>
    
    <xsl:template priority="2" match="flag">
        <xsl:attribute name="{@gi}">
            <xsl:apply-templates/>
        </xsl:attribute>
    </xsl:template>
    
    <xsl:template match="*" mode="cast-prose">
        <xsl:element name="{local-name()}" namespace="{ $ns }">
            <xsl:copy-of select="@*"/>
            <xsl:apply-templates mode="#current"/>
        </xsl:element>
    </xsl:template>
    
    
    
</xsl:stylesheet>