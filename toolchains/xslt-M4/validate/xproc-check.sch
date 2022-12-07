<?xml version="1.0" encoding="UTF-8"?>
<sch:schema xmlns:p="http://www.w3.org/ns/xproc"
    xmlns:sch="http://purl.oclc.org/dsdl/schematron" queryBinding="xslt2"
    xmlns:sqf="http://www.schematron-quickfix.com/validator/process">
    <sch:ns uri="http://www.w3.org/ns/xproc" prefix="p"/>
    <sch:pattern>
        <sch:rule context="//(p:document|p:import)/@href">
            <sch:assert role="fatal" test="doc-available(resolve-uri(current(), document-uri(/)))" id="xpl-import-bad-href-target">No XML document at target location <sch:value-of select="resolve-uri(current(), document-uri(/))"/>.</sch:assert>
        </sch:rule>
    </sch:pattern>
</sch:schema>
