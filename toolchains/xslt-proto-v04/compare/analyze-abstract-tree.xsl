<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:math="http://www.w3.org/2005/xpath-functions/math"
    xmlns:m="http://csrc.nist.gov/ns/oscal/metaschema/1.0"
    xmlns="http://www.w3.org/1999/xhtml"
    
    expand-text="true"
    xpath-default-namespace="http://csrc.nist.gov/ns/oscal/metaschema/1.0"
    exclude-result-prefixes="#all"
    version="3.0">
    
    
    
    <xsl:template match="/" >
        <html>
            <style type="text/css">

body > * {{ margin-top: 1ex }}
details {{ padding: 0.5ex; border: thin solid black; margin-top: 0.5ex }}

            </style>
               <xsl:apply-templates/>
        </html>
    </xsl:template>
    
    <xsl:template match="root" priority="5">
        <body>
            <xsl:variable name="body-contents">
          <xsl:for-each-group select="//n" group-by="@name">
              <xsl:variable name="t" select="substring-before(current-grouping-key(),'#')"/>
              <xsl:variable name="type" select="if ($t='e') then 'Element' else if ($t='a') then 'Attribute' else 'Text'"/>
              <div>
                  <h3>{ $type }{ $type[not(.='Text')] ! (': ' || substring-after(current-grouping-key(),'#')) } </h3>
                  <p class="parents" data-count="{sum(current-group()/@count)}"
                      data-type-count="{ current-group()/../@name => distinct-values() => count() }">Parents <xsl:call-template name="list-parents">
                      <xsl:with-param name="who" select="current-group()"/>
                  </xsl:call-template></p>
                  <xsl:if test="$t = 'e'">
                      <p class="children" data-count="{sum(current-group()/n/@count)}"
                          data-type-count="{ current-group()/n/@name => distinct-values() => count() }">Children <xsl:call-template name="list">
                          <xsl:with-param name="who" select="current-group()/n"/>
                      </xsl:call-template></p>
                  </xsl:if>
              </div>
              
          </xsl:for-each-group>
            </xsl:variable>
            <div class="summary" xsl:xpath-default-namespace="http://www.w3.org/1999/xhtml">
                <xsl:variable name="node-count" select="count($body-contents/div)"/>
                <xsl:variable name="parent-count" select="sum($body-contents/div/p[@class='parents']/@data-type-count)"/>
                <p>Declared node type count: { $node-count} </p>
                <p>Parentage rate (is the number of parents defined for nodes, divided by the number of nodes): { $parent-count }/{ $node-count } = 
                    { $parent-count div $node-count }. Its upper limit is the node type count (if everything is allowed inside everything); its lower limit is 1 (no node has more than one parent type).</p>          
                <p>Parentage quotient is the parentage rate, divided again by the count of declared node types: { $parent-count }/({ $node-count }*{$node-count}) = {  $parent-count div ($node-count * $node-count) }. Its upper limit is 1 (if everything is allowed inside everything) and lower limit, the reciprocal of the node type count (so, approach zero for many node types). This is a rough measure of 'model entropy', characteristic of more generic and free-form models -- whereas ordered models would have more prescribed structures.</p>
            </div>
            <xsl:sequence select="$body-contents"/>
        </body>
    </xsl:template>
    
    <xsl:template name="list-parents">
        <xsl:param name="who" as="node()*"/>
        <xsl:text>: </xsl:text>
        <xsl:for-each select="$who">
            <xsl:if test="not(position() eq 1)">, </xsl:if>
            <xsl:value-of select="parent::n/@name => substring-after('#')"/>
        <xsl:text> ({ @count })</xsl:text>
        </xsl:for-each>
    </xsl:template>
    
    <xsl:template name="list">
        <xsl:param name="who" as="node()*"/>
        <!--<xsl:value-of select="distinct-values($who/substring-after(@name,'#'))" separator=", "/>-->
        <xsl:text> ({ if (empty($who)) then 'none' else count(distinct-values($who/@name)) })</xsl:text>
        <xsl:if test="exists($who)">: </xsl:if>
        <xsl:for-each-group select="$who" group-by="@name">
            <xsl:if test="not(position() eq 1)">, </xsl:if>
            <xsl:value-of select="current-grouping-key() => substring-after('#')"/>
        </xsl:for-each-group>
    </xsl:template>
    
    <xsl:function name="m:definitions" as="element()*">
        <xsl:param name="metaschema" as="element(METASCHEMA)"/>
        <xsl:sequence select="$metaschema/(define-assembly | define-field | define-flag)"/>
    </xsl:function>
    
    <!--high entropy count p/c is close to (c*c) 
      <a b="n">
          <a b="n">
              <b>
                  <a>
                      <b></b>
                  </a>
              </b>
          </a>
      </a>
    
    low entropy count p/c is close to count c, p/c^2 is low depending on c (no of children)
    <bob>
        <jim>
            <jane>
                <bill></bill>
                <joe></joe>
            </jane>
        </jim>
        <mark>
            <mary></mary>
        </mark>
    </bob>
    -->
    <!--

    absolute count of object types (element|attribute names)
    where { p/c } is a set of p/c instances
      extant parent/child
      or permissible via schema
    count(p) / count(c)*count(c)
    
    larger schemas address greater semantic complexity
    but do not always provide advantages
    paradoxically they can be difficult to extend and adapt
    also, problem of 'many ways to do things' is not solved
      by having more ways to do things
    
    for every a/b pair, how many have a b/a pair?
    how many a permit a//a?
    -->
</xsl:stylesheet>