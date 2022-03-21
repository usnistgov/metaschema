<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:math="http://www.w3.org/2005/xpath-functions/math"
    xmlns:map="http://www.w3.org/2005/xpath-functions/map"
    xmlns:m="http://csrc.nist.gov/ns/oscal/metaschema/1.0"
    xmlns="http://csrc.nist.gov/ns/oscal/metaschema/1.0"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xpath-default-namespace="http://csrc.nist.gov/ns/oscal/metaschema/1.0"
    exclude-result-prefixes="xs math m xsi" version="3.0">

    <xsl:output indent="yes"/>

    <xsl:strip-space
        elements="METASCHEMA define-flag define-field define-assembly remarks model choice"/>

    <xsl:variable name="show-warnings" as="xs:string">yes</xsl:variable>
    <xsl:variable name="verbose" select="lower-case($show-warnings) = ('yes', 'y', '1', 'true')"/>

    <xsl:key name="global-assembly-definition" match="METASCHEMA/define-assembly" use="@_key-name"/>
    <xsl:key name="global-field-definition"    match="METASCHEMA/define-field"    use="@_key-name"/>
    
    
    <!-- ====== ====== ====== ====== ====== ====== ====== ====== ====== ====== ====== ====== -->
    <!-- Pass Three: filter definitions (2) - keep only top-level definitions that are actually
         called by references in the models descending from assemblies with root-name.
         
         Note that we ignore flag definitions, which can stay,
         since all flag definitions are rewritten into local declarations,
         so all top-level flag definitions will be dropped in any case.
    -->
    
    <xsl:mode on-no-match="shallow-copy"/>

    <xsl:variable name="root-assembly-definitions" select="//METASCHEMA/define-assembly[exists(root-name)]"/>

    <xsl:variable name="reference-counts" as="map(xs:string, xs:integer)">
        <xsl:iterate select="//(m:assembly | m:field | m:flag)">
            <xsl:param name="counts" as="map(xs:string, xs:integer)" select="map{}"/>
            <xsl:on-completion select="$counts"/>
            <xsl:variable name="key" select="(name(.), @_key-ref) => string-join('#')"/>
            <xsl:variable name="new-counts" as="map(xs:string, xs:integer)" select="
                if (map:contains($counts, $key))
                then
                map:put($counts, string($key), $counts($key)+1)
                else
                map:put($counts, string($key), 1)"/>
            <xsl:next-iteration>
                <xsl:with-param name="counts" select="$new-counts"/>
            </xsl:next-iteration>
        </xsl:iterate>
    </xsl:variable>

    <xsl:template match="/METASCHEMA">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:if test="not(@abstract='yes') and empty($root-assembly-definitions)">
                <EXCEPTION problem-type="missing-root">No root found in this metaschema composition.</EXCEPTION>
            </xsl:if>
            <xsl:for-each select="map:keys($reference-counts)">
                <xsl:comment expand-text="true">{ . } = { $reference-counts(.) }</xsl:comment>
                <xsl:text>&#xa;</xsl:text>
            </xsl:for-each>
            
            <xsl:apply-templates/>
            
        </xsl:copy>
    </xsl:template>
    
    <!-- 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 -->    

    <xsl:template match="METASCHEMA[not(@abstract='yes')]/define-assembly[not(exists(m:root-name) or map:contains($reference-counts,string((substring-after(name(.),'define-'), @_key-name) => string-join('#'))))]">
<!--        <xsl:comment>Root Name? <xsl:value-of select="exists(m:root-name)"/></xsl:comment>
        <xsl:comment>Map Key <xsl:value-of select="string((substring-after(name(.),'define-'), @_key-name) => string-join('#'))"/></xsl:comment>
        <xsl:comment>Map Contains? <xsl:value-of select="map:contains($reference-counts,string((substring-after(name(.),'define-'), @_key-ref) => string-join('#')))"/></xsl:comment>
-->
        <xsl:call-template name="warning">
            <!-- since we can detect unused definitions a better way, this can be
                 silenced and/or rendered as a comment -->
            <xsl:with-param name="type">unused-definition</xsl:with-param>
            <xsl:with-param name="msg" expand-text="true">REMOVING unused assembly definition for '{ @name }' from { ancestor::METASCHEMA[1]/@module
                }</xsl:with-param>
        </xsl:call-template>
    </xsl:template>
    
    <xsl:template match="METASCHEMA[not(@abstract='yes')]/define-field[not(map:contains($reference-counts,string((substring-after(name(.),'define-'), @_key-name) => string-join('#'))))]">
        <xsl:call-template name="warning">
            <!-- since we can detect unused definitions a better way, this can be
                 silenced and/or rendered as a comment -->
            <xsl:with-param name="type">unused-definition</xsl:with-param>
            <xsl:with-param name="msg" expand-text="true">REMOVING unused field definition for '{ @name }' from { ancestor::METASCHEMA[1]/@module
                }</xsl:with-param>
        </xsl:call-template>
    </xsl:template>
    
    <xsl:template match="METASCHEMA[not(@abstract='yes')]/define-flag[not(map:contains($reference-counts,string((substring-after(name(.),'define-'), @_key-name) => string-join('#'))))]">
        <xsl:call-template name="warning">
            <!-- since we can detect unused definitions a better way, this can be
                 silenced and/or rendered as a comment -->
            <xsl:with-param name="type">unused-definition</xsl:with-param>
            <xsl:with-param name="msg" expand-text="true">REMOVING unused flag definition for '{ @name }' from { ancestor::METASCHEMA[1]/@module
                }</xsl:with-param>
        </xsl:call-template>
    </xsl:template>
    
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