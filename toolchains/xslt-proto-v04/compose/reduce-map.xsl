<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:math="http://www.w3.org/2005/xpath-functions/math"
    xmlns="http://csrc.nist.gov/ns/oscal/metaschema/1.0"
    xpath-default-namespace="http://csrc.nist.gov/ns/oscal/metaschema/1.0"
    xmlns:html="http://www.w3.org/1999/xhtml"
    
    exclude-result-prefixes="#all"
    version="3.0">
    
    <xsl:mode on-no-match="shallow-copy"/>
    
    <xsl:template match="@group-name | @group-xml | @in-xml | @link | @root-name | @use-name"/>
    
    <xsl:template match="/map">
        <model root-at="{*/@root-name}">
            <xsl:copy-of select="@*"/>
            <xsl:apply-templates/>
        </model>
    </xsl:template>
    
    <xsl:template match="@name">
        <xsl:if test="empty(../parent::group)">
            <xsl:attribute name="key" select="(../@root-name,../@use-name,.)[1]"/>
        </xsl:if>
        <xsl:if test="not(../@in-xml=('UNWRAPPED','HIDDEN'))">
            <xsl:attribute name="gi"  select="(../@root-name,../@use-name,.)[1]"/>
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="@required"/>
    
    <xsl:template match="@max-occurs">
        <!--<xsl:attribute name="occurs" select="(../@min-occurs,.) => string-join(' ')"/>-->
    </xsl:template>
    
    <xsl:template match="@min-occurs"/>
    
    <!--<xsl:template match="@min-occurs[empty(../@max-occurs)]">
        <xsl:attribute name="occurs" select="(.,'1') => string-join(' ')"/>
    </xsl:template>-->
    
</xsl:stylesheet>