<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns="http://csrc.nist.gov/ns/oscal/metaschema/1.0"
    xmlns:m="http://csrc.nist.gov/ns/oscal/metaschema/1.0"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="#all"
    xpath-default-namespace="http://csrc.nist.gov/ns/oscal/metaschema/1.0"
    default-mode="scrubbing">

    <!--

    XSLT provides utility functionality for testing OSCAL profile resolution.
    
    Function opr:scrub-document returns an OSCAL catalog or profile with 'cosmetic' whitespace removed,
    for clean comparison.
    
    -->

    <xsl:output method="xml"/>

    <xsl:strip-space elements="METASCHEMA remarks define-assembly define-field define-flag model assembly field enum flag choice constraint"/>
    
    <xsl:function name="m:scrub" as="document-node()">
        <xsl:param name="n" as="node()"/>
        <xsl:document>
          <xsl:apply-templates select="$n" mode="scrubbing"/>
        </xsl:document>
    </xsl:function>
    
    <xsl:template mode="scrubbing" match="* | text() | @*">
        <xsl:copy>
            <xsl:apply-templates mode="#current" select="@*"/>
            <xsl:apply-templates mode="#current"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template mode="scrubbing" match="@_base-uri">
        <xsl:attribute name="{ name() }">...</xsl:attribute>
    </xsl:template>
    
    <!-- some defense against whitespace/indentation glitches -->
    <xsl:template mode="scrubbing" match="text()[matches(.,'\S') => not()]">
        <xsl:variable name="wrapper" select="ancestor::p[1] | ancestor::li[1]"/>
        <xsl:if test="not(. is $wrapper/descendant::text()[1]) and not(. is $wrapper/descendant::text()[last()])">
            <xsl:next-match/>
        </xsl:if>
    </xsl:template>
    
</xsl:stylesheet>
