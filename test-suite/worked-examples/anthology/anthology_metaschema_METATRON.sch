<?xml version="1.0" encoding="UTF-8"?>
<schema xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
        xmlns:m="http://csrc.nist.gov/ns/oscal/metaschema/1.0"
        xmlns:sch="http://purl.oclc.org/dsdl/schematron"
        xmlns="http://purl.oclc.org/dsdl/schematron"
        queryBinding="xslt2">
   <ns prefix="m" uri="http://csrc.nist.gov/ns/oscal/metaschema/1.0"/>
   <ns prefix="ανθ" uri="http://csrc.nist.gov/metaschema/ns/anthology"/>
   <let name="silence-warnings" value="true()"/>
   <!-- INDEX DEFINITIONS AS KEY DECLARATIONS -->
   <xsl:key name="distinct-keyword" match="ανθ:keyword" use="string(.)"/>
   <xsl:key name="creators-index" match="ανθ:author-index/ανθ:author" use="@id"/>
   <!-- RULES -->
   <pattern>
      <rule context="@who">
         <assert test="not(exists(self::attribute(who)/parent::ανθ:creator/parent::ανθ:meta/ancestor-or-self::node()/parent::ανθ:ANTHOLOGY)) or matches(., '^#(\S+)$')">This <name/> is expected to match regular expression '^#(\S+)$'
            </assert>
      </rule>
      <rule context="ανθ:creator"><!--<index-has-key xmlns="http://csrc.nist.gov/ns/oscal/metaschema/1.0" name="creators-index" target=".//meta/creator[matches(@who,'\S')]" id="creators-index-ref"><key-field target="@who" pattern="#(\S+)"/></index-has-key>-->
         <let name="lookup"
              value="@who[matches(.,'^#(\S+)$')] ! replace(.,'^#(\S+)$','$1')"/>
         <assert test="not(exists(self::ανθ:creator[matches(@who,'\S')]/parent::ανθ:meta/ancestor-or-self::node()/parent::ανθ:ANTHOLOGY)) or exists(key('creators-index',$lookup,ancestor::ανθ:ANTHOLOGY))"
                 id="creators-index-ref">This <name/> is expected to correspond to an entry in the 'creators-index' index within the containing ανθ:ANTHOLOGY[[See id#creators-index-ref]]</assert>
      </rule>
      <rule context="ανθ:keyword"><!--<is-unique xmlns="http://csrc.nist.gov/ns/oscal/metaschema/1.0" name="distinct-keyword" target="."><key-field target="."/></is-unique>-->
         <assert test="not(exists(self::ανθ:keyword/parent::ανθ:meta)) or count(key('distinct-keyword',string(.)))=1">This <name/> is expected to be unique.
            </assert>
      </rule>
      <rule context="@type"><!--<allowed-values xmlns="http://csrc.nist.gov/ns/oscal/metaschema/1.0" id="type-check" target="@type"><enum value="YYYY">Four-digit year (CE)</enum></allowed-values>-->
         <assert test="not(exists(self::attribute(type)/parent::ανθ:meta)) or (. = ( 'YYYY' ))"
                 id="type-check">This <name/> is expected to be (one of) 'YYYY', not '<value-of select="."/>'
            [[See id#type-check]]</assert>
      </rule>
      <rule context="@date">
         <assert test="not(ancestor::ανθ:meta/@type='YYYY' and exists(self::attribute(date)/parent::ανθ:meta)) or matches(., '^[1-9]\d?\d?\d?$')">This <name/> is expected to match regular expression '^[1-9]\d?\d?\d?$'
            </assert>
      </rule>
      <rule context="@role"><!--<allowed-values xmlns="http://csrc.nist.gov/ns/oscal/metaschema/1.0" id="creator-type-check"><enum value="author">Author</enum><enum value="editor">Editor</enum><enum value="translator">Translator</enum></allowed-values>-->
         <assert test="not(exists(self::ανθ:role/parent::ανθ:creator)) or (. = ( 'author', 'editor', 'translator' ))"
                 id="creator-type-check">This <name/> is expected to be (one of) 'author', 'editor', 'translator', not '<value-of select="."/>'
            [[See id#creator-type-check]]</assert>
      </rule>
      <rule context="ανθ:verse"><!--<has-cardinality xmlns="http://csrc.nist.gov/ns/oscal/metaschema/1.0" id="quatrain-cardinality-check" target="line" max-occurs="4" min-occurs="4"/>-->
         <assert test="not(@type='quatrain') or count(ανθ:line) eq 4"
                 id="quatrain-cardinality-check">Where @type='quatrain', <name/> is expected to have exactly 4 occurrences of ανθ:line[[See id#quatrain-cardinality-check]]</assert>
      </rule>
      <rule context="@base"><!--<allowed-values xmlns="http://csrc.nist.gov/ns/oscal/metaschema/1.0" id="versetype-enumerations-check" allow-other="no"><enum value="dactyl">Dactylic</enum><enum value="anapest">Anapestic</enum><enum value="trochee">Trochaic</enum><enum value="iamb">Iambic</enum><enum value="mixed">Mixed</enum></allowed-values>-->
         <assert test="not(exists(self::ανθ:base)) or (. = ( 'dactyl', 'anapest', 'trochee', 'iamb', 'mixed' ))"
                 id="versetype-enumerations-check">This <name/> is expected to be (one of) 'dactyl', 'anapest', 'trochee', 'iamb', 'mixed', not '<value-of select="."/>'
            [[See id#versetype-enumerations-check]]</assert>
      </rule>
      <rule context="@feet">
         <assert test="not(exists(self::ανθ:feet)) or matches(., '^[1-9]$')">This <name/> is expected to match regular expression '^[1-9]$'
            </assert>
      </rule>
      <rule context="ανθ:author"/>
      <rule context="@id"/>
      <rule context="@birth">
         <assert test="not(exists(self::attribute(birth)/parent::ανθ:dates)) or m:datatype-validate(., 'date')">Where exists(self::attribute(birth)/parent::ανθ:dates), <name/> is expected to take the form of datatype date'
            </assert>
      </rule>
      <rule context="ανθ:dates"><!--<expect xmlns="http://csrc.nist.gov/ns/oscal/metaschema/1.0" id="chronology-check" test="xs:date(@birth) &lt; xs:date(@death)"/>-->
         <assert test="not(exists(self::ανθ:dates)) or exists(self::node()[xs:date(@birth) &lt; xs:date(@death)])"
                 id="chronology-check">This <name/> fails to pass evaluation of 'xs:date(@birth) &lt; xs:date(@death)'
            [[See id#chronology-check]]</assert>
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
