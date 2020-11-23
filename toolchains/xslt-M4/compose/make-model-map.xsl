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
    
    <xsl:template match="/METASCHEMA">
        <map namespace="{child::namespace ! normalize-space(.) }"
            prefix="{child::short-name ! normalize-space(.) }">
            <xsl:copy-of select="schema-name | schema-version"/>
            <xsl:apply-templates select="child::*[exists(root-name)]" mode="build"/>
        </map>
    </xsl:template>
    
    <xsl:key name="global-assemblies" match="METASCHEMA/define-assembly" use="@name"/>
    <xsl:key name="global-fields"     match="METASCHEMA/define-field"    use="@name"/>
    
    <xsl:template match="define-assembly | define-field" mode="build">
        <xsl:param name="minOccurs" select="(@min-occurs,'0')[1]"/>
        <xsl:param name="maxOccurs" select="(@max-occurs,'1')[1]"/>
        <xsl:param name="use-name" select="use-name"/>
        <xsl:param name="group-name" select="group-as/@name"/>
        <xsl:param name="group-json" select="group-as/@in-json"/>
        <xsl:param name="group-xml" select="group-as/@in-xml"/>
        <xsl:param name="in-xml" select="()"/>
        <xsl:param name="visited" select="()" tunnel="true"/>
        <xsl:variable name="type" select="replace(local-name(),'^define\-','')"/>
        
        <xsl:element name="{ $type }" namespace="http://csrc.nist.gov/ns/oscal/metaschema/1.0">
            <xsl:attribute name="scope" select="if (exists(parent::METASCHEMA)) then 'global' else 'local'"/>
            <xsl:if test="@name = $visited">
                <xsl:attribute name="recursive">true</xsl:attribute>
            </xsl:if>
            <xsl:apply-templates select="@*" mode="build"/>
            <xsl:attribute name="min-occurs" select="$minOccurs"/>
            <xsl:attribute name="max-occurs" select="$maxOccurs"/>
            <xsl:for-each select="$in-xml"><!-- UNWRAPPED or WITH_WRAPPER - supports unwrapped markup-multiline fields -->
                <xsl:attribute name="in-xml" select="."/>
            </xsl:for-each>
            <xsl:for-each select="$group-xml"><!-- GROUPED or UNGROUPED - introduces a grouping element for the group -->
                <xsl:attribute name="group-xml" select="."/>
            </xsl:for-each>
            <xsl:for-each select="$group-json"><!-- ARRAY (default), SINGLETON_OR_ARRAY, BY_KEY --> 
                <xsl:attribute name="group-json" select="."/>
            </xsl:for-each>
            <xsl:for-each select="root-name | ($use-name, child::use-name)[1]">
                <xsl:attribute name="{ local-name() }" select="."/>
            </xsl:for-each>
            <xsl:apply-templates select="json-key" mode="build"/>
            <xsl:for-each select="$group-name">
                <xsl:attribute name="group-name" select="."/>
            </xsl:for-each>
            <xsl:if test="not(@name = $visited)">
                <xsl:apply-templates select="define-flag | flag" mode="build"/>
                <xsl:apply-templates select="model" mode="build">
                    <xsl:with-param name="visited" tunnel="true" select="$visited, string(@name)"/>
                </xsl:apply-templates>
                <xsl:for-each select="self::define-field">
                    <value as-type="{(@as-type,'string')[1]}">
                        <xsl:apply-templates select="." mode="value-key"/>
                    </value>
                </xsl:for-each>
            </xsl:if>
            <xsl:apply-templates select="constraint" mode="build"/>
        </xsl:element>
    </xsl:template>
    
    <xsl:template mode="build" match="json-value-key[matches(@flag-name,'\S')]">
        <xsl:attribute name="json-value-flag" select="@flag-name"/>
    </xsl:template>
    
    <!--<xsl:template mode="build" match="json-value-key">
        <xsl:attribute name="{ local-name() }" select="."/>
    </xsl:template>-->
    
    <xsl:template mode="build" match="json-key">
        <xsl:attribute name="json-key-flag" select="@flag-name"/>
    </xsl:template>
    
    <xsl:template match="@module | @ref" mode="build"/>
    
    <xsl:template match="@*" mode="build">
        <xsl:copy-of select="."/>
    </xsl:template>
    
    <!-- dropped in build mode b/c picked up by calling template -->
    <xsl:template match="define-field/@as-type" mode="build"/>
    
    <xsl:template match="choice" mode="build">
        <choice>
            <xsl:apply-templates mode="#current"/>
        </choice>
    </xsl:template>
    
    <xsl:template mode="build" match="model//assembly">
        <xsl:apply-templates mode="build" select="key('global-assemblies', @ref)">
            <xsl:with-param name="minOccurs" select="(@min-occurs,'0')[1]"/>
            <xsl:with-param name="maxOccurs" select="(@max-occurs,'1')[1]"/>
            <xsl:with-param name="group-name" select="group-as/@name"/>
            <xsl:with-param name="group-json" select="group-as/@in-json"/>
            <xsl:with-param name="group-xml" select="group-as/@in-xml"/>
            <xsl:with-param name="in-xml" select="@in-xml"/>
        </xsl:apply-templates>
    </xsl:template>
    
    <xsl:template mode="build" match="model//field">
        <xsl:apply-templates mode="build" select="key('global-fields', @ref)">
            <xsl:with-param name="minOccurs" select="(@min-occurs,'0')[1]"/>
            <xsl:with-param name="maxOccurs" select="(@max-occurs,'1')[1]"/>
            <xsl:with-param name="group-name" select="group-as/@name"/>
            <xsl:with-param name="group-json" select="group-as/@in-json"/>
            <xsl:with-param name="group-xml" select="group-as/@in-xml"/>
            <xsl:with-param name="in-xml" select="@in-xml"/>
        </xsl:apply-templates>
    </xsl:template>
    
    <xsl:template match="flag | define-flag" mode="build">
        <flag max-occurs="1" min-occurs="{if (@required='yes') then 1 else 0}" as-type="string">
            <xsl:for-each select="self::flag">
                <xsl:attribute name="scope">global</xsl:attribute>
            </xsl:for-each>
            <xsl:attribute name="name" select="(use-name,@name,@ref)[1]"/>
            <xsl:attribute name="link" select="(@ref,../@name)[1]"/>
            <xsl:attribute name="as-type">string</xsl:attribute>
            <xsl:apply-templates select="@*" mode="build"/>
            <xsl:apply-templates select="constraint" mode="build"/>
        </flag>
    </xsl:template>
    
    <xsl:template match="constraint" mode="build">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:copy-of select="*"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="text()" mode="build"/>
    
    <xsl:variable name="string-value-label">STRVALUE</xsl:variable>
    <xsl:variable name="markdown-value-label">RICHTEXT</xsl:variable>
    <xsl:variable name="markdown-multiline-label">PROSE</xsl:variable>

    <xsl:template priority="3" match="define-field[exists(json-value-key/@flag-name)]" mode="value-key">
        <xsl:attribute name="key-flag" select="json-value-key/@flag-name"/>
    </xsl:template>

    <!-- When a field has no flags not designated as a json-value-flag, it is 'naked'; its value is given without a key
         (in target JSON it will be the value of a (scalar) property, not a value on a property of an object property. -->
    <xsl:template mode="value-key" priority="2" match="define-field[empty(flag[not(@ref=../json-value-key/@flag-name)] | define-flag[not(@ref=../json-value-key/@flag-name)])]"/>
    
    <xsl:template priority="2" match="define-field[exists(json-value-key)]" mode="value-key">
        <xsl:attribute name="key" select="json-value-key"/>
    </xsl:template>
    
    <xsl:template match="define-field[@as-type='markup-line']" mode="value-key">
        <xsl:attribute name="key" select="$markdown-value-label"/>
    </xsl:template>
    
    <xsl:template match="define-field[@as-type='markup-multiline']" mode="value-key">
        <xsl:attribute name="key" select="$markdown-multiline-label"/>
    </xsl:template>
    
        
    <xsl:template match="define-field" mode="value-key">
        <xsl:attribute name="key" select="$string-value-label"/>
    </xsl:template>
    
</xsl:stylesheet>