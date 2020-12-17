<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:math="http://www.w3.org/2005/xpath-functions/math"
    xmlns:m="http://csrc.nist.gov/ns/oscal/metaschema/1.0"
    xmlns:XSLT="http://csrc.nist.gov/ns/oscal/metaschema/xslt-alias"
    
    xpath-default-namespace="http://csrc.nist.gov/ns/oscal/metaschema/1.0"
    exclude-result-prefixes="xs math"
    version="3.0"
    xmlns="http://csrc.nist.gov/ns/oscal/metaschema/1.0/supermodel">
    
<!-- Purpose: Produce an XSLT for converting JSON valid to a Metaschema model, to its supermodel equivalent. -->
<!-- Input:   A Metaschema definition map -->
<!-- Output:  An XSLT -->

    <!-- Path conversion logic is here -->
    <xsl:import href="../metapath/metapath-jsonize.xsl"/>

    <!-- Most of the logic is the same as the XML converter. -->
    <xsl:import href="produce-xml-converter.xsl"/>
    
    
    <xsl:output indent="yes"/>
    
    <xsl:namespace-alias stylesheet-prefix="XSLT" result-prefix="xsl"/>
    
    <!-- $px is the prefix to be used on names in the XPath JSON -->
    <xsl:param name="px" as="xs:string">j</xsl:param>
    
    <!-- The definition map for tracing path traversals is the source document -->
    <xsl:param name="definition-map" select="/"/>
    
    <!-- Overriding the root template in metapath-jsonize.xsl (which drives testing) -->
    <xsl:template match="/">
            <xsl:apply-templates/>
    </xsl:template>
    
    <xsl:template name="xpath-namespace">
        <!--<xsl:attribute name="xpath-default-namespace">http://www.w3.org/2005/xpath-functions</xsl:attribute>-->
        <xsl:namespace name="{$px}">http://www.w3.org/2005/xpath-functions</xsl:namespace>
    </xsl:template>
    
    <xsl:template name="make-strip-space">
        <XSLT:strip-space elements="{$px}:map {$px}:array"/>
    </xsl:template>
    
    <xsl:template name="initial-comment">
        <xsl:comment> METASCHEMA conversion stylesheet supports JSON -> METASCHEMA/SUPERMODEL conversion </xsl:comment>
    </xsl:template>
    
    <!-- Overriding the imported template for casting prose elements (wrt namespace) since we do not need it -->
    <xsl:template name="cast-prose-template"/>
    
    <!-- Overriding interface template -->
    <xsl:template match="*" mode="make-match" as="xs:string">
        <xsl:variable name="matching-xml">
            <xsl:apply-templates select="." mode="make-xml-match"/>
        </xsl:variable>
        <!--<xsl:try select="m:jsonize-path($matching-xml)">
            <xsl:catch>
                <xsl:message expand-text="true" xmlns:err="http://www.w3.org/2005/xqt-errors">(On { @name }) { $matching-xml }: { $err:description }</xsl:message>
            </xsl:catch>
        </xsl:try>-->
        <xsl:text expand-text="true">{ m:jsonize-path($matching-xml) }</xsl:text>
        <!--<xsl:sequence select="m:jsonize-path($matching-xml)"/>-->
        
    </xsl:template>
    
    <!-- Overriding interface template -->
    <xsl:template match="*" mode="make-step" as="xs:string">
        <xsl:variable name="step-xml">
            <xsl:apply-templates select="." mode="make-xml-step"/>
        </xsl:variable>
        <xsl:sequence select="m:jsonize-path($step-xml)"/>
    </xsl:template>
    
    <!-- Overriding interface template in mode 'make-pull' -->
    <xsl:template match="*" mode="make-pull">
        <xsl:apply-templates select="." mode="make-json-pull"/>
    </xsl:template>
    
    <xsl:template priority="2" match="value" mode="make-json-pull">
        <XSLT:apply-templates select="." mode="get-value-property"/>
    </xsl:template>
    
    <!-- fallback should never match -->
    <xsl:template match="*" mode="make-json-pull">
        <pull who="{local-name()}">
            <xsl:copy-of select="@gi | @key"/>
        </pull>
    </xsl:template>
    
    <xsl:template match="*[matches(@key,'\S')]" mode="make-json-pull">
        <XSLT:apply-templates select="*[@key='{@key}']"/>
    </xsl:template>
    
    <xsl:template match="choice" mode="make-xml-pull make-json-pull">
        <xsl:apply-templates mode="#current"/>
    </xsl:template>
    
    <xsl:template match="constraint" mode="make-json-pull"/>
    
    <xsl:template match="group/*[empty(@key)]" mode="make-json-pull">
        <XSLT:apply-templates select="*"/>
    </xsl:template>

    <!-- overriding template in produce-xml-converter that suppresses template
         production for an element not present in the XML: this time we want the field
         (but must also hard-wire the match). -->
    <xsl:template priority="2" match="field[empty(@gi)][value/@as-type='markup-multiline']" mode="make-template">
        <xsl:variable name="parent-xml-context">
            <xsl:for-each select="ancestor::*[exists(@gi)][1]">
              <xsl:call-template name="make-full-context-match"/>
            </xsl:for-each>
        </xsl:variable>
        <xsl:comment expand-text="true"> matching markup-multiline value for { $parent-xml-context }</xsl:comment>
        <XSLT:template priority="{count(ancestor::*/@gi)}" match="{ m:jsonize-path($parent-xml-context) }/{ $px }:string[@key='{@key}']">
            <field>
                <xsl:copy-of select="@*"/>
                <value>
                    <xsl:copy-of select="value/@*"/>
                    <xsl:apply-templates select="value/@as-type" mode="assign-json-type"/>
                    <XSLT:value-of select="."/>
                </value>
            </field>
        </XSLT:template>
    </xsl:template>
    
    <!-- fields with @gi including markup-line and markup-multiline -->
    <xsl:template match="field" mode="make-template">
        <xsl:call-template name="make-template"/>
        <xsl:variable name="matching">
            <xsl:apply-templates select="." mode="make-match"/>
        </xsl:variable>
        <!-- now producing a template to produce a value node representing the value of the field-->
        <xsl:comment> matching <xsl:apply-templates select="." mode="make-xml-match"/></xsl:comment>
        <XSLT:template match="{ $matching }" mode="get-value-property">
            <!-- make a flag for the value key, when it's dynamic -->
            <xsl:for-each select="flag[@name=../value/@key-flag]">
                <flag>
                    <xsl:copy-of select="@*"/>
                    <XSLT:value-of select="*[not(@key=({ flag/@name ! ('''' || . || '''') => string-join(',') }))]/@key"/>
                </flag>
            </xsl:for-each>
            <!-- and now make a value -->
            <value>
                <xsl:copy-of select="value/(@key | @key-flag | @as-type)"/>
                <xsl:apply-templates select="value/@as-type" mode="assign-json-type"/>
                <!-- traversing to child properties and keeping only the value property -->
                <XSLT:apply-templates mode="keep-value-property"/>
            </value>
        </XSLT:template>
    </xsl:template>
    
    
    <!-- A field with no value key has its own value in the JSON, not on a property -->
    <xsl:template match="field[empty(flag|value/@key)]" mode="make-template">
        <xsl:call-template name="make-template"/>
        <xsl:variable name="matching">
            <xsl:apply-templates select="." mode="make-match"/>
        </xsl:variable>
        <!-- now producing a template to produce a value node representing the value of the field-->
        <XSLT:template match="{ $matching }" mode="get-value-property" priority="{count(ancestor-or-self::*)}">
            <value>
                <xsl:copy-of select="value/(@key | @key-flag | @as-type)"/>
                <xsl:apply-templates select="value/@as-type" mode="assign-json-type"/>
                <XSLT:value-of select="."/>
            </value>
        </XSLT:template>
    </xsl:template>
    
    <!-- A field with a dynamic value key has a value with a @key-flag -->
<!--    In addition to its default template, all flags are provided
        with a filter to suppress it when fields retrieves its value.
    Note that global flags can be on fields or assemblies so we must match
    either (we are matching the first as proxy for all) -->
    <xsl:template match="flag" mode="make-template">
        <xsl:apply-imports/>
        <xsl:variable name="matching">
            <xsl:apply-templates select="." mode="make-match"/>
        </xsl:variable>
        <XSLT:template match="{ $matching}" mode="keep-value-property" priority="{count(ancestor-or-self::*)}">
            <xsl:comment> Not keeping the flag here. </xsl:comment>
        </XSLT:template>
    </xsl:template>
    
    <xsl:template match="*[@json-key-flag=flag/@name]" mode="make-key-flag">
        <xsl:apply-templates select="flag[@name=../@json-key-flag]" mode="make-key-flag"/>
    </xsl:template>
    
    <xsl:template match="flag" mode="make-key-flag">
        <flag>
            <xsl:copy-of select="@*"/>
            <XSLT:value-of select="@key"/>
        </flag>
    </xsl:template>

    <xsl:template name="comment-template">
        <xsl:comment expand-text="true">
            <xsl:text> XML match="</xsl:text>
            <xsl:apply-templates select="." mode="make-xml-match"/>
            <xsl:text>" </xsl:text>
        </xsl:comment>
    </xsl:template>
    
    <xsl:template name="for-this-converter">
        <!-- For the JSON converter, we provide templates (in two modes) to give us field values from the fields; this defaults them. -->
       
        <xsl:comment> by default, fields traverse their properties to find a value </xsl:comment>
        <XSLT:template match="*" mode="get-value-property">
            <XSLT:apply-templates mode="keep-value-property"/>
        </XSLT:template>

        <!-- anything without a better match (a property representing a flag) is kept as a value -->
        <XSLT:template match="*" mode="keep-value-property">
            <XSLT:value-of select="."/>
        </XSLT:template>
        
        
    </xsl:template>
    <!--
    -->
</xsl:stylesheet>