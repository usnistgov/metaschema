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
            <xsl:comment> ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ </xsl:comment>
            <xsl:text>&#xA;</xsl:text>
            <xsl:comment expand-text="true"> METASCHEMA: { schema-name}{ schema-version ! (' (version ' || . || ')' ) } in namespace "{ $source-namespace }"</xsl:comment>
            <xsl:text>&#xA;</xsl:text>

            <!--<XSLT:character-map name="delimiters">
                <!-\- Rewrites Unicode PUA char E0000 to reverse solidus -\->
                <!-\-<XSLT:output-character character="&#xE0000;" string="\"/>-\->
            </XSLT:character-map>-->

            <!-- first we produce templates for (each) of the global definitions.-->
            <xsl:for-each-group select="//*[@scope = 'global'][not(@recursive='true')]"
                group-by="string-join((local-name(), @name), ':')">
                <!-- These are all the same so we do only one -->
                <xsl:apply-templates select="current-group()[1]" mode="make-template">
                    <xsl:with-param name="ilk" select="current-group()"/>
                </xsl:apply-templates>
            </xsl:for-each-group>

            <!-- next we produce templates for local definitions -->
            <xsl:apply-templates select=".//assembly | .//field | .//flag" mode="make-template-for-local"/>

            <!--finally, if needed, a template for copying prose across, stripping ns -->
            <xsl:if test="exists(//value[@as-type=('markup-line','markup-multiline')])">
            <XSLT:template match="*" mode="cast-prose">
                <XSLT:element name="{{ local-name() }}" namespace="http://csrc.nist.gov/ns/oscal/metaschema/1.0/supermodel">
                    <XSLT:copy-of select="@*"/>
                    <XSLT:apply-templates mode="#current"/>     
                </XSLT:element>
            </XSLT:template>
            </xsl:if>
            
        </XSLT:stylesheet> 
    </xsl:template>
    
    <xsl:template match="*[@scope='global']" mode="make-template-for-local"/>
    
    <xsl:template match="*" mode="make-template-for-local">
        <xsl:apply-templates select="." mode="make-template"/>
    </xsl:template>
 
    <!-- no template for implicit wrappers on markup-multiline -->
    <xsl:template priority="2" match="field[empty(@gi)][value/@as-type='markup-multiline']" mode="make-template"/>
        
    <xsl:template match="*" mode="make-template">
        <!-- $ilk keeps all the declarations with this name -->
        <xsl:param name="ilk" as="element()+"/>
        <xsl:variable name="matching">
            <xsl:apply-templates select="." mode="make-xml-match"/>
        </xsl:variable>
        <xsl:variable name="json-key-flag-name" select="@json-key-flag"/>
        <XSLT:template match="{ $matching}">
            <XSLT:param name="with-key" select="true()"/>
            <xsl:element name="{ local-name() }" namespace="http://csrc.nist.gov/ns/oscal/metaschema/1.0/supermodel">
                <xsl:copy-of select="@* except (@key|@scope)"/>
                <!--'SCALAR' marks fields that will be strings or data values, not maps (objects)
                by virtue of not permitting flags other than designated for the JSON key-->
                <xsl:if test="self::field[empty(flag[not(@key=$json-key-flag-name)])]">
                    <xsl:attribute name="in-json">SCALAR</xsl:attribute>
                </xsl:if>
                <XSLT:if test="$with-key">
                    <XSLT:attribute name="key">
                        <xsl:value-of select="@key"/>
                    </XSLT:attribute>
                </XSLT:if>
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
    
<!-- Matches local declarations (only) -->
    <xsl:template match="*" mode="make-xml-match">
        
        <xsl:for-each select="ancestor-or-self::*[@gi] except ancestor-or-self::*[@scope='global']/ancestor::*">
            <xsl:if test="position() gt 1">/</xsl:if>
            <xsl:value-of select="self::flag/'@'"/>
            <xsl:apply-templates select="." mode="make-xml-step"/>
        </xsl:for-each>
    </xsl:template>

    <xsl:template match="*" mode="make-pull">
        <pull who="{local-name()}">
            <xsl:copy-of select="@gi | @key"/>
        </pull>
    </xsl:template>
    
    <xsl:variable name="prose-elements">p | ul | ol | pre | h1 | h2 | h3 | h4 | h5 | h6 | table</xsl:variable>
    
    <!-- A field without a GI is implicit in the XML; Metaschema prevents it from having flags -->
    <xsl:template priority="2" match="field[empty(@gi)][value/@as-type='markup-multiline']" mode="make-pull">
        <XSLT:for-each-group select="{ $prose-elements }" group-by="true()">
            <field in-json="SCALAR">
                <xsl:copy-of select="@* except @scope"/>
                <value in-json="string">
                    <xsl:copy-of select="value/@*"/>
                    <XSLT:apply-templates select="current-group()" mode="cast-prose"/>
                </value>
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
                <XSLT:apply-templates select="current-group()">
                    <!-- defending against an inadvertant JSON key directive -->
                    <XSLT:with-param name="with-key" select="false()"/>
                </XSLT:apply-templates>
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
    
    <xsl:template match="value" mode="make-pull">
        <value>
            <xsl:copy-of select="@key | @key-flag | @as-type"/>
            <xsl:apply-templates select="@as-type" mode="json-type"/>
            <xsl:apply-templates select="." mode="cast-value"/>
        </value>
    </xsl:template>
    
    <!-- In the JSON representation all values are strings unless mapped otherwise. -->
    <xsl:template match="@as-type" mode="json-type">
        <xsl:attribute name="in-json">string</xsl:attribute>
    </xsl:template>
    
    <xsl:template match="@as-type[.='boolean']" mode="json-type">
        <xsl:attribute name="in-json">boolean</xsl:attribute>
    </xsl:template>
    
    <xsl:variable name="integer-types" as="element()*">
        <type>integer</type>
        <type>positiveInteger</type>
        <type>nonNegativeInteger</type>
    </xsl:variable>
    
    <xsl:template match="@as-type[.=$integer-types]" mode="json-type">
        <xsl:attribute name="in-json">number</xsl:attribute>
    </xsl:template>
    
    <xsl:variable name="numeric-types" as="element()*">
        <type>decimal</type>
    </xsl:variable>
    
    <xsl:template match="@as-type[.=$numeric-types]" mode="json-type">
        <xsl:attribute name="in-json">number</xsl:attribute>
    </xsl:template>
    
    <xsl:template match="value[@as-type='markup-line']" mode="cast-value">
        <XSLT:apply-templates mode="cast-prose"/>
    </xsl:template>
    
    <xsl:template match="value[@as-type='markup-multiline']" mode="cast-value">
        <XSLT:for-each-group select="{ $prose-elements }" group-by="true()">
            <XSLT:apply-templates select="current-group()" mode="cast-prose"/>
        </XSLT:for-each-group>
    </xsl:template>
    
    <xsl:template match="value" mode="cast-value">
        <XSLT:value-of select="."/>
    </xsl:template>
    
    
</xsl:stylesheet>