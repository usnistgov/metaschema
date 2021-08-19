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
    
    <!--In metadata metaschema-->
    <xsl:template priority="2" match="define-field[@name='base64']/description">
        <description>The Base64 alphabet in RFC 2045 - aligned with XSD.</description>
    </xsl:template>
    
    <!-- In SSP metaschema -->
    
    
    
    <xsl:template match="define-flag[@name=../(json-key|json-value-key)/@flag-name]">
        <xsl:copy>
            <xsl:attribute name="required">yes</xsl:attribute>
            <xsl:copy-of select="@*"/>
            <xsl:apply-templates/>
        </xsl:copy>
    </xsl:template>
    
</xsl:stylesheet>