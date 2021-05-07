<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:math="http://www.w3.org/2005/xpath-functions/math"
    xmlns="http://csrc.nist.gov/ns/oscal/metaschema/1.0"
    xpath-default-namespace="http://csrc.nist.gov/ns/oscal/metaschema/1.0"
    xmlns:html="http://www.w3.org/1999/xhtml"
    
    exclude-result-prefixes="#all"
    version="3.0">
    
    <xsl:mode on-no-match="shallow-copy"/>
    
    <!-- Moved up to new 'group' parent -->
    <xsl:template match="@group-json | @group-xml | @group-name"/>
    
    <!-- Removing from objects not to be keyed -->
    <xsl:template match="*[exists(@group-name)][@group-json='ARRAY']/@key"/>
    
    <xsl:template priority="10" match="*[exists(@group-name)]">
        <group in-xml="{ if (@group-xml='GROUPED') then 'SHOWN' else 'HIDDEN' }"
            max-occurs="1" min-occurs="{ if (@min-occurs='0') then '0' else '1'}">
            <xsl:if test="@group-xml='GROUPED'">
                <xsl:attribute name="gi" select="@group-name"/>
                <!--<xsl:attribute name="_step" select="tokenize(@_step,'/')[1]"/>-->
            </xsl:if>
            <xsl:copy-of select="@json-key-flag | @group-json | @recursive"/>
            <xsl:copy-of select="@scope | @name"/>
            <xsl:copy-of select="@_caller-xml-id | @_caller-json-id | @_def-xml-id | @_def-json-id"/>
            <xsl:copy-of select="@_base-uri | @_key-name | @_key-ref"/>
            <!--<xsl:apply-templates select="@* except (@max-occurs|@min-occurs|@key)"/>-->
            <xsl:attribute name="key" expand-text="true">{@group-name}</xsl:attribute>
            
            <xsl:next-match/>
        </group>
    </xsl:template> 
   
    <xsl:template match="*" mode="step-name"/>

    <xsl:template as="xs:string" match="*[exists(@_using-root-name|@_using-name|@name)]" mode="step-name">
        <xsl:value-of select="(@_using-root-name,@_using-name,@name)[1]"/>
    </xsl:template>

</xsl:stylesheet>