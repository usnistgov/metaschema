<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:math="http://www.w3.org/2005/xpath-functions/math"
    exclude-result-prefixes="xs math"
    xpath-default-namespace="http://csrc.nist.gov/ns/oscal/metaschema/1.0"
    version="3.0">
    
    <xsl:variable name="metaschemas" select="collection('.?select=*_metaschema.xml')"/>
    
    <xsl:template match="/" expand-text="true">
        <!--<xsl:apply-templates select="$metaschemas//(define-assembly | define-field|define-flag)[matches(@name,'all')]"/>-->
        <!--<xsl:for-each-group select="$metaschemas//define-field" group-by="(@as-type,'[string]')[1]">
            <xsl:text>&#xA;&#xA;{ current-grouping-key() } FIELDS:&#xA;</xsl:text>
            <xsl:call-template name="breakout"/>
        </xsl:for-each-group>
        <xsl:for-each-group select="$metaschemas//define-flag" group-by="(@as-type,'[string]')[1]">
            <xsl:text>&#xA;&#xA;{ current-grouping-key() } FLAGS:&#xA;</xsl:text>
            <xsl:call-template name="breakout"/>
        </xsl:for-each-group>-->
        <xsl:for-each-group select="(//assembly | //flag | //field)[exists(remarks)]" group-by="@name">
                <xsl:text expand-text="true"> { current-grouping-key() }</xsl:text>
            <xsl:sequence select="current-group()/remarks/string()"/>
        </xsl:for-each-group>
        
        <xsl:for-each-group select="$metaschemas/METASCHEMA/define-assembly" group-by="@name">
            <xsl:if test="count(current-group()) gt 1">
                <xsl:text expand-text="true">, '{ current-grouping-key() }'</xsl:text>
            </xsl:if>
        </xsl:for-each-group>
        <xsl:for-each-group select="$metaschemas/METASCHEMA/define-field" group-by="@name">
            <xsl:if test="count(current-group()) gt 1">
                <xsl:text expand-text="true">, '{ current-grouping-key() }'</xsl:text>
            </xsl:if>
        </xsl:for-each-group>
        <xsl:for-each-group select="$metaschemas/METASCHEMA/define-flag" group-by="@name">
            <xsl:if test="count(current-group()) gt 1">
                <xsl:text expand-text="true">, '{ current-grouping-key() }'</xsl:text>
            </xsl:if>
        </xsl:for-each-group>
    </xsl:template>
    
    <xsl:template name="breakout" expand-text="true">
        <xsl:param name="who" select="current-group()"/>
        <xsl:for-each-group select="$who" group-by="base-uri()">
            <xsl:text>&#xA;&#xA;{ current-grouping-key() }:&#xA;</xsl:text>
            <xsl:value-of select="current-group() ! (ancestor-or-self::*/@name => string-join('/'))" separator=", "/>
        </xsl:for-each-group>
    </xsl:template>
    
    <xsl:template match="define-assembly | define-field | define-flag">
        <xsl:copy>
            <xsl:attribute name="module" select="/*/short-name"/>
            <xsl:attribute name="context" select="string-join(ancestor-or-self::*/@name,'/')"/>
            <xsl:copy-of select="node()"/>
        </xsl:copy>
    </xsl:template>
    
</xsl:stylesheet>