<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:math="http://www.w3.org/2005/xpath-functions/math"
    exclude-result-prefixes="xs math"
    version="3.0"
    xpath-default-namespace="http://csrc.nist.gov/ns/oscal/metaschema/1.0">
    
<!-- Pulls only assembly definitions (at all levels), flattened and reduced to models for comparison between versions. -->

<xsl:strip-space elements="*"/>

<xsl:output indent="yes"/>
<xsl:mode on-no-match="shallow-copy"/>
    
    <xsl:template match="/*">
        <xsl:copy>
          <xsl:apply-templates select="//define-assembly | //define-flag"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="define-assembly | define-field">
        <xsl:copy>
            <xsl:copy-of select="@name"/>
            <xsl:attribute name="where">
                <xsl:for-each select="ancestor::define-assembly/@name,@name">
                    <xsl:if test="position() ne 1" expand-text="true">/{ . }</xsl:if>
                </xsl:for-each>
            </xsl:attribute>
            <xsl:apply-templates select="(formal-name  | use-name | root-name | flag | define-flag | model)"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="constraint | description | remarks"/>
    
</xsl:stylesheet>