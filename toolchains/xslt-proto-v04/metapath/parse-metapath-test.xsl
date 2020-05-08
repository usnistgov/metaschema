<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:math="http://www.w3.org/2005/xpath-functions/math"
    exclude-result-prefixes="xs math"
    version="3.0"
    xmlns:m="http://csrc.nist.gov/ns/oscal/metaschema/1.0">
    
    <xsl:import href="parse-metapath.xsl"/>
    
    <xsl:output indent="yes"/>
    
    <xsl:mode on-no-match="shallow-skip"/>
    
    <!--<xsl:variable name="target-namespace" select="string(/m:METASCHEMA/m:namespace)"/>
    
    <xsl:variable name="declaration-prefix" select="string(/m:METASCHEMA/m:short-name)"/>
    
    -->
    <xsl:template match="/">
        <tests>
        <xsl:variable name="paths" as="element()*">
            <path p="a">a/child::b</path>
            <path p="b">a//b</path>
            <path p="p">a[x]//b/c[y][z]</path>
            <path p="q">child::a[x]/descendant-or-self::*/child::b/child::c[y][z]</path>
            
            <path p="x">@type[.='boo']</path>
            <path p="z">.//meta/creator[matches(@who,'\S')]</path>
            <path p="a">a[true()] | b[true()]/c</path>
            <path p="anthology">descendant::meta/creator</path>
            <path p="anthology">.//meta/creator[matches(@who,'\S')]</path>
            <path p="d">short[count(z) > 1]</path>
            <path p="d">long/path//into//document</path>
            <path p="n">blue[@class='midnight']/pink[@class='green'][contains(line[1],'boo')]</path>
            <path p="osc">catalog[@id='x']/group/control[@id='ac.2']/part[@name='statement']</path>
            <path p="a" label="pipe (union) operator">line | phrase</path>
            
            <path p="x" label="PI test">descendant::processing-instruction('boo')</path>
            
            
            <!-- THESE SHOULD BREAK under reduced XPath (metapath): they are no longer permissible -->
            <path p="d">short[count(z) > 1 (: comment :)]</path>
            <path p="b" label="union operator">line union phrase</path>
            <path p="b" label="except operator">line except phrase</path>
            <path p="b" label="intersect operator">.//line intersect descendant::*[1]</path>
            <path p="x" label="schema element test">child::schema-element(boo)</path>
            <path p="b" label="a step, but not to a node">path/1/node</path>
            <path p="b" label="compound step">path/(to|from)/node</path>
            <path p="d" label="unsupported gt operator">short[count(z) gt 1]</path>
            <path p="x" label="comment test">child::comment()</path>
            <path p="o" label="node comparison">line[. is id('abc')]</path>
            <path p="o" label="node comparison">stanza[line[1] >> title[1]]</path>
            <path p="x" label="typed comparison">line[@meter gt 3]</path>
            <path p="x" label="instance of">line[@x instance of xs:string]</path>
            <path p="x" label="treat as">line[@x treat as xs:string]</path>
            <path p="x" label="castable as">line[@x castable as xs:string]</path>
            <path p="x" label="cast as">line[@x cast as xs:string]</path>
            <path p="q" label="idiv operator">line[count(*) = (100 idiv 12)]</path>
            <path p="a" label="RangeExpr">line[position() = (1 to 10)]</path>
            <path p="p" label="Sequence">paragraph, figure</path>
            <path p="p" label="ForExpr">for $i in (1 to 10) return (1 div $i)</path>
            <path p="p" label="QuantifiedExpr">every $thing in (thing) satisfies ($thing='green')</path>
            <path p="p" label="IfExpr">if (true()) then child::child else /</path>
        </xsl:variable>
        <xsl:for-each select="$paths">
            <xsl:variable name="path" select="."/>
            <test>
                <path>
                    <xsl:value-of select="$path"/>
                </path>
                <xsl:variable name="rewritten-path" select="m:prefixed-path($path, $path/@p)"/>
                <xsl:choose>
                    <xsl:when test="starts-with($rewritten-path,'!ERROR! ')">
                        <ERROR>
                            <xsl:value-of select="substring-after($rewritten-path,'!ERROR! ')"/>
                        </ERROR>
                    </xsl:when>
                        <xsl:otherwise>
                            <rewritten prefix="{$path/@p}">
                                <xsl:value-of select="$rewritten-path"/>
                            </rewritten>
                        </xsl:otherwise>
                </xsl:choose>    
                
                <target-branch>
                    <!-- wipes predicates (filters) from expressions -->
                    <xsl:value-of select="m:prefixed-path-no-filters($path, $path/@p)"/>
                </target-branch>
                <target-terminal-step>
                    <!-- returns only the terminal step of the forgoing -->
                    <xsl:value-of select="m:prefixed-path-no-filters($path, $path/@p) => replace('.*/','')"/>
                </target-terminal-step>
                <target-exception>
                    <xsl:value-of select="m:rewrite-match-as-test($path,$path/@p)"/>
                </target-exception>
                <filtered>
                    <!-- emits a sequence of steps, each with its NodeTest and filter (predicate) -->
                    <xsl:sequence select="m:prefixed-step-map($path, $path/@p)"/>
                </filtered>
                
                <!--<xsl:sequence xmlns:p="metapath01" select="p:parse-XPath($path)"/>-->
            </test>
        </xsl:for-each>
        </tests>
    </xsl:template>
    
</xsl:stylesheet>