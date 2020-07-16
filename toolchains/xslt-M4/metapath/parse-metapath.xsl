<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:m="http://csrc.nist.gov/ns/oscal/metaschema/1.0"
    exclude-result-prefixes="#all"
    version="3.0" xmlns:p="metapath02">


<!-- XXX cleanup punchlist for when finished
       check functions - any not being called? (remove)
         (regression test everything after this)
       reconsider names of functions and modes
       cut all the commented code
       add explanatory comments
       any cosmetic reformatting
       look at namespaces
       
    -->
    
    <xsl:import href="REx/metapath02.xslt"/>

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
        <xsl:param name="pfx" tunnel="yes"/>
        <!-- defending against prefixes not NCName       -->
        <xsl:if test="matches($pfx,'\i[\c^:]*')" expand-text="true">{$pfx}:</xsl:if>
        <xsl:next-match/>
    </xsl:template>

    <xsl:template mode="prefix-ncnames scrub-filters"
        match="AxisStep/*/AbbrevForwardStep[not(TOKEN = '@')]/NodeTest/NameTest/QName[not(contains(., ':'))]">
        <xsl:param name="pfx" tunnel="yes"/>
        <xsl:if test="matches($pfx,'\i[\c^:]*')" expand-text="true">{$pfx}:</xsl:if>
        <xsl:next-match/>
    </xsl:template>

    <!-- returns a path, element names prefixed, filters (predicates) removed -->
    <xsl:function name="m:prefixed-path-no-filters" as="xs:string">
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

    <xsl:function name="m:simple-step-map" as="element()*">
        <xsl:param name="expr"/>
        <xsl:variable name="parse.tree" select="p:parse-XPath($expr)"/>
        <xsl:apply-templates select="$parse.tree" mode="step-map"/>
    </xsl:function>
    
    <!-- With two arguments, a prefix can be provided -->
    <xsl:function name="m:prefixed-step-map" as="element()*">
        <xsl:param name="expr" as="xs:string"/>
        <xsl:param name="ns-prefix" as="xs:string"/>
        <xsl:variable name="parse.tree" select="p:parse-XPath($expr)"/>
        <xsl:apply-templates select="$parse.tree" mode="step-map">
            <xsl:with-param name="pfx" as="xs:string" tunnel="yes" select="$ns-prefix"/>
        </xsl:apply-templates>
    </xsl:function>
    
<!-- because the axis is expanded we switch the token   -->
    <xsl:template match="text()" mode="step-map"/>
    
    <xsl:template match="XPath" mode="step-map">
        <m:metapath>
            <xsl:apply-templates mode="#current"/>
        </m:metapath>
    </xsl:template>
    
    <xsl:template match="XPath/UnionExpr/UnaryExpr" mode="step-map">
        <m:alternative>
            <xsl:apply-templates mode="#current"/>
        </m:alternative>
    </xsl:template>
    
    <xsl:template match="StepExpr" mode="step-map">
        <xsl:if test="preceding-sibling::*[1]/self::TOKEN='//'">
            <m:step>
                <m:axis>descendant-or-self</m:axis>
                <m:node>node()</m:node>
            </m:step>
        </xsl:if>
        <m:step>
            <xsl:if test="AxisStep/ForwardStep/AbbrevForwardStep[empty(TOKEN)]">
                <m:axis>child</m:axis>
            </xsl:if>
            <xsl:apply-templates mode="#current"/>
        </m:step>
    </xsl:template>
    
    <xsl:template match="ForwardStep[AbbrevForwardStep/TOKEN='@']" mode="step-map">
        <m:axis>attribute</m:axis>
        <xsl:apply-templates mode="#current"/>
    </xsl:template>
    
    <xsl:template match="ForwardAxis" mode="step-map">
        <m:axis>
            <xsl:value-of select="TOKEN[not(.='::')]"/>
        </m:axis>
    </xsl:template>
    
    <xsl:template match="NodeTest" mode="step-map">
        <m:node>
            <xsl:apply-templates mode="prefix-ncnames"/>
        </m:node>
    </xsl:template>
    
    <xsl:template match="Predicate" mode="step-map">
        <m:filter>
            <xsl:apply-templates mode="#current"/>
        </m:filter>
    </xsl:template>
    
    <xsl:template priority="2" match="Predicate/TOKEN" mode="step-map"/>
    
    <xsl:template match="Predicate/*" mode="step-map">
        <xsl:apply-templates select="." mode="prefix-ncnames"/>
    </xsl:template>

    <!-- for path a[x]/b/c[y][z] and prefix p, returns "exists(self::p:c:[p:y][p:z]/parent::p:b/ancestor::p:a[p:x]) "-->
    
    <xsl:variable name="debug-serializer" as="element()">
        <output:serialization-parameters
            xmlns="http://csrc.nist.gov/ns/oscal/metaschema/1.0"
            xmlns:output="http://www.w3.org/2010/xslt-xquery-serialization">
            <output:method value="xml"/>
            <output:version value="1.0"/>
            <output:indent value="yes"/>
        </output:serialization-parameters>
    </xsl:variable>   
    
    
    <xsl:function name="m:rewrite-match-as-test" as="xs:string?">
        <xsl:param name="who" as="item()?"/>
        <xsl:param name="ns-prefix" as="xs:string"/>
        <xsl:variable name="alternatives" as="element()*" select="m:prefixed-step-map(string($who), $ns-prefix)/*"/>
        
        <xsl:for-each-group select="$alternatives[exists(m:step/m:node)]" group-by="true()">
            <xsl:value-of>
                <xsl:text>exists(</xsl:text>
                <xsl:for-each select="current-group()">
                    <xsl:for-each select="m:step[exists(m:node)]">
                        <xsl:sort select="position()" order="descending"/>
                        <xsl:apply-templates select="." mode="invert-path"/>
                        <xsl:if test="not(position() = last())">/</xsl:if>
                    </xsl:for-each>
                    <xsl:if test="not(position() = last())"> | </xsl:if>
                </xsl:for-each>
                    <xsl:text>)</xsl:text>
            </xsl:value-of>
        </xsl:for-each-group>
    </xsl:function>

<!-- Mode 'invert-path' converts match-pattern logic to selection logic
        "a//b" becomes self::b/ancestor-or-self::*/parent::a -->
    
    <xsl:template priority="3" match="m:step[m:axis='attribute']" mode="invert-path">
        <xsl:text expand-text="true">self::attribute({ m:node })</xsl:text>
        <xsl:apply-templates mode="#current" select="m:filter"/>
    </xsl:template>
    
    <xsl:template priority="2" match="m:step[empty(following-sibling::m:step)]" mode="invert-path">
        <xsl:text>self::</xsl:text>
        <xsl:value-of select="m:node"/>
        <xsl:apply-templates mode="#current" select="m:filter"/>
    </xsl:template>
    
    <xsl:template match="m:step[m:axis='child']" mode="invert-path">
        <xsl:text>parent::</xsl:text>
        <xsl:value-of select="m:node"/>
        <xsl:apply-templates mode="#current" select="m:filter"/>
    </xsl:template>
    
    <xsl:template match="m:step[m:axis='descendant-or-self']" mode="invert-path">
        <xsl:text>ancestor-or-self::</xsl:text>
        <xsl:value-of select="m:node"/>
        <xsl:apply-templates mode="#current" select="m:filter"/>
    </xsl:template>

    <!-- catches descendant   -->
    <xsl:template match="m:step" mode="invert-path">
        <xsl:text>ancestor::</xsl:text>
        <xsl:value-of select="node"/>
        <xsl:apply-templates mode="#current" select="filter"/>
    </xsl:template>
    
    <xsl:template match="m:filter" mode="invert-path">
        <xsl:text>[</xsl:text>
        <xsl:value-of select="."/>
        <xsl:text>]</xsl:text>
    </xsl:template>
    
    <!-- Mode path-map is somewhat like simple-step-map and they could XXX be
        consolidated (except where they can't) -->
    
    <!-- Differences: text is not suppressed in step-map
           (slightly rewritten where paths are explicated)
      paths are kept, not only steps-->
    
    <xsl:template match="XPath" mode="path-map">
        <m:metapath>
            <xsl:apply-templates mode="#current"/>
        </m:metapath>
    </xsl:template>
    
    <xsl:template match="XPath/UnionExpr/UnaryExpr" mode="path-map">
        <m:alternative>
            <xsl:apply-templates mode="#current"/>
        </m:alternative>
    </xsl:template>
    
    <xsl:template match="PathExpr" mode="path-map">
        <m:path>
            <xsl:apply-templates mode="#current"/>
        </m:path>
    </xsl:template>
    
    <!-- since '//' is expanded, we reduce the token to '/' -->
    <xsl:template match="TOKEN[.='//']" mode="path-map">/</xsl:template>
    <!-- similarly we drop '@s since we expand to 'attribute::'   -->
    <xsl:template match="TOKEN[.='@']" mode="path-map"/>
    
    <xsl:template match="StepExpr" mode="path-map">
        <xsl:if test="preceding::*[1]/self::TOKEN='//'">
            <m:step>
                <m:axis>descendant-or-self::</m:axis>
                <m:node>node()</m:node>
            </m:step>
            <xsl:text>/</xsl:text>
        </xsl:if>
        <m:step>
            <xsl:if test="AxisStep/ForwardStep/AbbrevForwardStep[empty(TOKEN)]">
                <m:axis>child::</m:axis>
            </xsl:if>
            <xsl:apply-templates mode="#current"/>
        </m:step>
    </xsl:template>
    
    <xsl:template match="ForwardStep[AbbrevForwardStep/TOKEN='@']" mode="path-map">
        <m:axis>attribute::</m:axis>
        <xsl:apply-templates mode="#current"/>
    </xsl:template>
    
    <xsl:template match="ForwardAxis" mode="path-map">
        <m:axis>
            <xsl:apply-templates mode="#current"/>
        </m:axis>
    </xsl:template>
    
    <xsl:template match="NodeTest" mode="path-map">
        <m:node>
            <xsl:apply-templates mode="prefix-ncnames"/>
        </m:node>
    </xsl:template>
    
    <xsl:template match="Predicate" mode="path-map">
        <m:filter>
            <xsl:apply-templates mode="#current"/>
        </m:filter>
    </xsl:template>

    <xsl:template match="FunctionCall" mode="path-map">
        <m:function>
            <xsl:apply-templates mode="#current"/>
        </m:function>
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