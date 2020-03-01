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
    
    <!--
        
    Account for:
    
    assemblies -> objects
    fields -> objects
    field values -> (labeled) strings
    flags -> strings
    groups -> arrays or object-or-array
    
    markup-line
    markup-multiline
    
    json-value-key (fixed or by flag)
    json-key (changes parent from array to object)
    
    datatypes
      numeric types -> number
      booleans

    -->
    
    <!--<xsl:template match="@min-occurs">
        <xsl:if test="not(.='0')">
            <xsl:attribute name="required">yes</xsl:attribute>
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="@max-occurs"/>-->
    
    <xsl:template match="assembly | field">
        <object>
            <xsl:apply-templates select="@name,@min-occurs,@max-occurs,@as-type"/>
            <xsl:apply-templates/>
        </object>
    </xsl:template>
    
    <xsl:template match="field[empty(flag)]">
        <string>
            <xsl:apply-templates select="@name,@min-occurs,@max-occurs,@as-type"/>
            <xsl:apply-templates/>
        </string>
    </xsl:template>
    
    <xsl:template match="group">
        <singleton-or-array>
            <xsl:apply-templates select="@name,@min-occurs,@max-occurs,@as-type"/>
            <xsl:apply-templates/>
        </singleton-or-array>
    </xsl:template>
    
    <xsl:template match="group[@in-json='ARRAY' or true()]">
        <array>
            <xsl:apply-templates select="@name,@min-occurs,@max-occurs,@as-type"/>
            <xsl:apply-templates/>
        </array>
    </xsl:template>
    
    <xsl:template match="group[@in-json='SINGLETON_OR_ARRAY']">
        <singleton-or-array>
            <xsl:apply-templates select="@name,@min-occurs,@max-occurs,@as-type"/>
            <xsl:apply-templates/>
        </singleton-or-array>
    </xsl:template>
    
    <xsl:template match="group[@in-json='BY_KEY']">
        <group-by-key key-flag="{@json-key-flag}">
            <xsl:apply-templates select="@name,@min-occurs,@max-occurs,@as-type"/>
            <xsl:apply-templates/>
        </group-by-key>
    </xsl:template>
    
    <xsl:template match="flag">
        <string>
            <xsl:apply-templates select="@name,@min-occurs,@max-occurs,@as-type"/>
            <xsl:apply-templates/>
        </string>
    </xsl:template>
    
    <!--<xsl:template match="field[@as-type='markup-multiline'][@in-xml='UNWRAPPED']">
        <unwrapped-prose-sequence/>
    </xsl:template>-->
    
</xsl:stylesheet>