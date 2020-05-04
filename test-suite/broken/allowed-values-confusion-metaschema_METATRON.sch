<?xml version="1.0" encoding="UTF-8"?>
<schema xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
        xmlns:m="http://csrc.nist.gov/ns/oscal/metaschema/1.0"
        xmlns:sch="http://purl.oclc.org/dsdl/schematron"
        xmlns="http://purl.oclc.org/dsdl/schematron"
        queryBinding="xslt2">
   <ns prefix="m" uri="http://csrc.nist.gov/ns/oscal/metaschema/1.0"/>
   <ns prefix="anthology" uri="http://csrc.nist.gov/metaschema/ns/test"/>
   <let name="silence-warnings" value="true()"/>
   <!-- INDEX DEFINITIONS AS KEY DECLARATIONS -->
   <xsl:key name="item-uniqueness" match="anthology:item" use="@id"/>
   <!-- RULES -->
   <pattern>
      <rule context="anthology:item">
               <!-- when @type='hex',  should match regex '[\dabcdef]+'-->
         <assert test="not(@type='hex') or matches(., '^[\dabcdef]+$')">Where @type='hex', <name/> is expected to match regular expression '^[\dabcdef]+$'
            </assert>
      </rule>
      <rule context="anthology:sequence//anthology:item">
         <!-- when exists(self::anthology:item[@type='number']), allowed-values on .//anthology:item[@type='number']: 1, 2, 3-->
         <assert test="not(exists(self::anthology:item[@type='number'])) or ($silence-warnings or . = ( '1', '2', '3' ))"
                 role="warning"
                 id="T1">Where exists(self::anthology:item[@type='number']), <name/> is expected to be (one of) '1', '2', '3', not '<value-of select="."/>'
            [[See id#T1]]</assert>
      </rule>
      <rule context="anthology:sequence//anthology:item">
         <!-- when exists(self::anthology:item[@type='german']), allowed-values on .//anthology:item[@type='german']: Ä, Ö, Ü-->
         <assert test="not(exists(self::anthology:item[@type='german'])) or (. = ( 'Ä', 'Ö', 'Ü' ))"
                 id="T2">Where exists(self::anthology:item[@type='german']), <name/> is expected to be (one of) 'Ä', 'Ö', 'Ü', not '<value-of select="."/>'
            [[See id#T2]]</assert>
      </rule>
      <rule context="anthology:sequence//anthology:subsequence//anthology:item">
         <!-- when exists(self::anthology:item/ancestor::anthology:subsequence), allowed-values on .//anthology:subsequence//anthology:item: pink, orange, purple-->
         <assert test="not(exists(self::anthology:item/ancestor::anthology:subsequence)) or (. = ( 'pink', 'orange', 'purple' ))"
                 id="T3">Where exists(self::anthology:item/ancestor::anthology:subsequence), <name/> is expected to be (one of) 'pink', 'orange', 'purple', not '<value-of select="."/>'
            [[See id#T3]]</assert>
      </rule>
      <rule context="anthology:subsequence/anthology:item">
         <!--allowed-values on : red, blue, green-->
         <assert test="(. = ( 'red', 'blue', 'green' ))" id="L1">
            <name/> is expected to be (one of) 'red', 'blue', 'green', not '<value-of select="."/>'
            [[See id#L1]]</assert>
      </rule>
      <rule context="anthology:item">
         <!--allowed-values on : A, B, C-->
         <assert test="(. = ( 'A', 'B', 'C' ))" id="G1">
            <name/> is expected to be (one of) 'A', 'B', 'C', not '<value-of select="."/>'
            [[See id#G1]]</assert>
      </rule>
      <rule context="anthology:item">
        <!-- is unique-->
         <assert test="count(key('item-uniqueness',@id))=1">
            <name/> is expected to be unique.
            </assert>
      </rule>
   </pattern>
</schema>
