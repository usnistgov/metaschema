<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:math="http://www.w3.org/2005/xpath-functions/math"
    xmlns:m="http://csrc.nist.gov/ns/oscal/metaschema/1.0"
    exclude-result-prefixes="#all"
    version="3.0"
    xmlns:p="xpath20">
    
    <xsl:import href="REx/xpath20.xslt"/>
    
    <xsl:output indent="yes"/>
    
    <xsl:mode on-no-match="shallow-skip"/>
    
    <xsl:function name="m:prefixed-path" as="xs:string">
        <xsl:param name="expr" as="xs:string"/>
        <xsl:param name="ns-prefix" as="xs:string"/>
        <xsl:variable name="parse.tree" select="p:parse-XPath($expr)"/>
        <xsl:value-of>
          <xsl:apply-templates select="$parse.tree" mode="prefix-ncnames">
              <xsl:with-param name="pfx" as="xs:string" tunnel="yes" select="$ns-prefix"/>
          </xsl:apply-templates>
        </xsl:value-of>
    </xsl:function>
    
    <xsl:template match="AxisStep/*[not(ForwardAxis/TOKEN=('@','attribute'))]/NodeTest/NameTest/QName[not(contains(.,':'))]" mode="prefix-ncnames">
        <xsl:param name="pfx" as="xs:string" tunnel="yes"/>
        <xsl:value-of select="$pfx ! (. || ':')"/>
        <xsl:next-match/>
    </xsl:template>
    
    <xsl:template match="AxisStep/*/AbbrevForwardStep[not(TOKEN='@')]/NodeTest/NameTest/QName[not(contains(.,':'))]" mode="prefix-ncnames">
        <xsl:param name="pfx" as="xs:string" tunnel="yes"/>
        <xsl:value-of select="$pfx ! (. || ':')"/>
        <xsl:next-match/>
    </xsl:template>
    
    <xsl:function name="m:xpath-eval-okay" as="xs:boolean">
        <xsl:param name="expr" as="xs:string"/>
        <xsl:variable name="any.place" as="element()"><m:any/></xsl:variable>
        <!-- this filter assumes that a successful parse does not deliver mp:ERROR (hah) -->
        <xsl:sequence select="empty(m:try-xpath-eval($expr,$any.place)/m:ERROR)"/>
    </xsl:function>
    
    <xsl:function name="m:try-xpath-eval" as="element()">
        <xsl:param name="expr" as="xs:string"/>
        <xsl:param name="from" as="node()"/>
        <xsl:message expand-text="true">expr: { $expr } from: { name($from) }</xsl:message>
        <m:try>
            <xsl:try xmlns:err="http://www.w3.org/2005/xqt-errors">
                <xsl:evaluate context-item="$from" xpath="$expr"/>
                <xsl:catch expand-text="true">
                    <m:ERROR code="{ $err:code}">{ $err:description }</m:ERROR>
                </xsl:catch>
            </xsl:try>
        </m:try>
    </xsl:function>
    
    
</xsl:stylesheet>