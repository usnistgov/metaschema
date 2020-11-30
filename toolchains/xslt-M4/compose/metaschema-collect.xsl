<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:math="http://www.w3.org/2005/xpath-functions/math"
    xmlns:m="http://csrc.nist.gov/ns/oscal/metaschema/1.0"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xpath-default-namespace="http://csrc.nist.gov/ns/oscal/metaschema/1.0"
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
    
    Also expands top-level declarations marked scope='local' into local declarations, while removing them. -->
    
    <xsl:mode name="acquire" on-no-match="shallow-copy"/>
    
    <xsl:template match="comment() | processing-instruction()" mode="#all"/>
    
    <xsl:template match="METASCHEMA" mode="acquire">
        <xsl:copy>
            <xsl:copy-of select="@* except @xsi:*"/>
            <xsl:attribute name="module" select="base-uri(.)"/>
            <xsl:apply-templates mode="#current"/>
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
        
    <xsl:key name="top-level-local-assembly-definition-by-name"
        match="METASCHEMA/define-assembly[@scope='local']" use="@name"/>
    
    <xsl:key name="top-level-local-field-definition-by-name"
        match="METASCHEMA/define-field[@scope='local']" use="@name"/>
    
    <xsl:key name="top-level-local-flag-definition-by-name"
        match="METASCHEMA/define-flag[@scope='local']" use="@name"/>
    
    <xsl:template mode="acquire" match="assembly[exists( key('top-level-local-assembly-definition-by-name',@ref) )]">
        <xsl:apply-templates mode="expand" select="key('top-level-local-assembly-definition-by-name',@ref) ">
            <xsl:with-param name="from" select="."/>
        </xsl:apply-templates>
    </xsl:template>
    
    <xsl:template mode="acquire" match="field[exists( key('top-level-local-field-definition-by-name',@ref) )]">
        <xsl:apply-templates mode="expand" select="key('top-level-local-field-definition-by-name',@ref) ">
            <xsl:with-param name="from" select="."/>
        </xsl:apply-templates>
    </xsl:template>
    
    <xsl:template mode="acquire" match="flag[exists( key('top-level-local-flag-definition-by-name',@ref) )]">
        <xsl:apply-templates mode="expand" select="key('top-level-local-flag-definition-by-name',@ref) ">
            <xsl:with-param name="from" select="."/>
        </xsl:apply-templates>
    </xsl:template>
    
    <xsl:template match="*" mode="expand">
        <xsl:param name="from" select="()"/>
        <xsl:copy>
            <xsl:copy-of select="$from/@* except $from/@ref"/>
            <xsl:copy-of select="@*"/>
            <xsl:apply-templates mode="acquire" select="$from/*"/>
            <xsl:apply-templates mode="acquire"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template mode="acquire"
        match="METASCHEMA/define-assembly[@scope='local'] |
               METASCHEMA/define-field[@scope='local'] |
               METASCHEMA/define-flag[@scope='local']"/>
    
</xsl:stylesheet>