<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns="http://csrc.nist.gov/ns/oscal/metaschema/1.0"
    xpath-default-namespace="http://csrc.nist.gov/ns/oscal/metaschema/1.0"
    
    exclude-result-prefixes="#all"
    version="3.0">
    
<!-- expand references with info from their target declarations
        
explicit cardinality


recover from definition
  as-type
  json-key (flag)
  json-value-key (flag)
  json-value-key (literal)
        
        @in-xml
        @in-json
        
    -->
    <xsl:output indent="yes"/>
    
    <xsl:mode name="build" on-no-match="shallow-copy"/>
    
    <xsl:strip-space elements="*"/>
    
    <xsl:preserve-space elements="
        schema-name schema-version short-name namespace p code formal-name description json-value-key q enum root-name a em"/>
    
    <xsl:template match="/METASCHEMA">
        <DEFINITIONS>
            <xsl:apply-templates mode="build"/>
        </DEFINITIONS>
    </xsl:template>
    
    <xsl:template match="remarks | example" mode="#all"/>
    
    <xsl:template match="METASCHEMA/*" mode="build"/>
    
    <xsl:template mode="build" priority="2" match="/*/define-assembly | /*/define-field | /*/define-flag">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:apply-templates mode="#current"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="model//*[exists(group-as)]" mode="build">
        <group in-json="ARRAY">
            <xsl:copy-of select="group-as/@*"/>
            <xsl:next-match/>
        </group>
    </xsl:template>
    
    <xsl:template match="model//group-as" mode="build"/>
    
    <xsl:key name="flag-definition-by-name"     match="METASCHEMA/define-flag" use="@name"/>
    <xsl:key name="field-definition-by-name"    match="METASCHEMA/define-field" use="@name"/>
    <xsl:key name="assembly-definition-by-name" match="METASCHEMA/define-assembly" use="@name"/>
    
    <xsl:template match="assembly" mode="build">
        <xsl:copy>
            <xsl:attribute name="min-occurs">0</xsl:attribute>
            <xsl:attribute name="max-occurs">1</xsl:attribute>
            <xsl:copy-of select="@*"/>
            <xsl:apply-templates select="key('assembly-definition-by-name',@ref)" mode="reflect"/>
            <xsl:apply-templates mode="build"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="field" mode="build">
        <xsl:copy>
            <xsl:attribute name="min-occurs">0</xsl:attribute>
            <xsl:attribute name="max-occurs">1</xsl:attribute>
            <xsl:copy-of select="@*"/>
            <xsl:apply-templates select="key('field-definition-by-name',@ref)" mode="reflect"/>
            <xsl:apply-templates mode="build"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="flag" mode="build">
        <xsl:apply-templates mode="local-definition" select="key('flag-definition-by-name',@ref)">
            <xsl:with-param name="caller" select="."/>
        </xsl:apply-templates>
    </xsl:template>
    
    <xsl:template match="define-flag" mode="local-definition">
        <xsl:param name="caller" as="element()?"/>
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:copy-of select="$caller/@required"/>
            <xsl:apply-templates mode="build"/>
        </xsl:copy>
    </xsl:template>
    
    
    <xsl:template match="define-assembly | define-field" mode="reflect">
        <xsl:copy-of select="@as-type"/>
        <xsl:attribute name="name" select="@name"/>
        <xsl:apply-templates select="use-name"    mode="#current"/>
        <xsl:apply-templates select="json-key"    mode="#current"/>
        <xsl:apply-templates select="json-value-key"    mode="#current"/>
        <!--<xsl:apply-templates select="formal-name" mode="#current"/>-->
        <!--<xsl:apply-templates select="description" mode="#current"/>-->
        
    </xsl:template>
    
    <xsl:mode name="reflect" on-no-match="deep-skip"/>
    
    <xsl:template mode="reflect" match="use-name">
        <xsl:attribute name="name" select="."/>
    </xsl:template>
    
    <xsl:template mode="reflect" match="json-key[@flag-name]">
        <xsl:attribute name="json-key-flag" select="@flag-name"/>
    </xsl:template>
    
    <xsl:template mode="reflect" match="json-value-key[@flag-name]">
        <xsl:attribute name="json-value-key-flag" select="@flag-name"/>
    </xsl:template>
    
    <xsl:template mode="reflect" match="json-value-key">
        <xsl:attribute name="json-value-key-flag" select="normalize-space(.)"/>
    </xsl:template>
    
    
    
</xsl:stylesheet>