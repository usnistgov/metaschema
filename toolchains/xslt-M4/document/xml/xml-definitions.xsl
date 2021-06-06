<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet  version="3.0"
xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
xmlns:xs="http://www.w3.org/2001/XMLSchema"
xmlns:m="http://csrc.nist.gov/ns/oscal/metaschema/1.0"
xmlns="http://www.w3.org/1999/xhtml"

xpath-default-namespace="http://csrc.nist.gov/ns/oscal/metaschema/1.0"
exclude-result-prefixes="#all">

    <xsl:import href="../common-definitions.xsl"/>
    
    <xsl:param name="xml-definitions-page">xml/definitions</xsl:param>
    <xsl:param name="json-definitions-page">json/definitions</xsl:param>
    
    
    <xsl:template match="METASCHEMA/json-base-uri"/>
    
    <xsl:template name="reference-class">
        <xsl:attribute name="class">xml-definition</xsl:attribute>
    </xsl:template>
    
    <xsl:template mode="definition-title-text" expand-text="true"
        match="model//define-field[@as-type='markup-multiline'][@in-xml='UNWRAPPED']">(unwrapped)</xsl:template>
    
    <xsl:template mode="definition-title-text" expand-text="true"
        match="field[@as-type='markup-multiline'][@in-xml='UNWRAPPED']">
        <xsl:variable name="definition" as="element()">
            <xsl:apply-templates select="." mode="find-definition"/>
        </xsl:variable>
        <xsl:choose>
            <xsl:when test="(.|$definition)/@as-type='markup-multiline' and @in-xml='UNWRAPPED'">(unwrapped)</xsl:when>
            <xsl:otherwise>
                <xsl:next-match/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="define-assembly | define-field" mode="model">
        <xsl:variable name="metaschema-type" select="replace(name(),'^define\-','')"/>
        <xsl:for-each-group select="flag | define-flag" group-by="true()" expand-text="true">
            <details open="open">
                <summary>{ if (count(current-group()) ne 1) then 'Attributes' else 'Attribute' } ({ count(current-group()) }):</summary>
                
                <div class="model { $metaschema-type }-model">
                    <xsl:apply-templates select="current-group()" mode="model-view"/>
                </div>
            </details>
        </xsl:for-each-group>
        <xsl:for-each-group select="model/*" group-by="true()" expand-text="true">
            <details open="open">
                <summary>Elements ({ count(current-group()) }):</summary>
                <div class="model { $metaschema-type }-model">
                    <xsl:apply-templates select="current-group()" mode="model-view"/>
                </div>
            </details>
        </xsl:for-each-group>
    </xsl:template>
    
    
    <xsl:template name="mark-id">
        <xsl:attribute name="id" select="@_metaschema-xml-id"/>
    </xsl:template>
    
    <!-- writes '../' times the number of steps in $outline-page  -->
    <xsl:variable name="path-to-common">
        <xsl:for-each select="tokenize($xml-definitions-page,'/')">../</xsl:for-each>
    </xsl:variable>
    <xsl:variable name="json-definitions-link" select="$path-to-common || $json-definitions-page"/>
    
    <!-- JSON values dropped in default traversal for XML docs   -->
    <xsl:template match="json-value-key | json-key"/>
    
    <xsl:template match="group-as" expand-text="true">
        <xsl:if test="@in-xml='GROUPED'">
            <p><span class="usa-tag">wrapper element</span>&#xA0;<code class="name">{ @name }</code></p>
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="assembly" mode="link-to-definition">
        <xsl:variable name="definition" select="key('assembly-definition-by-name',@_key-ref)"/>
        <p class="definition-link">
            <a href="#{$definition/@_metaschema-xml-id}">See definition</a>
        </p>
    </xsl:template>
    
    <xsl:template match="field" mode="link-to-definition">
        <xsl:variable name="definition" select="key('field-definition-by-name',@_key-ref)"/>
        <p class="definition-link">
            <a href="#{$definition/@_metaschema-xml-id}">See definition</a>
        </p>
    </xsl:template>
    
    <xsl:template match="flag" mode="link-to-definition">
        <xsl:variable name="definition" select="key('flag-definition-by-name',@_key-ref)"/>
        <p class="definition-link">
            <a href="#{$definition/@_metaschema-xml-id}">See definition</a>
        </p>
    </xsl:template>
    
    <xsl:template name="remarks-group">
        <xsl:param name="these-remarks" select="child::remarks"/>
        <xsl:for-each-group select="$these-remarks[not(contains-token(@class,'json'))]" group-by="true()">
            <div class="remarks-group usa-prose">
                <details open="open">
                    <summary class="subhead">Remarks</summary>
                    <xsl:apply-templates select="current-group()" mode="produce"/>
                </details>
            </div>
        </xsl:for-each-group>
    </xsl:template>
    
    <!-- Crosslink heads to JSON page -->
    <xsl:template name="crosslink">
        <div class="crosslink">
            <a class="usa-button" href="{$json-definitions-link}#{@_metaschema-json-id}">Switch to JSON</a>
        </div>
    </xsl:template>

    <xsl:template mode="metaschema-type" match="define-assembly">
        <xsl:text expand-text="true">assembly</xsl:text><br class="br" />
        <xsl:text> </xsl:text>
    </xsl:template>
    
    <xsl:template mode="metaschema-type" match="assembly | field | flag">
        <xsl:variable name="definition" as="element()">
            <xsl:apply-templates select="." mode="find-definition"/>
        </xsl:variable>
        <xsl:apply-templates select="$definition" mode="metaschema-type"/>
        <br class="br"/>
        <xsl:if test="exists($definition)">
            <xsl:text> </xsl:text>
            <a class="definition-link" href="#{ @_metaschema-xml-id }">(global definition)</a>
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="*" mode="report-context" expand-text="true">
        <xsl:for-each select="@target[matches(.,'\S')][not(.=('.','value()')) ]">
            <xsl:text> for </xsl:text>
            <code class="path">{ . }</code>
        </xsl:for-each>
    </xsl:template>
    
</xsl:stylesheet>