<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:nm="http://csrc.nist.gov/ns/metaschema"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="#all">

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
         - retain nm:ERROR and nm:WARNING messages in results. -->
    
    <xsl:variable name="home" select="/"/>
    <xsl:variable name="xslt-base" select="document('')/document-uri()"/>

    <xsl:import href="lib/metaschema-metaprocess.xsl"/>
    
    <!-- The $transformation-sequence declares transformations to be applied in order. -->
    <xsl:variable name="transformation-sequence">
        
<!-- Collects metaschema modules and renames definitions scoped locally to their modules -->
        <nm:transform version="3.0">compose/metaschema-collect.xsl</nm:transform>
<!-- Removes overwritten definitions (imported but subsequently rewritten) -->
        <nm:transform version="3.0">compose/metaschema-reduce1.xsl</nm:transform>
<!-- Removes unused definitions (not descended from an assembly defined for the root) -->
        <nm:transform version="3.0">compose/metaschema-reduce2.xsl</nm:transform>
<!-- Flattens, normalizes and (to come) expands examples -->
        <nm:transform version="3.0">compose/metaschema-digest.xsl</nm:transform>
        
    </xsl:variable>
    
    <xsl:function name="nm:compose-metaschema">
        <xsl:param name="source" as="document-node()"/>
        <xsl:call-template name="nm:process-pipeline">
            <xsl:with-param name="source" select="$source"/>
            <xsl:with-param name="sequence" select="$transformation-sequence"/>
        </xsl:call-template>
    </xsl:function>
    
</xsl:stylesheet>