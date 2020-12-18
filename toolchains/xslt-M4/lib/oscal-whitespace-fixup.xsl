<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:math="http://www.w3.org/2005/xpath-functions/math"
    xmlns:m="http://csrc.nist.gov/ns/oscal/metaschema/1.0"
    xpath-default-namespace="http://csrc.nist.gov/ns/oscal/1.0"
    exclude-result-prefixes="xs math"
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
    
    <xsl:mode on-no-match="shallow-copy"/>
    
    <xsl:template match="pre//text()">
        <xsl:value-of select="."/>
    </xsl:template>

    <xsl:template match="p//text() | li//text() | td//text() | th//text()">
        <xsl:value-of select="replace(.,'\s+',' ')"/>
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

    <xsl:template priority="3" match="p/descendant::text()[1]
        | li/descendant::text()[1]
        | td/descendant::text()[1]
        | th/descendant::text()[1]">
        <xsl:variable name="so-far">
            <xsl:next-match/>
        </xsl:variable>
        <xsl:sequence select="replace($so-far,'^\s+','')"/>
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