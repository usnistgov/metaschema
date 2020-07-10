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
    
    <!-- Interface template for override -->
    <xsl:template match="*" mode="make-match" as="xs:string">
        <xsl:apply-templates select="." mode="make-xml-match"/>
    </xsl:template>
    
    <!-- Interface template for override -->
    <xsl:template match="*" mode="make-step" as="xs:string">
        <xsl:apply-templates select="." mode="make-xml-step"/>
    </xsl:template>
    
    <!-- Interface template for override -->
    <xsl:template match="*" mode="make-pull">
        <xsl:apply-templates select="." mode="make-xml-pull"/>
    </xsl:template>
    
    <xsl:template match="/model">
        <XSLT:stylesheet version="3.0"
            exclude-result-prefixes="#all">
            <xsl:call-template name="xpath-namespace"/>
            <xsl:call-template name="make-strip-space"/>
            
            <xsl:call-template name="initial-comment"/>
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
                <!-- These are all the same so we do only one, but we pass in the group to construct the match -->
                <xsl:apply-templates select="current-group()[1]" mode="make-template">
                    <xsl:with-param name="team" tunnel="true" select="current-group()"/>
                </xsl:apply-templates>
            </xsl:for-each-group>

            <!-- next we produce templates for local definitions - a receiving template
                 filters out the globals ... -->
            <xsl:apply-templates select=".//assembly | .//field | .//flag" mode="make-template-for-local"/>

            <!--finally, if needed, a template for copying prose across, stripping ns -->
            <xsl:call-template name="for-this-converter"/>
            
        </XSLT:stylesheet> 
    </xsl:template>
    
    
    <xsl:template name="xpath-namespace">
        <xsl:attribute name="xpath-default-namespace" select="$source-namespace"/>
    </xsl:template>
    
    <xsl:template name="make-strip-space">
        <XSLT:strip-space elements="{distinct-values(//assembly/@gi)}"/>
    </xsl:template>

    <xsl:template name="initial-comment">
        <xsl:comment> METASCHEMA conversion stylesheet supports XML -> METASCHEMA/SUPERMODEL conversion </xsl:comment>
    </xsl:template>

    <xsl:template name="provide-namespace">
        <!-- iff at the top -->
        <xsl:for-each select="parent::model" expand-text="true">
            <!-- likewise the XSLT provides a namespace only if at the top -->
            <XSLT:if test=". is /*">
                <XSLT:attribute name="namespace">{ $source-namespace }</XSLT:attribute>
                <!-- don't need unless we have a requirement to prefix in serialization: <XSLT:attribute name="prefix">{ $source-prefix }</XSLT:attribute>-->
            </XSLT:if>
        </xsl:for-each>
    </xsl:template>
    
    <xsl:template name="for-this-converter">
        <!-- For the XML converter, we need a generic template to cast prose contents into the supermodel namespace -->
        <xsl:if test="exists(//value[@as-type = ('markup-line', 'markup-multiline')])">
            <XSLT:template match="*" mode="cast-prose">
                <XSLT:element name="{{ local-name() }}"
                    namespace="http://csrc.nist.gov/ns/oscal/metaschema/1.0/supermodel">
                    <XSLT:copy-of select="@*"/>
                    <XSLT:apply-templates mode="#current"/>
                </XSLT:element>
            </XSLT:template>
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="*[@scope='global']" mode="make-template-for-local"/>
    
    <xsl:template match="*" mode="make-template-for-local">
        <xsl:apply-templates select="." mode="make-template">
            <xsl:with-param name="local" select="true()"/>
        </xsl:apply-templates>
    </xsl:template>
 
    <!-- no template for implicit wrappers on markup-multiline -->
    <xsl:template priority="2" match="field[empty(@gi)][value/@as-type='markup-multiline']" mode="make-template"/>
        
    <!--Invoke by name when we wish to override mode 'template-for-global' -->
    <xsl:template match="*" mode="make-template" name="make-template">
        <xsl:variable name="matching">
            <xsl:apply-templates select="." mode="make-match"/>
        </xsl:variable>
        <xsl:variable name="json-key-flag-name" select="@json-key-flag"/>
        <XSLT:template match="{ $matching}">
            <xsl:if test="not(@scope='global')">
                <xsl:attribute name="priority" select="10"/>
            </xsl:if>
            <!-- A parameter allows the call to drop the key, necessary for recursive
                groups of elements also allowed at the root (at least) -->
            <XSLT:param name="with-key" select="true()"/>
            <xsl:call-template name="comment-template"/>
            <xsl:element name="{ local-name() }" namespace="http://csrc.nist.gov/ns/oscal/metaschema/1.0/supermodel">
                <xsl:copy-of select="@* except (@key|@scope)"/>
                <!--'SCALAR' marks fields that will be strings or data values, not maps (objects)
                by virtue of not permitting flags other than designated for the JSON key-->
                <xsl:if test="self::field[empty(flag[not(@key=$json-key-flag-name)])]">
                    <xsl:attribute name="in-json">SCALAR</xsl:attribute>
                </xsl:if>
                <xsl:if test="exists(@key)">
                    <XSLT:if test="$with-key">
                        <XSLT:attribute name="key">
                            <xsl:value-of select="@key"/>
                        </XSLT:attribute>
                    </XSLT:if>
                </xsl:if>
                <xsl:call-template name="provide-namespace"/>
                <xsl:apply-templates select="." mode="make-key-flag"/>
                <xsl:apply-templates select="*" mode="make-pull"/>
            </xsl:element>
        </XSLT:template>
        <!--Additionally we need templates for elements defined implicitly as wrappers for given assemblies or fields-->
        <xsl:apply-templates select="parent::group[exists(@gi)]" mode="make-template"/>
    </xsl:template>
    
    <xsl:template match="flag" mode="make-template">
        <xsl:variable name="matching">
            <xsl:apply-templates select="." mode="make-match"/>
        </xsl:variable>
        <XSLT:template match="{ $matching}">
            <xsl:call-template name="comment-template"/>
            <flag in-json="string">
                <xsl:copy-of select="@* except @scope"/>
                <!-- rewriting in-json where necessary -->
                <xsl:apply-templates select="@as-type" mode="assign-json-type"/>
                <XSLT:value-of select="."/>
            </flag>
        </XSLT:template>
    </xsl:template>
    
    <!-- In the XML, even a flag designated as a key is an attribute, so it will be produced without explicit instruction. -->
    <xsl:template match="*" mode="make-key-flag"/>
    
    <xsl:template priority="11" match="flag" mode="make-xml-match">
        <xsl:param name="team" tunnel="true" select="."/>
        <xsl:variable name="team-matches" as="xs:string*">
            <xsl:for-each select="$team">
                <xsl:value-of>
                    <xsl:apply-templates select=".." mode="make-xml-match"/>
                    <xsl:text>/@</xsl:text>
                    <xsl:value-of select="@gi"/>
                </xsl:value-of>
            </xsl:for-each>
        </xsl:variable>
        <xsl:value-of select="distinct-values($team-matches)" separator=" | "/>
    </xsl:template>
    
    <xsl:template priority="11" match="flag" mode="make-xml-step">
        <xsl:value-of select="'@' || @gi"/>
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
            <xsl:apply-templates select="." mode="make-xml-step"/>
        </xsl:for-each>
    </xsl:template>

    <!-- fallback should never match -->
    <xsl:template match="*" mode="make-xml-pull make-json-pull">
        <pull who="{local-name()}">
            <xsl:copy-of select="@gi | @key"/>
        </pull>
    </xsl:template>
    
    <xsl:variable name="prose-elements">p | ul | ol | pre | h1 | h2 | h3 | h4 | h5 | h6 | table</xsl:variable>
    
    <!-- A field without a GI is implicit in the XML; Metaschema prevents it from having flags -->
    <xsl:template priority="2" match="field[empty(@gi)][value/@as-type='markup-multiline']" mode="make-xml-pull">
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
    
    <xsl:template match="flag | field | assembly | group[exists(@gi)]" mode="make-xml-pull">
        <xsl:variable name="path">
            <xsl:apply-templates select="." mode="make-xml-step"/>
        </xsl:variable>
        <XSLT:apply-templates select="{$path}"/>
    </xsl:template>
    
<!-- A group with no @gi does not appear as an element in the XML source, so when
     sourcing from XML, we have to group its children as a group. -->
    <xsl:template match="group" mode="make-xml-pull">
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
    
    <xsl:template match="value" mode="make-xml-pull">
        <value>
            <xsl:copy-of select="@key | @key-flag | @as-type"/>
            <xsl:apply-templates select="@as-type" mode="assign-json-type"/>
            <xsl:apply-templates select="." mode="cast-value"/>
        </value>
    </xsl:template>
    
    <!-- In the JSON representation all values are strings unless mapped otherwise. -->
    <xsl:template match="@as-type" mode="assign-json-type">
        <xsl:attribute name="in-json">string</xsl:attribute>
    </xsl:template>
    
    <xsl:template match="@as-type[.='boolean']" mode="assign-json-type">
        <xsl:attribute name="in-json">boolean</xsl:attribute>
    </xsl:template>
    
    
    <!-- The following assign-json-type logic parallels mode 'xpath-json-type' in metapath-jsonize.xsl
         these could be consolidated -->
    
    <xsl:variable name="integer-types" as="element()*">
        <type>integer</type>
        <type>positiveInteger</type>
        <type>nonNegativeInteger</type>
    </xsl:variable>
    
    <xsl:variable name="numeric-types" as="element()*">
        <type>decimal</type>
    </xsl:variable>
    
    <xsl:template match="@as-type[.=($integer-types,$numeric-types)]" mode="assign-json-type">
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
    
    <!-- stub for override   -->
    <xsl:template name="comment-template"/>
        
    
</xsl:stylesheet>