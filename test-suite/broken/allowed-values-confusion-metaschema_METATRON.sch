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
      <rule context="@id"/>
      <rule context="anthology:item">
               <!-- when true(),  should match regex '[\dabcdef]+'-->
         <assert test="not(true()) or matches(., '^[\dabcdef]+$')">Where true(), <name/> is expected to match regular expression '^[\dabcdef]+$'
            </assert>
      </rule>
      <rule context="anthology:item">
         <!-- when true(), allowed-values on .//anthology:item[@type='number']: 1, 2, 3-->
         <assert test="not(true()) or ($silence-warnings or . = ( '1', '2', '3' ))"
                 role="warning"
                 id="T1">Where true(), <name/> is expected to be (one of) '1', '2', '3', not '<value-of select="."/>'
            [[See id#T1]]</assert>
      </rule>
      <rule context="anthology:item">
         <!-- when true(), allowed-values on .//anthology:item[@type='german']: Ä, Ö, Ü-->
         <assert test="not(true()) or (. = ( 'Ä', 'Ö', 'Ü' ))" id="T2">Where true(), <name/> is expected to be (one of) 'Ä', 'Ö', 'Ü', not '<value-of select="."/>'
            [[See id#T2]]</assert>
      </rule>
      <rule context="anthology:item">
         <!-- when true(), allowed-values on .//anthology:subsequence//anthology:item: pink, orange, purple-->
         <assert test="not(true()) or (. = ( 'pink', 'orange', 'purple' ))" id="T3">Where true(), <name/> is expected to be (one of) 'pink', 'orange', 'purple', not '<value-of select="."/>'
            [[See id#T3]]</assert>
      </rule>
      <rule context="anthology:subsequence/anthology:item">
         <!-- when true(), allowed-values on : red, blue, green-->
         <assert test="not(true()) or (. = ( 'red', 'blue', 'green' ))" id="L1">Where true(), <name/> is expected to be (one of) 'red', 'blue', 'green', not '<value-of select="."/>'
            [[See id#L1]]</assert>
      </rule>
      <rule context="anthology:item">
         <!-- when true(), allowed-values on : A, B, C-->
         <assert test="not(true()) or (. = ( 'A', 'B', 'C' ))" id="G1">Where true(), <name/> is expected to be (one of) 'A', 'B', 'C', not '<value-of select="."/>'
            [[See id#G1]]</assert>
      </rule>
      <rule context="anthology:item">
        <!-- when true(),  is unique-->
         <assert test="not(true()) or count(key('item-uniqueness',@id))=1">Where true(), <name/> is expected to be unique.
            </assert>
      </rule>
   </pattern>
</schema>
