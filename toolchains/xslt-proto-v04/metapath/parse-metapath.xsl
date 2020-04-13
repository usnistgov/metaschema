<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:math="http://www.w3.org/2005/xpath-functions/math"
    xmlns:m="http://csrc.nist.gov/ns/oscal/metaschema/1.0" exclude-result-prefixes="#all"
    version="3.0" xmlns:p="metapath01">

    <xsl:import href="REx/metapath01.xslt"/>

    <xsl:output indent="yes"/>

    <xsl:mode on-no-match="shallow-skip"/>

    <xsl:function name="m:prefixed-path" as="xs:string">
        <xsl:param name="expr" as="xs:string"/>
        <xsl:param name="ns-prefix" as="xs:string"/>
        <xsl:variable name="parse.tree" select="p:parse-XPath($expr)"/>
        <xsl:choose>
            <xsl:when test="exists($parse.tree/self::ERROR)" expand-text="true">!ERROR! { normalize-space($parse.tree) }</xsl:when>
            <xsl:otherwise>
                <xsl:value-of>
                    <xsl:apply-templates select="$parse.tree" mode="prefix-ncnames">
                        <xsl:with-param name="pfx" as="xs:string" tunnel="yes" select="$ns-prefix"/>
                    </xsl:apply-templates>
                </xsl:value-of>

            </xsl:otherwise>
        </xsl:choose>

    </xsl:function>

    <xsl:template mode="prefix-ncnames scrub-filters"
        match="AxisStep/*[not(ForwardAxis/TOKEN = ('@', 'attribute'))]/NodeTest/NameTest/QName[not(contains(., ':'))]">
        <xsl:param name="pfx" as="xs:string" tunnel="yes"/>
        <xsl:value-of select="$pfx ! (. || ':')"/>
        <xsl:next-match/>
    </xsl:template>

    <xsl:template mode="prefix-ncnames scrub-filters"
        match="AxisStep/*/AbbrevForwardStep[not(TOKEN = '@')]/NodeTest/NameTest/QName[not(contains(., ':'))]">
        <xsl:param name="pfx" as="xs:string" tunnel="yes"/>
        <xsl:value-of select="$pfx ! (. || ':')"/>
        <xsl:next-match/>
    </xsl:template>

    <!-- returns a path, element names prefixed, filters (predicates) removed -->
    <xsl:function name="m:target-branch" as="xs:string">
        <xsl:param name="expr" as="xs:string"/>
        <xsl:param name="ns-prefix" as="xs:string"/>
        <xsl:variable name="parse.tree" select="p:parse-XPath($expr)"/>
        <xsl:variable name="rewrite">
            <xsl:apply-templates select="$parse.tree" mode="scrub-filters">
                <xsl:with-param name="pfx" as="xs:string" tunnel="yes" select="$ns-prefix"/>
            </xsl:apply-templates>
        </xsl:variable>
        <!-- strip initial './' as no-op -->
        <xsl:value-of select="replace($rewrite,'^(\./)+','')"/>
    </xsl:function>

    <xsl:template mode="scrub-filters" match="PredicateList"/>


    <xsl:function name="m:step-map" as="element()*">
        <xsl:param name="expr" as="xs:string"/>
        <xsl:param name="ns-prefix" as="xs:string"/>
        <xsl:variable name="parse.tree" select="p:parse-XPath($expr)"/>
        <xsl:apply-templates select="$parse.tree" mode="step-map">
            <xsl:with-param name="pfx" as="xs:string" tunnel="yes" select="$ns-prefix"/>
        </xsl:apply-templates>
    </xsl:function>

    <xsl:template match="text()" mode="step-map"/>

    <xsl:template match="UnaryExpr" mode="step-map">
        <alternative>
            <xsl:apply-templates mode="#current"/>
        </alternative>
    </xsl:template>
    
    <xsl:template match="StepExpr" mode="step-map">
        <step>
            <xsl:apply-templates mode="#current"/>
        </step>
    </xsl:template>
    
    <xsl:template match="ForwardStep[AbbrevForwardStep/TOKEN='@']" mode="step-map">
        <axis>attribute</axis>
        <xsl:apply-templates mode="#current"/>
    </xsl:template>
    
    <xsl:template match="ForwardAxis" mode="step-map">
        <axis>
            <xsl:value-of select="TOKEN[not(.='::')]"/>
        </axis>
    </xsl:template>
    
    <xsl:template match="NodeTest" mode="step-map">
        <node>
            <xsl:apply-templates mode="prefix-ncnames"/>
        </node>
    </xsl:template>

    <xsl:template match="Predicate" mode="step-map">
        <filter>
            <xsl:apply-templates mode="#current"/>
        </filter>
    </xsl:template>

    <xsl:template priority="2" match="Predicate/TOKEN" mode="step-map"/>

    <xsl:template match="Predicate/*" mode="step-map">
        <xsl:apply-templates select="." mode="prefix-ncnames"/>
    </xsl:template>

    <xsl:function name="m:write-target-exception" as="xs:string?">
        <xsl:param name="who" as="item()?"/>
        <xsl:param name="ns-prefix" as="xs:string"/>
        <xsl:variable name="alternatives" as="element()*" select="m:step-map(string($who), $ns-prefix)"/>
        <xsl:for-each-group select="$alternatives[exists(step/node)]" group-by="true()">
            <xsl:value-of>
                <xsl:text>exists(</xsl:text>
                <xsl:for-each select="current-group()">
                    <xsl:for-each select="step[exists(node)]">
                        <xsl:sort select="position()" order="descending"/>
                        <xsl:apply-templates select="." mode="target-step-check"/>
                        <xsl:if test="not(position() = last())">/</xsl:if>
                    </xsl:for-each>
                    <xsl:if test="not(position() = last())"> | </xsl:if>
                </xsl:for-each>
                    <xsl:text>)</xsl:text>
            </xsl:value-of>
            
        </xsl:for-each-group>
        
    </xsl:function>

<!-- Mode 'target-step-check', for any step, writes an XPath traversing to that step, going up the tree -->
    <xsl:template priority="2" match="step[axis='attribute']" mode="target-step-check">
      <xsl:text>.</xsl:text>
        <xsl:apply-templates mode="#current" select="filter"/>
    </xsl:template>
    
    <xsl:template match="step[empty(following-sibling::step)]" mode="target-step-check">
        <xsl:text>self::</xsl:text>
        <xsl:value-of select="node"/>
        <xsl:apply-templates mode="#current" select="filter"/>
    </xsl:template>
    
    <xsl:template match="step" mode="target-step-check">
        <xsl:text>ancestor::</xsl:text>
        <xsl:value-of select="node"/>
        <xsl:apply-templates mode="#current" select="filter"/>
    </xsl:template>
    
    <xsl:template match="filter" mode="target-step-check">
        <xsl:text>[</xsl:text>
        <xsl:value-of select="."/>
        <xsl:text>]</xsl:text>
    </xsl:template>
    
    <!--<xsl:function name="m:xpath-eval-okay" as="xs:boolean">
        <xsl:param name="expr" as="xs:string"/>
        <xsl:variable name="any.place" as="element()"><m:any/></xsl:variable>
        <!-\- this filter assumes that a successful parse does not deliver mp:ERROR (hah) -\->
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
    -->

</xsl:stylesheet>