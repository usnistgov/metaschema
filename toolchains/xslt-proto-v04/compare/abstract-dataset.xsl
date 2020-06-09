<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:math="http://www.w3.org/2005/xpath-functions/math"
    xmlns:m="http://csrc.nist.gov/ns/oscal/metaschema/1.0"
    xmlns="http://csrc.nist.gov/ns/oscal/metaschema/1.0"
    
    expand-text="true"
    exclude-result-prefixes="#all"
    version="3.0">
    
    <xsl:param name="collection" as="xs:string"/>
    
    <xsl:variable name="everything" as="document-node()">
        <xsl:sequence select="document($collection)"/>
    </xsl:variable>
    
    <xsl:template match="/" name="xsl:initial-template">
        <root name="#root">
            <xsl:call-template name="handle-children">
                <xsl:with-param name="whose" select="$everything"/>
            </xsl:call-template>
        </root>
    </xsl:template>
    
    <xsl:key name="all-named" match="* | @* | text()" use="m:nodename(.)"/>
    
    <xsl:function name="m:nodename" as="xs:string">
        <xsl:param name="who"/>
        <xsl:variable name="what" select="if ($who/self::element()) then 'e#' else if ($who/self::attribute()) then 'a#' else ()"/>
        <xsl:sequence select="$what || $who/(node-name(),'#text')[1]"/>        
    </xsl:function>
    
    <!-- $whose is always a like-named set of nodes -->
    <xsl:template name="handle-children">
        <xsl:param name="whose"   select="()"/>
        <xsl:variable name="whose-name" select="m:nodename($whose[1])"/>
            <xsl:for-each-group select="$whose/(* | @* | text()[matches(.,'\S')])"
                group-by="m:nodename(.)">
                <n name="{current-grouping-key()}" count="{count(current-group())}"
                    >
                    <xsl:if test="exists(current-group()/(* | text()))">
                        <xsl:attribute name="significantly-ordered" select="count(current-group()[m:significantly-ordered(.)])"/>
                    </xsl:if>
                <xsl:call-template name="handle-children">
                    <xsl:with-param name="whose" select="current-group()"/>
                </xsl:call-template>
                </n>
            </xsl:for-each-group>
    </xsl:template>
    
    <!-- Returns true if an element contains children who names suggest a significant order -->
    <xsl:function name="m:significantly-ordered" as="xs:boolean">
      <xsl:param name="who" as="element()"/>
      <xsl:sequence select="some $c in ($who/(*|text())) satisfies
            exists(m:recaller($c))"/>
    </xsl:function>
    
    <!-- For any node, retrieves sibling nodes of the same name, when nodes of any other name intervene -->
    <xsl:function name="m:recaller" as="node()*">
        <xsl:param name="who" as="node()"/>
        <xsl:variable name="named" select="m:nodename($who)"/>
        <xsl:sequence select="$who/(following-sibling::*|following-sibling::text()[matches(.,'\S')])[not(m:nodename(.)=$named)]/
            (following-sibling::*|following-sibling::text()[matches(.,'\S')])[m:nodename(.)=$named]"/>
    </xsl:function>
</xsl:stylesheet>