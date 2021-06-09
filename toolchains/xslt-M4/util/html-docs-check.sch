<?xml version="1.0" encoding="UTF-8"?>
<sch:schema xmlns:sch="http://purl.oclc.org/dsdl/schematron" queryBinding="xslt2"
    xmlns:sqf="http://www.schematron-quickfix.com/validator/process"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    
    <sch:ns prefix="h" uri="http://www.w3.org/1999/xhtml"/>
    
    <xsl:key name="internal-reference" match="*[exists(@id)]" use="'#' || @id"/>
    
    <xsl:variable name="screened" as="element()*">
        <regex>^/reference/datatypes/</regex>
        <regex>^/artifacts</regex>
        <regex>^/concepts</regex>
    </xsl:variable>
    
    <sch:pattern>
        
        <!-- Absolute links are not checked -->
        <sch:rule context="h:a[matches(@href,'^\w+:+//')]"/>
        
        <sch:rule context="h:a[starts-with(@href,'#')]">
            <sch:assert test="exists(key('internal-reference',@href))">Not finding <sch:value-of select="@href"/></sch:assert>
        </sch:rule>
        
<!-- not matched by prior rules are external links with relative URI @href       -->
        <sch:rule context="h:a">
            <sch:let name="doc"  value="replace(@href,'#.*$','')[normalize-space(.)] => replace('^../','')"/>
            <sch:let name="link" value="substring-after(@href,$doc)"/>
            <sch:let name="doc-is-screened" value="some $s in ($screened) satisfies matches($doc,$s)"/>
            <sch:let name="path-to-doc" value="$doc => resolve-uri(document-uri(/))"/>
            <sch:let name="doc-is-available" value="not($doc-is-screened) and doc-available($path-to-doc)"/>
            <sch:let name="internal-target"  value="$link[normalize-space(.)]"/>
            <sch:assert test="$doc-is-screened or $doc-is-available">NO DOCUMENT <sch:value-of select="$doc"/> at <sch:value-of select="$path-to-doc"/></sch:assert>
            <sch:assert test="not($doc-is-available) or empty($internal-target) or exists(document($doc,/)/key('internal-reference',$link))">BROKEN LINK to <sch:value-of select="@href"/>  <sch:value-of select="if ($doc-is-available) then ' (document is visible)' else ''"/></sch:assert>
        </sch:rule>
            
            <sch:rule context="h:details">
                <sch:assert test="exists(* except h:summary)">Empty ...details...</sch:assert>
                
            </sch:rule>
        
    </sch:pattern>
</sch:schema>