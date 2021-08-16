<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:nm="http://csrc.nist.gov/ns/metaschema"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="#all">

<!-- Purpose: Assemble a logical metaschema instance out of its modules and reconcile definitions -->
<!-- Dependencies: This is a 'shell' XSLT and calls several steps in sequence, each implemented as an XSLT -->
<!-- Input: A valid and correct OSCAL Metaschema instance linked to its modules (also valid and correct) -->
<!-- Output: A single metaschema instance, unifying the definitions from the input modules and annotating with identifiers and pointers  -->
<!-- Note: This XSLT uses the transform() function to execute a series of transformations (referenced out of line) over its input -->

<!-- NIST/ITL Metaschema github.com/usnistgov/metaschema https://pages.nist.gov/metaschema/ -->
    
<!-- Purpose|Dependencies|Input|Output|Note|Limitations|Warning -->

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
        <nm:transform version="3.0">compose/metaschema-collect.xsl</nm:transform>
        <nm:transform version="3.0">compose/metaschema-build-refs.xsl</nm:transform>
        <nm:transform version="3.0">compose/metaschema-trim-extra-modules.xsl</nm:transform>
        <nm:transform version="3.0">compose/metaschema-prune-unused-definitions.xsl</nm:transform>
        <nm:transform version="3.0">compose/metaschema-resolve-use-names.xsl</nm:transform>
        <nm:transform version="3.0">compose/metaschema-resolve-sibling-names.xsl</nm:transform>
        <nm:transform version="3.0">compose/metaschema-digest.xsl</nm:transform>
        <nm:transform version="3.0">compose/annotate-composition.xsl</nm:transform>
    </xsl:variable>
    
    <xsl:function name="nm:compose-metaschema">
        <xsl:param name="source" as="document-node()"/>
        <xsl:call-template name="nm:process-pipeline">
            <xsl:with-param name="source" select="$source"/>
            <xsl:with-param name="sequence" select="$transformation-sequence"/>
        </xsl:call-template>
    </xsl:function>
    
</xsl:stylesheet>