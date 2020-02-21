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
         Defend against endless loops. -->
    
    <xsl:mode name="acquire" on-no-match="shallow-copy"/>
    
    <xsl:template match="comment() | processing-instruction()" mode="#all"/>
    
    <xsl:template match="METASCHEMA" mode="acquire">
        <xsl:copy>
            <xsl:copy-of select="@* except @xsi:*"/>
            <xsl:attribute name="module" select="document-uri(/)"/>
            <xsl:apply-templates mode="#current"/>
        </xsl:copy>
    </xsl:template>
  
    <xsl:template match="import" mode="acquire">
        <xsl:param name="so-far" tunnel="yes" required="yes"/>
        <xsl:variable name="uri" select="resolve-uri(@href,document-uri(/))"/>
        <xsl:choose>
            <xsl:when test="$uri = $so-far">
                <xsl:comment expand-text="true">Warning: circular import of { $uri } skipped</xsl:comment>
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates select="document($uri)/METASCHEMA" mode="acquire">
                    <xsl:with-param name="so-far" select="$so-far,$uri"/>
                </xsl:apply-templates>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
        
</xsl:stylesheet>