<schema xmlns:sch="http://purl.oclc.org/dsdl/schematron"
        xmlns="http://purl.oclc.org/dsdl/schematron"
        queryBinding="xslt2">
   <ns prefix="everything" uri="http://csrc.nist.gov/metaschema/ns/everything"/>
   <pattern>
      <rule context="everything:everything"/>
      <rule context="everything:widget/@banner-type">
         <assert test=". = ( 'date', 'color', 'wholeNo', 'ID' )">
            <name/>/. '<value-of select="."/>' is expected to be one of 'date', 'color', 'wholeNo', 'ID'</assert>
      </rule>
      <rule context="everything:widget">
         <assert test="matches( @banner, '^\d+$')">
            <name/>/@banner '<value-of select="@banner"/>' is expected to match regular expression '^\d+$'</assert>
         <assert test="not(@banner-type='color') or @banner = ( 'red', 'blue', 'green' )">Where @banner-type='color', <name/>/@banner '<value-of select="@banner"/>' is expected to be one of 'red', 'blue', 'green'</assert>
         <assert test="not(@banner-type='wholeNo') or matches( @banner, '^\d+$')">Where @banner-type='wholeNo', <name/>/@banner '<value-of select="@banner"/>' is expected to match regular expression '^\d+$'</assert>
      </rule>
      <rule context="everything:stanza/@type">
         <assert test=". = ( 'couplet', 'tercet', 'quatrain' )">
            <name/>/. '<value-of select="."/>' is expected to be one of 'couplet', 'tercet', 'quatrain'</assert>
      </rule>
      <rule context="everything:stanza">
         <assert test="not(@type='couplet') or count(everything:line) eq 2">Where @type='couplet', <name/>/ everything:line is expected to occur exactly 2 times</assert>
         <assert test="not(@type='tercet') or count(everything:line) eq 3">Where @type='tercet', <name/>/ everything:line is expected to occur exactly 3 times</assert>
         <assert test="not(@type='quatrain') or count(everything:line) eq 4">Where @type='quatrain', <name/>/ everything:line is expected to occur exactly 4 times</assert>
      </rule>
      <rule context="everything:expectation/@type">
         <assert test=". = ( 'type', 'date', 'roleref', 'oneof' )">
            <name/>/. '<value-of select="."/>' is expected to be one of 'type', 'date', 'roleref', 'oneof'</assert>
      </rule>
      <rule context="everything:expectation">
         <assert test="not(@type='type') or data() = ( 'start', 'end' )">Where @type='type', <name/>/data() '<value-of select="data()"/>' is expected to be one of 'start', 'end'</assert>
      </rule>
      <rule context="everything:one-string">
         <assert test=". = ( 'Alpha', 'Beta', 'Gamma' )">
            <name/>/. '<value-of select="."/>' is expected to be one of 'Alpha', 'Beta', 'Gamma'</assert>
      </rule>
   </pattern>
</schema>
