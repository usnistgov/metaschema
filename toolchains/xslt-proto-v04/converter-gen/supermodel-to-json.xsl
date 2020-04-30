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
    
    <!--group assembly field flag value-->
    
    <xsl:template match="group">
        <array>
            <xsl:copy-of select="@key"/>
            <xsl:apply-templates/>
        </array>
    </xsl:template>
    
    <xsl:template match="group[@in-json='BY_KEY']">
        <map>
            <xsl:copy-of select="@key"/>
            <xsl:apply-templates/>
        </map>
    </xsl:template>
    
    <xsl:template match="flag[@key=../@json-key-flag]"/>
    
    <xsl:template match="group[@in-json='SINGLETON_OR_ARRAY'][count(*)=1]">
        <xsl:apply-templates>
            <xsl:with-param name="group-key" select="@key"/>
        </xsl:apply-templates>
    </xsl:template>
    
    <xsl:template priority="2" match="group/assembly | group/field">
        <!-- $group-key is only provided when group/@in-json="SINGLETON_OR_ASSEMBLY" and there is one member of the group -->
        <xsl:param name="group-key" select="()"/>
        <!--@json-key-flag is only available when group/@in-json="BY_KEY"-->
        <xsl:variable name="json-key-flag-name" select="@json-key-flag"/>
        <map>
            <xsl:copy-of select="($group-key,@key)[1]"/>
            <!-- when there's a JSON key flag, we get the key from there -->
            <xsl:for-each select="flag[@key=$json-key-flag-name]">
                <xsl:attribute name="key" select="."/>
            </xsl:for-each>
            <xsl:apply-templates/>
        </map>
    </xsl:template>
    
    <xsl:template priority="3" match="group/field[@in-json='STRING']">
        <xsl:param name="group-key" select="()"/>
        <xsl:variable name="json-key-flag-name" select="@json-key-flag"/>
        <!-- with no flags, this field has only its value -->
        <xsl:apply-templates>
                <xsl:with-param name="use-key" select="flag[@key=$json-key-flag-name]"/>
            </xsl:apply-templates>
    </xsl:template>
    
    <xsl:template match="assembly">
        <map key="{@key}">
            <xsl:apply-templates/>
        </map>
    </xsl:template>
    
    <xsl:template match="field">
        <map key="{@key}">
            <xsl:apply-templates/>
        </map>
    </xsl:template>
    
    <xsl:template match="field[@in-json='STRING']">
        <!-- when there are no flags, the field is a string whose value is the value -->
        <string>
            <xsl:copy-of select="@key"/>
            <xsl:value-of select="value"/>
        </string>
    </xsl:template>
    
    <xsl:template match="flag">
        <string>
            <xsl:copy-of select="@key"/>
            <xsl:apply-templates/>
        </string>
    </xsl:template>
    
    <xsl:template match="field[@in-json='STRING']/value">
        <xsl:param name="use-key" select="()"/>
        <string>
            <xsl:for-each select="$use-key">
                <xsl:attribute name="key" select="."/>
            </xsl:for-each>
            <xsl:apply-templates/>
        </string>
    </xsl:template>
    
    <xsl:template match="value">
        <xsl:param name="use-key" select="()"/>
        <string key="{ ($use-key,@key)[1] }">
            <xsl:apply-templates/>
        </string>
    </xsl:template>
    
    <xsl:template match="p | ul | ol | pre | h1 | h2 | h3 | h4 | h5 | h6 | table">
        <xsl:apply-templates select="." mode="make-markdown"/>
    </xsl:template>
    
    
    
    
    
</xsl:stylesheet>