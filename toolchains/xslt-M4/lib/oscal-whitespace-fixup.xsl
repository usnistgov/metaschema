<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:math="http://www.w3.org/2005/xpath-functions/math"
    xmlns:m="http://csrc.nist.gov/ns/oscal/metaschema/1.0"
    xmlns="http://csrc.nist.gov/ns/oscal/1.0"
    xpath-default-namespace="http://csrc.nist.gov/ns/oscal/1.0"
    exclude-result-prefixes="#all"
    version="3.0">
    
    <!-- p pre code tr table td th list li br q img insert a strong em sub sup -->
    
    <xsl:output indent="yes"/>
    
    <xsl:strip-space elements="*"/>
    
    <xsl:preserve-space elements="p pre code td th list li br q img insert a strong em sub sup"/>
    
<!-- cleanup mode emits content with all whitespace stripped except schema-determined 'significant' ws
     this includes whitespace normalization inside p and li (in prose contexts)
    
     reset mode rewrites OSCAL with new whitespace.
     it can be run together with 'cleanup' for a simple filter
     or either mode can be used at the start or end of a pipeline
     
    -->
    
    <xsl:template match="/comment()"/>
    
    
    <xsl:template match="title | label | choice | text">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            
            <xsl:apply-templates>
                <xsl:with-param name="text-trim" tunnel="true" select="true()"/>
            </xsl:apply-templates>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="text()">
        <xsl:param name="text-trim" tunnel="true" select="false()"/>
        <xsl:choose>
            <xsl:when test="$text-trim">
                <xsl:apply-templates select="." mode="trim"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="."/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="text()[exists(../*)]" mode="trim">
        <xsl:value-of select="replace(.,'\s+',' ')"/>
    </xsl:template>
    
    <xsl:template match="text()" mode="trim">
        <xsl:value-of select="string(.) => normalize-space()"/>
    </xsl:template>
    
    <xsl:template match="metadata">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:apply-templates select="title, published"/>
            <!-- time stamp it at runtime -->
            <last-modified xsl:expand-text="true">{ current-dateTime() }</last-modified>
            <xsl:apply-templates select="* except (title | published)"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="last-modified" priority="6"/>
    
    <xsl:template match="oscal-version" priority="6">
        <oscal-version>1.0.0-rc1</oscal-version>
    </xsl:template>
    
    <xsl:template match="i">
        <em>
            <xsl:apply-templates/>
        </em>
    </xsl:template>
    
    <xsl:mode on-no-match="shallow-copy"/>
    
    <xsl:template match="pre//text()">
        <xsl:value-of select="."/>
    </xsl:template>

    <xsl:template priority="3" match="p/descendant::text()[last()] 
        | li/descendant::text()[last()]
        | td/descendant::text()[last()]
        | th/descendant::text()[last()]">
        <xsl:variable name="so-far">
            <xsl:next-match/>
        </xsl:variable>
        <xsl:sequence select="replace($so-far,'\s+$','')"/>
    </xsl:template>

    <xsl:template priority="2" match="p/descendant::text()[1]
        | li/descendant::text()[1]
        | td/descendant::text()[1]
        | th/descendant::text()[1]">
        <xsl:variable name="so-far">
            <xsl:next-match/>
        </xsl:variable>
        <xsl:sequence select="replace($so-far,'^\s+','')"/>
    </xsl:template>
    
    <xsl:template match="p//text() | li//text() | td//text() | th//text()">
        <xsl:value-of select="replace(.,'\s+',' ')"/>
    </xsl:template>

    <!--<xsl:template priority="10" match="p//text()[m:first-text(.,ancestor::p[1])] [m:last-text(.,ancestor::p[1])]
        | li//text()[m:first-text(.,ancestor::li[1])] [m:last-text(.,ancestor::li[1])]
        | td//text()[m:first-text(.,ancestor::td[1])] [m:last-text(.,ancestor::td[1])]
        | th//text()[m:first-text(.,ancestor::th[1])] [m:last-text(.,ancestor::th[1])]">
        <xsl:value-of select="replace(.,'\s',' ') => replace('\s$','') => replace('^ ','')"/>
    </xsl:template>-->
    
    <!--<xsl:template match="p//text()[m:first-text(.,ancestor::p[1])]
        | li//text()[m:first-text(.,ancestor::li[1])]
        | td//text()[m:first-text(.,ancestor::td[1])]
        | th//text()[m:first-text(.,ancestor::th[1])]">
        <xsl:value-of select="replace(.,'\s',' ') => replace('^\s','')"/>
    </xsl:template>
    
    <xsl:template match="p//text()[m:last-text(.,ancestor::p[1])]
        | li//text()[m:last-text(.,ancestor::li[1])]
        | td//text()[m:last-text(.,ancestor::td[1])]
        | th//text()[m:last-text(.,ancestor::th[1])]">
        <xsl:value-of select="replace(.,'\s',' ') => replace('\s$','')"/>
    </xsl:template>-->
    
    <xsl:function name="m:first-text" as="xs:boolean">
        <xsl:param name="which" as="text()"/>
        <xsl:param name="whose" as="element()"/>
        <xsl:sequence select="$which is $whose/descendant::text()[1]"/>
    </xsl:function>

    <xsl:function name="m:last-text" as="xs:boolean">
        <xsl:param name="which" as="text()"/>
        <xsl:param name="whose" as="element()"/>
        <xsl:sequence select="$which is $whose/descendant::text()[last()]"/>
    </xsl:function>
    
</xsl:stylesheet>