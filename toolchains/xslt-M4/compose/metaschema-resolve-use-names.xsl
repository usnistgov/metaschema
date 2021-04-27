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
    <xsl:template priority="5" match="METASCHEMA/define-assembly[exists(root-name)]">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:attribute name="using-root-name" select="root-name"/>
            <xsl:apply-templates/>
        </xsl:copy>
    </xsl:template>

    <xsl:key name="global-assembly-definition" match="METASCHEMA/define-assembly" use="@key-name"/>
    <xsl:key name="global-field-definition"    match="METASCHEMA/define-field"    use="@key-name"/>
    <xsl:key name="global-flag-definition"     match="METASCHEMA/define-flag"     use="@key-name"/>
    
    
    <!-- Inline definitions can give their own use-name values. -->
    <xsl:template match="define-assembly/define-flag | define-field/define-flag">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:attribute name="using-name" select="(use-name,@name)[1]"/>
            <xsl:apply-templates/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="model//define-field">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:attribute name="using-name" select="(use-name,@name)[1]"/>
            <xsl:apply-templates/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="model//define-assembly">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:attribute name="using-name" select="(use-name,@name)[1]"/>
            <xsl:apply-templates/>
        </xsl:copy>
    </xsl:template>
    
    <!-- Alternatively, references to definitions can give their own use-name
         values, or acquire them from the definition. -->
    
    <xsl:template match="flag[exists(@key-ref)]">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:variable name="def" select="key('global-flag-definition',@key-ref)"/>
            <xsl:attribute name="using-name" select="(use-name,$def/use-name,$def/@name)[1]"/>
            <xsl:apply-templates/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="field[exists(@key-ref)]">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:variable name="def" select="key('global-field-definition',@key-ref)"/>
            <xsl:attribute name="using-name" select="(use-name,$def/use-name,$def/@name)[1]"/>
            <xsl:apply-templates/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="assembly[exists(@key-ref)]">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:variable name="def" select="key('global-assembly-definition',@key-ref)"/>
            <xsl:attribute name="using-name" select="(use-name,$def/use-name,$def/@name)[1]"/>
            <xsl:apply-templates/>
        </xsl:copy>
    </xsl:template>

    
</xsl:stylesheet>