<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:nm="http://csrc.nist.gov/ns/metaschema"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="#all">
    
    <!-- Entry point traps the root node of the source and passes it down the chain of transformation references -->
    
    <!-- Utility XSLT supporting pipelining. -->
    
    <xsl:param name="trace" as="xs:string">off</xsl:param>
    
    <xsl:variable name="louder" select="$trace = 'on'"/>
    
    <xsl:variable name="transformation-sequence" select="()"/>
    
    <xsl:variable name="xslt-base" select="document('')/document-uri()"/>
    
    <!--<xsl:variable name="transformation-sequence">
        <nm:transform version="3.0">compose/metaschema-collect.xsl</nm:transform>
        <nm:transform version="3.0">compose/metaschema-reduce1.xsl</nm:transform>
        <nm:transform version="3.0">compose/metaschema-reduce2.xsl</nm:transform>
        <nm:transform version="3.0">compose/metaschema-digest.xsl</nm:transform>
    </xsl:variable>-->
    
    <xsl:template match="/" name="nm:process-pipeline">
        <xsl:param name="source"   as="document-node()"  select="/"/>
        <xsl:param name="sequence" as="document-node()?" select="$transformation-sequence"/>
        <!-- Each element inside $transformation-sequence is processed in turn.
             Each represents a stage in processing.
             The result of each processing step is passed to the next step as its input, until no steps are left. -->
        <xsl:call-template name="alert">
            <xsl:with-param name="msg" expand-text="yes"> COMPOSING METASCHEMA { document-uri($source) } </xsl:with-param>
        </xsl:call-template>
        <xsl:iterate select="$sequence/*">
            <xsl:param name="doc" select="$source" as="document-node()"/>
            <xsl:on-completion select="$doc"/>
            <xsl:next-iteration>
                <xsl:with-param name="doc">
                    <xsl:apply-templates mode="nm:execute" select=".">
                        <xsl:with-param name="sourcedoc" select="$doc"/>
                    </xsl:apply-templates>
                </xsl:with-param>
            </xsl:next-iteration>
        </xsl:iterate>
    </xsl:template>

    <!-- for nm:transformation, the semantics are "apply this XSLT" -->
    <xsl:template mode="nm:execute" match="nm:transform">
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
                <xsl:map-entry key="'stylesheet-location'" select="resolve-uri(string($xslt-spec),$xslt-base)"/>
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
    <xsl:template mode="nm:execute" match="*">
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