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
    
    <!-- Moved up to new 'group' parent -->
    <xsl:template match="@group-json | @group-xml | @group-name"/>
    
    <!-- Removing from objects not to be keyed -->
    <xsl:template match="*[exists(@group-name)][@group-json='ARRAY']/@key"/>
    
    <xsl:template priority="10" match="*[exists(@group-name)]">
        <group key="{@group-name}" in-xml="{ if (@group-xml='GROUPED') then 'SHOWN' else 'HIDDEN' }"
            max-occurs="1" min-occurs="{ if (@min-occurs='0') then '0' else '1'}">
            <xsl:if test="@group-xml='GROUPED'">
                <xsl:attribute name="gi" select="@group-name"/>
            </xsl:if>
            <xsl:copy-of select="@json-key-flag | @group-json | @recursive"/>
            <xsl:next-match/>
        </group>
    </xsl:template> 
   
    <xsl:template match="assembly | field | flag">
        <xsl:copy>
            <xsl:apply-templates select="@*"/>
            <xsl:attribute name="id" separator="_">
                <xsl:apply-templates select="ancestor-or-self::*" mode="step-name"/>
                <xsl:value-of select="local-name(.) => upper-case()"/>
            </xsl:attribute>
            <xsl:apply-templates/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="*" mode="step-name"/>

    <xsl:template as="xs:string" match="*[exists(@_using-root-name|@_using-name|@name)]" mode="step-name">
        <xsl:value-of select="(@_using-root-name,@_using-name,@name)[1]"/>
    </xsl:template>

</xsl:stylesheet>