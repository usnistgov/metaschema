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


    <!-- Configuration of metaschema defaults -->
    <xsl:variable name="max-occurs-default" as="xs:integer">1</xsl:variable>
    
    
    <xsl:template match="/">
        <xsl:comment expand-text="true">{ name(/*) }</xsl:comment>
        <xsl:if test="empty(/METASCHEMA)" expand-text="true">
            <EXCEPTION level="error">No Metaschema found in namespace 'http://csrc.nist.gov/ns/oscal/metaschema/1.0' : instead we have a document '{ */name() }' in namespace '{ /*/namespace-uri(.) }'</EXCEPTION>
        </xsl:if>
        <xsl:apply-templates mode="acquire" select="/METASCHEMA">
            <xsl:with-param name="so-far" tunnel="true" select="document-uri(/)"/>
        </xsl:apply-templates>
    </xsl:template>

    
    <!-- ====== ====== ====== ====== ====== ====== ====== ====== ====== ====== ====== ====== -->
    <!-- Aggregate metaschema imports without further processing anything.
        
         Disambiguate references among modules (main and imported)
         
         Add default values for metaschema assumptions on definitions and references
           x @max-occurs=1 @min-occurs=0   field and assembly references
           x required=no                   flag references
           x @as-type=string               field and flag definitions
           x collapsible=yes               field definitions
           x in-xml=WITH_WRAPPER           field references and local definitions (markup-multiline case)
             o Metaschema Schematron prevent @in-xml when as-type is not markup-multiline
           x group-by/@in-json             default SINGLETON_OR_ARRAY
           x group-by/@in-xml              default UNGROUPED (to avoid the extra wrapper)
         
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
        <xsl:choose expand-text="true">
            <xsl:when test="$uri = $so-far">
                <EXCEPTION level="error">Circular import of { $uri } skipped.</EXCEPTION>
            </xsl:when>
            <xsl:when test="not(doc-available($uri))">
                <EXCEPTION level="error">Error: No metaschema module is found at { $uri }.</EXCEPTION>
            </xsl:when>
            <xsl:when test="empty(document($uri)/METASCHEMA)">
                <EXCEPTION level="error">Error: No metaschema module is found at { $uri } (it is not named METASCHEMA in namespace 'http://csrc.nist.gov/ns/oscal/metaschema/1.0').</EXCEPTION>
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates select="document($uri)/METASCHEMA" mode="acquire">
                    <xsl:with-param name="so-far" select="$so-far,$uri"/>
                </xsl:apply-templates>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
  
    <xsl:template priority="60" mode="assign-defaults" match="field | assembly | model//define-field | model//define-assembly">
        <xsl:attribute name="max-occurs" select="$max-occurs-default"/>
        <xsl:attribute name="min-occurs">0</xsl:attribute>
        <xsl:next-match/>
    </xsl:template>
    
    <xsl:template priority="60" mode="assign-defaults" match="flag | define-field/define-flag | define-assembly/define-flag">
        <xsl:attribute name="required">no</xsl:attribute>
        <xsl:next-match/>
    </xsl:template>
    
    
    <xsl:template priority="50" mode="assign-defaults" match="define-field[@as-type='markup-multiline']">
        <xsl:attribute name="in-xml">WITH_WRAPPER</xsl:attribute>
        <xsl:next-match/>
    </xsl:template>
    
    
    <xsl:template priority="40" mode="assign-defaults" match="define-field">
        <xsl:attribute name="collapsible">no</xsl:attribute>
        <xsl:next-match/>
    </xsl:template>
    
    <xsl:template mode="assign-defaults" match="define-flag | define-field">
        <xsl:attribute name="as-type">string</xsl:attribute>    
    </xsl:template>
    
    <xsl:template mode="assign-defaults" match="group-by">
        <xsl:attribute name="in-json">SINGLETON_OR_ARRAY</xsl:attribute>    
        <xsl:attribute name="in-xml">UNGROUPED</xsl:attribute>    
    </xsl:template>
    
    <xsl:template mode="assign-defaults" match="*"/>
    
    <xsl:template priority="10" mode="acquire"
        match="METASCHEMA/define-assembly |
        METASCHEMA/define-field    |
        METASCHEMA/define-flag">
        <xsl:copy>
            <!-- hit the node again in the mode to acquire applicable defaults -->
            <xsl:apply-templates select="." mode="assign-defaults"/>
            <!-- XXX: this can be moved to default settings -->
            <xsl:attribute name="scope">global</xsl:attribute>
            <!-- Now copy attributes as given, overwriting any defaults just provided -->
            <xsl:copy-of select="@*"/>
            <xsl:attribute name="module" expand-text="true">{ ../short-name }</xsl:attribute>
            <xsl:attribute name="_base-uri" expand-text="true">{ base-uri(.) }</xsl:attribute>
            <!--<xsl:if test="function-available('saxon:line-number')" xmlns:saxon="http://saxon.sf.net/">
                <xsl:attribute name="_line_no"  expand-text="true" select="saxon:line-number(.)"/>    
            </xsl:if>-->
            <xsl:attribute name="key-name"  expand-text="true">{ ../short-name }:{ @name }</xsl:attribute>
            <xsl:apply-templates mode="#current"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template mode="acquire" match="define-assembly | define-field | define-flag | assembly | field | flag">
        <xsl:copy>
            <!-- hit the node again in the mode to acquire applicable defaults -->
            <xsl:apply-templates select="." mode="assign-defaults"/>
            <!-- Now copy attributes as given, overwriting any defaults just provided -->
            <xsl:copy-of select="@*"/>
            <xsl:apply-templates mode="#current"/>
        </xsl:copy>
    </xsl:template>
    
</xsl:stylesheet>