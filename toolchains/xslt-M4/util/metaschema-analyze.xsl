<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:math="http://www.w3.org/2005/xpath-functions/math"
    xpath-default-namespace="http://csrc.nist.gov/ns/oscal/metaschema/1.0"
    xmlns="http://csrc.nist.gov/ns/oscal/metaschema/1.0"
    exclude-result-prefixes="xs math"
    version="3.0">
    
    <!-- Pulls a set of Metaschema instances and produces a report
         on its definitions and constraints -->
     
     <xsl:output indent="yes" method="xml" omit-xml-declaration="true"/>
    
    <!-- uri of folder of input document -->
    <xsl:variable name="metaschema-dir" as="xs:string">../../../test-suite/oscal</xsl:variable>
    <xsl:variable name="selector" as="xs:string"      >*_metaschema.xml</xsl:variable>
    
    <xsl:variable name="collector" as="xs:string" expand-text="true">{$metaschema-dir}?select={$selector}</xsl:variable>
    
    <!-- all schema documents in the base URI -->
    <xsl:variable name="metaschema-set" select="collection($collector)"/>
    
    <xsl:template match="/">
        <xsl:variable name="tagged">        <report>
            <xsl:for-each select="$metaschema-set">
                <module>
                <file>
                    <xsl:value-of select="replace(document-uri(/),'.*/','')"/>
                </file>
                    <xsl:apply-templates select="//allowed-values">
                        <xsl:sort select="ancestor::*[exists(@name)][1]/@name"/>
                    </xsl:apply-templates>
                </module>
            </xsl:for-each>
        </report>
        </xsl:variable>
        
        <!--<xsl:copy-of select="$tagged"/>-->
        <xsl:apply-templates select="$tagged" mode="format"/>
    </xsl:template>
    
    <xsl:template match="allowed-values" expand-text="true">
        <allowed-values>
            <xsl:copy-of select="@allow-other"/>
            <context>
                <xsl:apply-templates select="ancestor::*/@name" mode="path"/>
            </context>
            <xsl:apply-templates select="enum"/>
        </allowed-values>
    </xsl:template>
    
    <xsl:template match="flag/@name | define-flag/@name" mode="path">
        <xsl:text expand-text="true">/@{.}</xsl:text>
    </xsl:template>
    <xsl:template match="@name" mode="path">
        <xsl:text expand-text="true">/{.}</xsl:text>
    </xsl:template>
    
    <xsl:template match="enum" expand-text="true">
        <value>{@value}</value>
    </xsl:template>
    
    <xsl:template match="report" mode="format">
        <xsl:text>ALLOWED VALUES REPORT</xsl:text>
        <xsl:apply-templates mode="#current"/>
    </xsl:template>
    
    <xsl:template mode="format" match="file">
        <xsl:text>&#xA;&#xA;</xsl:text>
        <xsl:apply-templates mode="#current"/>
        <xsl:text expand-text="true"> ({ if (empty(../allowed-values)) then 'NONE' else count(../allowed-values)})</xsl:text>
    </xsl:template>
    <xsl:template mode="format" match="allowed-values">
        <xsl:text>&#xA;</xsl:text>
        <xsl:apply-templates mode="#current"/>
    </xsl:template>
    <xsl:template mode="format" match="context">
        <xsl:text>&#xA;&#xA;  </xsl:text>
        <xsl:apply-templates mode="#current"/>
        <xsl:text expand-text="true"> (allow-other={(../@allow-other,'yes')[1]})</xsl:text>
    </xsl:template>
    <xsl:template mode="format" match="value">
        <xsl:choose>
            <xsl:when test="exists(preceding-sibling::value)"> | '</xsl:when>
            <xsl:otherwise>
                <xsl:text>&#xA;    '</xsl:text>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:apply-templates mode="#current"/>
        <xsl:text>'</xsl:text>
    </xsl:template>
    
</xsl:stylesheet>