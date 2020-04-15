<?xml version="1.0" encoding="UTF-8"?>
<schema xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
        xmlns:m="http://csrc.nist.gov/ns/oscal/metaschema/1.0"
        xmlns:sch="http://purl.oclc.org/dsdl/schematron"
        xmlns="http://purl.oclc.org/dsdl/schematron"
        queryBinding="xslt2">
   <ns prefix="m" uri="http://csrc.nist.gov/ns/oscal/metaschema/1.0"/>
   <ns prefix="anthology" uri="http://csrc.nist.gov/metaschema/ns/anthology"/>
   <!-- INDEX DEFINITIONS AS KEY DECLARATIONS -->
   <xsl:key name="creators-index"
            match="anthology:author-index/anthology:author"
            use="@id"/>
   <!-- RULES : CONTEXT DEPTH : 1-->
   <pattern id="match-depth-1">
      <rule context="anthology:verse"><!-- when ancestor::anthology:verse/@type='quatrain' and exists(self::anthology:line), anthology:line has cardinality:  at least 4  at most 4-->
         <assert test="not(@type='quatrain') or count(anthology:line) eq 4">Where @type='quatrain', <name/> is expected to have exactly 4 occurrences of anthology:line</assert>
      </rule>
      <rule context="@feet"><!-- should match regex '^[1-9]'-->
         <assert test="matches(., '^^[1-9]$')">
            <name/> is expected to match regular expression '^^[1-9]$'
            </assert>
      </rule>
      <rule context="anthology:dates"><!--expect on : @birth < @death-->
         <assert test="exists(self::node()[@birth &lt; @death])" id="chronology-check">
            <name/> fails to pass evaluation of '@birth &lt; @death'
            [[See id#chronology-check]]</assert>
      </rule>
   </pattern>
   <!-- RULES : CONTEXT DEPTH : 2-->
   <pattern id="match-depth-2">
      <rule context="anthology:meta/@type"><!-- when exists(.), allowed-values on @type: YYYY-->
         <assert test="not(exists(.)) or ( . = ( 'YYYY' ) )"
                 id="meta-rules_1_allowed-values">Where exists(.), <name/> is expected to be (one of) 'YYYY', not '<value-of select="."/>'
            [[See constraint#meta-rules]]</assert>
      </rule>
      <rule context="anthology:meta/@date"><!-- when ancestor::anthology:meta/@type='YYYY' and exists(.), @date should match regex '^[1-9]\d?\d?\d?$'-->
         <assert test="not(ancestor::anthology:meta/@type='YYYY' and exists(.)) or matches(., '^^[1-9]\d?\d?\d?$$')"
                 id="meta-rules_1_regex">Where ancestor::anthology:meta/@type='YYYY' and exists(.), <name/> is expected to match regular expression '^^[1-9]\d?\d?\d?$$'
            [[See constraint#meta-rules]]</assert>
      </rule>
      <rule context="anthology:creator/@role"><!--allowed-values on : author, editor, translator-->
         <assert test="( . = ( 'author', 'editor', 'translator' ) )">
            <name/> is expected to be (one of) 'author', 'editor', 'translator', not '<value-of select="."/>'
            </assert>
      </rule>
      <rule context="anthology:dates/@birth"><!-- when exists(.), @birth should take the form of datatype 'date'-->
         <assert test="not(exists(.)) or m:datatype-validate(., 'date')">Where exists(.), <name/> is expected to take the form of datatype date'
            </assert>
      </rule>
   </pattern>
   <!-- RULES : CONTEXT DEPTH : 4-->
   <pattern id="match-depth-4">
      <rule context="anthology:ANTHOLOGY//anthology:meta/anthology:creator"><!-- when exists(self::anthology:creator[matches(@who,'\S')]/ancestor::anthology:meta), .//anthology:meta/anthology:creator[matches(@who,'\S')] must correspond to an entry in the 'creators-index' index within the context of its ancestoranthology:ANTHOLOGY-->
         <let name="lookup"
              value="@who[matches(.,'^#(\S+)$')] ! replace(.,'^#(\S+)$','$1')"/>
         <assert test="not(exists(self::anthology:creator[matches(@who,'\S')]/ancestor::anthology:meta)) or exists(key('creators-index',$lookup,ancestor::anthology:ANTHOLOGY))"
                 id="ref-creators-index">Where exists(self::anthology:creator[matches(@who,'\S')]/ancestor::anthology:meta), <name/> is expected to correspond to an entry in the 'creators-index' index within the containing anthology:ANTHOLOGY[[See id#ref-creators-index]]</assert>
      </rule>
   </pattern>
   <!-- RULES : CONTEXT DEPTH : 5-->
   <pattern id="match-depth-5">
      <rule context="anthology:ANTHOLOGY//anthology:meta/anthology:creator/@who"><!-- when exists(./ancestor::anthology:creator/ancestor::anthology:meta), .//anthology:meta/anthology:creator/@who should match regex '#(\S+)'-->
         <assert test="not(exists(./ancestor::anthology:creator/ancestor::anthology:meta)) or matches(., '^#(\S+)$')">Where exists(./ancestor::anthology:creator/ancestor::anthology:meta), <name/> is expected to match regular expression '^#(\S+)$'
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
