<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:math="http://www.w3.org/2005/xpath-functions/math"
    xmlns="http://csrc.nist.gov/ns/oscal/metaschema/1.0"
    xpath-default-namespace="http://csrc.nist.gov/ns/oscal/metaschema/1.0"
    xmlns:html="http://www.w3.org/1999/xhtml"
    
    exclude-result-prefixes="#all"
    version="3.0">
    
    <!--
        
    Input: an unfolded metaschema 'abstract tree' as produced by
    steps in ../compose subdirectory

    -->
    
    <xsl:mode on-no-match="shallow-copy"/>
    
    <xsl:template match="assembly | field | group">
        <element>
            <xsl:apply-templates select="@name,@min-occurs,@max-occurs,@as-type"/>
            <xsl:apply-templates/>
        </element>
    </xsl:template>
    
    <xsl:template match="group[@in-xml='HIDDEN']">
        <xsl:apply-templates/>
    </xsl:template>
    
    <xsl:template match="choice">
        <choice>
            <xsl:apply-templates/>
        </choice>
    </xsl:template>
    
    <xsl:template match="flag">
        <attribute>
            <xsl:apply-templates select="@name,@min-occurs,@max-occurs,@as-type"/>
        </attribute>
    </xsl:template>
    
    <xsl:template priority="2" match="field[@as-type='markup-multiline'][@in-xml='UNWRAPPED']">
        <block-sequence/>
    </xsl:template>
    
    <xsl:template match="field[@as-type='markup-multiline']">
        <element>
            <xsl:apply-templates select="@name,@min-occurs,@max-occurs,@as-type"/>
            <xsl:apply-templates/>
            <block-sequence/>
        </element>
        
    </xsl:template>
    
    <xsl:template match="constraint"/>
    
</xsl:stylesheet>