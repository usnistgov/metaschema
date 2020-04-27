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
        
    Input: an unfolded metaschema 'abstract tree' as produced by
    steps in ../compose subdirectory

    -->
    
    <!--<xsl:template match="@min-occurs">
        <xsl:if test="not(.='0')">
            <xsl:attribute name="required">yes</xsl:attribute>
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="@max-occurs"/>-->
    
    <xsl:template match="@name">
        <xsl:copy-of select="."/>
        <xsl:attribute name="key" select="."/>
    </xsl:template>
      
    <xsl:template match="assembly">
        <object>
            <xsl:apply-templates select="@name,@min-occurs,@max-occurs"/>
            <xsl:apply-templates/>
        </object>
    </xsl:template>
    
    <xsl:template match="field">
        <object>
            <xsl:apply-templates select="@name,@min-occurs,@max-occurs"/>
            <xsl:apply-templates mode="field-value" select="."/>
            <xsl:apply-templates select="flag"/>
        </object>
    </xsl:template>
    
    <xsl:template match="field" mode="field-value">
        <string name="STRVALUE" min-occurs="0" max-occurs="1">
            <xsl:apply-templates select="@as-type"/>
        </string>
    </xsl:template>
    
    <xsl:template match="field[@as-type='markup-line']" mode="field-value">
        <string name="RICHTEXT" min-occurs="0" max-occurs="1">
            <xsl:apply-templates select="@as-type"/>
        </string>
    </xsl:template>
    
    <xsl:template match="field[@as-type='markup-multiline']" mode="field-value">
        <string name="PROSE" min-occurs="0" max-occurs="1">
            <xsl:apply-templates select="@as-type"/>
        </string>
    </xsl:template>
    
    <xsl:template priority="2" match="field[matches(@json-value-key,'\S')]" mode="field-value">
        <string name="{@json-value-key}" min-occurs="0" max-occurs="1">
            <xsl:apply-templates select="@as-type"/>
        </string>
    </xsl:template>
    
    <!-- required so we have a value for the required implicit flag (whose value is designated in this name) -->
    <xsl:template priority="3" match="field[matches(@json-value-flag,'\S')]" mode="field-value">
        <string name="{ '{{' || @json-value-flag || '}}' }" min-occurs="1" max-occurs="1">
            <xsl:apply-templates select="@as-type"/>
        </string>
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
    
    <xsl:template match="group[exists(@json-key-flag)]">
        <object property-key="{@json-key-flag}">
            <xsl:apply-templates select="@name,@min-occurs,@max-occurs,@as-type"/>
            <xsl:apply-templates/>
        </object>
    </xsl:template>
    
    <xsl:template match="group[exists(@json-key-flag)]/*">
        <object key="{{{{ {@json-key-flag} }}}}">
            <xsl:apply-templates select="@min-occurs,@max-occurs,@as-type"/>
            <xsl:apply-templates/>
        </object>
    </xsl:template>
    
    <xsl:template priority="3" match="group[exists(@json-key-flag)]/field[not(flag/@name != @json-key-flag)]">
        <string name="{{{{@json-key-flag}}}}">
            <xsl:apply-templates select="@name,@min-occurs,@max-occurs,@as-type"/>
            <xsl:apply-templates/>
        </string>
    </xsl:template>
    
    <!-- Suppressing flags when they are presented as keys on a value (json-value-flag) -->
    <xsl:template match="flag[@name=../@json-value-flag]"/>
    
    <!-- ... and when they are presented as keys on an object (json-key-flag) -->
    <xsl:template match="flag[@name=../@json-key-flag]"/>
    
    <xsl:template match="flag">
        <string>
            <xsl:apply-templates select="@name,@min-occurs,@max-occurs,@as-type"/>
            <xsl:apply-templates/>
        </string>
    </xsl:template>
    
    <xsl:template match="constraint"/>
    <!--<xsl:template match="field[@as-type='markup-multiline'][@in-xml='UNWRAPPED']">
        <unwrapped-prose-sequence/>
    </xsl:template>-->
    
</xsl:stylesheet>