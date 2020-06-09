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
    
    <xsl:template match="METASCHEMA" priority="5">
        <body>
          <xsl:apply-templates/>
        </body>
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