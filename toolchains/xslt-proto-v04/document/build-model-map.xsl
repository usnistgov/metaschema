<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:math="http://www.w3.org/2005/xpath-functions/math"
    xmlns="http://csrc.nist.gov/ns/oscal/metaschema/1.0"
    xpath-default-namespace="http://csrc.nist.gov/ns/oscal/metaschema/1.0"
    xmlns:html="http://www.w3.org/1999/xhtml"
    
    exclude-result-prefixes="#all"
    version="3.0">
    
    <xsl:template match="/METASCHEMA">
        <map>
            <xsl:apply-templates select="child::*[exists(root-name)]" mode="build"/>
        </map>
    </xsl:template>
    
    <xsl:key name="definitions" match="METASCHEMA/define-assembly | METASCHEMA/define-field | METASCHEMA/define-flag" use="@name"/>
    
    <xsl:template match="define-assembly | define-field" mode="build">
        <xsl:param name="minOccurs" select="(@min-occurs,'0')[1]"/>
        <xsl:param name="maxOccurs" select="(@max-occurs,'0')[1]"/>
        <xsl:param name="use-name" select="use-name"/>
        <xsl:param name="group-name" select="group-as/@name"/>
        <xsl:param name="group-json" select="group-as/@in-json"/>
        <xsl:param name="group-xml" select="group-as/@in-xml"/>
        <xsl:param name="in-xml" select="()"/>
        <xsl:param name="visited" select="()" tunnel="true"/>
        <xsl:variable name="type" select="replace(local-name(),'^define\-','')"/>
        
        <xsl:element name="{ $type }" namespace="http://csrc.nist.gov/ns/oscal/metaschema/1.0">
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
            
            <xsl:apply-templates select="json-key, json-value-key" mode="build"/>
            <xsl:for-each select="$group-name">
                <xsl:attribute name="group-name" select="."/>
            </xsl:for-each>
            <xsl:if test="not(@name = $visited)">
                <xsl:apply-templates select="define-flag | flag" mode="build"/>
                <xsl:apply-templates select="model" mode="build">
                    <xsl:with-param name="visited" tunnel="true" select="$visited, string(@name)"/>
                </xsl:apply-templates>
            </xsl:if>
        </xsl:element>
    </xsl:template>
    
    <xsl:template mode="build" match="json-value-key[matches(@flag-name,'\S')]">
        <xsl:attribute name="json-value-flag" select="@flag-name"/>
    </xsl:template>
    
    <xsl:template mode="build" match="json-value-key">
        <xsl:attribute name="{ local-name() }" select="."/>
    </xsl:template>
    
    <xsl:template mode="build" match="json-key">
        <xsl:attribute name="json-key-flag" select="@flag-name"/>
    </xsl:template>
    
    <xsl:template match="@module | @ref" mode="build"/>
    
    <xsl:template match="@*" mode="build">
        <xsl:copy-of select="."/>
    </xsl:template>
    
    <xsl:template match="flag | define-flag" mode="build">
        <flag max-occurs="1" min-occurs="{if (@required='yes') then 1 else 0}" as-type="string">
            <xsl:attribute name="name" select="(@name,@ref)[1]"/>
            <xsl:attribute name="link" select="(@ref,../@name)[1]"/>
            <xsl:apply-templates select="@*" mode="build"/>
        </flag>
    </xsl:template>
    
    <xsl:template match="text()" mode="build"/>
    
    <xsl:template mode="build" match="model//field | model//assembly">
        <xsl:apply-templates mode="build" select="key('definitions', @ref)">
            <xsl:with-param name="minOccurs" select="(@min-occurs,'0')[1]"/>
            <xsl:with-param name="maxOccurs" select="(@max-occurs,'1')[1]"/>
            <xsl:with-param name="group-name" select="group-as/@name"/>
            <xsl:with-param name="group-json" select="group-as/@in-json"/>
            <xsl:with-param name="group-xml" select="group-as/@in-xml"/>
            <xsl:with-param name="in-xml" select="@in-xml"/>
        </xsl:apply-templates>
    </xsl:template>
    
    <!--<xsl:template mode="build" match="description | remarks">
        <xsl:apply-templates mode="#current"/>
    </xsl:template>
    
    <xsl:template mode="build" match="*">
        <xsl:apply-templates mode="#current"/>
    </xsl:template>-->
    
</xsl:stylesheet>