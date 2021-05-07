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
    <xsl:variable name="metaschema-abstract-default" as="xs:string">no</xsl:variable>
    <xsl:variable name="instance-max-occurs-default" as="xs:integer">1</xsl:variable>
    <xsl:variable name="instance-min-occurs-default" as="xs:integer">0</xsl:variable>
    <xsl:variable name="instance-flag-required-default" as="xs:string">no</xsl:variable>
    <xsl:variable name="instance-group-as-in-json" as="xs:string">SINGLETON_OR_ARRAY</xsl:variable>
    <xsl:variable name="instance-group-as-in-xml" as="xs:string">UNGROUPED</xsl:variable>
    <xsl:variable name="definition-field-markup-multiline-in-xml" as="xs:string">WITH_WRAPPER</xsl:variable>
    <xsl:variable name="definition-field-collapsible" as="xs:string">no</xsl:variable>
    <xsl:variable name="definition-flag-or-field-as-type" as="xs:string">string</xsl:variable>
    <xsl:variable name="definition-scope-default" as="xs:string">global</xsl:variable>
    
    
    <xsl:template match="/">
        <!--<xsl:comment expand-text="true">{ name(/*) }</xsl:comment>-->
        <xsl:if test="empty(/METASCHEMA)" expand-text="true">
            <EXCEPTION problem-type="not-a-metaschema">No Metaschema found in namespace 'http://csrc.nist.gov/ns/oscal/metaschema/1.0' : instead we have a document '{ */name() }' in namespace '{ /*/namespace-uri(.) }'</EXCEPTION>
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
            <xsl:attribute name="abstract" select="$metaschema-abstract-default"/>
            <xsl:copy-of select="@* except @xsi:*"/>
            <xsl:attribute name="module" select="short-name"/>
            <xsl:attribute name="_base-uri" select="base-uri(.)"/>
            <xsl:apply-templates select="* except import" mode="#current"/>
            <xsl:apply-templates select="import" mode="#current"/>
        </xsl:copy>
    </xsl:template>
  
    <xsl:template match="import" mode="acquire">
        <xsl:param name="so-far" tunnel="yes" required="yes"/>
        <xsl:variable name="uri" select="resolve-uri(@href,base-uri(parent::METASCHEMA))"/>
            <xsl:choose expand-text="true">
                <xsl:when test="$uri = $so-far">
                    <xsl:copy>
                        <xsl:copy-of select="@* except @xsi:*"/>
                        <EXCEPTION problem-type="circular-import">Circular import of { $uri } in this file (or one of its children) skipped.</EXCEPTION>
                    </xsl:copy>
                </xsl:when>
                <xsl:when test="not(doc-available($uri))">
                    <xsl:copy>
                        <xsl:copy-of select="@* except @xsi:*"/>
                        <EXCEPTION problem-type="broken-import">Error: No metaschema module is found at { $uri }.</EXCEPTION>
                    </xsl:copy>
                </xsl:when>
                <xsl:when test="empty(document($uri)/METASCHEMA)">
                    <xsl:copy>
                        <xsl:copy-of select="@* except @xsi:*"/>
                        <EXCEPTION problem-type="import-not-a-metaschema">Error: No metaschema module is found at { $uri } (it is not named METASCHEMA in namespace 'http://csrc.nist.gov/ns/oscal/metaschema/1.0').</EXCEPTION>
                    </xsl:copy>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:apply-templates select="document($uri)/METASCHEMA" mode="acquire">
                        <xsl:with-param name="so-far" select="$so-far,$uri"/>
                    </xsl:apply-templates>
                </xsl:otherwise>
            </xsl:choose>
    </xsl:template>
  
    <xsl:template priority="60" mode="assign-defaults" match="field | assembly | model//define-field | model//define-assembly">
        <xsl:attribute name="max-occurs" select="$instance-max-occurs-default"/>
        <xsl:attribute name="min-occurs" select="$instance-min-occurs-default"/>
        <xsl:next-match/>
    </xsl:template>
    
    <xsl:template priority="60" mode="assign-defaults" match="flag | define-field/define-flag | define-assembly/define-flag">
        <xsl:attribute name="required" select="$instance-flag-required-default"/>
        <xsl:next-match/>
    </xsl:template>
    
    
    <xsl:template priority="50" mode="assign-defaults" match="define-field[@as-type='markup-multiline']">
        <xsl:attribute name="in-xml" select="$definition-field-markup-multiline-in-xml"/>
        <xsl:next-match/>
    </xsl:template>
    
    
    <xsl:template priority="40" mode="assign-defaults" match="define-field">
        <xsl:attribute name="collapsible" select="$definition-field-collapsible"/>
        <xsl:next-match/>
    </xsl:template>
    
    <xsl:template mode="assign-defaults" match="define-flag | define-field">
        <xsl:attribute name="as-type" select="$definition-flag-or-field-as-type"/>
    </xsl:template>
    
    <xsl:template mode="assign-defaults" match="group-by">
        <xsl:attribute name="in-json" select="$instance-group-as-in-json"/>    
        <xsl:attribute name="in-xml" select="$instance-group-as-in-xml"/>
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
            <xsl:attribute name="scope" select="$definition-scope-default"/>
            <!-- Now copy attributes as given, overwriting any defaults just provided -->
            <xsl:copy-of select="@*"/>
            <xsl:attribute name="module" expand-text="true">{ ../short-name }</xsl:attribute>
            <xsl:attribute name="_base-uri" expand-text="true">{ base-uri(.) }</xsl:attribute>
            <!--<xsl:if test="function-available('saxon:line-number')" xmlns:saxon="http://saxon.sf.net/">
                <xsl:attribute name="_line_no"  expand-text="true" select="saxon:line-number(.)"/>    
            </xsl:if>-->
            <xsl:attribute name="_key-name"  expand-text="true">{ ../short-name }:{ @name }</xsl:attribute>
            <xsl:apply-templates mode="#current"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template mode="acquire" match="define-assembly | define-field | define-flag | assembly | field | flag | group-by">
        <xsl:copy>
            <!-- hit the node again in the mode to acquire applicable defaults -->
            <xsl:apply-templates select="." mode="assign-defaults"/>
            <!-- Now copy attributes as given, overwriting any defaults just provided -->
            <xsl:copy-of select="@*"/>
            <xsl:apply-templates mode="#current"/>
        </xsl:copy>
    </xsl:template>
    
</xsl:stylesheet>