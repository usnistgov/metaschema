<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    exclude-result-prefixes="xs"
    version="3.0"
    expand-text="true"
    xmlns="http://csrc.nist.gov/ns/oscal/metaschema/1.0"
    xpath-default-namespace="http://csrc.nist.gov/ns/oscal/metaschema/1.0">
    
    <xsl:output indent="yes"/>
    
    <xsl:strip-space elements="*"/>
    
    <xsl:preserve-space elements="schema-name schema-version short-name namespace formal-name description root-name p enum code json-value-key a"/>
    
    <xsl:mode on-no-match="shallow-copy"/>   
    
    <xsl:template match="processing-instruction()"/>
    
    <xsl:template match="/">
        <xsl:text>&#xA;</xsl:text>
        <xsl:processing-instruction name="xml-model">href="../../support/lib/metaschema-check.sch" type="application/xml" schematypens="http://purl.oclc.org/dsdl/schematron"</xsl:processing-instruction>
        <xsl:text>&#xA;</xsl:text>
        <xsl:apply-templates/>
    </xsl:template>
    
    
    <xsl:template match="METASCHEMA/@xsi:schemaLocation">
        <xsl:attribute name="xsi:schemaLocation" namespace="http://www.w3.org/2001/XMLSchema-instance">http://csrc.nist.gov/ns/oscal/metaschema/1.0 ../../support/lib/metaschema.xsd</xsl:attribute>
    </xsl:template>
    
    
    <xsl:template match="description[2] | remarks[2]"/>
    
    <xsl:template match="METASCHEMA//*[not(self::example)][exists(remarks|example)]">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:apply-templates select="node() except (remarks, example)"/>
            <xsl:apply-templates select="remarks, example"/>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="remarks">
        <xsl:if test="empty(following-sibling::remarks)">
            <xsl:copy>
                <xsl:apply-templates select="../remarks/node()"/>
            </xsl:copy>
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="p//text() | description//text()">
        <xsl:value-of select="replace(.,'\s+',' ')"/>
    </xsl:template>

</xsl:stylesheet>