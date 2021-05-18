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
    
    
    <xsl:template priority="5" mode="make-json-name" match="define-assembly | define-field | assembly | field | define-flag | flag">
        <xsl:value-of select="@_in-json-name"/>
    </xsl:template>
    
    <xsl:template priority="10" mode="make-xml-name" match="*[group-as/@in-xml='GROUPED']">
        <xsl:value-of select="group-as/@name"/>/<xsl:value-of select="@_in-xml-name"/>
    </xsl:template>
    
    <xsl:template priority="5" mode="make-xml-name" match="define-assembly | define-field | assembly | field | define-flag | flag">
        <xsl:value-of select="@_in-xml-name"/>
    </xsl:template>
    
    <!-- <xsl:template mode="make-xml-name" match="*[exists(root-name)]">
        <xsl:value-of select="@_using-root-name"/>
    </xsl:template>-->
    
    <xsl:template mode="make-xml-name" match="field[@as-type='markup-multiline' and @in-xml='UNWRAPPED'] |
        define-field[@as-type='markup-multiline' and @in-xml='UNWRAPPED']">
        <xsl:value-of select="@_using-name"/>
    </xsl:template>   
    
    <xsl:template priority="10" match="METASCHEMA/define-assembly | METASCHEMA/define-field | METASCHEMA/define-flag">
        <xsl:copy>
            <xsl:variable name="def-id">
                <xsl:text expand-text="true">/{ replace(name(),'^define\-','') }/{ @module }/{@name}</xsl:text>
            </xsl:variable>
                        
            <xsl:attribute name="_metaschema-xml-id"  select="$def-id"/>
            <xsl:attribute name="_metaschema-json-id" select="$def-id"/>
            <xsl:apply-templates select="@*"/>
            <xsl:apply-templates>
                <xsl:with-param name="sofar-xml"  tunnel="true" select="$def-id"/>
                <xsl:with-param name="sofar-json" tunnel="true" select="$def-id"/>
            </xsl:apply-templates>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="define-assembly | define-field | define-flag | assembly | field | flag">
        <xsl:param name="sofar-xml"  tunnel="true"/>
        <xsl:param name="sofar-json" tunnel="true"/>
        <xsl:copy>
            <xsl:variable name="xml-name">
                <xsl:apply-templates select="." mode="make-xml-name"/>
            </xsl:variable>
            <xsl:variable name="json-name">
                <xsl:apply-templates select="." mode="make-json-name"/>
            </xsl:variable>
            <xsl:variable name="def-id-xml" expand-text="true">{$sofar-xml}/{$xml-name}</xsl:variable>
            <xsl:variable name="def-id-json" expand-text="true">{$sofar-json}/{$json-name}</xsl:variable>
            
            <xsl:attribute name="_step"  select="$xml-name"/>
            <xsl:attribute name="_key" select="$json-name"/>
            <xsl:for-each select="group-as">
                <xsl:attribute name="_group-name" select="@name"/>
            </xsl:for-each>
            
            <xsl:attribute name="_metaschema-xml-id"  select="$def-id-xml"/>
            <xsl:attribute name="_metaschema-json-id" select="$def-id-json"/>
            <xsl:apply-templates select="@*"/>
            <xsl:apply-templates>
                <!-- the new def-id values have been incremented -->
                <xsl:with-param tunnel="true" name="sofar-xml"  select="$def-id-xml"/>
                <xsl:with-param tunnel="true" name="sofar-json" select="$def-id-json"/>
            </xsl:apply-templates>
        </xsl:copy>
        
    </xsl:template>
    
</xsl:stylesheet>