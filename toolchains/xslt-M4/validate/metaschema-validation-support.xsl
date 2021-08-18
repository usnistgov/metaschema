<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:nm="http://csrc.nist.gov/ns/metaschema"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xpath-default-namespace="http://csrc.nist.gov/ns/oscal/metaschema/1.0"
    exclude-result-prefixes="#all">

    <!--
    This XSLT provides a functional interface to OSCAL Metaschema composition.
    
    For a Metaschema, nm:compose-metaschema($metaschema) returns its composed form.
    
    TBD: More aggressive exception handling. For example, errors for broken links in Metaschema import.
    
    Logic replicates ../nist-metaschema-COMPOSE.xsl. 
    
    -->

    <xsl:variable name="home" select="/"/>
    <xsl:variable name="xslt-base" select="document('')/document-uri()"/>

    <xsl:import href="../metaschema-metaprocess.xsl"/>
    
    <!-- The $transformation-sequence declares transformations to be applied in order. -->
    <xsl:variable name="transformation-sequence">
        <nm:transform version="3.0">../compose/metaschema-collect.xsl</nm:transform>
        <nm:transform version="3.0">../compose/metaschema-build-refs.xsl</nm:transform>
        <nm:transform version="3.0">../compose/metaschema-trim-extra-modules.xsl</nm:transform>
        <nm:transform version="3.0">../compose/metaschema-prune-unused-definitions.xsl</nm:transform>
        <nm:transform version="3.0">../compose/metaschema-resolve-use-names.xsl</nm:transform>
        <nm:transform version="3.0">../compose/metaschema-resolve-sibling-names.xsl</nm:transform>
        <nm:transform version="3.0">../compose/metaschema-digest.xsl</nm:transform>
    </xsl:variable>
    
    <xsl:function name="nm:compose-metaschema" as="document-node()?">
        <xsl:param name="doc" as="document-node()?"/>
        <xsl:choose>
            <xsl:when test="empty($doc/*[2]) and ($doc/*[1] is $doc/METASCHEMA[1])">
                <xsl:call-template name="nm:process-pipeline">
                    <xsl:with-param name="source"   select="$doc"/>
                    <xsl:with-param name="sequence" select="$transformation-sequence"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise expand-text="true">
                <xsl:document>
                    <ERROR>Cannot compose a document as a METASCHEMA. The document element is "{ $doc/*[1]/name() }" in namespace "{ $doc/*[1]/namespace-uri() }"</ERROR>
                </xsl:document>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>

    <xsl:template match="/">
        <xsl:sequence select="nm:compose-metaschema(/)"/>
    </xsl:template>
    
</xsl:stylesheet>