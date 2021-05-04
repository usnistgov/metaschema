<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:math="http://www.w3.org/2005/xpath-functions/math"
    xmlns:m="http://csrc.nist.gov/ns/oscal/metaschema/1.0"
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
    </xsl:template>
    
    <xsl:template match="@key">
        <xsl:copy-of select="."/>
    </xsl:template>
    
    <xsl:template match="assembly">
        <object>
            <xsl:apply-templates select="@id,@key,@name,@min-occurs,@max-occurs"/>
            <xsl:apply-templates/>
        </object>
    </xsl:template>
    
    <xsl:template match="group/assembly">
        <object min-occurs="1">
            <xsl:apply-templates select="@id,@key,@name,@min-occurs,@max-occurs"/>
            <xsl:apply-templates/>
        </object>
    </xsl:template>
    
    <!-- Within a group, an assembly is always required even for min-occurs='0' because its wrapper (array or object) is optional.   -->
    <xsl:template match="group[@group-json='ARRAY']/assembly/@min-occurs[.='0']">
        <xsl:attribute name="min-occurs">1</xsl:attribute>
    </xsl:template>
    
    <xsl:template match="field">
        <object>
            <xsl:apply-templates select="@id,@key,@name,@min-occurs,@max-occurs"/>
            <xsl:apply-templates mode="field-value" select="."/>
            <xsl:apply-templates select="flag, formal-name, description, remarks, value"/>
        </object>
    </xsl:template>
    
    <xsl:template match="value">
        <string name="{@key}" min-occurs="0" max-occurs="1">
            <xsl:apply-templates select="@as-type"/>
        </string>
    </xsl:template>
    
    <xsl:template match="field[empty(flag)]">
        <string>
            <xsl:apply-templates select="@id,@key,@name,@min-occurs,@max-occurs,@as-type,value/@as-type"/>
            <xsl:apply-templates select="formal-name, description, remarks"/>
        </string>
    </xsl:template>
    
    <xsl:template match="group">
        <singleton-or-array>
            <xsl:apply-templates select="@key,@name,@min-occurs,@max-occurs,@as-type"/>
            <xsl:apply-templates/>
        </singleton-or-array>
    </xsl:template>
    
    <xsl:template match="group[@group-json='ARRAY']">
        <array>
            <xsl:apply-templates select="@key,@name,@min-occurs,@max-occurs,@as-type"/>
            <xsl:apply-templates/>
        </array>
    </xsl:template>
    
    <xsl:template match="group[exists(@json-key-flag)]">
        <object property-key="{@json-key-flag}">
            <xsl:apply-templates select="@key,@name,@min-occurs,@max-occurs,@as-type"/>
            <xsl:apply-templates/>
        </object>
    </xsl:template>
    
    <xsl:template priority="5" match="group[exists(@json-key-flag)]/*">
        <!-- escaping out for consumption by Hugo -->
        <xsl:variable as="xs:string" name="o">{</xsl:variable>
        <xsl:variable as="xs:string" name="c">}</xsl:variable>
        <object key="{ $o || @json-key-flag || $c }">
            <xsl:apply-templates select="@min-occurs,@max-occurs,@as-type"/>
            <xsl:apply-templates/>
        </object>
    </xsl:template>
    
    <xsl:template priority="3" match="group[exists(@json-key-flag)]/field[not(flag/@name != @json-key-flag)]">
        <string name="[[{@json-key-flag}]]">
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
            <xsl:apply-templates select="@id,@key,@name,@min-occurs,@max-occurs,@as-type"/>
            <xsl:apply-templates/>
        </string>
    </xsl:template>

    <!--<xsl:template match="constraint" mode="#all"/>-->
    
    
</xsl:stylesheet>