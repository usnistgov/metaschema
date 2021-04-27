<?xml version="1.0" encoding="UTF-8"?>
<sch:schema xmlns:sch="http://purl.oclc.org/dsdl/schematron" queryBinding="xslt2"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:m="http://csrc.nist.gov/ns/oscal/metaschema/1.0"
    xmlns:nm="http://csrc.nist.gov/ns/metaschema"
    xmlns:sqf="http://www.schematron-quickfix.com/validator/process"
    xmlns:oscal="http://csrc.nist.gov/ns/oscal/1.0">

<!-- Extra-XSD validation for NIST Metaschema format 

    This is ISO Schematron with XSLT extensions, requiring 'allow-foreign-namespace' to run.

       -->

    <sch:ns uri="http://csrc.nist.gov/ns/oscal/metaschema/1.0" prefix="m"/>
    <sch:ns uri="http://csrc.nist.gov/ns/metaschema" prefix="nm"/>
    
    <xsl:import href="metaschema-validation-support.xsl"/>
    
    <!--<xsl:import href="oscal-datatypes-check.xsl"/>-->
    
    <xsl:variable name="composed-metaschema" select="nm:compose-metaschema(/)"/>
 
    <!--<sch:let name="metaschema-is-abstract" value="/m:METASCHEMA/@abstract='yes'"/>-->
    
    <sch:pattern id="top-level-and-schema-docs">
        
        <!--<sch:rule context="/m:METASCHEMA">
            <sch:assert test="exists($composed-metaschema)">Can't find composition...</sch:assert>
            <sch:assert test="exists(m:schema-version)" role="warning">Metaschema schema version must be set for any top-level metaschema</sch:assert>
            <sch:assert test="exists($composed-metaschema/m:define-assembly/m:root-name) or @abstract='yes'">Unless marked as @abstract='yes', a metaschema (or an imported metaschema) should have at least one assembly with a root-name.</sch:assert>
        </sch:rule>
        <sch:rule context="/m:METASCHEMA/m:import">
            <sch:report role="warning" test="document-uri(/) = resolve-uri(@href,document-uri(/))">Schema can't import itself</sch:report>
            <sch:assert test="exists(document(@href)/m:METASCHEMA)">Can't find a metaschema at <sch:value-of select="@href"/></sch:assert>
        </sch:rule>-->
    </sch:pattern>
    
    <!--<sch:pattern id="detect-exceptions">
        <sch:rule context="m:*">
            <xsl:variable name="as-composed" as="element()*" select="key('composed-definition-by-identifier',nm:metaschema-module-node-identifier(.),$composed-metaschema)"/>
            <sch:assert test="empty($as-composed/m:EXCEPTION)">
                <xsl:apply-templates select="m:EXCEPTION"/>
            </sch:assert>
        </sch:rule>
            
    </sch:pattern>-->
    
    <sch:pattern id="definitions-and-name-clashes">
        
        <sch:rule context="m:assembly | m:field">
            <xsl:variable name="maybe-composed" as="element()*" select="key('composed-definition-by-identifier',nm:metaschema-module-node-identifier(.),$composed-metaschema)"/>
            
            <xsl:variable name="as-composed" as="element()?" select="$maybe-composed[count($maybe-composed) eq 1]"/>         
            <xsl:variable name="is-multiple"  select="count($maybe-composed) gt 1"/>
            
            <sch:let name="my-xml-name"  value="$as-composed/@in-xml-name"/>
            <sch:let name="my-json-name" value="$as-composed/@in-json-name"/>
            <sch:let name="named-like-me-in-xml" value="$as-composed/ancestor::m:model[1]/(*|m:choice/*)[@in-xml-name=$my-xml-name]"/>
            
            <sch:let name="named-like-me-in-json" value="$as-composed/ancestor::m:model[1]/(*|m:choice/*)[@in-json-name=$my-json-name]"/>
            
            <sch:assert test="not($is-multiple)" >Duplicate found for <sch:name/> reference to <sch:value-of select="@ref"/> in <xsl:value-of select="$maybe-composed/(ancestor-or-self::m:define-assembly|ancestor-or-self::m:define-field|ancestor::m:define-flag)/@_base-uri" separator=", "/>. Is this due to a duplicated METASCHEMA/short-name in a module?</sch:assert>
            <sch:report test="$is-multiple">Matching <xsl:value-of select="$maybe-composed/serialize(.)" separator=", "/></sch:report>
            
            <sch:assert test="empty($as-composed) or $is-multiple or count($named-like-me-in-json) = 1">Name clash among siblings (properties of the same object) with JSON name '<sch:value-of select="$my-json-name"/>'.</sch:assert>
            <sch:assert test="empty($as-composed) or $is-multiple or count($named-like-me-in-xml) = 1">Name clash among siblings with XML name '<sch:value-of select="$my-xml-name"/>'.</sch:assert>
        </sch:rule>
        
        <sch:rule context="m:define-flag | m:define-field | m:define-assembly">
            <sch:let name="def-id" value="nm:metaschema-module-node-identifier(.)"/>
            <!--<sch:report test="true()">Seeing <sch:value-of select="$def-id"/></sch:report>-->
            <xsl:variable name="maybe-composed" as="element()*" select="key('composed-definition-by-identifier',nm:metaschema-module-node-identifier(.),$composed-metaschema)"/>
            
            <xsl:variable name="as-composed" as="element()?" select="$maybe-composed[count($maybe-composed) eq 1]"/>
            <xsl:variable name="is-multiple"  select="count($maybe-composed) gt 1"/>
            
            <sch:assert test="not($is-multiple)" >Duplicate found for <sch:name/> reference to <sch:value-of select="@ref"/> in <xsl:value-of select="$maybe-composed/(ancestor-or-self::m:define-assembly|ancestor-or-self::m:define-field|ancestor::m:define-flag)/@_base-uri" separator=", "/>. Is this due to a duplicated METASCHEMA/short-name in a module?</sch:assert>
            
        </sch:rule>
    </sch:pattern>
    
    <sch:pattern>
        <sch:rule context="/m:METASCHEMA/m:define-assembly | /m:METASCHEMA/m:define-field | /m:METASCHEMA/m:define-flag">
            <xsl:variable name="as-composed" as="element()*" select="key('composed-definition-by-identifier',nm:metaschema-module-node-identifier(.),$composed-metaschema)"/>
            
            <sch:let name="defs" value="key('top-level-definition-by-name',@name,$composed-metaschema)"/>
            <sch:assert test="exists($defs)">broken</sch:assert>
            <sch:assert test="count($defs)=1">Definition shadows by another definition in this (composed) metaschema: see <xsl:value-of select="($defs except $as-composed)/concat(@module,':',@name)" separator=", "/> (<xsl:value-of select="($defs except $as-composed)/@_base-uri" separator=", "/>)</sch:assert>
        </sch:rule>
    </sch:pattern>
    <!-- 0#0|0#0|0#0|0#0|0#0|0#0|0#0|0#0|0#0|0#0|0#0|0#0|0#0|0#0|0#0|0#0|0#0|0#0|0#0|0#0|0#0|0#0|0#0|0#0|-->
    
    <!--<xsl:function name="nm:has-a-distinct-name" as="xs:boolean">
        <!-\- checks a field or assembly as referenced in a modeled (i.e. references and inline definitions)
             and returns if they have distinct names -\->
    </xsl:function>-->
    
    <xsl:function name="nm:composed-node-id" as="xs:string">
        <xsl:param name="who" as="element()"/>
        <xsl:variable name="top-level-definition" select="$who/ancestor-or-self::m:define-assembly[parent::m:METASCHEMA] |
            $who/ancestor-or-self::m:define-field[parent::m:METASCHEMA] | 
            $who/ancestor-or-self::m:define-flag[parent::m:METASCHEMA]"/>
        <xsl:variable name="module-defined" select="$top-level-definition/@module"/>
        <xsl:value-of
            select="($module-defined,
            $who/ancestor-or-self::*/(@name | @ref),
            name($who), $who/m:use-name) => string-join('#')"/>
    </xsl:function>
    
    <xsl:function name="nm:metaschema-module-node-identifier" as="xs:string">
        <xsl:param name="who" as="element()"/>
        <xsl:value-of
            select="($who/root()/*/m:short-name,
            $who/ancestor-or-self::*/(@name | @ref),
            name($who), $who/m:use-name) => string-join('#')"/>
    </xsl:function>
    
    <xsl:key name="top-level-definition-by-name" use="@name"
        match="m:METASCHEMA/m:define-assembly[not(@scope='local')] |
        m:METASCHEMA/m:define-field[not(@scope='local')] |
        m:METASCHEMA/m:define-flag[not(@scope='local')]"/>
    
    
    
    <xsl:key name="composed-definition-by-identifier"
        match="m:define-assembly | m:define-field | m:define-flag
        | m:flag | m:field | m:assembly" use="nm:composed-node-id(.)"/>
    
    
</sch:schema>