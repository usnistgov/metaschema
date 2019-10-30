<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:math="http://www.w3.org/2005/xpath-functions/math"
    exclude-result-prefixes="xs math"
    version="3.0" expand-text="true">

    <xsl:output method="text"></xsl:output>
    <!--  Emits a Markdown dump of XSD element and attribute declarations, with docs -->

    <xsl:template match="xs:schema">
        <xsl:apply-templates select="//xs:element/@name/.."/>
        <xsl:text>&#xA;&#xA;</xsl:text>
    </xsl:template>
    
    <xsl:template match="xs:element">
        <xsl:text>&#xA;* `{ @name }`</xsl:text>
        <xsl:apply-templates select="child::xs:annotation/xs:documentation"/>
        <xsl:apply-templates select="child::xs:complexType/xs:attribute"/>
    </xsl:template>
    
    <xsl:template match="xs:attribute">
        <xsl:text>&#xA;  * `{ ../../@name }/@{ @name }`</xsl:text>
        <xsl:apply-templates select="child::xs:annotation/xs:documentation"/>
    </xsl:template>
    
    <xsl:template match="xs:documentation">
        <xsl:text>: </xsl:text>
        <xsl:value-of select="normalize-space(.)"/>
    </xsl:template> 
    

</xsl:stylesheet>