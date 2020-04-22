<?xml version="1.0" encoding="UTF-8"?>
<schema xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
        xmlns:m="http://csrc.nist.gov/ns/oscal/metaschema/1.0"
        xmlns:sch="http://purl.oclc.org/dsdl/schematron"
        xmlns="http://purl.oclc.org/dsdl/schematron"
        queryBinding="xslt2">
   <ns prefix="m" uri="http://csrc.nist.gov/ns/oscal/metaschema/1.0"/>
   <ns prefix="anthology" uri="http://csrc.nist.gov/metaschema/ns/test"/>
   <pattern>
      <rule context="anthology:sequence//anthology:item">
         <!-- when exists(self::anthology:item[@type='german']), allowed-values on .//anthology:item[@type='german']: Ä, Ö, Ü-->
         <assert test="not(exists(self::anthology:item[@type='german'])) or ( . = ( 'Ä', 'Ö', 'Ü' ) )">Where exists(self::anthology:item[@type='german']), <name/> is expected to be (one of) 'Ä', 'Ö', 'Ü', not '<value-of select="."/>'
            </assert>
      </rule>
      <rule context="anthology:subsequence/anthology:item">
            <!-- when @type='color', allowed-values on : red, blue, green-->
         <assert test="not(@type='color') or ( . = ( 'red', 'blue', 'green' ) )"
                 id="local-color-item-allowed-values">Where @type='color', <name/> is expected to be (one of) 'red', 'blue', 'green', not '<value-of select="."/>'
            [[See id#local-color-item-allowed-values]]</assert>
      </rule>
      <rule context="anthology:item">
         <!--allowed-values on : A, B, C-->
         <assert test="( . = ( 'A', 'B', 'C' ) )" id="global-item-allowed-values">
            <name/> is expected to be (one of) 'A', 'B', 'C', not '<value-of select="."/>'
            [[See id#global-item-allowed-values]]</assert>
      </rule>
   </pattern>
</schema>
