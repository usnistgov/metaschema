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
    
    <xsl:template match="/">
        <xsl:apply-templates mode="acquire" select="/">
            <xsl:with-param name="so-far" tunnel="true" select="document-uri(/)"/>
        </xsl:apply-templates>
    </xsl:template>

    
    <!-- ====== ====== ====== ====== ====== ====== ====== ====== ====== ====== ====== ====== -->
    <!-- Aggregate metaschema imports without further processing anything.
         Trace nominal sources.
         Defend against endless loops.
    
     -->
    
    <xsl:mode name="acquire" on-no-match="shallow-copy"/>
    
    <xsl:template match="comment() | processing-instruction()" mode="#all"/>
    
    <xsl:template match="METASCHEMA" mode="acquire">
        <xsl:copy>
            <xsl:copy-of select="@* except @xsi:*"/>
            <xsl:attribute name="module" select="short-name"/>
            <xsl:attribute name="src" select="base-uri(.)"/>
            <xsl:apply-templates select="* except import" mode="#current"/>
            <xsl:apply-templates select="import" mode="#current"/>
        </xsl:copy>
    </xsl:template>
  
    <xsl:template match="import" mode="acquire">
        <xsl:param name="so-far" tunnel="yes" required="yes"/>
        <xsl:variable name="uri" select="resolve-uri(@href,base-uri(parent::METASCHEMA))"/>
        <xsl:choose>
            <xsl:when test="$uri = $so-far">
                <xsl:comment expand-text="true">Warning: circular import of { $uri } skipped</xsl:comment>
            </xsl:when>
            <xsl:when test="not(doc-available($uri))">
                <xsl:message terminate="yes" expand-text="true">Error: No metaschema module is found at { $uri }</xsl:message>
                <xsl:comment expand-text="true">Warning: circular import of { $uri } skipped</xsl:comment>
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates select="document($uri)/METASCHEMA" mode="acquire">
                    <xsl:with-param name="so-far" select="$so-far,$uri"/>
                </xsl:apply-templates>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
  
    <xsl:template mode="acquire"
        match="METASCHEMA/define-assembly |
        METASCHEMA/define-field    |
        METASCHEMA/define-flag">
        <xsl:copy>
            <xsl:attribute name="scope">global</xsl:attribute>
            <xsl:copy-of select="@*"/>
            <xsl:attribute name="module" expand-text="true">{ ../short-name }</xsl:attribute>
            <xsl:attribute name="key-name" expand-text="true">{ ../short-name }:{ @name }</xsl:attribute>
            <xsl:apply-templates mode="#current"/>
        </xsl:copy>
    </xsl:template>
    
    
    
    
</xsl:stylesheet>