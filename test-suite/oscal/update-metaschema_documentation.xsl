<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    exclude-result-prefixes="xs"
    version="3.0"
    expand-text="true"
    xmlns="http://csrc.nist.gov/ns/oscal/metaschema/1.0"
    xpath-default-namespace="http://csrc.nist.gov/ns/oscal/metaschema/1.0">
    
    <xsl:output indent="yes"/>
    
    <xsl:strip-space elements="*"/>
    
    <xsl:preserve-space elements="schema-name schema-version short-name namespace formal-name description root-name p enum code json-value-key a"/>
    
    <xsl:mode on-no-match="shallow-copy"/>
    
    <xsl:template match="define-assembly | define-field | define-flag">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:if test="empty(formal-name)">
                <formal-name>{ (root-name,use-name,@name)[1] } { local-name(.) =>
                    substring-after('define-') }</formal-name>
            </xsl:if>
            <xsl:if test="empty(description)">
                <description>{ (root-name,use-name,@name)[1] } { local-name(.) =>
                    substring-after('define-') } ... </description>
            </xsl:if>

            <xsl:variable name="head" select="formal-name, description, json-key, json-value-key, group-as"/>
            <xsl:variable name="tail" select="remarks, example"/>
            
            <xsl:apply-templates select="$head"/>
            <xsl:apply-templates select="* except ($head | $tail)"/>
            <xsl:apply-templates select="$tail"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="assembly | field | flag">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:apply-templates/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="remarks[not(matches(.,'\w'))] | description[not(matches(.,'\w'))]"/>
    
    
    <xsl:template match="assembly/description | field/description | flag/description">
       <remarks>
           <p>
               <xsl:apply-templates/>
           </p>
       </remarks>
    </xsl:template>
    
<!-- Patches too   -->
    <!--<define-field name="base64" as-type="base64Binary">
        <formal-name>Base64</formal-name>
        <description/>-->
    <!--In metadata metaschema-->
    <xsl:template priority="2" match="define-field[@name='base64']/description">
        <description>The Base64 alphabet in RFC 2045 - aligned with XSD.</description>
    </xsl:template>
</xsl:stylesheet>