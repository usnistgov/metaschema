<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:math="http://www.w3.org/2005/xpath-functions/math"
    exclude-result-prefixes="xs math"
    version="3.0"
    xpath-default-namespace="http://csrc.nist.gov/ns/oscal/metaschema/1.0">
    
<!-- Provides contents for empty 'formal-name' and 'description'  -->
    <xsl:mode on-no-match="shallow-copy"/>
    
    <xsl:template match="formal-name[not(matches(.,'\S'))]">
        <xsl:copy expand-text="true">{ upper-case(../@name) }</xsl:copy>
    </xsl:template>
    
    <xsl:template match="description[not(matches(.,'\S'))]">
        <xsl:copy expand-text="true">{ replace(name(..),'.*-','') } { ../@name }</xsl:copy>
    </xsl:template>
    
    
</xsl:stylesheet>