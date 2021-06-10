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
    
    <xsl:output indent="yes"/>
    
    <xsl:mode on-no-match="shallow-copy"/>
    
    <!--
        
    Input: an unfolded metaschema 'abstract tree' as produced by
    steps in ../compose subdirectory

    -->

    <xsl:template match="@*">
        <!--<xsl:message expand-text="true">matching @{ local-name() }</xsl:message>-->
        <xsl:copy-of select="."/>
    </xsl:template>

<!-- When a JSON object has no single corresponding XML element
     we provide as a nominal corresponding target the first available XML path
     given in its contents (generally its single permitted child object). -->
    <!--<xsl:template match="@_tree-xml-id">
        <xsl:copy-of select="."/>
        <xsl:if test="empty(parent::*/@_tree-xml-id)">
            <xsl:apply-templates select="parent::*/child::*[@_tree-xml-id][1]/@_tree-xml-id"/>
        </xsl:if>
    </xsl:template>-->
    
    <xsl:template match="assembly">
        <object>
            <xsl:apply-templates select="@*"/>
            <xsl:apply-templates/>
        </object>
    </xsl:template>
    
    <xsl:template match="group/assembly">
        <object min-occurs="1">
            <xsl:apply-templates select="@* except @min-occurs"/>
            <xsl:apply-templates/>
        </object>
    </xsl:template>
    
    <!-- Within a group, an assembly is always required even for min-occurs='0' because its wrapper (array or object) is optional.   -->
    <xsl:template match="group[@group-json='ARRAY']/assembly/@min-occurs[.='0']">
        <xsl:attribute name="min-occurs">1</xsl:attribute>
    </xsl:template>
    
    <xsl:template match="field">
        <object>
            <xsl:apply-templates select="@*"/>
            <!--<xsl:apply-templates mode="field-value" select="."/>-->
            <xsl:apply-templates/>
        </object>
    </xsl:template>
    
    <xsl:template match="value">
        <string name="{@key}" min-occurs="0" max-occurs="1">
            <xsl:apply-templates select="@* except (@name,@min-occurs,@max-occurs)"/>
        </string>
    </xsl:template>
    
    <xsl:template match="field[empty(flag)]/value"/>
    
    <xsl:template match="field[empty(flag)]">
        <string>
            <xsl:apply-templates select="@*,value/@as-type"/>
            <xsl:apply-templates/>
        </string>
    </xsl:template>
    
    <xsl:template match="group">
        <singleton-or-array>
            <xsl:apply-templates select="@*"/>
            <xsl:apply-templates/>
        </singleton-or-array>
    </xsl:template>
    
    <xsl:template match="group[@group-json='ARRAY']">
        <array>
            <xsl:apply-templates select="@*"/>
            <xsl:apply-templates/>
        </array>
    </xsl:template>
    
    <xsl:template match="group[exists(@json-key-flag)]">
        <object property-key="{@json-key-flag}">
            <xsl:apply-templates select="@*"/>
            <xsl:apply-templates/>
        </object>
    </xsl:template>
    
    <xsl:template priority="5" match="group[exists(@json-key-flag)]/*">
        <xsl:variable as="xs:string" name="o">{</xsl:variable>
        <xsl:variable as="xs:string" name="c">}</xsl:variable>
        <object key="{ $o || @json-key-flag || $c }">
            <xsl:apply-templates select="@* except @key"/>
            <xsl:apply-templates/>
        </object>
    </xsl:template>
    
    <!--IDs on assemblies and fields with dynamic key flags are adjusted
    to reflect the position of the target node in the represented hierarchy -->
    <xsl:template match="assembly[exists(@json-key-flag)]/@_tree-xml-id |
                            field[exists(@json-key-flag)]/@_tree-xml-id">
        <xsl:attribute name="_tree-xml-id">
            <!-- it's a flag so it gets an '@' in the XML path -->
            <xsl:variable name="step" expand-text="true">@{ ../@json-key-flag }</xsl:variable>
            <xsl:value-of select="(.,$step) => string-join('/')"/>
        </xsl:attribute>
    </xsl:template>
    
    <xsl:template match="assembly[exists(@json-key-flag)]/@_tree-json-id |
                            field[exists(@json-key-flag)]/@_tree-json-id">
        <xsl:attribute name="_tree-json-id">
            <xsl:variable name="step" expand-text="true">{ ../@json-key-flag }</xsl:variable>
            <xsl:value-of select="(.,$step) => string-join('/')"/>
        </xsl:attribute>
    </xsl:template>
    
    <xsl:template priority="3"
        match="group[exists(@json-key-flag)]/field[not(flag/@name != @json-key-flag)]">
        <string name="[[{@json-key-flag}]]">
            <xsl:apply-templates select="@* except @name"/>
            <xsl:apply-templates/>
        </string>
    </xsl:template>
    
    <!-- Suppressing flags when they are presented as keys on a value (json-value-flag) -->
    <xsl:template match="flag[@name=../@json-value-flag]"/>
    
    <!-- ... and when they are presented as keys on an object (json-key-flag) -->
    <xsl:template match="flag[@name=../@json-key-flag]"/>
    
    <xsl:template match="flag">
        <string>
            <xsl:apply-templates select="@*"/>
            <xsl:apply-templates/>
        </string>
    </xsl:template>

    <!--<xsl:template match="constraint" mode="#all"/>-->
    
</xsl:stylesheet>