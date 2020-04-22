<?xml version="1.0" encoding="UTF-8"?>
<schema xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
        xmlns:m="http://csrc.nist.gov/ns/oscal/metaschema/1.0"
        xmlns:sch="http://purl.oclc.org/dsdl/schematron"
        xmlns="http://purl.oclc.org/dsdl/schematron"
        queryBinding="xslt2">
   <ns prefix="m" uri="http://csrc.nist.gov/ns/oscal/metaschema/1.0"/>
   <ns prefix="anthology" uri="http://csrc.nist.gov/metaschema/ns/test"/>
   <!-- RULES : CONTEXT DEPTH : 1-->
   <pattern id="match-depth-1">
      <rule context="anthology:dates"><!--expect on : xs:date(@birth) < xs:date(@death)-->
         <assert test="exists(self::node()[xs:date(@birth) &lt; xs:date(@death)])"
                 id="chronology-check">
            <name/> fails to pass evaluation of 'xs:date(@birth) &lt; xs:date(@death)'
            [[See id#chronology-check]]</assert>
      </rule>
   </pattern>
   <!-- RULES : CONTEXT DEPTH : 2-->
   <pattern id="match-depth-2">
      <rule context="anthology:dates/@birth"><!-- when exists(.), @birth should take the form of datatype 'date'-->
         <assert test="not(exists(.)) or m:datatype-validate(., 'date')">Where exists(.), <name/> is expected to take the form of datatype date'
            </assert>
      </rule>
   </pattern>
   <!-- LEXICAL / DATATYPE VALIDATION FUNCTIONS -->
   <xsl:function name="m:datatype-validate" as="xs:boolean">
      <xsl:param name="value" as="item()"/>
      <xsl:param name="nominal-type" as="item()?"/>
      <xsl:variable name="test-type" as="xs:string">
         <xsl:choose>
            <xsl:when test="empty($nominal-type)">string</xsl:when>
            <xsl:when test="$nominal-type = ('IDREFS', 'NMTOKENS')">string</xsl:when>
            <xsl:when test="$nominal-type = ('ID', 'IDREF')">NCName</xsl:when>
            <xsl:otherwise expand-text="yes">{ $nominal-type }</xsl:otherwise>
         </xsl:choose>
      </xsl:variable>
      <xsl:variable name="proxy" as="element()">
         <xsl:element namespace="http://csrc.nist.gov/ns/oscal/metaschema/1.0"
                      name="{$test-type}"
                      expand-text="true">{$value}</xsl:element>
      </xsl:variable>
      <xsl:apply-templates select="$proxy" mode="m:validate-type"/>
   </xsl:function>
   <xsl:template match="m:date" mode="m:validate-type" as="xs:boolean">
      <xsl:sequence select=". castable as xs:date"/>
   </xsl:template>
</schema>
