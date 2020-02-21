<?xml version="1.0" encoding="UTF-8"?>
<sch:schema xmlns:sch="http://purl.oclc.org/dsdl/schematron" queryBinding="xslt2"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:m="http://csrc.nist.gov/ns/oscal/metaschema/1.0"
    xmlns:nm="http://csrc.nist.gov/ns/metaschema"
    xmlns:sqf="http://www.schematron-quickfix.com/validator/process"
    xmlns:oscal="http://csrc.nist.gov/ns/oscal/1.0">

<!-- Extra-XSD validation for NIST Metaschema format 

    This is ISO Schematron with XSLT extensions, requiring 'allow-foreign-namespace' to run.

    x Referential integrity between definitions and references - @ref always resolves
      warnings when flag/@ref points to field|assembly etc
    x Expected appearance of formal-name, description
    x Name usage / name clashes
      x including group-as/@name
    o Stray definitions
      x unused
      o overridden (check interim 'collected' metaschema)
    Inconsistent data type assignments
    Constraints relating to markup-multiline, json-key, json-value-key
    Any other good things from old implementation
    -->

    <sch:ns uri="http://csrc.nist.gov/ns/oscal/metaschema/1.0" prefix="m"/>
    <sch:ns uri="http://csrc.nist.gov/ns/metaschema" prefix="nm"/>
    
    <xsl:import href="metaschema-validation-support.xsl"/>
    
    <xsl:import href="oscal-datatypes-check.xsl"/>
    
    <xsl:variable name="composed-metaschema" select="nm:compose-metaschema(/)"/>
 
    
    <sch:pattern id="top-level-and-schema-docs">
        
        <sch:rule context="/m:METASCHEMA">
            <sch:assert test="exists(m:schema-version)" role="warning">Metaschema schema version must be set for any top-level metaschema</sch:assert>
        </sch:rule>
        <sch:rule context="/m:METASCHEMA/m:title"/>
        <sch:rule context="/m:METASCHEMA/m:import">
            <sch:report role="warning" test="document-uri(/) = resolve-uri(@href,document-uri(/))">Schema can't import itself</sch:report>
            <sch:assert test="exists(document(@href)/m:METASCHEMA)">Can't find a metaschema at <sch:value-of select="@href"/></sch:assert>
        </sch:rule>        
        
        <sch:rule context="m:define-assembly | m:define-field | m:define-flag">
            <sch:assert role="warning" test="exists(m:formal-name)">formal-name missing from <sch:name/></sch:assert>
            <sch:assert role="warning" test="exists(m:description)">description missing from <sch:name/></sch:assert>
            <sch:assert role="warning" test="empty(self::m:define-assembly) or exists(m:model)">model missing from <sch:name/></sch:assert>
        </sch:rule>
        
        <sch:rule context="m:p | m:li | m:pre">
            <sch:assert test="matches(.,'\S')">Empty <name/> (is likely to distort rendition)</sch:assert>
        </sch:rule>
    </sch:pattern>
    
    <sch:pattern id="definitions-and-name-clashes">
        <sch:rule context="m:flag | m:field | m:assembly">
            <sch:let name="aka" value="nm:identifiers(.)"/>
            <sch:let name="def" value="nm:definition-for-reference(.)"/>
            <sch:assert test="exists($def)"><sch:name/> has no definition.</sch:assert>
            <sch:assert test="exists($aka) or empty($def)"><sch:name/> has no name defined</sch:assert>
            <sch:let name="siblings" value="(../m:flag | ../m:model//m:field | ../m:model//m:assembly) except ."/>
            <sch:let name="rivals" value="$siblings[nm:identifiers(.) = $aka]"/>
            <sch:assert test="empty($rivals)">Name clash on flag using name '<sch:value-of select="$aka"/>'; clashes with
                neighboring <xsl:value-of select="$rivals/local-name()" separator=", "/></sch:assert>
          
        </sch:rule>
        
        <sch:rule context="m:METASCHEMA/m:define-assembly | m:METASCHEMA/m:define-field | m:METASCHEMA/m:define-flag">
            <sch:let name="references" value="nm:references-to-definition(.)"/>
            <sch:report test="@name=(../@name except @name)">Definition for '<sch:value-of select="@name"/>' clashes in this metaschema: not a good idea.</sch:report>
            <sch:assert role="warning" test="exists($references | self::m:define-assembly/m:root-name)">Orphan <sch:value-of select="substring-after(local-name(),'define-')"/> '<sch:value-of select="@name"/>' is never used in the composed metaschema</sch:assert>
            
            <sch:assert test="not($references/m:group-as/@in-json='BY_KEY') or exists(m:json-key)"><sch:value-of select="substring-after(local-name(),
            'define-')"/> is assigned a json key, but no 'json-key' is given</sch:assert>
            <sch:report test="@name=('RICHTEXT','STRVALUE','PROSE')">Names "STRVALUE", "RICHTEXT" or "PROSE" are reserved.</sch:report>
            
        
        </sch:rule>
        
        <!-- top-level definitions have already matched, so this rule does not apply -->
        <sch:rule context="m:define-assembly | m:define-field">
            <sch:assert test="matches(m:group-as/@name,'\S') or number((@max-occurs,1)[1])=1">Unless @max-occurs is 1, a group name must be given with a local assembly definition.</sch:assert>
        </sch:rule>
        
        
        <sch:rule context="m:group-as">
            <sch:let name="name" value="@name"/>
            <sch:report test="../@max-occurs/number() = 1">"group-as" should not be given when max-occurs is 1.</sch:report>
            <sch:let name="def" value="nm:definition-for-reference(parent::*)"/>
            <sch:assert test="count(ancestor::m:model//(m:field | m:define-field | m:assembly | m:define-assembly)[nm:identifiers(.)=$name]) = 1">group-as @name is not unique within this model</sch:assert>
            <sch:assert test="not(@in-json='BY_KEY') or $def/m:json-key/@flag-name=$def/(m:flag/@ref|m:define-flag/@name)">Cannot group by key since the definition of <sch:value-of select="name(..)"/>
                '<sch:value-of select="../@ref"/>' has no json-key specified. Consider adding a json-key to the '<sch:value-of select="../@ref"/>' definition, or using a different 'in-json' setting.</sch:assert>
        </sch:rule>
        
        </sch:pattern>
    
    <sch:pattern id="flags_and_keys_and_datatypes">
        <sch:rule context="m:field | m:assembly">
            <sch:let name="def" value="nm:definition-for-reference(.)"/>
            <sch:assert test="empty($def) or not(m:group-as/@in-json='BY_KEY') or exists($def/m:json-key)">Target definition for <sch:value-of select="@ref"/> designates a json key, so
            the invocation should have group-as/@in-json='BY_KEY'</sch:assert>
            <sch:assert test="matches(m:group-as/@name,'\S') or not((@max-occurs/number() gt 1) or (@max-occurs='unbounded'))">Unless @max-occurs is 1,
                a grouping name (group-as/@name) must be given</sch:assert>

            <!-- constraints related to markup-multiline -->
            <sch:assert test="not(@in-xml='UNWRAPPED') or not($def/@as-type='markup-multiline') or not(preceding-sibling::*[@in-xml='UNWRAPPED']/nm:definition-for-reference(.)/@as-type='markup-multiline')">Only one field may be marked
            as 'markup-multiline' (without xml wrapping) within a model.</sch:assert>
            <sch:report test="(@in-xml='UNWRAPPED') and (@max-occurs!='1')">An 'unwrapped' field must have a max occurrence of 1</sch:report>
            <sch:assert test="$def/@as-type='markup-multiline' or not(@in-xml='UNWRAPPED')">Only 'markup-multiline' fields may be unwrapped in XML.</sch:assert>
            
        </sch:rule>
        
        <sch:rule context="m:flag | m:define-field/m:define-flag | m:define-assembly/m:define-flag">

            <sch:assert
                test="not((@name | @ref) = ../m:json-value-key/@flag-name) or @required = 'yes'">A
                flag declared as a value key must be required (@required='yes')</sch:assert>
            
            <sch:assert test="not(parent::m:define-field[@as-type='markup-multiline']/nm:references-to-definition(.)/@in-xml='UNWRAPPED')">Multiline markup fields must have no flags, unless always used with a wrapper - put your flags on an assembly with an unwrapped multiline field</sch:assert>
            
        </sch:rule>
        
        <sch:rule context="m:json-key">
            <sch:assert test="@flag-name = (../m:flag/@ref|../m:define-flag/@name)">JSON key indicates no flag on this <sch:value-of select="substring-after(local-name(..),'define-')"/>
                <xsl:if test="exists(../m:flag)">Should be (one of) <xsl:value-of select="../m:flag/@ref | ../m:define-flag/@name" separator=", "/></xsl:if></sch:assert>
        </sch:rule>
        
        <sch:rule context="m:json-value-key">
            <sch:report test="exists(@flag-name) and matches(.,'\S')">JSON value key may be set to a value or a flag's value, but not both.</sch:report>
            <sch:assert test="empty(@flag-name) or @flag-name = (../m:flag/@ref|../m:define-flag/@name)">flag '<sch:value-of select="@flag-name"/>' not found for JSON value key</sch:assert>
        </sch:rule>
        
        <sch:rule context="m:allowed-values/m:enum">
            <sch:assert test="not(@value = preceding-sibling::*/@value)">Allowed value '<sch:value-of select="@value"/>' may only be
                specified once for flag '<sch:value-of select="../../@name"/>'.</sch:assert>
            <sch:assert test="m:datatype-validate(@value,../../@as-type)">Value '<sch:value-of select="@value"/>' is not a valid token of type <sch:value-of select="../../@as-type"/></sch:assert>
        </sch:rule>
    </sch:pattern>
    
    <sch:pattern>
       
        <sch:rule context="m:assembly[exists(@ref)]">
            <!-- XYZ <sch:report test="@ref = $composed-metaschema/m:METASCHEMA/m:define-field/@name">'<sch:value-of select="@ref"/>' is a field, not an assembly.</sch:report>-->
            <!-- XYZ <sch:report test="@ref = $composed-metaschema/m:METASCHEMA/m:define-flag/@name">'<sch:value-of select="@ref"/>' is a flag, not an assembly.</sch:report>-->
        </sch:rule>
        <sch:rule context="m:field[exists(@ref)]">
            <!-- XYZ <sch:report test="@ref = $composed-metaschema/m:METASCHEMA/m:define-assembly/@name">'<sch:value-of select="@ref"/>' is an assembly, not a field.</sch:report>-->
            <!-- XYZ <sch:report test="@ref = $composed-metaschema/m:METASCHEMA/m:define-flag/@name">'<sch:value-of select="@ref"/>' is a flag, not an assembly.</sch:report>-->
        </sch:rule>
        
        <sch:rule context="m:flag[exists(@ref)]">
            <!--<sch:report test="@ref = $composed-metaschema/m:METASCHEMA/m:define-field/@name">'<sch:value-of select="@name"/>' is a field, not a flag.</sch:report>-->
            <!--<sch:report test="@ref = $composed-metaschema/m:METASCHEMA/m:define-assembly/@name">'<sch:value-of select="@name"/>' is an assembly, not a flag.</sch:report>-->
        </sch:rule>
    </sch:pattern>


    <!-- 0#0|0#0|0#0|0#0|0#0|0#0|0#0|0#0|0#0|0#0|0#0|0#0|0#0|0#0|0#0|0#0|0#0|0#0|0#0|0#0|0#0|0#0|0#0|0#0|-->
    
    

    <xsl:key name="definition-for-reference" match="m:METASCHEMA/m:define-assembly" use="@name || ':ASSEMBLY'"/>
    <xsl:key name="definition-for-reference" match="m:METASCHEMA/m:define-field"    use="@name || ':FIELD'"/>
    <xsl:key name="definition-for-reference" match="m:METASCHEMA/m:define-flag"     use="@name || ':FLAG'"/>

    <xsl:key name="references-to-definition" match="m:assembly" use="@ref || ':ASSEMBLY'"/>
    <xsl:key name="references-to-definition" match="m:field"    use="@ref || ':FIELD'"/>
    <xsl:key name="references-to-definition" match="m:flag"     use="@ref || ':FLAG'"/>
    
    <!-- gets back only the appropriate global definition for an assembly, field or flag   -->
    <xsl:function name="nm:definition-for-reference" as="element()?">
        <xsl:param name="who" as="element()"/>
        <xsl:variable name="really-who" select="$who/(self::m:assembly | self::m:field | self::m:flag)"/>
        <xsl:variable name="tag" expand-text="true">{ $really-who/@ref }:{ local-name($really-who) => upper-case() }</xsl:variable>
        <xsl:sequence select="key('definition-for-reference',$tag,$composed-metaschema)"/>
    </xsl:function>
    
    <xsl:function name="nm:references-to-definition" as="element()*">
        <!-- expects define-assembly, define-field or define-flag -->
        <xsl:param name="who" as="element()"/>
        <xsl:variable name="really-who" select="$who/(self::m:define-assembly | self::m:define-field | self::m:define-flag)"/>
        <xsl:variable name="tag" expand-text="true">{ $really-who/@name }:{ substring-after(local-name($really-who),'define-') => upper-case() }</xsl:variable>
        <xsl:sequence select="$really-who/key('references-to-definition',$tag,$composed-metaschema)"/>
    </xsl:function>
    
    <xsl:template mode="nm:get-references" match="m:define-assembly | m:define-field | m:define-flag">
        <xsl:variable name="tag" expand-text="true">:{ substring-after(local-name(.),'define-') => upper-case() }</xsl:variable>
        
    </xsl:template>
    
    
    <xsl:function name="nm:sort" as="item()*">
        <xsl:param name="seq" as="item()*"/>
        <xsl:for-each select="$seq">
            <xsl:sort select="."/>
            <xsl:sequence select="."/>
        </xsl:for-each>
    '</xsl:function>
    
    
    <xsl:function name="nm:identifiers" as="xs:string*">
        <xsl:param name="who" as="element()"/>
        <xsl:apply-templates select="$who" mode="nm:get-identifiers"/>
    </xsl:function>
    
    <xsl:template match="m:define-assembly | m:define-field | m:define-flag" mode="nm:get-identifiers">
        <xsl:sequence select="m:root-name,(m:use-name,@name)[1]"/>
    </xsl:template>
    
    <xsl:template match="m:assembly[exists(m:use-name)] |
                         m:field[exists(m:use-name)] |
                         m:flag[exists(m:use-name)]" mode="nm:get-identifiers">
        <xsl:sequence select="m:use-name, m:group-as/@name"/>
    </xsl:template>
    
    <xsl:template match="m:assembly | m:field | m:flag" mode="nm:get-identifiers">
        <xsl:sequence select="m:group-as/@name"/>
        <xsl:apply-templates select="nm:definition-for-reference(.)" mode="#current"/>
    </xsl:template>
    
    <xsl:template match="*" mode="nm:get-identifiers"/>
    
</sch:schema>