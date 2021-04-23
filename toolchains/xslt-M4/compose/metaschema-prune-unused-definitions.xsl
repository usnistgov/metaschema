<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:math="http://www.w3.org/2005/xpath-functions/math"
    xmlns:m="http://csrc.nist.gov/ns/oscal/metaschema/1.0"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xpath-default-namespace="http://csrc.nist.gov/ns/oscal/metaschema/1.0"
    exclude-result-prefixes="xs math m xsi" version="3.0">

    <xsl:output indent="yes"/>

    <xsl:strip-space
        elements="METASCHEMA define-flag define-field define-assembly remarks model choice"/>

    <xsl:variable name="show-warnings" as="xs:string">yes</xsl:variable>
    <xsl:variable name="verbose" select="lower-case($show-warnings) = ('yes', 'y', '1', 'true')"/>

    <xsl:key name="global-assembly-definition" match="METASCHEMA/define-assembly" use="@key-name"/>
    <xsl:key name="global-field-definition"    match="METASCHEMA/define-field"    use="@key-name"/>
    
    
    <!-- ====== ====== ====== ====== ====== ====== ====== ====== ====== ====== ====== ====== -->
    <!-- Pass Three: filter definitions (2) - keep only top-level definitions that are actually
         called by references in the models descending from assemblies with root-name.
         
         Note that we ignore flag definitions, which can stay,
         since all flag definitions are rewritten into local declarations,
         so all top-level flag definitions will be dropped in any case.
    -->
    
    <xsl:mode on-no-match="shallow-copy"/>
    
    <xsl:variable name="assembly-references" as="xs:string*">
        <xsl:for-each select="//METASCHEMA/define-assembly[exists(root-name)]">
            <xsl:sequence select="string(@key-name)"/>
            <xsl:apply-templates select="model" mode="collect-assembly-references">
                <xsl:with-param name="assembly-refs" tunnel="yes" select="string(@key-name)"/>
            </xsl:apply-templates>
        </xsl:for-each>
    </xsl:variable>
    
    <xsl:variable name="field-references" as="xs:string*">
        <xsl:apply-templates select="//METASCHEMA/define-assembly[exists(root-name)]" mode="collect-field-references">
            <xsl:with-param name="field-refs" tunnel="yes" select="()"/>
        </xsl:apply-templates>
    </xsl:variable>
    
    <xsl:variable name="flag-references" as="xs:string*">
        <xsl:apply-templates select="//METASCHEMA/define-assembly[exists(root-name)]" mode="collect-flag-references">
            <xsl:with-param name="flag-refs" tunnel="yes" select="()"/>
        </xsl:apply-templates>
    </xsl:variable>
    
    <xsl:template match="/">
        <xsl:if test="$verbose">
            <xsl:comment expand-text="true">Assembly references: { $assembly-references }</xsl:comment>
            <xsl:text>&#xA;</xsl:text>
            <xsl:comment expand-text="true">Field references: { $field-references }</xsl:comment>
            <xsl:text>&#xA;</xsl:text>
            <xsl:comment expand-text="true">Flag references: { $flag-references }</xsl:comment>
            <xsl:text>&#xA;</xsl:text>
        </xsl:if>
        <xsl:apply-templates/>
    </xsl:template>
    
    <!-- 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 -->    

    <xsl:template match="METASCHEMA/define-assembly[not(@key-name=$assembly-references)]">
        <xsl:call-template name="warning">
            <xsl:with-param name="msg" expand-text="true">REMOVING unused assembly definition for '{ @name }' from { ancestor::METASCHEMA[1]/@module
                }</xsl:with-param>
        </xsl:call-template>
    </xsl:template>
    
    <xsl:template match="METASCHEMA/define-field[not(@key-name=$field-references)]">
        <xsl:call-template name="warning">
            <xsl:with-param name="msg" expand-text="true">REMOVING unused field definition for '{ @name }' from { ancestor::METASCHEMA[1]/@module
                }</xsl:with-param>
        </xsl:call-template>
    </xsl:template>
    
    <xsl:template match="METASCHEMA/define-flag[not(@key-name=$flag-references)]">
        <xsl:call-template name="warning">
            <xsl:with-param name="msg" expand-text="true">REMOVING unused flag definition for '{ @name }' from { ancestor::METASCHEMA[1]/@module
                }</xsl:with-param>
        </xsl:call-template>
    </xsl:template>

    <!-- 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 -->
    <!-- Modes collecting sets of strings naming definitions
     we actually need, by traversing the definitions tree from the declared root;
     recursive models are accounted for. -->
    
    <xsl:template match="define-assembly" mode="collect-assembly-references">
        <xsl:apply-templates select="model" mode="#current"/>
    </xsl:template>
    
    <xsl:template match="model" mode="collect-assembly-references">
        <xsl:apply-templates select=".//assembly" mode="#current"/>
    </xsl:template>
    
    <xsl:template match="assembly" mode="collect-assembly-references">
        <xsl:param name="assembly-refs" tunnel="yes" select="()"/>
        <xsl:if test="not(@key-ref = $assembly-refs)">
            <xsl:sequence select="string(@key-ref)"/>
            <xsl:apply-templates select="key('global-assembly-definition',@key-ref)" mode="#current">
                <xsl:with-param name="assembly-refs" tunnel="yes" select="$assembly-refs,string(@key-ref)"/>
            </xsl:apply-templates>
        </xsl:if>
    </xsl:template>

    <!-- 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 -->   

    <xsl:template match="define-assembly" mode="collect-field-references">
        <xsl:apply-templates select="model" mode="#current"/>
    </xsl:template>
    
    <xsl:template match="model" mode="collect-field-references">
        <xsl:apply-templates select=".//field" mode="#current"/>
        <xsl:apply-templates select=".//assembly" mode="#current"/>
    </xsl:template>
    
    <xsl:template match="assembly" mode="collect-field-references collect-flag-references">
        <xsl:param name="assembly-refs" tunnel="yes" select="()"/>
        <xsl:if test="not(@key-ref = $assembly-refs)">
            <xsl:apply-templates select="key('global-assembly-definition',@key-ref)" mode="#current">
                <xsl:with-param name="assembly-refs" tunnel="yes" select="$assembly-refs,string(@key-ref)"/>
            </xsl:apply-templates>
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="field" mode="collect-field-references">
        <xsl:sequence select="string(@key-ref)"/>
    </xsl:template>

    <!-- 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 -->   
    
    <xsl:template match="define-assembly | define-field" mode="collect-flag-references">
        <xsl:apply-templates select="flag" mode="#current"/>
        <xsl:apply-templates select="model" mode="#current"/>
    </xsl:template>
    
    <xsl:template match="model" mode="collect-flag-references">
        <xsl:apply-templates select=".//field" mode="#current"/>
        <xsl:apply-templates select=".//define-field/flag" mode="#current"/>
        <xsl:apply-templates select=".//assembly" mode="#current"/>
        <xsl:apply-templates select=".//define-assembly/flag" mode="#current"/>
    </xsl:template>
    
    <!-- Match for 'assembly' appears above -->
    <xsl:template match="field" mode="collect-flag-references">
            <xsl:apply-templates select="key('global-field-definition',@key-ref)" mode="#current"/>        
    </xsl:template>
    
    <xsl:template match="flag" mode="collect-flag-references">
        <xsl:sequence select="string(@key-ref)"/>
    </xsl:template>
    
    <xsl:template name="warning">
        <xsl:param name="msg"/>
        <xsl:if test="$verbose">
            <xsl:comment>
                <xsl:copy-of select="$msg"/>
            </xsl:comment>
            <xsl:message>
                <xsl:copy-of select="$msg"/>
            </xsl:message>
        </xsl:if>
    </xsl:template>
    
</xsl:stylesheet>