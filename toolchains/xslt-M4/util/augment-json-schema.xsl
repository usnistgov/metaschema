<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="3.0"
    xpath-default-namespace="http://www.w3.org/2005/xpath-functions"
    xmlns="http://www.w3.org/2005/xpath-functions">
    <!-- The input JSON file -->
    <xsl:param name="input" select="''"/>
    
    
<!-- Accepts JSON and emits JSON with '\/' unescaped back into '/' 
     Intervenes with strategic adjustments -->
    
    <xsl:output method="text"/>
    
    <xsl:mode on-no-match="shallow-copy"/>
    
    <xsl:variable name="write-options" as="map(*)">
        <xsl:map>
            <xsl:map-entry key="'indent'" expand-text="true">true</xsl:map-entry>
        </xsl:map>
    </xsl:variable>
    
    <!-- The initial template that process the JSON -->
    <xsl:template name="xsl:initial-template" match="/">
        <xsl:variable name="amended">
          <xsl:apply-templates select="(unparsed-text($input) => json-to-xml() )/*"/>
        </xsl:variable>
        <xsl:sequence select="xml-to-json($amended, $write-options) => replace('\\/','/')"/>
    </xsl:template>
    
    <xsl:template match="/map">
        <xsl:copy>
            <xsl:apply-templates/>
            <xsl:if test="not(string/@key = 'additionalProperties')">
                <boolean key="additionalProperties">false</boolean>
            </xsl:if>
            <xsl:if test="not(string/@key = 'maxProperties')">
                <number key="maxProperties">1</number>
            </xsl:if>
        </xsl:copy>
    </xsl:template>

</xsl:stylesheet>