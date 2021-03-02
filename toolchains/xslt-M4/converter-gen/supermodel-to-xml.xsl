<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:s="http://csrc.nist.gov/ns/oscal/metaschema/1.0/supermodel"
    default-mode="write-xml"
    version="3.0">
    
    <xsl:output indent="true"/>
    <xsl:strip-space elements="s:*"/>
    <xsl:preserve-space elements="s:flag s:value"/>
    
    <xsl:mode name="write-xml"/>
    
    <xsl:template match="s:*[exists(@gi)]" mode="write-xml">
        <xsl:element name="{@gi}" namespace="{ /*/@namespace }">
            <!-- putting flags first in case of disarranged inputs -->
            <xsl:apply-templates select="s:flag, (* except s:flag)" mode="write-xml"/>
        </xsl:element>
    </xsl:template>
    
    <xsl:template match="s:value[@as-type=('markup-line','markup-multiline')]" mode="write-xml">
        <xsl:apply-templates mode="cast-prose"/>
    </xsl:template>
    
    <xsl:template match="p | ul | ol | pre | h1 | h2 | h3 | h4 | h5 | h6 | table" xpath-default-namespace="http://csrc.nist.gov/ns/oscal/metaschema/1.0/supermodel">
        <xsl:apply-templates select="." mode="cast-prose"/>
    </xsl:template>
    
    <xsl:template priority="2" match="s:flag" mode="write-xml">
       <xsl:attribute name="{@gi}">
           <xsl:value-of select="."/>
       </xsl:attribute>
    </xsl:template>
    
    <xsl:template match="*" mode="cast-prose">
        <xsl:element name="{local-name()}" namespace="{ /*/@namespace }">
            <xsl:copy-of select="@*"/>
            <xsl:apply-templates mode="#current"/>
        </xsl:element>
    </xsl:template>
    
</xsl:stylesheet>