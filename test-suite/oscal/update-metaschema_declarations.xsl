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
    
    <xsl:template match="processing-instruction()"/>
    
    <xsl:variable name="metaschema-sources" as="document-node()">
        <xsl:document>
          <xsl:copy-of select="/, /*/import/document(@href)"/>
        </xsl:document>
    </xsl:variable>
    
    <xsl:template match="/">
        <xsl:text>&#xA;</xsl:text>
        <xsl:processing-instruction name="xml-model">href="../../support/lib/metaschema-check.sch" type="application/xml" schematypens="http://purl.oclc.org/dsdl/schematron"</xsl:processing-instruction>
        <xsl:text>&#xA;</xsl:text>
        <xsl:apply-templates/>
    </xsl:template>
    
    <xsl:template match="METASCHEMA/@root"/>
    
    <xsl:template match="define-assembly[@name=parent::METASCHEMA/@root]">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:apply-templates select="formal-name, description"/>
            <root-name>{ @name }</root-name>
            <xsl:apply-templates select="* except (formal-name, description)"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:key name="assembly-definition-for-ref" match="/METASCHEMA/define-assembly" use="@name"/>
    
    <xsl:template match="assembly[exists(flag)]">
        <define-assembly name="{@ref}">
            <xsl:copy-of select="@* except @ref"/>
            <xsl:apply-templates select="key('assembly-definition-for-ref',@ref,$metaschema-sources)/(formal-name | description)"/>
            <xsl:apply-templates select="key('assembly-definition-for-ref',@ref,$metaschema-sources)/(json-key | json-value-key)"/>
            <xsl:apply-templates select="group-as"/>
            <xsl:apply-templates select="flag"/>
            <xsl:apply-templates select="key('assembly-definition-for-ref',@ref,$metaschema-sources)/model"/>
            <xsl:apply-templates select="* except (flag | group-as)"/>
        </define-assembly>
    </xsl:template>
    
    <xsl:template match="field[exists(* except (group-as | use-name | remarks))]">
        <define-field name="{(@name,@ref)[1]}">
            <xsl:copy-of select="@* except @ref"/>
            <xsl:apply-templates/>
        </define-field>
    </xsl:template>
    
    <xsl:template match="flag[exists(* except (use-name | remarks | description))]">
        <define-flag name="{(@name,@ref)[1]}">
            <xsl:copy-of select="@* except @ref"/>
            <xsl:call-template name="flag-requirement"/>
            <xsl:if test="@name = ../(json-key|json-value-key)/@flag-name">
                <xsl:attribute name="required">yes</xsl:attribute>
            </xsl:if>
            <xsl:apply-templates/>
        </define-flag>
    </xsl:template>
    
    <xsl:template match="flag">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:call-template name="flag-requirement"/>
            <xsl:apply-templates/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template name="flag-requirement">
        <xsl:if test="(@name | @ref) = ../(json-key | json-value-key)/@flag-name">
            <xsl:attribute name="required">yes</xsl:attribute>
        </xsl:if>
    </xsl:template>
    <xsl:template match="allowed-values">
        <constraint>
            <allowed-values>
                <xsl:if test="not(parent::flag|parent::define-flag)">
                    <xsl:attribute name="target">.</xsl:attribute>
                </xsl:if>
                <xsl:copy-of select="@*"/>
                <xsl:apply-templates/>
            </allowed-values>
        </constraint>
    </xsl:template>



</xsl:stylesheet>