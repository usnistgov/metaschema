<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:math="http://www.w3.org/2005/xpath-functions/math"
    xmlns:m="http://csrc.nist.gov/ns/oscal/metaschema/1.0"
    xpath-default-namespace="http://csrc.nist.gov/ns/oscal/metaschema/1.0"
    exclude-result-prefixes="xs math"
    version="3.0"
    xmlns:sch="http://purl.oclc.org/dsdl/schematron"
    xmlns="http://purl.oclc.org/dsdl/schematron"
    >

    
<!-- Purpose: Produce an XSD Schema representing constraints declared in a netaschema -->
<!-- Input:   A Metaschema -->
<!-- Output:  An XSD, with embedded documentation -->

<!-- nb The schema and Schematron for the metaschema format is essential
        for validating constraints assumed by this transformation. -->

    <xsl:import href="../metapath/parse-metapath.xsl"/>
    
    <xsl:import href="metatron-datatype-functions.xsl"/>
    
    <xsl:output indent="yes"/>

    <xsl:strip-space elements="METASCHEMA define-assembly define-field define-flag model choice allowed-values remarks"/>
    
    <xsl:variable name="target-namespace" select="string(/METASCHEMA/namespace)"/>
    
    <xsl:variable name="declaration-prefix" select="string(/METASCHEMA/short-name)"/>
    
    <xsl:key name="global-assembly-by-name" match="/METASCHEMA/define-assembly" use="@name"/>
    <xsl:key name="global-field-by-name"    match="/METASCHEMA/define-field"    use="@name"/>
    <xsl:key name="global-flag-by-name"     match="/METASCHEMA/define-flag"     use="@name"/>
    
    <xsl:variable name="metaschema" select="/"/>
    
    <!-- Produces intermediate results, w/o namespace alignment -->
    <!-- entry template -->
    
    <xsl:param name="debug" select="'no'"/>
    
    <!--MAIN ACTION HERE -->
    
    <xsl:template match="/" name="build-schema">
        <schema queryBinding="xslt2">
            
            <ns prefix="m" uri="http://csrc.nist.gov/ns/oscal/metaschema/1.0"/>
            <ns prefix="{ $declaration-prefix }" uri="{ $target-namespace }"/>
            
            <!--<pattern>
                <rule context="/*">
                    <report test="true()" role="warning">Here be <name/></report>
                </rule>
            </pattern>-->
            
            <pattern>
              <xsl:apply-templates select="//constraint"/>
            </pattern>
            
            <xsl:call-template name="m:produce-validation-function"/>
            
            <xsl:apply-templates select="$type-definitions[@name=$metaschema//constraint//matches/@datatype]" mode="m:make-template"/>
        </schema>
    </xsl:template>
    
    <xsl:variable name="types-library" select="document('oscal-datatypes.xsd')/*"/>
    
    <!--<require when="@banner-type='date'">
        <matches target="@banner" datatype="date"/>
    </require>-->
    
    <xsl:template match="text()"/>
    
    <xsl:template match="constraint">
        <xsl:variable name="context">
            <xsl:apply-templates select="." mode="rule-context"/>
        </xsl:variable>
        <xsl:where-populated>
            <rule context="{ $context }">
                <xsl:apply-templates/>
            </rule>
        </xsl:where-populated>
    </xsl:template>
    
    <xsl:template match="matches |allowed-values | has-cardinality">
        <xsl:apply-templates mode="assertion" select="."/>
    </xsl:template>
    
    <xsl:template match="has-cardinality/@min-occurs" mode="assertion">
        <xsl:variable name="target" select="m:target(parent::has-cardinality)"/>
        <xsl:variable name="condition" select="m:condition(parent::has-cardinality)"/>
        <xsl:variable name="exception-clause">
            <xsl:if test="exists($condition)" expand-text="true">not({ $condition }) or</xsl:if>
        </xsl:variable>
        <assert test="{ $exception-clause } count({ $target }) le { (. cast as xs:integer) } )">
            <xsl:call-template name="id-assertion"/>
            <xsl:value-of select="m:condition(parent::has-cardinality) ! ('Where ' || . || ', ')"/><name/> is expected to have at most <xsl:value-of select="m:conditional-plural(. cast as xs:integer ,'occurrence')"/> of <xsl:value-of
                select="$target"/></assert>
    </xsl:template>
    
    <xsl:template match="has-cardinality/@max-occurs" mode="assertion">
        <xsl:variable name="target" select="m:target(parent::has-cardinality)"/>
        <xsl:variable name="condition" select="m:condition(parent::has-cardinality)"/>
        <xsl:variable name="exception-clause">
            <xsl:if test="exists($condition)" expand-text="true">not({ $condition }) or</xsl:if>
        </xsl:variable>
        <assert test="{ $exception-clause } count({ $target }) ge { (. cast as xs:integer) } )">
            <xsl:call-template name="id-assertion"/>
            <xsl:value-of select="$condition ! ('Where ' || . || ', ')"/><name/> is expected to have at least <xsl:value-of select="m:conditional-plural(. cast as xs:integer,'occurrence')"/> of <xsl:value-of select="$target"/></assert>
    </xsl:template>
    
    <xsl:template priority="3" match="has-cardinality[@min-occurs = @max-occurs]" mode="assertion">
        <xsl:variable name="target" select="m:target(.)"/>
        <xsl:variable name="condition" select="m:condition(.)"/>
        <xsl:variable name="exception-clause">
            <xsl:if test="exists($condition)" expand-text="true">not({ $condition }) or</xsl:if>
        </xsl:variable>
        <xsl:variable name="test" expand-text="true">count({$target}) eq { xs:integer(@min-occurs) }</xsl:variable>
        <xsl:apply-templates select="." mode="echo.if"/>
        <assert test="{ $exception-clause } { $test }">
            <xsl:call-template name="id-assertion"/>
            <xsl:value-of select="$condition ! ('Where ' || . || ', ')"/><name/> is expected to have exactly <xsl:value-of select="m:conditional-plural(@min-occurs cast as xs:integer,'occurrence')"/> of <xsl:value-of select="$target"/></assert>
    </xsl:template>
    
    
    <xsl:template priority="2" match="has-cardinality" mode="assertion">
        <xsl:apply-templates select="." mode="echo.if"/>
        <xsl:apply-templates mode="#current" select="@min-occurs, @max-occurs"/>
    </xsl:template>
    
    <xsl:template priority="2" match="matches/@datatype" mode="assertion">
        <xsl:variable name="target" select="m:target(parent::matches)"/>
        <xsl:variable name="exception">
            <xsl:if test="exists(m:condition(parent::matches))" expand-text="true">not({ m:condition(parent::matches) }) or </xsl:if>
        </xsl:variable>
        <xsl:variable name="test" expand-text="true">(every $t in ({$target}) satisfies m:datatype-validate($t, '{.}') )</xsl:variable>
        <xsl:apply-templates select="." mode="echo.if"/>
        <assert test="{ $exception }{ $test }">
            <xsl:call-template name="id-assertion"/>
            <xsl:value-of select="m:condition(parent::matches) ! ('Where ' || . || ', ')"/><name/>/<xsl:value-of select="$target"/> '<value-of select="{ $target }"/>' is expected to follow rules for <xsl:value-of select="."/>'</assert>
        
    </xsl:template>
    
    <xsl:template priority="2" match="matches/@regex" mode="assertion">
        <xsl:variable name="target" select="m:target(parent::matches)"/>
        <xsl:variable name="exception">
            <xsl:if test="exists(m:condition(parent::matches))" expand-text="true">not({ m:condition(parent::matches) }) or </xsl:if>
        </xsl:variable>
        <xsl:variable name="test" expand-text="true">(every $t in ({$target}) satisfies matches($t, '{.}') )</xsl:variable>
        <xsl:apply-templates select="." mode="echo.if"/>
        <assert test="{ $exception }{ $test }">
            <xsl:call-template name="id-assertion"/>
            <xsl:value-of select="m:condition(parent::matches) ! ('Where ' || . || ', ')"/><name/>/<xsl:value-of select="$target"/> '<value-of select="{ $target }"/>' is expected to match regular expression '<xsl:value-of select="."/>'</assert>
    </xsl:template>
    
    <xsl:template priority="2" match="matches" mode="assertion">    
        <xsl:apply-templates mode="#current" select="@regex | @datatype"/>
    </xsl:template>
    
    <xsl:template priority="2" match="allowed-values" mode="assertion">
        <xsl:param name="exception">
            <xsl:if test="exists(m:condition(.))" expand-text="true">not({ m:condition(.) }) or </xsl:if>
        </xsl:param>
        <xsl:variable name="value-sequence" select="(enum/@value ! ('''' || . || '''')) => string-join(', ')"/>
        <xsl:variable name="test">
            <xsl:text expand-text="true">{ m:target(.) } = ( { $value-sequence }</xsl:text>
        </xsl:variable>
        <xsl:apply-templates select="." mode="echo.if"/>
        <assert test="{ $exception }{ $test } )">
            <xsl:call-template name="id-assertion"/>
            <xsl:value-of select="m:condition(.) ! ('Where ' || . || ', ')"/><name/>/<xsl:value-of select="m:target(.)"/> is expected to be (one of) <xsl:value-of select="$value-sequence"/>, not '<value-of select="{ m:target(.) }"/>'</assert>
    </xsl:template>
    
    <xsl:param name="noisy" as="xs:string">yes</xsl:param>
    <xsl:variable name="echo.source" select="$noisy='yes'"/>
    
    <xsl:template match="*" mode="echo.if">
        <xsl:if test="$echo.source">
            <xsl:text>&#xA;&#xA;</xsl:text>
            <xsl:comment>
                <xsl:value-of select="serialize(.,$serializer-settings)"/>
            </xsl:comment>
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="allowed-values" mode="echo.if">
        <xsl:if test="$echo.source">
            <xsl:text expand-text="true">&#xA;      { ancestor::*[exists(ancestor-or-self::constraint)] ! '  ' } </xsl:text>
            <xsl:comment expand-text="true">{ m:condition(.) ! (' when ' || . || ', ') }allowed-values on { m:target(.) }: { string-join(enum/@value,', ' ) }</xsl:comment>
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="matches/@regex" mode="echo.if">
        <xsl:if test="$echo.source">
            <xsl:text expand-text="true">&#xA;      { ancestor::*[exists(ancestor-or-self::constraint)] ! '  ' } </xsl:text>
            <xsl:comment expand-text="true">{ m:condition(parent::matches) ! (' when ' || . || ', ') }{ m:target(parent::matches) } should match regex '{ . }'</xsl:comment>
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="matches/@datatype" mode="echo.if">
        <xsl:if test="$echo.source">
            <xsl:text expand-text="true">&#xA;      { ancestor::*[exists(ancestor-or-self::constraint)] ! '  ' } </xsl:text>
            <xsl:comment expand-text="true">{ m:condition(parent::matches) ! (' when ' || . || ', ') }{ m:target(parent::matches) } should datatype '{ . }'</xsl:comment>
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="has-cardinality" mode="echo.if">
        <xsl:if test="$echo.source">
            <xsl:text expand-text="true">&#xA;      { ancestor::*[exists(ancestor-or-self::constraint)] ! '  ' } </xsl:text>
            <xsl:comment expand-text="true">{ m:condition(.) ! (' when ' || . || ', ') }{ m:target(.) } has cardinality: { @min-occurs ! ( ' at least ' || (.,'0')[1]) } { @max-occurs ! ( ' at most ' || (.,'unbounded')[1]) }</xsl:comment>
        </xsl:if>
    </xsl:template>
    
    <xsl:variable name="serializer-settings" as="element()">
        <output:serialization-parameters
            xmlns="http://csrc.nist.gov/ns/oscal/metaschema/1.0"
            xmlns:output="http://www.w3.org/2010/xslt-xquery-serialization">
            <output:method value="xml"/>
            <output:version value="1.0"/>
            <output:indent value="yes"/>
        </output:serialization-parameters>
    </xsl:variable>
    
    <!-- Not yet handling flags, definition references, root or use-name ... -->
    <xsl:template match="*[@name]" mode="rule-context" as="xs:string">
        <xsl:value-of select="ancestor-or-self::*/(@name|@ref)/m:prefixed(.)" separator="/"/>
    </xsl:template>
    
    <xsl:template match="flag[@ref]" mode="rule-context" as="xs:string">
        <xsl:value-of>
            <xsl:value-of select="ancestor::*/@name/m:prefixed(.)" separator="/"/>
            <xsl:text>/</xsl:text>
            <xsl:apply-templates mode="#current" select="key('global-flag-by-name',@ref)"/>
        </xsl:value-of>
    </xsl:template>
    
    <xsl:template match="assembly[@ref]" mode="rule-context" as="xs:string">
        <xsl:value-of>
            <xsl:value-of select="ancestor::*/@name/m:prefixed(.)" separator="/"/>
            <xsl:text>/</xsl:text>
            <xsl:apply-templates mode="#current" select="key('global-assembly-by-name', @ref)"/>
        </xsl:value-of>
    </xsl:template>
    
    <xsl:template match="field[@ref]" mode="rule-context" as="xs:string">
        <xsl:value-of>
            <xsl:value-of select="ancestor::*/@name/m:prefixed(.)" separator="/"/>
            <xsl:text>/</xsl:text>
            <xsl:apply-templates mode="#current" select="key('global-field-by-name', @ref)"/>
        </xsl:value-of>
    </xsl:template>
    
    <xsl:template match="define-assembly | define-field" mode="rule-context">
        <xsl:for-each select="ancestor::model/parent::define-assembly">
            <xsl:value-of select="(root-name, use-name, @name)[1] / m:prefixed(.)"/>
            <xsl:text>/</xsl:text>
        </xsl:for-each>
        <xsl:value-of select="(root-name, use-name, @name)[1] / m:prefixed(.)"/>
    </xsl:template>
    
    <xsl:template priority="2" match="define-flag" mode="rule-context">
        <xsl:for-each select="ancestor::define-assembly | ancestor::define-field">
            <xsl:value-of select="(root-name, use-name, @name)[1] / m:prefixed(.)"/>
            <xsl:text>/</xsl:text>
        </xsl:for-each>
        <xsl:value-of select="'@' || (use-name, @name)[1]"/>
    </xsl:template>
    
    <xsl:template match="*" mode="rule-context">
       <xsl:apply-templates select="ancestor-or-self::constraint/parent::*" mode="#current"/>
    </xsl:template>
    
    <xsl:function name="m:rule-context" as="xs:string" cache="yes">
        <xsl:param name="whose"/>
        <!-- Insulate XPath here -->
        <xsl:apply-templates select="$whose" mode="rule-context"/>
    </xsl:function>
    
    <xsl:function name="m:prefixed" as="xs:string" cache="yes">
        <xsl:param name="whose"/>
        <!-- Insulate XPath here -->
        <xsl:text expand-text="true">{ $declaration-prefix }:{ $whose/string(.) }</xsl:text>
    </xsl:function>
    
    <xsl:function name="m:target" as="xs:string" cache="yes">
        <xsl:param name="whose" as="element()"/>
        <!-- Insulate XPath here -->
<!-- no-namespace paths have to be expanded to ns? -->
        <xsl:value-of>
          <xsl:apply-templates mode="okay-xpath" select="($whose/@target,'.')[1] => m:prefixed-path($declaration-prefix)"/>
        </xsl:value-of>
    </xsl:function>
    
    <xsl:template mode="okay-xpath" match=".">
        <xsl:sequence select="."/>
    </xsl:template>
    
    <xsl:template mode="okay-xpath" priority="100" match=".[starts-with(.,'/')]">
        <xsl:text> ( (: ... not liking absolute path </xsl:text>
        <xsl:sequence select="."/>
        <xsl:text> ... :) ) </xsl:text>
    </xsl:template>
    
    <!-- regex matches axis specifiers we want to exclude -->
    <xsl:variable name="backward-axes" as="xs:string">(parent|ancestor|ancestor-or-self|preceding-sibling|preceding)::</xsl:variable>
    
    <xsl:template mode="okay-xpath" priority="101" match=".[matches(.,$backward-axes)]">
        <xsl:text>(: not liking the reverse axis </xsl:text>
        <xsl:sequence select="."/>
        <xsl:text> :)</xsl:text>
    </xsl:template>
    
    <!-- produces a sequence of conditional tests from @when ancestry -->
    <xsl:function name="m:condition" as="xs:string?" cache="yes">
        <!-- Insulate XPath here -->
        <xsl:param name="whose" as="element()"/>
        <xsl:variable name="predicates" select="$whose/ancestor-or-self::*/@when"/>
        <xsl:if test="exists($predicates)">
            <xsl:value-of select="string-join($predicates,' and ')"/>
        </xsl:if>
    </xsl:function>
    
    <xsl:function name="m:conditional-plural" as="xs:string?" cache="yes">
        <xsl:param name="count" as="xs:integer"/>
        <xsl:param name="noun" as="xs:string"/>
        <xsl:text expand-text="true">{ if ($count eq 1) then ('one ' || $noun) else ($count || ' ' || $noun || 's' ) }</xsl:text>
    </xsl:function>
    
    <xsl:template name="id-assertion">
        <!--<xsl:attribute name="id">
            <xsl:value-of select="string-join(ancestor-or-self::*/(@name | @ref), '.')"/>
            <xsl:text>-</xsl:text>
            <xsl:value-of select="local-name()"/>
        </xsl:attribute>-->
    </xsl:template>
    
</xsl:stylesheet>