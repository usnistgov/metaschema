<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:math="http://www.w3.org/2005/xpath-functions/math" exclude-result-prefixes="xs math"
    version="3.0" xmlns:XSLT="http://csrc.nist.gov/ns/oscal/metaschema/xslt-alias"
    xpath-default-namespace="http://csrc.nist.gov/ns/oscal/metaschema/1.0">

    <!-- Writes 'pull' (reordering) sequences of xsl:apply-templates
     for OSCAL conversions
     pulls into the defined order
    
    RUN ON A COMPOSED METASCHEMA FOR BEST RESULTS -->

    <xsl:strip-space elements="*"/>

    <xsl:namespace-alias stylesheet-prefix="XSLT" result-prefix="xsl"/>

    <xsl:key name="assembly-definition-by-name" match="/METASCHEMA/define-assembly" use="@_key-name"/>
    <xsl:key name="field-definition-by-name" match="/METASCHEMA/define-field" use="@_key-name"/>
    <xsl:key name="flag-definition-by-name" match="/METASCHEMA/define-flag" use="@_key-name"/>


    <xsl:output indent="yes"/>
    <xsl:mode on-no-match="shallow-copy"/>

    <xsl:template match="/*">
        <xsl:copy>
            <xsl:namespace name="xsl">http://www.w3.org/1999/XSL/Transform</xsl:namespace>
            <xsl:apply-templates select="//define-assembly"/>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="define-assembly | define-field">
        <xsl:copy>
            <xsl:copy-of select="@name | @_metaschema-xml-id"/>
            
            <xsl:apply-templates select="model" mode="write-pulls"/>
        </xsl:copy>
    </xsl:template>

    <xsl:template priority="3" match="choice" mode="write-pulls">
        <xsl:apply-templates mode="#current"/>
    </xsl:template>
    
    <xsl:template priority="3" match="any" mode="write-pulls"/>
        
    <xsl:template priority="2" match="model//*" mode="write-pulls">
        <xsl:variable name="def" as="element()*">
            <xsl:apply-templates select="." mode="find-definition"/>
        </xsl:variable>
        <xsl:if test="not(count($def) eq 1)">
            <xsl:message expand-text="true">No def for { @name}</xsl:message>
        </xsl:if>
        <XSLT:apply-templates select="{ @_using-name }"/>
    </xsl:template>

    <xsl:template mode="find-definition" as="element()" match="define-assembly | define-field | define-flag">
        <xsl:sequence select="."/>
    </xsl:template>
    
    <xsl:template mode="find-definition" as="element()" match="assembly">
        <xsl:sequence select="key('assembly-definition-by-name',@_key-ref)"/>
    </xsl:template>
    
    <xsl:template mode="find-definition" as="element()" match="field">
        <xsl:sequence select="key('field-definition-by-name',@_key-ref)"/>
    </xsl:template>
    
    <xsl:template mode="find-definition" as="element()" match="flag">
        <xsl:sequence select="key('flag-definition-by-name',@_key-ref)"/>
    </xsl:template>
    
    

</xsl:stylesheet>