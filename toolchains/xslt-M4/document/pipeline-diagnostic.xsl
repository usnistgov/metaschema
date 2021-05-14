<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:math="http://www.w3.org/2005/xpath-functions/math"
    exclude-result-prefixes="xs math"
    version="3.0">
    
    <xsl:param name="test1" required="true"/>
    
    <xsl:param name="test2" required="true"/>
    
    <xsl:template match="/" expand-text="true">
        <DIAGNOSTIC base-uri="{ base-uri(.) }">
            <test1>{ $test1 }</test1>
            <test2>{ $test2 } </test2>
        </DIAGNOSTIC>
    </xsl:template>
</xsl:stylesheet>