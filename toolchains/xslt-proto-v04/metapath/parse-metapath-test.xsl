<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:math="http://www.w3.org/2005/xpath-functions/math"
    exclude-result-prefixes="xs math"
    version="3.0"
    xmlns:m="http://csrc.nist.gov/ns/oscal/metaschema/1.0"
    xmlns:p="xpath20">
    
    <xsl:import href="parse-metapath.xsl"/>
    
    <xsl:output indent="yes"/>
    
    <xsl:mode on-no-match="shallow-skip"/>
    
    <!--<xsl:variable name="target-namespace" select="string(/m:METASCHEMA/m:namespace)"/>
    
    <xsl:variable name="declaration-prefix" select="string(/m:METASCHEMA/m:short-name)"/>
    
    -->
    <xsl:template match="/">
        <xsl:variable name="path">@pink[../link/@href='.' and matches(ancestor::sec/@id,'AC')]</xsl:variable>
        <test>
            <path>
                <xsl:value-of select="m:prefixed-path($path,'pf')"/>
            </path>
            <xsl:sequence select="p:parse-XPath($path)"/>
        </test>
    </xsl:template>
    
</xsl:stylesheet>