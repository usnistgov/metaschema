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
         <assert test="matches(., '^[1-9]')">
            <name/> is expected to match regular expression '^[1-9]'</assert>
      </rule>
   </pattern>
   <!-- RULES : CONTEXT DEPTH : 2-->
   <pattern id="match-depth-2">
      <rule context="anthology:meta/anthology:date"><!-- should match regex '^[1-9]\d?\d?\d?$'-->
         <assert test="matches(., '^[1-9]\d?\d?\d?$')">
            <name/> is expected to match regular expression '^[1-9]\d?\d?\d?$'</assert>
      </rule>
      <rule context="anthology:creator/@role"><!--allowed-values on : author, editor, translator-->
         <assert test="( . = ( 'author', 'editor', 'translator' ) )">
            <name/> is expected to be (one of) 'author', 'editor', 'translator', not '<value-of select="."/>'</assert>
      </rule>
      <rule context="anthology:line/@base"><!--allowed-values on : dactyl, anapest, trochee, iambic, mixed-->
         <assert test="( . = ( 'dactyl', 'anapest', 'trochee', 'iambic', 'mixed' ) )">
            <name/> is expected to be (one of) 'dactyl', 'anapest', 'trochee', 'iambic', 'mixed', not '<value-of select="."/>'</assert>
      </rule>
   </pattern>
   <!-- RULES : CONTEXT DEPTH : 4-->
   <pattern id="match-depth-4">
      <rule context="anthology:ANTHOLOGY//anthology:meta/anthology:creator"><!-- when exists(self::anthology:creator[matches(@who,'\S')]/ancestor::anthology:meta), .//anthology:meta/anthology:creator[matches(@who,'\S')] must correspond to an entry in the 'creators-index' index within the context of its ancestoranthology:ANTHOLOGY-->
         <assert test="not(exists(self::anthology:creator[matches(@who,'\S')]/ancestor::anthology:meta)) or exists(key('creators-index',@who,ancestor::anthology:ANTHOLOGY))">Where exists(self::anthology:creator[matches(@who,'\S')]/ancestor::anthology:meta), <name/> is expected to correspond to an entry in the 'creators-index' index within the containing anthology:ANTHOLOGY</assert>
      </rule>
   </pattern>
</schema>
