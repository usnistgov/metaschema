<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:math="http://www.w3.org/2005/xpath-functions/math"
    xmlns:map="http://www.w3.org/2005/xpath-functions/map"
    xmlns:m="http://csrc.nist.gov/ns/oscal/metaschema/1.0"
    xmlns="http://csrc.nist.gov/ns/oscal/metaschema/1.0"
    xpath-default-namespace="http://csrc.nist.gov/ns/oscal/metaschema/1.0"
    exclude-result-prefixes="#all" version="3.0">
    
    <xsl:output indent="yes"/>
    
    <xsl:strip-space
        elements="METASCHEMA define-flag define-field define-assembly remarks model choice"/>
    
    <xsl:variable name="show-warnings" as="xs:string">yes</xsl:variable>
    <xsl:variable name="verbose" select="lower-case($show-warnings) = ('yes', 'y', '1', 'true')"/>
    
    <!--<xsl:key name="global-assembly-definition" match="METASCHEMA/define-assembly" use="@_key-name"/>
    <xsl:key name="global-field-definition"    match="METASCHEMA/define-field"    use="@_key-name"/>-->
    
    
    <!-- ====== ====== ====== ====== ====== ====== ====== ====== ====== ====== ====== ====== -->
    <!-- Pass Three: filter definitions (2) - keep only top-level definitions that are actually
         called by references in the models descending from assemblies with root-name.
         
         Note that we ignore flag definitions, which can stay,
         since all flag definitions are rewritten into local declarations,
         so all top-level flag definitions will be dropped in any case.
    -->
    
    <xsl:mode on-no-match="shallow-copy"/>
    
    <!-- potentially we have nested //METASCHEMA elements -->
    <xsl:variable name="root-assembly-definitions" select="//METASCHEMA/define-assembly[exists(root-name)]"/>
    
    <xsl:function name="m:definition-key" as="xs:string">
        <xsl:param name="d"/>
        <xsl:sequence select="$d ! (substring-after(name(.),'define-'), @_key-name) => string-join('#')"/>
    </xsl:function>
    
    <xsl:key name="m:definition-by-key" match="METASCHEMA/define-assembly |
        METASCHEMA/define-field | METASCHEMA/define-flag" use="m:definition-key(.)"/>
    
    <xsl:function name="m:referencing-key" as="xs:string">
        <xsl:param name="r"/>
        <xsl:sequence select="$r ! (name(.), @_key-ref) => string-join('#')"/>
    </xsl:function>
    
    <xsl:variable name="definitions" as="xs:string*">
        <xsl:iterate select="$root-assembly-definitions">
            <xsl:param name="so-far" select="()" as="xs:string*"/>
            <xsl:on-completion select="$so-far"/>
            <xsl:variable name="key" select="m:definition-key(.)"/>
            <xsl:variable name="captured" as="xs:string*">
                <xsl:if test="not($key = $so-far)">
                    <xsl:apply-templates select="." mode="collect-definitions">
                        <xsl:with-param name="defined-so-far" select="$so-far"/>
                    </xsl:apply-templates>
                </xsl:if>
            </xsl:variable>
            <xsl:next-iteration>
                <xsl:with-param name="so-far" select="$so-far, $captured"/>
            </xsl:next-iteration>
            
        </xsl:iterate>
    </xsl:variable>
    
    <xsl:template mode="collect-definitions" match="METASCHEMA/define-field | METASCHEMA/define-flag" as="xs:string*">
        <xsl:param name="defined-so-far" select="()" as="xs:string*"/>
        <xsl:variable name="key" select="m:definition-key(.)"/>
        <!-- now traversing to descendant references -->
        <xsl:if test="not($key = $defined-so-far)">
            <xsl:sequence select="$key"/>
            <xsl:apply-templates mode="#current" select="flag">
                <xsl:with-param name="defined-so-far" select="$defined-so-far, $key"/>
            </xsl:apply-templates>
        </xsl:if>
    </xsl:template>
    
    <xsl:template mode="collect-definitions" match="METASCHEMA/define-assembly" as="xs:string*">
        <xsl:param name="defined-so-far" select="()" as="xs:string*"/>
        <xsl:variable name="key" select="m:definition-key(.)"/>
        <!-- now traversing to descendant references -->
        <xsl:iterate select="descendant::flag | descendant::field | descendant::assembly">
            <xsl:param name="so-far" select="$defined-so-far,$key" as="xs:string*"/>
            <xsl:on-completion select="$so-far"/>
            <xsl:variable name="captured" as="xs:string*">
                <xsl:if test="not(m:referencing-key(.) = $so-far)">
                    <xsl:apply-templates select="key('m:definition-by-key', m:referencing-key(.))"
                        mode="#current">
                        <xsl:with-param name="defined-so-far" select="$so-far"/>
                    </xsl:apply-templates>
                </xsl:if>
            </xsl:variable>
            <xsl:next-iteration>
                <xsl:with-param name="so-far" select="distinct-values(($so-far,$captured))"/>
            </xsl:next-iteration>
            
        </xsl:iterate>
    </xsl:template>
    
    <!--<xsl:template mode="collect-definitions" match="assembly | field | flag" as="xs:string?">
        <!-\- only continuing if not already visited -\->
        <xsl:message expand-text="true">REFERENCING { m:referencing-key(.) } ACCUMULATED { accumulator-before('m:definitions-seen') }</xsl:message>
        <xsl:if test="not(m:referencing-key(.) = accumulator-before('m:definitions-seen'))">
            <xsl:message expand-text="true">... okay on { m:referencing-key(.) } for { count( key('m:definition-by-key',m:referencing-key(.)) ) }</xsl:message>
          <xsl:apply-templates select="key('m:definition-by-key',m:referencing-key(.))" mode="#current"/>
        </xsl:if>
    </xsl:template>-->
    
    <xsl:template mode="collect-definitions" match="flag">
        <xsl:param name="defined-so-far" select="()" as="xs:string*"/>       
        <xsl:apply-templates select="key('m:definition-by-key',m:referencing-key(.))" mode="#current">
            <xsl:with-param name="defined-so-far" select="$defined-so-far"/>
        </xsl:apply-templates>
    </xsl:template>
    
    
    <xsl:template match="/METASCHEMA">
        <xsl:copy expand-text="true">
            <xsl:copy-of select="@*"/>
            <EXCEPTION>Seeing { $definitions => string-join(', ') }</EXCEPTION>
            <xsl:if test="not(@abstract='yes') and empty($root-assembly-definitions)">
                <EXCEPTION problem-type="missing-root">No root found in this metaschema composition.</EXCEPTION>
            </xsl:if>
            
            <!-- Selecting everything so we can emit warning for things we will drop -->
            <xsl:apply-templates/>
            
        </xsl:copy>
    </xsl:template>
    
    <!-- 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 -->    
    
    <!--<xsl:template match="METASCHEMA[not(@abstract='yes')]/define-assembly[not(exists(m:root-name) or (m:definition-key(.) = $definitions))]">
        <xsl:call-template name="warning">
            <xsl:with-param name="type">unused-definition</xsl:with-param>
            <xsl:with-param name="msg" expand-text="true">REMOVING unused assembly definition for '{ @name }' from { ancestor::METASCHEMA[1]/@module
                }</xsl:with-param>
        </xsl:call-template>
    </xsl:template>
    
    <xsl:template match="METASCHEMA[not(@abstract='yes')]/define-field[not(m:definition-key(.) = $definitions)]">
        <xsl:call-template name="warning">
            <xsl:with-param name="type">unused-definition</xsl:with-param>
            <xsl:with-param name="msg" expand-text="true">REMOVING unused field definition for '{ @name }' from { ancestor::METASCHEMA[1]/@module
                }</xsl:with-param>
        </xsl:call-template>
    </xsl:template>
    
    <xsl:template match="METASCHEMA[not(@abstract='yes')]/define-flag[not(m:definition-key(.) = $definitions)]">
        <xsl:call-template name="warning">
            <xsl:with-param name="type">unused-definition</xsl:with-param>
            <xsl:with-param name="msg" expand-text="true">REMOVING unused flag definition for '{ @name }' from { ancestor::METASCHEMA[1]/@module
                }</xsl:with-param>
        </xsl:call-template>
    </xsl:template>-->
    
    <xsl:template name="warning">
        <xsl:param name="msg"/>
        <xsl:param name="type">warning</xsl:param>
        <xsl:if test="$verbose">
            <EXCEPTION problem-type="{ $type }">
                <xsl:copy-of select="$msg"/>
            </EXCEPTION>
        </xsl:if>
    </xsl:template>
    
</xsl:stylesheet>