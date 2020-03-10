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
        <nm:transform version="3.0">compose/metaschema-reduce1.xsl</nm:transform>
        <nm:transform version="3.0">compose/metaschema-reduce2.xsl</nm:transform>
        <nm:transform version="3.0">compose/metaschema-digest.xsl</nm:transform>
        <nm:transform version="3.0">compose/make-model-map.xsl</nm:transform>
        <nm:transform version="3.0">compose/unfold-model-map.xsl</nm:transform>
        <nm:transform version="3.0">document/xml/element-tree.xsl</nm:transform>
        <nm:transform version="3.0">document/xml/element-map-html.xsl</nm:transform>
    </xsl:variable>
    
</xsl:stylesheet>