<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:math="http://www.w3.org/2005/xpath-functions/math"
    xmlns:m="http://csrc.nist.gov/ns/oscal/metaschema/1.0"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xpath-default-namespace="http://csrc.nist.gov/ns/oscal/metaschema/1.0"
    xmlns="http://csrc.nist.gov/ns/oscal/metaschema/1.0"
    exclude-result-prefixes="xs math m xsi"
    version="3.0">

    <xsl:output indent="yes"/>
    
    <xsl:strip-space elements="METASCHEMA define-flag define-field define-assembly remarks model choice"/>

    <xsl:mode on-no-match="shallow-copy"/>
    
    <xsl:template match="assembly | field | flag |
        define-assembly/define-flag | define-field/define-flag |
        model//define-assembly | model//define-field">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:attribute name="_in-xml-name" expand-text="true">{ @_using-name }</xsl:attribute>
            <xsl:attribute name="_in-json-name" expand-text="true">{ (group-as/@name,@_using-name)[1] }</xsl:attribute>
            <xsl:apply-templates/>
        </xsl:copy>
    </xsl:template>

    <xsl:template priority="10" match="field[group-as/@in-xml='GROUPED']">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:attribute name="_in-xml-name" expand-text="true">{ group-as/@name }</xsl:attribute>
            <xsl:attribute name="_in-json-name" expand-text="true">{ group-as/@name }</xsl:attribute>
            <xsl:apply-templates/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template priority="10" match="field[@in-xml='UNWRAPPED' and @as-type='markup-multiline'] |
        model//define-field[@in-xml='UNWRAPPED' and @as-type='markup-multiline']">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:attribute name="_in-xml-name">p ul ol pre table h1 h2 h3 h4 h5 h6</xsl:attribute>
            <xsl:attribute name="_in-json-name" expand-text="true">{ @_using-name }</xsl:attribute>
            <xsl:apply-templates/>
        </xsl:copy>
    </xsl:template>
    
</xsl:stylesheet>