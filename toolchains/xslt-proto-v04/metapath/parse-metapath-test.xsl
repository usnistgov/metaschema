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
        <tests>
        <xsl:variable name="paths" as="element()*">
            <path p="d">long/path//into//document</path>
            <path p="n">blue[@class='midnight']/pink[@class='green'][contains(../line[1],'boo')]</path>
            <path p="osc">catalog[@id='x']/group/control[@id='ac.2']/part[@name='statement']</path>
        </xsl:variable>
        <xsl:for-each select="$paths">
            <xsl:variable name="path" select="."/>
            <test>
                <path>
                    <xsl:value-of select="$path"/>
                </path>
                <rewritten prefix="{$path/@p}">
                    <xsl:value-of select="m:prefixed-path($path, $path/@p)"/>
                </rewritten>
                <target-match>
                    <!-- wipes predicates (filters) from expressions -->
                    <xsl:value-of select="m:target-branch($path, $path/@p)"/>
                </target-match>
                <target-exception>
                    <xsl:value-of select="m:write-target-exception($path,$path/@p)"/>
                </target-exception>
                <filtered>
                    <!-- emits a sequence of steps, each with its NodeTest and filter (predicate) -->
                    <xsl:sequence select="m:step-map($path, $path/@p)"/>
                </filtered>
                <!--<xsl:sequence select="p:parse-XPath($path)"/>-->
            </test>
        </xsl:for-each>
        </tests>
    </xsl:template>
    
</xsl:stylesheet>