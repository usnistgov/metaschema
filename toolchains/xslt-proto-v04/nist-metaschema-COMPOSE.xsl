<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:opr="http://csrc.nist.gov/ns/oscal/profile-resolution"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:math="http://www.w3.org/2005/xpath-functions/math" exclude-result-prefixes="#all"
    xpath-default-namespace="http://csrc.nist.gov/ns/oscal/1.0">

    <!--
        
    An XSLT 3.0 stylesheet using XPath 3.1 functions including transform()
        
    This XSLT orchestrates a sequence of transformations over its input.
    
    -->

    <xsl:output method="xml" indent="yes"/>

    <xsl:strip-space
        elements="catalog group control param guideline select part
        metadata back-matter annotation party person org rlink address resource role responsible-party citation
        profile import merge custom modify include exclude set alter add"/>

    <!-- Turning $trace to 'on' will
         - emit runtime messages with each transformation, and
         - retain opr:ERROR and opr:WARNING messages in results. -->
    
    <xsl:param name="trace" as="xs:string">off</xsl:param>

    <xsl:variable name="louder" select="$trace = 'on'"/>

    <xsl:variable name="home" select="/"/>

    <!-- The $transformation-sequence declares transformations to be applied in order. -->
    <xsl:variable name="transformation-sequence">
        <opr:transform version="3.0">compose/metaschema-collect.xsl</opr:transform>
        <opr:transform version="3.0">compose/metaschema-reduce.xsl</opr:transform>
        <opr:transform version="3.0">compose/metaschema-digest.xsl</opr:transform>
    </xsl:variable>

    <!-- Entry point traps the root node of the source and passes it down the chain of transformation references -->
    <xsl:template match="/" name="metaschema-compose">
        <xsl:param name="source" select="." as="document-node()"/>
        <!-- Each element inside $transformation-sequence is processed in turn.
             Each represents a stage in processing.
             The result of each processing step is passed to the next step as its input, until no steps are left. -->
        <xsl:call-template name="alert">
            <xsl:with-param name="msg" expand-text="yes"> COMPOSING METASCHEMA { document-uri($source) } </xsl:with-param>
        </xsl:call-template>
        <xsl:iterate select="$transformation-sequence/*">
            <xsl:param name="doc" select="$source" as="document-node()"/>
            <xsl:on-completion select="$doc"/>
            <xsl:next-iteration>
                <xsl:with-param name="doc">
                    <xsl:apply-templates mode="opr:execute" select=".">
                        <xsl:with-param name="sourcedoc" select="$doc"/>
                    </xsl:apply-templates>
                </xsl:with-param>
            </xsl:next-iteration>
        </xsl:iterate>
    </xsl:template>

    <!-- for opr:transformation, the semantics are "apply this XSLT" -->
    <xsl:template mode="opr:execute" match="opr:transform">
        <xsl:param name="sourcedoc" as="document-node()"/>
        <xsl:variable name="xslt-spec" select="."/>
        <xsl:variable name="runtime-params" as="map(xs:QName,item()*)">
            <xsl:map>
                <!--<xsl:map-entry key="QName('','profile-origin-uri')" select="document-uri($home)"/>
                <xsl:map-entry key="QName('','path-to-source')"     select="$path-to-source"/>
                <xsl:map-entry key="QName('','uri-stack-in')"       select="($uri-stack, document-uri($home))"/>-->
            </xsl:map>
        </xsl:variable>
        <xsl:variable name="runtime" as="map(xs:string, item())">
            <xsl:map>
                <xsl:map-entry key="'xslt-version'"        select="xs:decimal($xslt-spec/@version)"/>
                <xsl:map-entry key="'stylesheet-location'" select="string($xslt-spec)"/>
                <xsl:map-entry key="'source-node'"         select="$sourcedoc"/>
                <xsl:map-entry key="'stylesheet-params'"   select="$runtime-params"/>
            </xsl:map>
        </xsl:variable>

        <!-- The function returns a map; primary results are under 'output'
             unless a base output URI is given
             https://www.w3.org/TR/xpath-functions-31/#func-transform -->
        <xsl:sequence select="transform($runtime)?output"/>
        <xsl:call-template name="alert">
            <xsl:with-param name="msg" expand-text="true"> ... applied step { count(.|preceding-sibling::*) }: XSLT { $xslt-spec } ... </xsl:with-param>
        </xsl:call-template>
    </xsl:template>


    <!-- Not knowing any better, any other execution step passes through its source. -->
    <xsl:template mode="opr:execute" match="*">
        <xsl:param name="sourcedoc" as="document-node()"/>
        <xsl:call-template name="alert">
            <xsl:with-param name="msg" expand-text="true"> ... applied step { count(.|preceding-sibling::*) }: { name() } ...</xsl:with-param>
        </xsl:call-template>
                <xsl:sequence select="$sourcedoc"/>
    </xsl:template>

    
    <xsl:template name="alert">
        <xsl:param name="msg"/>
        <xsl:if test="$louder">
            <xsl:message>
                <xsl:sequence select="$msg"/>
            </xsl:message>
        </xsl:if>
    </xsl:template>
    
</xsl:stylesheet>