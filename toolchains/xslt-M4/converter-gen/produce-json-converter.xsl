<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:math="http://www.w3.org/2005/xpath-functions/math"
    xmlns:m="http://csrc.nist.gov/ns/oscal/metaschema/1.0"
    xmlns:XSLT="http://csrc.nist.gov/ns/oscal/metaschema/xslt-alias"
    
    xpath-default-namespace="http://csrc.nist.gov/ns/oscal/metaschema/1.0"
    exclude-result-prefixes="xs math"
    version="3.0"
    xmlns="http://csrc.nist.gov/ns/oscal/metaschema/1.0/supermodel">
    
<!-- Purpose: Produce an XSLT for converting JSON valid to a Metaschema model, to its supermodel equivalent. -->
<!-- Input:   A Metaschema definition map -->
<!-- Output:  An XSLT -->

    <!-- Most of the logic is the same as the XML converter. -->
    <xsl:import href="produce-xml-converter.xsl"/>
    
    <!-- Path conversion logic is here -->
    <xsl:import href="../metapath/metapath-jsonize.xsl"/>
    
    <xsl:output indent="yes"/>
    
    <xsl:namespace-alias stylesheet-prefix="XSLT" result-prefix="xsl"/>
    
    <!-- $px is the prefix to be used on names in the XPath JSON -->
    <xsl:param name="px" as="xs:string">j</xsl:param>
    
    <!-- The definition map for tracing path traversals is the source document -->
    <xsl:param name="definition-map" select="/"/>
    
    <!-- Overriding the root template in metapath-jsonize.xsl (which drives testing) -->
    <xsl:template match="/">
            <xsl:apply-templates/>
    </xsl:template>
    
    <xsl:template name="xpath-namespace">
        <!--<xsl:attribute name="xpath-default-namespace">http://www.w3.org/2005/xpath-functions</xsl:attribute>-->
        <xsl:namespace name="{$px}">http://www.w3.org/2005/xpath-functions</xsl:namespace>
    </xsl:template>
    
    <xsl:template name="make-strip-space">
        <XSLT:strip-space elements="{$px}:map {$px}:array"/>
    </xsl:template>
    
    <xsl:template name="initial-comment">
        <xsl:comment> METASCHEMA conversion stylesheet supports JSON -> METASCHEMA/SUPERMODEL conversion </xsl:comment>
    </xsl:template>
    
    <!-- Overriding the imported template for casting prose elements (wrt namespace) since we do not need it -->
    <xsl:template name="cast-prose-template"/>
    
    <!-- Overriding interface template -->
    <xsl:template match="*" mode="make-match" as="xs:string">
        <xsl:variable name="matching-xml">
            <xsl:apply-templates select="." mode="make-xml-match"/>
        </xsl:variable>
        <!--<xsl:try select="m:jsonize-path($matching-xml)">
            <xsl:catch>
                <xsl:message expand-text="true" xmlns:err="http://www.w3.org/2005/xqt-errors">(On { @name }) { $matching-xml }: { $err:description }</xsl:message>
            </xsl:catch>
        </xsl:try>-->
        <xsl:text expand-text="true"><!--(: { $matching-xml} :) -->{ m:jsonize-path($matching-xml) }</xsl:text>
        <!--<xsl:sequence select="m:jsonize-path($matching-xml)"/>-->
        
    </xsl:template>
    
    <!-- Overriding interface template -->
    <xsl:template match="*" mode="make-step" as="xs:string">
        <xsl:variable name="step-xml">
            <xsl:apply-templates select="." mode="make-xml-step"/>
        </xsl:variable>
        <xsl:sequence select="m:jsonize-path($step-xml)"/>
    </xsl:template>
    
    <!-- Overriding interface template -->
    <xsl:template match="*" mode="make-pull">
        <XSLT:apply-templates select="*[@key='{@key}']"/>
        <!--<pull>
            <xsl:copy>
                <xsl:copy-of select="@*"/>
            </xsl:copy>
        </pull>-->
        <!--<xsl:apply-templates select="." mode="make-xml-pull"/>-->
    </xsl:template>
    
    <xsl:template name="comment-template">
        <xsl:comment expand-text="true">
            <xsl:text> Cf XML match="</xsl:text>
            <xsl:apply-templates select="." mode="make-xml-match"/>
            <xsl:text>" </xsl:text>
        </xsl:comment>
    </xsl:template>
    
</xsl:stylesheet>