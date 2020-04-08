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
   <!-- RULES : CONTEXT DEPTH : 2-->
   <pattern id="match-depth-2">
      <rule context="anthology:creator/@role"><!--allowed-values on : author, editor, translator-->
         <assert test="( . = ( 'author', 'editor', 'translator' ) )">
            <name/> is expected to be (one of) 'author', 'editor', 'translator', not '<value-of select="."/>'</assert>
      </rule>
      <rule context="anthology:line/@feet"><!-- should match regex '^[1-9]'-->
         <assert test="matches(., '^[1-9]')">
            <name/> is expected to match regular expression '^[1-9]'</assert>
      </rule>
      <rule context="anthology:line/@base"><!--allowed-values on : dactyl, anapest, trochee, iambic, mixed-->
         <assert test="( . = ( 'dactyl', 'anapest', 'trochee', 'iambic', 'mixed' ) )">
            <name/> is expected to be (one of) 'dactyl', 'anapest', 'trochee', 'iambic', 'mixed', not '<value-of select="."/>'</assert>
      </rule>
   </pattern>
   <!-- RULES : CONTEXT DEPTH : 5-->
   <pattern id="match-depth-5">
      <rule context="anthology:anthology/lexical analysis failed&#xA;while expecting [EOF, S, '!=', ')', '*', '+', ',', '-', '&lt;', '&lt;=', '=', '&gt;', '&gt;=', '[', ']', 'and', 'div', 'mod', 'or', '|']&#xA;at line 1, column 2:&#xA;...//meta/creator[matches(@who,'\S')]..."><!--!ERROR! lexical analysis failed while expecting [EOF, S, '!=', ')', '*', '+', ',', '-', '<', '<=', '=', '>', '>=', '[', ']', 'and', 'div', 'mod', 'or', '|'] at line 1, column 2: ...//meta/creator[matches(@who,'\S')]... must correspond to an entry in the 'creators-index' index within the context of its ancestor anthology:anthology-->
         <assert test="exists(key('creators-index',@who,ancestor::anthology:anthology))">
            <name/> is expected to correspond to an entry in the '<sch:value-of select="@name"/>' index within the containing <sch:value-of select="$parent-context"/>
         </assert>
      </rule>
   </pattern>
</schema>
