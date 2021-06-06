<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:m="http://csrc.nist.gov/ns/oscal/metaschema/1.0"
    exclude-result-prefixes="#all"
    version="3.0" xmlns:p="metapath02">

   
    <xsl:import href="REx/metapath02.xslt"/>

    <xsl:include href="paths-split.xsl"/>
    
    <xsl:output indent="yes"/>

<!-- 1. reduce target paths to their minimized form accounting for axes, removing predicates etc.
          cast wildcards 'node()' 'element()' and 'attribute' to '*'
          normalize away child:: and attribute::
          truncate for deeper descendancy
          
     2. for every reduced-target given for target, 
          pass pairs of context and reduced-target to m:match-paths
          any 'true' qualifies us as a match
     
    -->
    
    <xsl:variable as="xs:string" name="t">a / (b|c|d)</xsl:variable>
    <!--<xsl:variable as="xs:string" name="t">control[a=b]/part//./part/prop[@name='label'] | a/(b|c)</xsl:variable>-->
    <xsl:variable name="tests" as="element()*">
        <test context="part/prop"
            target="part/.//prop"/>
        <test context="part/p"
            target="part/.//prop"/>
        <test context="name"
            target="part/.//prop/@name | person/@name | person/@age"/>
        
    </xsl:variable>
    
<!-- Run this XSLT on itself to see test results -->
    <xsl:template match="/">
        <test-results>
            <!--<IN>
            <xsl:copy-of select="$tests[m:any-match(@context,@target)]"/>
            </IN>
            <OUT>
                <xsl:copy-of select="$tests[not(m:any-match(@context,@target))]"/>
                
            </OUT>-->
            <xsl:for-each expand-text="true" select="m:express-targets($t)">
                <path>{ . }</path>
            </xsl:for-each>
            <xsl:sequence select="m:reduce-path-expr($t)"/>
            <xsl:sequence select="p:parse-XPath($t)"/>
        </test-results>
    </xsl:template>

<!-- m:reduce-alternatives accepts a reduced path expression, parses it and returns any number (usually one)
    representation of that path as a reduced string:
      everything up to a descendant axis is dropped
      filters are dropped
      self axis is dropped
      child and attribute axis are unified
        so '/path/to//deep[$true]/@in' becomes 'deep/in'
        'any/where | you/want' becomes 'any/where' and 'you/want' (two targets)
        a path that does not parse should be empty (TODO) or come back '*' (match everything)?
    -->
    <xsl:function name="m:express-targets" as="xs:string*">
        <xsl:param name="expr" as="xs:string"/>
        <xsl:variable name="reduced-path" select="m:reduce-path-expr($expr)"/>
        <xsl:apply-templates select="$reduced-path" mode="refine-path"/>
    </xsl:function>
    
    <!-- m:reduce-path-expr accepts a path, parses it, and returns a 'reduced' and rewritten path
         easier to rewrite than the raw parse tree -->
    <xsl:function name="m:expand-path-expr" as="node()*">
        <xsl:param name="expr" as="xs:string"/>
        <xsl:variable name="parse.tree" select="p:parse-XPath($expr)"/>
        <xsl:variable name="reduced.tree">
          <xsl:apply-templates select="$parse.tree" mode="reduce-path"/>
        </xsl:variable>
        <!-- each tree returns a sequence of paths as strings, expanded  -->
        <!-- so (a|b)/(c|d) comes back a/c, a/d, b/c, b/d etc. -->
        <xsl:apply-templates select="$reduced.tree" mode="expand"/>
    </xsl:function>
    
    <xsl:mode name="expand" on-no-match="shallow-copy"/>
    
    
    
    
    <xsl:function name="m:reduce-path-expr" as="node()*">
        <xsl:param name="expr" as="xs:string"/>
        <xsl:variable name="parse.tree" select="p:parse-XPath($expr)"/>
        <xsl:apply-templates select="$parse.tree" mode="reduce-path"/>
    </xsl:function>
    
    <!-- wrapper function to support sending union sequences in for matching -->
    <xsl:function name="m:any-match" as="xs:boolean">
        <xsl:param name="context-path" as="xs:string"/><!-- a/b/c -->
        <xsl:param name="target-expr"  as="xs:string"/><!-- a[1]/b/c[3] | d/e[$n]/f -->
        <xsl:sequence select="some $t in m:express-targets($target-expr) satisfies
            m:match-paths($context-path,$t)"/>
    </xsl:function>
    
    <xsl:function name="m:match-paths" as="xs:boolean">
        <xsl:param name="context-path" as="xs:string"/><!-- a/b/c -->
        <xsl:param name="target-path"  as="xs:string"/><!-- a/b/c -->
<!-- return true if the values as tokenized by '/' are coincident for all values in the shorter sequence       -->
<!--        'a/b/c' matches 'a/b/c' 'b/c' 'c' 'z/a/b/c' but not 'a/d/c' -->
        
        <xsl:variable name="cs" select="tokenize($context-path,'/') => reverse()"/>
        <xsl:variable name="ts" select="tokenize($target-path,'/')  => reverse()"/>
        <!-- the count is the length of the shorter sequence -->
        <xsl:variable name="count" select="(count($cs), count($ts)) => min()"/>
        <!-- we are good if either context or target has '*' or if they are same -->
        <xsl:sequence select="every $p in (1 to $count) satisfies
            ( ($cs[$p],$ts[$p])='*' or $cs[$p]=$ts[$p] )"/>
    </xsl:function>
    
    <!--<xsl:template mode="refine-path" match="m:metapath" as="xs:string*">
        <xsl:variable name="unified" as="element()">
            <xsl:apply-templates mode="#current"/>
        </xsl:variable>
        
    </xsl:template>-->
    
    <xsl:template mode="refine-path" match="m:alternative[exists(m:alternative)]">
        <xsl:apply-templates mode="#current"/>
    </xsl:template>
    
    <xsl:template mode="refine-path" match="m:alternative" as="xs:string">
        <xsl:variable name="steps" as="xs:string*">
            <xsl:apply-templates select="m:step" mode="#current"/>
        </xsl:variable>
        <xsl:value-of select="$steps" separator="/"/>
    </xsl:template>
    
    <xsl:template mode="refine-path" match="m:choice" as="xs:string">
        <xsl:value-of>
            <xsl:text>(</xsl:text>
            <xsl:variable name="alternatives" as="xs:string*">
                <xsl:apply-templates select="m:alternative" mode="#current"/>
            </xsl:variable>
            <xsl:value-of select="$alternatives" separator=" | "/>
            <xsl:text>)</xsl:text>
        </xsl:value-of>
    </xsl:template>
    
    <xsl:template mode="refine-path" match="m:choice[count(m:alternative)=1]" priority="2" as="xs:string">
        <xsl:apply-templates select="m:alternative" mode="#current"/>
    </xsl:template>
    
    <xsl:template mode="refine-path" match="m:step[(.|following-sibling::m:step)/m:axis='descendant-or-self']"/>
    <xsl:template mode="refine-path" match="m:step[(following-sibling::m:step)/m:axis='descendant']"/>
    <!--<xsl:template mode="refine-path" priority="2" match="m:step[m:axis='self']"/>-->
    <!--<xsl:template mode="refine-path" priority="2" match="m:step[empty(*)]"/>-->
    
    <xsl:template mode="refine-path" match="m:step">
        <xsl:apply-templates mode="#current"/>
    </xsl:template>
    
    <xsl:template mode="refine-path" match="m:axis"/>
    <xsl:template mode="refine-path" match="m:node[.='node()']">*</xsl:template>
    <!--<xsl:template mode="refine-path" match="m:step[m:axis='self'][empty(preceding-sibling::*)]" priority="3">.</xsl:template>-->
    
    
    <xsl:template mode="reduce-path" match="PredicateList"/>
    
<!-- because the axis is expanded we switch the token   -->
    <!--<xsl:template match="text()" mode="reduce-path"/>-->
    
    <xsl:template match="XPath" mode="reduce-path">
        <m:metapath>
            <xsl:apply-templates mode="#current"/>
        </m:metapath>
    </xsl:template>
    
    <!--<xsl:template match="UnionExpr" mode="reduce-path">
        <m:choice>
            <xsl:apply-templates mode="#current"/>
        </m:choice>
    </xsl:template>-->
    
    <xsl:template match="UnionExpr/UnaryExpr" mode="reduce-path">
        <m:alternative>
            <xsl:apply-templates mode="#current"/>
        </m:alternative>
    </xsl:template>
    
    <xsl:template match="StepExpr" mode="reduce-path">
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
    
    <xsl:template match="ForwardStep[AbbrevForwardStep/TOKEN='@']" mode="reduce-path">
        <m:axis>attribute</m:axis>
        <xsl:apply-templates mode="#current"/>
    </xsl:template>
    
    <xsl:template match="ForwardStep[AbbrevForwardStep/TOKEN='.']" mode="reduce-path">
        <m:axis>self</m:axis>
        <m:node>node()</m:node>
    </xsl:template>
    
    <xsl:template match="FilterExpr[normalize-space(.)='.']" mode="reduce-path">
        <m:step>.</m:step>
    </xsl:template>
    
    <xsl:template match="text()" mode="reduce-path"/>
    
    <xsl:template match="ForwardAxis" mode="reduce-path">
        <m:axis>
            <xsl:value-of select="TOKEN[not(.='::')]"/>
        </m:axis>
    </xsl:template>
    
    <xsl:template match="NodeTest" mode="reduce-path">
        <m:node>
            <xsl:value-of select="."/>
        </m:node>
    </xsl:template>
    
    
    
    <xsl:template priority="2" match="Predicate/TOKEN" mode="reduce-path"/>
    
   
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
   
<!-- functions:
    m:reduced-paths yields target+ from target path
      where target is a string '((\i\c*)+\/)(((\i\c*)+|\*)\/)*
      e.g.
        a1/a2/*/a4
        
    -->
    
   
    

</xsl:stylesheet>