<?xml version="1.0" encoding="UTF-8"?>
<schema xmlns="http://purl.oclc.org/dsdl/schematron" queryBinding="xslt2"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:sqf="http://www.schematron-quickfix.com/validator/process">

    <ns prefix="ev" uri="http://csrc.nist.gov/metaschema/ns/everything"/>
    
    <pattern>
        <rule context="/*">
            <report test="false()">Here be <name/></report>
        </rule>
    </pattern>
    
    <xsl:key name="role-index" match="ev:role" use="@role-id"/>
    
    <pattern>
        <rule context="ev:skit/ev:line">
            
        </rule>
        <rule context="ev:skit/ev:line">
            
        </rule>
        <rule context="ev:skit">
            <assert test="ev:line[@who='ghost']=('Boo!')">Ghost only says Boo!</assert>
            <assert test="every $i in (ev:line[@who='ghost']) satisfies ($i=('Boo!'))">Ghost only says Boo!</assert>
        </rule>
        <rule context="ev:color">
            <assert test=".=('red','pink')" subject="ev:color">Colors must be red or pink</assert>
        </rule>
        <rule context="ev:expectation">
            <!-- 3rd arg to key() comes from key declaration context -->
            <assert  subject="line" test="not(@type='type') or (string(.)=('start','end'))">
                when @type='type', an expectation value should be one of 'start', 'end'
            </assert>
            <assert test="not(@type='roleref') or exists(key('role-index',data(),ancestor::ev:everything[1]))">
                'role-index' index returns nothing for key '<value-of select="data()"/>': this everything has no role with this @role-id
            </assert>
        </rule>
        <rule context="ev:everything/@required-integer">
            <report test=". > 2">Biggish</report>
        </rule>
    </pattern>
<!-- 
    <define-field name="expectation">
        <constraint>
            <require when="@type='type'">
                <allowed-values target="value()">
                    <enum value="start">start</enum>
                    <enum value="end">end</enum>
                </allowed-values>
            </require>
            <require when="@type='date'">
                <matches datatype="date" target="value()"/>
            </require>
            <require when="@type='roleref'">
                <index-has-key target="." name="role-index">
                    <key-field target="value()"/>
                </index-has-key>
            </require>
        </constraint>
    -->
</schema>