<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:math="http://www.w3.org/2005/xpath-functions/math"
    xmlns:m="http://csrc.nist.gov/ns/oscal/metaschema/1.0"
    exclude-result-prefixes="#all"
    version="3.0"
    xmlns:mp="http://csrc.nist.gov/ns/oscal/metapath/1.0"
    
    xmlns:p="xpath20">
    
    <xsl:import href="REx/xpath20.xslt"/>
    
    <xsl:output indent="yes"/>
    
    <xsl:mode on-no-match="shallow-skip"/>
    
    <xsl:param name="declaration-prefix" select="(/m:METASCHEMA/m:short-name/string(.),'PRFX')[1]"/>
    
    <xsl:function name="mp:prefixed-path" as="xs:string">
        <xsl:param name="expr" as="xs:string"/>
        
        
        <xsl:variable name="parse.tree" select="p:parse-XPath($expr)"/>
        <xsl:value-of>
        <xsl:apply-templates select="$parse.tree" mode="prefix-ncnames"/>
        </xsl:value-of>
    </xsl:function>
    
    <xsl:template match="AxisStep/*[not(ForwardAxis/TOKEN=('@','attribute'))]/NodeTest/NameTest/QName[not(contains(.,':'))]" mode="prefix-ncnames">
        <xsl:value-of select="$declaration-prefix[matches(.,'\S')] ! (. || ':')"/>
        <xsl:next-match/>
    </xsl:template>
    
    <xsl:template match="AxisStep/*/AbbrevForwardStep[not(TOKEN='@')]/NodeTest/NameTest/QName[not(contains(.,':'))]" mode="prefix-ncnames">
        <xsl:value-of select="$declaration-prefix[matches(.,'\S')] ! (. || ':')"/>
        <xsl:next-match/>
    </xsl:template>
    
    <xsl:function name="mp:xpath-eval-okay" as="xs:boolean">
        <xsl:param name="expr" as="xs:string"/>
        <xsl:variable name="any.place" as="element()"><mp:any/></xsl:variable>
        <!-- this filter assumes that a successful parse does not deliver mp:ERROR (hah) -->
        <xsl:sequence select="empty(mp:try-xpath-eval($expr,$any.place)/mp:ERROR)"/>
    </xsl:function>
    
    <xsl:function name="mp:try-xpath-eval" as="element()">
        <xsl:param name="expr" as="xs:string"/>
        <xsl:param name="from" as="node()"/>
        <xsl:message expand-text="true">expr: { $expr } from: { name($from) }</xsl:message>
        <mp:try>
            <xsl:try xmlns:err="http://www.w3.org/2005/xqt-errors">
                <xsl:evaluate context-item="$from" xpath="$expr"/>
                <xsl:catch expand-text="true">
                    <mp:ERROR code="{ $err:code}">{ $err:description }</mp:ERROR>
                </xsl:catch>
            </xsl:try>
        </mp:try>
    </xsl:function>
    
    
</xsl:stylesheet>