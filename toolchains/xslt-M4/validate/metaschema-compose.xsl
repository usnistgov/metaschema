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
    
    <xsl:variable name="home" select="/"/>
    <xsl:variable name="xslt-base" select="document('')/document-uri()"/>

    <xsl:import href="metaschema-validation-support.xsl"/>
    
    <xsl:template match="/">
        <xsl:sequence select="nm:compose-metaschema(/)"/>
    </xsl:template>
    
</xsl:stylesheet>