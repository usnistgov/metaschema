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
    
<!-- Purpose: Produce an XSLT for converting XML valid to a Metaschema model, to its supermodel equivalent. -->
<!-- Input:   A Metaschema definition map -->
<!-- Output:  An XSLT -->

    <xsl:output indent="yes"/>
    
    <xsl:namespace-alias stylesheet-prefix="XSLT" result-prefix="xsl"/>
    
    <xsl:variable name="source-namespace" select="string(/*/@namespace)"/>
    <xsl:variable name="source-prefix"    select="string(/*/@prefix)"/>
    
    <xsl:template match="/model">
        <XSLT:stylesheet version="3.0" xpath-default-namespace="{ $source-namespace }"
            exclude-result-prefixes="#all">

            <XSLT:strip-space elements="{distinct-values(//assembly/@gi)}"/>
            
            <xsl:comment> METASCHEMA conversion stylesheet supports XML -> METASCHEMA/SUPERMODEL conversion </xsl:comment>
            <xsl:text>&#xA;</xsl:text>
            <xsl:comment> 888888888888888888888888888888888888888888888888888888888888888888888888888888888 </xsl:comment>
            <xsl:text>&#xA;</xsl:text>

            <!--<XSLT:character-map name="delimiters">
                <!-\- Rewrites Unicode PUA char E0000 to reverse solidus -\->
                <!-\-<XSLT:output-character character="&#xE0000;" string="\"/>-\->
            </XSLT:character-map>-->

            <!-- first we produce templates for (each) of the global definitions.-->
            <xsl:for-each-group select="//*[@scope = 'global']"
                group-by="string-join((local-name(), @gi), ':')">
                <!-- These are all the same so we do only one -->
                <xsl:apply-templates select="current-group()[1]" mode="make-template"/>
            </xsl:for-each-group>

            <!-- next we produce templates for local definitions -->
            <xsl:apply-templates select=".//assembly | .//field | .//flag" mode="make-template-for-local"/>

            <!--finally, a template for copying prose across, stripping ns -->
            <XSLT:template match="*" mode="cast-prose">
                <XSLT:element name="{{ local-name() }}" namespace="http://csrc.nist.gov/ns/oscal/metaschema/1.0/supermodel">
                    <XSLT:copy-of select="@*"/>
                    <XSLT:apply-templates mode="#current"/>     
                </XSLT:element>
            </XSLT:template>
            
        </XSLT:stylesheet> 
    </xsl:template>
    
    <xsl:template match="*[@scope='global']" mode="make-template-for-local"/>
    
    <xsl:template match="*" mode="make-template-for-local">
        <xsl:apply-templates select="." mode="make-template"/>
    </xsl:template>
 
    <!-- no template for implicit wrappers on markup-multiline -->
    <xsl:template priority="2" match="field[empty(@gi)][value/@as-type='markup-multiline']" mode="make-template"/>
        
    <xsl:template match="*" mode="make-template">
        <xsl:variable name="matching">
            <xsl:apply-templates select="." mode="make-xml-match"/>
        </xsl:variable>
        <xsl:variable name="json-key-flag-name" select="@json-key-flag"/>
        <XSLT:template match="{ $matching}">
            <xsl:element name="{ local-name() }" namespace="http://csrc.nist.gov/ns/oscal/metaschema/1.0/supermodel">
                <xsl:copy-of select="@* except @scope"/>
                <xsl:if test="self::field[empty(flag[not(@key=$json-key-flag-name)])]">
                    <xsl:attribute name="in-json">STRING</xsl:attribute>
                </xsl:if>
                <xsl:for-each select="parent::model" expand-text="true">
                    <XSLT:if test=". is /*">
                        <XSLT:attribute name="namespace">{ $source-namespace }</XSLT:attribute>
                        <!-- don't need unless we have a requirement to prefix in serialization: <XSLT:attribute name="prefix">{ $source-prefix }</XSLT:attribute>-->
                    </XSLT:if>
                </xsl:for-each>
                <xsl:apply-templates select="*" mode="make-pull"/>     
            </xsl:element>
        </XSLT:template>
        <!--Additionally we need templates for elements defined implicitly as wrappers for given assemblies or fields-->
        <xsl:apply-templates select="parent::group[exists(@gi)]" mode="make-template"/>
    </xsl:template>
    
    <xsl:template match="flag" mode="make-template">
        <xsl:variable name="matching">
            <xsl:apply-templates select="." mode="make-xml-match"/>
        </xsl:variable>
        <XSLT:template match="{ $matching}">
            <flag>
                <xsl:copy-of select="@* except @scope"/>
                <XSLT:value-of select="."/>     
            </flag>
        </XSLT:template>
    </xsl:template>
    
    <xsl:template priority="11" match="flag[@scope='global']" mode="make-xml-match make-xml-step">
        <xsl:text>@</xsl:text>
        <xsl:value-of select="@gi"/>
    </xsl:template>
    
    <xsl:template priority="10" match="*[@scope='global'] | group[*/@scope='global']" mode="make-xml-match make-xml-step">
        <xsl:value-of select="@gi"/>
    </xsl:template>
    
    <xsl:template match="*[exists(@gi)]" mode="make-xml-step">
        <xsl:value-of select="@gi"/>
    </xsl:template>
    
    <xsl:template match="*" mode="make-xml-match">
        <xsl:message expand-text="true">fired on { local-name() } '{ @gi }' ... { string-join(ancestor-or-self::*/@gi,'/') }</xsl:message>
        <xsl:for-each select="ancestor-or-self::*[@gi]">
            <xsl:value-of select="if (exists(self::flag)) then '/@' else '/'"/>
            <xsl:apply-templates select="." mode="make-xml-step"/>
        </xsl:for-each>
        <xsl:text>  | BOO </xsl:text>
    </xsl:template>

    <xsl:template match="*" mode="make-pull">
        <pull who="{local-name()}">
            <xsl:copy-of select="@gi | @key"/>
        </pull>
    </xsl:template>
    
    <xsl:variable name="prose-elements">p | ul | ol | pre | h1 | h2 | h3 | h4 | h5 | h6 | table</xsl:variable>
    
    <!-- A field without a GI is implicit in the XML -->
    <xsl:template priority="2" match="field[empty(@gi)][value/@as-type='markup-multiline']" mode="make-pull">
        <XSLT:for-each-group select="{ $prose-elements }" group-by="true()">
            <field>
                <xsl:copy-of select="@gi | @key"/>
                <XSLT:apply-templates select="current-group()" mode="cast-prose"/>
            </field>
        </XSLT:for-each-group>
    </xsl:template>
    
    <xsl:template match="flag" mode="make-pull">
        <XSLT:apply-templates select="@{@gi}"/>
    </xsl:template>
    
    <xsl:template match="field | assembly | group[exists(@gi)]" mode="make-pull">
        <XSLT:apply-templates select="{@gi}"/>
    </xsl:template>
    
    <xsl:template match="group" mode="make-pull">
        <xsl:variable name="json-grouping" select="if (exists(@group-json)) then @group-json else 'SINGLETON_OR_ARRAY'"/>
        <XSLT:for-each-group select="{ */@gi }" group-by="true()">
            <group in-json="{ $json-grouping }">
                <xsl:copy-of select="@key"/>
                <XSLT:apply-templates select="current-group()"/>
            </group>
        </XSLT:for-each-group>
    </xsl:template>
    
    
    <!--<xsl:template match="field | assembly" mode="make-pull">
        <XSLT:for-each select="{@gi}">
            <xsl:element name="{ local-name() }"
                namespace="http://csrc.nist.gov/ns/oscal/metaschema/1.0/supermodel">
                <xsl:copy-of select="@gi | @key"/>
                <xsl:apply-templates mode="#current"/>
            </xsl:element>
        </XSLT:for-each>
    </xsl:template>-->
    
    <xsl:template match="value[@as-type='markup-multiline']" mode="make-pull">
        <XSLT:for-each-group select="{ $prose-elements }" group-by="true()">
            <XSLT:apply-templates select="current-group()" mode="cast-prose"/>
        </XSLT:for-each-group>
    </xsl:template>
    
    <xsl:template match="value" mode="make-pull">
        <value>
            <xsl:copy-of select="@key | @key-flag | @as-type"/>
            <XSLT:value-of select="."/>
        </value>
    </xsl:template>
    
    
</xsl:stylesheet>