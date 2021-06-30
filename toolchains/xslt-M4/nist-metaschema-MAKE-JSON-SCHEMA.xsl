<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:nm="http://csrc.nist.gov/ns/metaschema"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="#all">

    <!-- Purpose: Produce a JSON Schema reflecting constraints defined in a metaschema -->
    <!-- Dependencies: This is a 'shell' XSLT and calls several steps in sequence, each implemented as an XSLT -->
    <!-- Input: A top-level metaschema; this XSLT also composes metaschema input so composition is not necessary -->
    <!-- Output: A JSON Schema (v7) describing a JSON format consistent with definitions given in the input metaschema -->
    <!-- Note: This XSLT uses the transform() function to execute a series of transformations (referenced out of line) over its input -->
    
    <xsl:output method="text" indent="yes"/>

    <!-- Turning $trace to 'on' will
         - emit runtime messages with each transformation, and
         - retain nm:ERROR and nm:WARNING messages in results. -->
    
    <xsl:param name="trace" as="xs:string">off</xsl:param>
    <xsl:variable name="louder" select="$trace = 'on'"/>

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
        
        <nm:transform version="3.0">schema-gen/make-json-schema-metamap.xsl</nm:transform>
        <nm:transform version="3.0">lib/xpath-json-to-json.xsl</nm:transform>
    </xsl:variable>
    
</xsl:stylesheet>