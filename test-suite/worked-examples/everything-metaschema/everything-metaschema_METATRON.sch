<schema xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
        xmlns:m="http://csrc.nist.gov/ns/oscal/metaschema/1.0"
        xmlns:sch="http://purl.oclc.org/dsdl/schematron"
        xmlns="http://purl.oclc.org/dsdl/schematron"
        queryBinding="xslt2">
   <ns prefix="m" uri="http://csrc.nist.gov/ns/oscal/metaschema/1.0"/>
   <ns prefix="everything" uri="http://csrc.nist.gov/metaschema/ns/everything"/>
   <!-- INDEX DEFINITIONS AS KEY DECLARATIONS -->
   <xsl:key name="role-index"
            match="everything:everything/!ERROR! lexical analysis failed while expecting [EOF, S, '!=', '(:', ')', '*', '+', ',', '-', '&lt;', '&lt;=', '=', '&gt;', '&gt;=', '[', ']', 'and', 'div', 'mod', 'or', '|'] at line 1, column 2: ...//role..."
            use="@role-id"/>
   <xsl:key name="unique-expectation-oneof"
            match="everything:everything/everything:expectation[@type='oneof']"
            use="string(.)"/>
   <xsl:key name="widget-banner" match="everything:widget" use="@banner"/>
   <xsl:key name="point-identifiers" match="everything:point" use="@point-id"/>
   <xsl:key name="all-roles" match="everything:role" use="@role-id"/>
   <xsl:key name="role-is-unique" match="everything:role" use="@role-id"/>
   <!-- RULES : CONTEXT DEPTH : 1-->
   <pattern id="match-depth-1">
      <rule context="everything:widget"/>
      <rule context="everything:stanza"><!-- when ancestor::everything:stanza/@type='couplet', everything:line has cardinality:  at least 2  at most 2-->
         <assert test="not(ancestor::everything:stanza/@type='couplet') or count(line) eq 2">Where ancestor::everything:stanza/@type='couplet', <name/> is expected to have exactly 2 occurrences of line</assert>
         <!-- when ancestor::everything:stanza/@type='tercet', everything:line has cardinality:  at least 3  at most 3-->
         <assert test="not(ancestor::everything:stanza/@type='tercet') or count(line) eq 3">Where ancestor::everything:stanza/@type='tercet', <name/> is expected to have exactly 3 occurrences of line</assert>
         <!-- when ancestor::everything:stanza/@type='quatrain', everything:line has cardinality:  at least 4  at most 4-->
         <assert test="not(ancestor::everything:stanza/@type='quatrain') or count(line) eq 4">Where ancestor::everything:stanza/@type='quatrain', <name/> is expected to have exactly 4 occurrences of line</assert>
      </rule>
      <rule context="everything:expectation"><!-- when @type='type', allowed-values on : start, end-->
         <assert test="not(@type='type') or ( . = ( 'start', 'end' ) )">Where @type='type', <name/> is expected to be (one of) 'start', 'end', not '<value-of select="."/>'</assert>
      </rule>
      <rule context="everything:point"/>
      <rule context="everything:role"/>
      <rule context="everything:greek-letter"><!--allowed-values on : Alpha, Beta, Gamma-->
         <assert test="( . = ( 'Alpha', 'Beta', 'Gamma' ) )">
            <name/> is expected to be (one of) 'Alpha', 'Beta', 'Gamma', not '<value-of select="."/>'</assert>
      </rule>
   </pattern>
   <!-- RULES : CONTEXT DEPTH : 2-->
   <pattern id="match-depth-2">
      <rule context="everything:everything/everything:expectation"><!-- when (empty( self::everything:expectation[@type='oneof'] )), everything:expectation[@type='oneof'] is unique within the context of its ancestor everything:everything-->
         <assert test="not((empty( self::everything:expectation[@type='oneof'] ))) or count(key('unique-expectation-oneof',string(.),ancestor::everything:everything))=1">Where (empty( self::everything:expectation[@type='oneof'] )), <name/> is expected to be unique within the containing <sch:value-of select="$parent-context"/>
         </assert>
      </rule>
      <rule context="everything:widget/@banner-type"><!--allowed-values on : date, color, wholeNo, ID-->
         <assert test="( . = ( 'date', 'color', 'wholeNo', 'ID' ) )">
            <name/> is expected to be (one of) 'date', 'color', 'wholeNo', 'ID', not '<value-of select="."/>'</assert>
      </rule>
      <rule context="everything:widget/everything:line"><!--everything:line should match regex '^\S'-->
         <assert test="matches(., '^\S')">
            <name/> is expected to match regular expression '^\S'</assert>
      </rule>
      <rule context="everything:widget/@banner"><!-- when ancestor::everything:widget/@banner-type='date', @banner should take the form of datatype 'date'-->
         <assert test="not(ancestor::everything:widget/@banner-type='date') or m:datatype-validate(., 'date')">Where ancestor::everything:widget/@banner-type='date', <name/> is expected to take the form of datatype date'</assert>
         <!-- when ancestor::everything:widget/@banner-type='color', allowed-values on @banner: red, blue, green-->
         <assert test="not(ancestor::everything:widget/@banner-type='color') or ( . = ( 'red', 'blue', 'green' ) )">Where ancestor::everything:widget/@banner-type='color', <name/> is expected to be (one of) 'red', 'blue', 'green', not '<value-of select="."/>'</assert>
         <!-- when ancestor::everything:widget/@banner-type='wholeNo', @banner should match regex '^\d+$'-->
         <assert test="not(ancestor::everything:widget/@banner-type='wholeNo') or matches(., '^\d+$')">Where ancestor::everything:widget/@banner-type='wholeNo', <name/> is expected to match regular expression '^\d+$'</assert>
      </rule>
      <rule context="everything:stanza/@type"><!--allowed-values on : couplet, tercet, quatrain-->
         <assert test="( . = ( 'couplet', 'tercet', 'quatrain' ) )">
            <name/> is expected to be (one of) 'couplet', 'tercet', 'quatrain', not '<value-of select="."/>'</assert>
      </rule>
      <rule context="everything:expectation/@type"><!--allowed-values on : type, date, roleref, oneof-->
         <assert test="( . = ( 'type', 'date', 'roleref', 'oneof' ) )">
            <name/> is expected to be (one of) 'type', 'date', 'roleref', 'oneof', not '<value-of select="."/>'</assert>
      </rule>
      <rule context="everything:point/everything:x"><!--everything:x should take the form of datatype 'decimal'-->
         <assert test="m:datatype-validate(., 'decimal')">
            <name/> is expected to take the form of datatype decimal'</assert>
      </rule>
      <rule context="everything:point/everything:y"><!--everything:y should take the form of datatype 'decimal'-->
         <assert test="m:datatype-validate(., 'decimal')">
            <name/> is expected to take the form of datatype decimal'</assert>
      </rule>
      <rule context="everything:skit/everything:line"><!-- when @who='ghost', allowed-values on : Boo!-->
         <assert test="not(@who='ghost') or ( . = ( 'Boo!' ) )">Where @who='ghost', <name/> is expected to be (one of) 'Boo!', not '<value-of select="."/>'</assert>
         <!-- when @class='has-a',  should match regex 'a|A'-->
         <assert test="not(@class='has-a') or matches(., 'a|A')">Where @class='has-a', <name/> is expected to match regular expression 'a|A'</assert>
         <!-- when (empty( self::everything:line[@who='ghost'] )), allowed-values on everything:line[@who='ghost']: Boo!-->
         <assert test="not((empty( self::everything:line[@who='ghost'] ))) or ( . = ( 'Boo!' ) )">Where (empty( self::everything:line[@who='ghost'] )), <name/> is expected to be (one of) 'Boo!', not '<value-of select="."/>'</assert>
         <!-- when (empty( self::everything:line[@class='has-a'] )), everything:line[@class='has-a'] should match regex 'a|A'-->
         <assert test="not((empty( self::everything:line[@class='has-a'] ))) or matches(., 'a|A')">Where (empty( self::everything:line[@class='has-a'] )), <name/> is expected to match regular expression 'a|A'</assert>
      </rule>
   </pattern>
   <!-- RULES : CONTEXT DEPTH : 3-->
   <pattern id="match-depth-3">
      <rule context="everything:expectation/everything:some/everything:path"><!-- when ancestor::everything:expectation/@type='date', everything:some/everything:path should take the form of datatype 'date'-->
         <assert test="not(ancestor::everything:expectation/@type='date') or m:datatype-validate(., 'date')">Where ancestor::everything:expectation/@type='date', <name/> is expected to take the form of datatype date'</assert>
      </rule>
      <rule context="everything:expectation/everything:some/node()"><!-- when ancestor::everything:expectation/@type='roleref', everything:some/node() must correspond to an entry in the 'role-index' index within the context of its ancestor everything:expectation-->
         <assert test="not(ancestor::everything:expectation/@type='roleref') or exists(key('role-index',string(.),ancestor::everything:expectation))">Where ancestor::everything:expectation/@type='roleref', <name/> is expected to correspond to an entry in the '<sch:value-of select="@name"/>' index within the containing <sch:value-of select="$parent-context"/>
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
   <xsl:template match="m:decimal" mode="m:validate-type" as="xs:boolean">
      <xsl:sequence select=". castable as xs:decimal"/>
   </xsl:template>
   <xsl:template match="m:date" mode="m:validate-type" as="xs:boolean">
      <xsl:sequence select=". castable as xs:date"/>
   </xsl:template>
</schema>
