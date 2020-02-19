<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    version="3.0" xmlns="http://www.w3.org/2005/xpath-functions"
    xpath-default-namespace="http://www.w3.org/2005/xpath-functions" expand-text="true">

    <xsl:strip-space elements="METASCHEMA define-assembly define-field model"/>
    
    <!--<xsl:output indent="yes" method="text"/>-->
    
    <xsl:param name="indent" as="xs:string">yes</xsl:param>
    
    <xsl:mode on-no-match="shallow-copy"/>
    
    <xsl:variable name="write-options" as="map(*)">
        <xsl:map>
            <xsl:map-entry key="'indent'" expand-text="true">{ string( $indent=('yes','1','true') ) }</xsl:map-entry>
        </xsl:map>
    </xsl:variable>
    
    <xsl:template match="/">
        <xsl:variable name="xpath-json">
            <xsl:apply-templates/>
        </xsl:variable>
        <!-- Running through a filter for specialized string handling -->
        <!--<xsl:copy-of select="$xpath-json"/>-->
        <json>
        <!-- Then post-processing the JSON to un-double-escape ... -->
            <xsl:value-of select="xml-to-json($xpath-json, $write-options) => replace('\\\\\\&quot;','\\&quot;') => replace('\\/','/')"/>
        </json>
    </xsl:template>
    
    
    <xsl:template match="string">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
          <xsl:value-of select=". ! replace(.,'\\&quot;','\\\\\\&quot;')"/>
        </xsl:copy>
    </xsl:template>
</xsl:stylesheet>