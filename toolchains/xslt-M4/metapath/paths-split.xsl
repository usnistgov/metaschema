<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:math="http://www.w3.org/2005/xpath-functions/math"
    exclude-result-prefixes="xs math"
     xmlns:m="http://csrc.nist.gov/ns/oscal/metaschema/1.0"
     version="3.0">
    
    <xsl:output indent="true"/>
    
    <xsl:strip-space elements="*"/>
    
    <xsl:template match="/">
        <RESULT>
            
            <xsl:variable name="split-paths">
              <xsl:apply-templates select="m:metapath" mode="split-out"/>
            </xsl:variable>
            <xsl:apply-templates select="$split-paths" mode="write"/>
            
        </RESULT>
    </xsl:template>
    
    
    <xsl:template match="m:path" mode="write">
        <p>
        <xsl:for-each select="m:step">
            <xsl:if test="position() gt 1">/</xsl:if>
            <xsl:apply-templates select="." mode="#current"/>
        </xsl:for-each>
        </p>
    </xsl:template>
    
    <xsl:template match="m:step[empty(*)]" mode="write" expand-text="true">{ . }</xsl:template>
    
    <xsl:template match="m:axis" mode="write" expand-text="true">{ . }::</xsl:template>
    
    
    <xsl:template match="m:metapath" mode="split-out">
        <xsl:apply-templates select="*[1]" mode="#current"/>
    </xsl:template>
    
    <!--each alternative is contains a sequence of (downward) steps-->
    
    <!--<xsl:mode name="split-out" on-no-match="shallow-copy"/>-->
    
    
   <!-- 
       
       mode 'split-out' burrows into a (flattened simplified) parse tree
       and returns split out paths
       
       passing in steps so far into each subsequent template
         passing along a $paths sequence staring with a single (empty) path
       each step receives $paths and for each
         it adds itself and marches forward
       except
         when a step shows alternatives we 'blow it out'
         by returning as many paths as we have alternatives
         for all $paths in the paths so far
      
    -->
    
    <!--<xsl:strip-space elements="*"/>-->
    
    <xsl:template match="m:step" mode="split-out">
        <xsl:param tunnel="true" name="so-far" as="element(m:path)*">
            <m:path/>
        </xsl:param>
        <xsl:variable name="me" select="."/>
        <xsl:variable name="nextstep" select="following-sibling::m:step[1]"/>
        <xsl:for-each select="$so-far">
            <xsl:variable name="path" select="."/>
            <xsl:variable name="new-path" as="element()">
                <m:path>
                    <xsl:sequence select="$path/*, $me"/>
                </m:path>
            </xsl:variable>
            <xsl:apply-templates select="$nextstep" mode="split-out">
                <xsl:with-param tunnel="true" name="so-far" select="$new-path"/>
            </xsl:apply-templates>
            <xsl:if test="empty($nextstep)">
                <xsl:sequence select="$new-path"/>
            </xsl:if>
        </xsl:for-each>
    </xsl:template>
    
<!--    <xsl:template match="m:alternative" mode="split-out">
        <xsl:param tunnel="true" name="so-far" as="element(m:path)*">
            <m:path/>
        </xsl:param>
        <xsl:variable name="me" select="."/>
        <xsl:iterate select="$so-far">
            <xsl:variable name="new-paths" as="element()">
                <m:path>
                    <xsl:sequence select="$path/*, $me"/>
                </m:path>
            </xsl:variable>
            <xsl:next-iteration>
            </xsl:next-iteration>
        </xsl:iterate>
        
        <xsl:variable name="me" select="."/>
        <xsl:variable name="nextstep" select="following-sibling::m:step[1]"/>
        <xsl:for-each select="$so-far">
            <xsl:variable name="path" select="."/>
            <xsl:variable name="new-path" as="element()">
                <m:path>
                    <xsl:sequence select="$path/*, $me"/>
                </m:path>
            </xsl:variable>
            <xsl:apply-templates select="$nextstep" mode="split-out">
                <xsl:with-param tunnel="true" name="so-far" select="$new-path"/>
            </xsl:apply-templates>
            <xsl:if test="empty($nextstep)">
                <xsl:sequence select="$new-path"/>
            </xsl:if>
        </xsl:for-each>
    </xsl:template>
-->    

    <xsl:template match="m:*[exists(m:choice)]" mode="split-out">
        <xsl:param tunnel="true" name="so-far" as="element(m:path)*">
            <m:path/>
        </xsl:param>
        <xsl:variable name="nextstep" select="following-sibling::m:step[1]"/>
        <xsl:variable name="splits" as="element()*">
        <!-- getting as many paths back as there are alternatives -->
             <xsl:apply-templates select="m:choice/m:alternative/m:step[1]" mode="split-out"/>
        </xsl:variable>
        <!--<xsl:iterate></xsl:iterate>-->
        
        <xsl:for-each select="$splits">
            <xsl:variable name="split" select="."/>
            <xsl:for-each select="$so-far">
                <!--<xsl:message expand-text="true">path is a { name($path) } containing { $path/*/name() => string-join(', ') }</xsl:message>-->
                <!--<xsl:message expand-text="true">{ serialize($split) }</xsl:message>-->
                <xsl:variable name="new-path" as="element()">
                    <m:path>
                        <xsl:sequence select="$split/*"/>
                    </m:path>
                </xsl:variable>
                <xsl:apply-templates select="$nextstep" mode="split-out">
                    <xsl:with-param tunnel="true" name="so-far" select="$new-path"/>
                </xsl:apply-templates>
                <xsl:if test="empty($nextstep)">
                    <xsl:sequence select="$new-path"/>
                </xsl:if>
            </xsl:for-each>
        </xsl:for-each>
    </xsl:template>

    
   
</xsl:stylesheet>