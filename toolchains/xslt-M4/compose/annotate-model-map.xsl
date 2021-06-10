<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:math="http://www.w3.org/2005/xpath-functions/math"
    xmlns="http://csrc.nist.gov/ns/oscal/metaschema/1.0"
    xpath-default-namespace="http://csrc.nist.gov/ns/oscal/metaschema/1.0"
    xmlns:html="http://www.w3.org/1999/xhtml"
    
    exclude-result-prefixes="#all"
    version="3.0">
    
    <!--
        
    Input: an unfolded metaschema 'abstract tree' as produced by
    steps in ../compose subdirectory

    -->
    
    <xsl:mode on-no-match="shallow-copy"/>
    
    <xsl:template priority="2" match="group[@in-xml='HIDDEN']">
        <xsl:copy>
            <xsl:apply-templates select="@*"/>
            <xsl:attribute name="_tree-xml-id">
                <xsl:apply-templates select="child::*[1]" mode="xml-path"/>
            </xsl:attribute>
            <xsl:attribute name="_tree-json-id">
                <xsl:apply-templates select="." mode="object-path"/>
            </xsl:attribute>
            <xsl:apply-templates/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="group | assembly | field | flag | value">
        <xsl:copy>
            <xsl:attribute name="_tree-xml-id">
                <xsl:apply-templates select="." mode="xml-path"/>
            </xsl:attribute>
            <xsl:attribute name="_tree-json-id">
                <xsl:apply-templates select="." mode="object-path"/>
            </xsl:attribute>
            <xsl:apply-templates select="@*"/>
            <xsl:apply-templates/>
        </xsl:copy>
    </xsl:template>
    
<!-- Modes "xml-path" and "object-path" produce complete paths for either model depending on keys and
     generic identifiers (GIs) assigned on the model tree. Each is discrete, with the exception of
     a synthetic path given for values in the XML represented as text leaves (addressable only as text nodes),
     which for model navigation purposes are given a name corresponding to the value name in JSON.
    
     Both modes work the same: a template first produces the result for the parent in the mode,
     then appends the appropriate name (@gi or @key). Since the parent does the same, the result
     of calling the mode anywhere in the tree, results in a path leading to that point from
     the top of the tree. -->
    
    
    <xsl:template match="*" mode="xml-path">
        <xsl:apply-templates select="parent::*" mode="#current"/>
        <xsl:apply-templates select="@gi" mode="#current"/>
    </xsl:template>
   
    <!--the path in XML must point to the parent, since a (field) value is constituted by
    its (element and text) children-->
    
    <xsl:template match="value" mode="xml-path">
        <xsl:apply-templates select="parent::*" mode="#current"/>
        <xsl:text>/_VALUE</xsl:text>
    </xsl:template>
   
    <xsl:template match="value" mode="object-path">
        <xsl:apply-templates select="parent::*" mode="#current"/>
        <xsl:text expand-text="true">/{ (@key,'_VALUE')[1] }</xsl:text>
    </xsl:template>
    
    <xsl:template priority="2" match="flag/@gi" mode="xml-path">
        <xsl:text expand-text="true">/@{ . }</xsl:text>
    </xsl:template>

    <xsl:template match="@gi" mode="xml-path">
        <xsl:text expand-text="true">/{ . }</xsl:text>
    </xsl:template>
    
     <xsl:template match="*" mode="object-path">
         <xsl:apply-templates select="parent::*" mode="#current"/>
        <xsl:apply-templates select="@key" mode="#current"/>
    </xsl:template>
    
    <xsl:template match="@key" mode="object-path">
        <xsl:text expand-text="true">/{ . }</xsl:text>
    </xsl:template>
    
    
</xsl:stylesheet>