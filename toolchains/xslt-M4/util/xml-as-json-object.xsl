<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:math="http://www.w3.org/2005/xpath-functions/math"
    xmlns="http://www.w3.org/2005/xpath-functions"
    exclude-result-prefixes="xs math"
    version="3.0">

    <!-- To debug, switch output methods and modes on template[@match='/'] -->
    <!--<xsl:output method="xml" indent="yes"/>-->
    <xsl:output method="text"/>

    <xsl:variable name="json-indent">yes</xsl:variable>
    <xsl:variable name="write-options" as="map(*)" expand-text="true">
        <xsl:map>
            <xsl:map-entry key="'indent'">{ $json-indent='yes' }</xsl:map-entry>
        </xsl:map>
    </xsl:variable>

    <xsl:template match="/">
        <xsl:variable name="xpath-json">
            <xsl:apply-templates select="*" mode="cast"/>
        </xsl:variable>
        <!--<xsl:copy-of select="$xpath-json"/>-->
        <xsl:value-of select="xml-to-json($xpath-json,$write-options)"/>
    </xsl:template>

    <xsl:template match="/" mode="hide">
        <xsl:apply-templates select="*" mode="cast"/>
    </xsl:template>

    <xsl:template match="element()" mode="cast" expand-text="true">
        <map>
            <xsl:call-template name="node-name"/>
            <xsl:where-populated>
                <map key="attributes">
                    <xsl:apply-templates select="@*" mode="cast"/>
                </map>
            </xsl:where-populated>
            <xsl:where-populated>
                <array key="contents">
                    <xsl:apply-templates mode="cast"/>
                </array>
            </xsl:where-populated>
        </map>
    </xsl:template>
    
    <xsl:template match="attribute()[matches(namespace-uri(.),'\S') and not(namespace-uri(.) = namespace-uri(parent::*))]" mode="cast" expand-text="true">
        <map key="{name()}">
            <xsl:call-template name="node-name"/>
            <string key="value">{ . }</string>
        </map>
    </xsl:template>
    
    <!-- An attribute in no namespace or the namespace of its parent is emitted as a string -->
    <xsl:template match="attribute()" mode="cast" expand-text="true">
        <string key="{name()}">{ . }</string>
    </xsl:template>
    
    <xsl:template name="node-name" expand-text="true">
        <xsl:choose>
            <xsl:when test="namespace-uri(.) = namespace-uri(parent::*)">
                <string key="name">{ local-name() }</string>
            </xsl:when>
            <xsl:otherwise>
                <map key="name">
                    <string key="lp">{ local-name(.) }</string>
                    <xsl:if test="not(name() = local-name())">
                        <string key="name">{ name(.) }</string>
                    </xsl:if>
                    <xsl:where-populated>
                        <string key="ns">{ namespace-uri(.) }</string>
                    </xsl:where-populated>
                </map>
            </xsl:otherwise>
        </xsl:choose>
        
    </xsl:template>

    <xsl:template match="text()" mode="cast">
        <string>
            <xsl:value-of select="."/>
        </string>
    </xsl:template>

    
<!-- Comments and PIs are dropped. -->

</xsl:stylesheet>
