<?xml version="1.0" encoding="UTF-8"?>
<schema xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
        xmlns:m="http://csrc.nist.gov/ns/oscal/metaschema/1.0"
        xmlns:sch="http://purl.oclc.org/dsdl/schematron"
        xmlns="http://purl.oclc.org/dsdl/schematron"
        queryBinding="xslt2">
   <ns prefix="m" uri="http://csrc.nist.gov/ns/oscal/metaschema/1.0"/>
   <ns prefix="anthology" uri="http://csrc.nist.gov/metaschema/ns/test"/>
   <let name="silence-warnings" value="true()"/>
   <!-- RULES -->
   <pattern>
      <rule context="anthology:item"><!--<allowed-values xmlns="http://csrc.nist.gov/ns/oscal/metaschema/1.0" target="." allow-other="no" id="G1"><enum value="A">a</enum><enum value="B">b</enum><enum value="C">c</enum></allowed-values>-->
         <assert test="not(exists(self::anthology:item)) or (. = ( 'A', 'B', 'C' ))"
                 id="G1">This <name/> is expected to be (one of) 'A', 'B', 'C', not '<value-of select="."/>'
            [[See id#G1]]</assert>
         <!--<allowed-values xmlns="http://csrc.nist.gov/ns/oscal/metaschema/1.0" target="." allow-other="no" id="G1"><enum value="A">a</enum><enum value="B">b</enum></allowed-values>-->
         <assert test="not(@class='aorb' and exists(self::anthology:item)) or (. = ( 'A', 'B' ))"
                 id="G1">This <name/> is expected to be (one of) 'A', 'B', not '<value-of select="."/>'
            [[See id#G1]]</assert>
         <!--<allowed-values xmlns="http://csrc.nist.gov/ns/oscal/metaschema/1.0" target=".//item[@type='number']" allow-other="yes" id="T1"><enum value="1">one</enum><enum value="2">two</enum><enum value="3">three</enum></allowed-values>-->
         <assert test="not(exists(self::anthology:item[@type='number']/ancestor-or-self::*/parent::anthology:sequence)) or ($silence-warnings or . = ( '1', '2', '3' ))"
                 role="warning"
                 id="T1">This <name/> is expected to be (one of) '1', '2', '3', not '<value-of select="."/>'
            [[See id#T1]]</assert>
         <!--<allowed-values xmlns="http://csrc.nist.gov/ns/oscal/metaschema/1.0" target=".//item[@type='german']" id="T2"><enum value="Ä">a umlaut</enum><enum value="Ö">o umlaut</enum><enum value="Ü">u umlaut</enum></allowed-values>-->
         <assert test="not(exists(self::anthology:item[@type='german']/ancestor-or-self::*/parent::anthology:sequence)) or (. = ( 'Ä', 'Ö', 'Ü' ))"
                 id="T2">This <name/> is expected to be (one of) 'Ä', 'Ö', 'Ü', not '<value-of select="."/>'
            [[See id#T2]]</assert>
         <!--<allowed-values xmlns="http://csrc.nist.gov/ns/oscal/metaschema/1.0" target=".//subsequence//item" id="T3"><enum value="pink">pink</enum><enum value="orange">orange</enum><enum value="purple">purple</enum></allowed-values>-->
         <assert test="not(exists(self::anthology:item/ancestor-or-self::*/parent::anthology:subsequence/ancestor-or-self::*/parent::anthology:sequence)) or (. = ( 'pink', 'orange', 'purple' ))"
                 id="T3">This <name/> is expected to be (one of) 'pink', 'orange', 'purple', not '<value-of select="."/>'
            [[See id#T3]]</assert>
         <!--<allowed-values xmlns="http://csrc.nist.gov/ns/oscal/metaschema/1.0" target="." id="L1"><enum value="red">red</enum><enum value="blue">blue</enum><enum value="green">green</enum></allowed-values>-->
         <assert test="not(exists(self::anthology:item/parent::anthology:subsequence)) or (. = ( 'red', 'blue', 'green' ))"
                 id="L1">This <name/> is expected to be (one of) 'red', 'blue', 'green', not '<value-of select="."/>'
            [[See id#L1]]</assert>
      </rule>
   </pattern>
</schema>
