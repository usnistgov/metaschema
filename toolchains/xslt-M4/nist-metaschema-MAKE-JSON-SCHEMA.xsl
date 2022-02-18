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
    
    <xsl:output method="text" indent="yes" use-character-maps="json-escaping"/>

    
    <!-- Turning $trace to 'on' will
         - emit runtime messages with each transformation, and
         - retain nm:ERROR and nm:WARNING messages in results. -->
    
    <xsl:param name="trace" as="xs:string">off</xsl:param>
    <xsl:variable name="louder" select="$trace = 'on'"/>

    <xsl:variable name="xslt-base" select="document('')/document-uri()"/>
    
    <xsl:import href="nist-metaschema-metaprocess.xsl"/>
    
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
        <nm:transform version="3.0">util/xpath-json-to-json.xsl</nm:transform>
    </xsl:variable>
    
    <xsl:character-map name="json-escaping">
        <xsl:output-character character="&#x00C0;" string="\u00C0"/>
        <xsl:output-character character="&#x00D6;" string="\u00D6"/>
        <xsl:output-character character="&#x00D8;" string="\u00D8"/>
        <xsl:output-character character="&#x00F6;" string="\u00F6"/>
        <xsl:output-character character="&#x00F8;" string="\u00F8"/>
        <xsl:output-character character="&#x02FF;" string="\u02FF"/>
        <xsl:output-character character="&#x0370;" string="\u0370"/>
        <xsl:output-character character="&#x037D;" string="\u037D"/>
        <xsl:output-character character="&#x037F;" string="\u037F"/>
        <xsl:output-character character="&#x1FFF;" string="\u1FFF"/>
        <xsl:output-character character="&#x200C;" string="\u200C"/>
        <xsl:output-character character="&#x200D;" string="\u200D"/>
        <xsl:output-character character="&#x2070;" string="\u2070"/>
        <xsl:output-character character="&#x218F;" string="\u218F"/>
        <xsl:output-character character="&#x2C00;" string="\u2C00"/>
        <xsl:output-character character="&#x2FEF;" string="\u2FEF"/>
        <xsl:output-character character="&#x3001;" string="\u3001"/>
        <xsl:output-character character="&#xD7FF;" string="\uD7FF"/>
        <xsl:output-character character="&#xF900;" string="\uF900"/>
        <xsl:output-character character="&#xFDCF;" string="\uFDCF"/>
        <xsl:output-character character="&#xFDF0;" string="\uFDF0"/>
        <xsl:output-character character="&#xFFFD;" string="\uFFFD"/>
        <xsl:output-character character="&#x00B7;" string="\u00B7"/>
        <xsl:output-character character="&#x0300;" string="\u0300"/>
        <xsl:output-character character="&#x036F;" string="\u036F"/>
        <xsl:output-character character="&#x203F;" string="\u203F"/>
        <xsl:output-character character="&#x2040;" string="\u2040"/>
    </xsl:character-map>
    
    
    
</xsl:stylesheet>