<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:math="http://www.w3.org/2005/xpath-functions/math"
    xmlns:m="http://csrc.nist.gov/ns/oscal/metaschema/1.0"
    xmlns:XSLT="http://csrc.nist.gov/ns/oscal/metaschema/xslt-alias"
    
    xpath-default-namespace="http://csrc.nist.gov/ns/oscal/metaschema/1.0"
    exclude-result-prefixes="xs math"
    version="3.0"
    xmlns:sch="http://purl.oclc.org/dsdl/schematron"
    xmlns="http://purl.oclc.org/dsdl/schematron"
    >
    
<!-- Purpose: Produce an Schematron representing constraints declared in a metaschema -->
<!-- Input:   A Metaschema -->
<!-- Output:  An XSD, with embedded documentation -->
<!-- Maintenance note: when Saxon10 is available in tooling, try cache=yes on function declarations. -->
<!-- nb Validation against both schema and Schematron for the metaschema format
        is assumed. -->
    <xsl:namespace-alias stylesheet-prefix="XSLT" result-prefix="xsl"/>
    
    
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
            
            <xsl:for-each-group select="//index | //is-unique" group-by="true()">
                <xsl:comment> INDEX DEFINITIONS AS KEY DECLARATIONS </xsl:comment>
                <xsl:apply-templates select="current-group()" mode="make-key"/>
            </xsl:for-each-group>
            
            <!--<xsl:apply-templates select="//constraint"/>-->
            <xsl:variable name="rules" as="element()*">
              <xsl:apply-templates select="//constraint"/>
            </xsl:variable>
            <xsl:for-each-group select="$rules" group-by="count(tokenize(@context,'/'))">
                <xsl:sort select="current-grouping-key()"/>
                <xsl:comment expand-text="true"> RULES : CONTEXT DEPTH : { current-grouping-key() }</xsl:comment>
                
                <pattern id="match-depth-{current-grouping-key()}">
                    <xsl:for-each-group select="current-group()" group-by="@context">
                        <rule context="{current-grouping-key()}">
                            <xsl:sequence select="current-group()/(*|comment())"/>
                        </rule>
                    </xsl:for-each-group>
                </pattern>
            </xsl:for-each-group>
            
            <xsl:for-each-group select="$type-definitions[@name=$metaschema//constraint//matches/@datatype]" group-by="true()">
                <xsl:comment> LEXICAL / DATATYPE VALIDATION FUNCTIONS </xsl:comment>

                <xsl:call-template name="m:produce-validation-function"/>
                <xsl:apply-templates select="current-group()" mode="m:make-template"/>
            </xsl:for-each-group>
            
        </schema>
    </xsl:template>
    
    <xsl:variable name="types-library" select="document('oscal-datatypes.xsd')/*"/>
    
    <xsl:template match="text()"/>
    
    <xsl:template match="constraint">
        <!--<xsl:apply-templates/>-->
        <xsl:variable name="rules" as="element(sch:rule)*">
            <xsl:apply-templates/>
        </xsl:variable>
        <xsl:for-each-group select="$rules" group-by="@context">
            <rule context="{ current-grouping-key() }">
                <xsl:sequence select="current-group()/(*|comment())"/>
            </rule>
        </xsl:for-each-group>
    </xsl:template>
    
    <xsl:template match="allowed-values[@allow-other='yes']"/>
    
    <xsl:template match="matches | allowed-values | index-has-key | is-unique">
        <xsl:variable name="context">
            <xsl:apply-templates select=".." mode="rule-context"/>
            <xsl:for-each select="@target[not(.=('.','value()'))]">
                <xsl:text>/</xsl:text>
                <xsl:sequence select="m:target-branch(string(.),$declaration-prefix)"/>
            </xsl:for-each>
        </xsl:variable>
        <rule context="{ $context }">
            <xsl:apply-templates mode="assertion" select="."/>
        </rule>
        
    </xsl:template>
    
    <xsl:template match="has-cardinality">
        <xsl:variable name="context">
            <xsl:apply-templates select=".." mode="rule-context"/>
        </xsl:variable>
        <rule context="{ $context }">
            <xsl:apply-templates mode="assertion" select="."/>
        </rule>
    </xsl:template>
    
    <xsl:template match="has-cardinality/@min-occurs" mode="assertion">
        <xsl:variable name="target" select="parent::has-cardinality/@target ! m:prefixed-path(.,$declaration-prefix)"/>
        <xsl:variable name="condition" select="m:wrapper-condition(parent::has-cardinality)"/>
        <xsl:variable name="exception-clause">
            <xsl:if test="exists($condition)" expand-text="true">not({ $condition }) or</xsl:if>
        </xsl:variable>
        <assert test="{ $exception-clause } count({ $target }) le { (. cast as xs:integer) } )">
            <xsl:call-template name="id-assertion"/>
            <xsl:value-of select="m:condition(parent::has-cardinality) ! ('Where ' || . || ', ')"/><name/> is expected to have at most <xsl:value-of select="m:conditional-plural(. cast as xs:integer ,'occurrence')"/> of <xsl:value-of
                select="$target"/></assert>
    </xsl:template>
    
    <xsl:template match="has-cardinality/@max-occurs" mode="assertion">
        <xsl:variable name="target" select="parent::has-cardinality/@target ! m:prefixed-path(.,$declaration-prefix)"/>
        <xsl:variable name="condition" select="m:wrapper-condition(parent::has-cardinality)"/>
        <xsl:variable name="exception-clause">
            <xsl:if test="exists($condition)" expand-text="true">not({ $condition }) or</xsl:if>
        </xsl:variable>
        <assert test="{ $exception-clause } count({ $target }) ge { (. cast as xs:integer) } )">
            <xsl:call-template name="id-assertion"/>
            <xsl:value-of select="$condition ! ('Where ' || . || ', ')"/><name/> is expected to have at least <xsl:value-of select="m:conditional-plural(. cast as xs:integer,'occurrence')"/> of <xsl:value-of select="$target"/></assert>
    </xsl:template>
    
    <xsl:template priority="3" match="has-cardinality[@min-occurs = @max-occurs]" mode="assertion">
        <xsl:variable name="target" select="@target ! m:prefixed-path(.,$declaration-prefix)"/>
        <xsl:variable name="condition" select="m:wrapper-condition(.)"/>
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
    
    <xsl:template match="index-has-key[matches(@target,'\S') and not(@target =('.','value()'))]" mode="assertion">
        <xsl:variable name="parent-context">
            <xsl:apply-templates mode="rule-context" select="ancestor::constraint"/>
        </xsl:variable>
        <xsl:variable name="exception">
            <xsl:if test="exists(m:condition(.))" expand-text="true">not({ m:condition(.) }) or </xsl:if>
        </xsl:variable>
        <xsl:variable name="test" expand-text="true">exists(key('{@name}',{m:key-value(.)},ancestor::{$parent-context}))</xsl:variable>
        <xsl:apply-templates select="." mode="echo.if"/>
        <assert test="{ $exception }{ $test }">
            <xsl:call-template name="id-assertion"/>
            <xsl:value-of select="m:condition(.) ! ('Where ' || . || ', ')"/><name/> is expected to correspond to an entry in the '<xsl:value-of select="@name"/>' index within the containing <xsl:value-of select="$parent-context"/></assert>
    </xsl:template>
    
    <!-- When an index-has-key is targetted not at . (or value) it needs extra logic for scoping. -->
    <xsl:template match="index-has-key" mode="assertion">
        <xsl:variable name="exception">
            <xsl:if test="exists(m:condition(.))" expand-text="true">not({ m:condition(.) }) or </xsl:if>
        </xsl:variable>
        <xsl:variable name="test" expand-text="true">exists(key('{@name}',{m:key-value(.)}))</xsl:variable>
        <xsl:apply-templates select="." mode="echo.if"/>
        <assert test="{ $exception }{ $test }">
            <xsl:call-template name="id-assertion"/>
            <xsl:value-of select="m:condition(.) ! ('Where ' || . || ', ')"/><name/> is expected to correspond to an entry in the '<xsl:value-of select="@name"/>' index.</assert>
    </xsl:template>
    
    <xsl:template match="is-unique[matches(@target,'\S') and not(@target =('.','value()'))]" mode="assertion">
        <xsl:variable name="parent-context">
            <xsl:apply-templates mode="rule-context" select="ancestor::constraint"/>
        </xsl:variable>
        <xsl:variable name="exception">
            <xsl:if test="exists(m:condition(.))" expand-text="true">not({ m:condition(.) }) or </xsl:if>
        </xsl:variable>
        <xsl:variable name="test" expand-text="true">count(key('{@name}',{m:key-value(.)},ancestor::{$parent-context}))=1</xsl:variable>
        <xsl:apply-templates select="." mode="echo.if"/>
        <assert test="{ $exception }{ $test }">
            <xsl:call-template name="id-assertion"/>
            <xsl:value-of select="m:condition(.) ! ('Where ' || . || ', ')"/><name/> is expected to be unique within the containing <xsl:value-of select="$parent-context"/></assert>
    </xsl:template>
    
    <!-- When an index-has-key is targetted not at . (or value) it needs extra logic for scoping. -->
    <xsl:template match="is-unique" mode="assertion">
        <xsl:variable name="exception">
            <xsl:if test="exists(m:condition(.))" expand-text="true">not({ m:condition(.) }) or </xsl:if>
        </xsl:variable>
        <xsl:variable name="test" expand-text="true">count(key('{@name}',{m:key-value(.)}))=1</xsl:variable>
        <xsl:apply-templates select="." mode="echo.if"/>
        <assert test="{ $exception }{ $test }">
            <xsl:call-template name="id-assertion"/>
            <xsl:value-of select="m:condition(.) ! ('Where ' || . || ', ')"/><name/> is expected to be unique.</assert>
    </xsl:template>
    
    <xsl:template match="matches/@datatype" mode="assertion">
        <xsl:variable name="exception">
            <xsl:if test="exists(m:condition(parent::matches))" expand-text="true">not({ m:condition(parent::matches) }) or </xsl:if>
        </xsl:variable> 
        <xsl:variable name="test" expand-text="true">m:datatype-validate(., '{.}')</xsl:variable>
        <xsl:apply-templates select="." mode="echo.if"/>
        <assert test="{ $exception }{ $test }">
            <xsl:call-template name="id-assertion"/>
            <xsl:value-of select="m:condition(parent::matches) ! ('Where ' || . || ', ')"/><name/> is expected to take the form of datatype <xsl:value-of select="."/>'</assert>
    </xsl:template>
    
    <xsl:template match="matches/@regex" mode="assertion">
        <xsl:variable name="exception">
            <xsl:if test="exists(m:condition(parent::matches))" expand-text="true">not({ m:condition(parent::matches) }) or </xsl:if>
        </xsl:variable>
        <xsl:variable name="test" expand-text="true">matches(., '{.}')</xsl:variable>
        <xsl:apply-templates select="." mode="echo.if"/>
        <assert test="{ $exception }{ $test }">
            <xsl:call-template name="id-assertion"/>
            <xsl:value-of select="m:condition(parent::matches) ! ('Where ' || . || ', ')"/><name/> is expected to match regular expression '<xsl:value-of select="."/>'</assert>
    </xsl:template>
    
    <xsl:template match="matches" mode="assertion">    
        <xsl:apply-templates mode="#current" select="@regex | @datatype"/>
    </xsl:template>
    
    <xsl:template match="allowed-values" mode="assertion">
        <xsl:variable name="exception">
            <xsl:if test="exists(m:condition(.))" expand-text="true">not({ m:condition(.) }) or </xsl:if>
        </xsl:variable>
        <xsl:variable name="value-sequence" select="(enum/@value ! ('''' || . || '''')) => string-join(', ')"/>
        <xsl:variable name="test" as="xs:string">
            <xsl:text expand-text="true">( . = ( { $value-sequence } ) )</xsl:text>
        </xsl:variable>
        <xsl:apply-templates select="." mode="echo.if"/>
        <assert test="{ $exception }{ $test }">
            <xsl:call-template name="id-assertion"/>
            <xsl:value-of select="m:condition(.) ! ('Where ' || . || ', ')"/><name/> is expected to be (one of) <xsl:value-of select="$value-sequence"/>, not '<value-of select="."/>'</assert>
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
            <xsl:comment expand-text="true">{ m:condition(.) ! (' when ' || . || ', ') }allowed-values on { m:target-match(.) }: { string-join(enum/@value,', ' ) }</xsl:comment>
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="matches/@regex" mode="echo.if">
        <xsl:if test="$echo.source">
            <xsl:text expand-text="true">&#xA;      { ancestor::*[exists(ancestor-or-self::constraint)] ! '  ' } </xsl:text>
            <xsl:comment expand-text="true">{ m:condition(parent::matches) ! (' when ' || . || ', ') }{ m:target-match(parent::matches) } should match regex '{ . }'</xsl:comment>
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="matches/@datatype" mode="echo.if">
        <xsl:if test="$echo.source">
            <xsl:text expand-text="true">&#xA;      { ancestor::*[exists(ancestor-or-self::constraint)] ! '  ' } </xsl:text>
            <xsl:comment expand-text="true">{ m:condition(parent::matches) ! (' when ' || . || ', ') }{ m:target-match(parent::matches) } should take the form of datatype '{ . }'</xsl:comment>
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="has-cardinality" mode="echo.if">
        <xsl:if test="$echo.source">
            <xsl:text expand-text="true">&#xA;      { ancestor::*[exists(ancestor-or-self::constraint)] ! '  ' } </xsl:text>
            <xsl:comment expand-text="true">{ m:condition(.) ! (' when ' || . || ', ') }{ m:target-match(.) } has cardinality: { @min-occurs ! ( ' at least ' || (.,'0')[1]) } { @max-occurs ! ( ' at most ' || (.,'unbounded')[1]) }</xsl:comment>
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="index-has-key" mode="echo.if">
        <xsl:if test="$echo.source">
            <xsl:text expand-text="true">&#xA;     { ancestor::*[exists(ancestor-or-self::constraint)] ! '  ' } </xsl:text>
            <xsl:comment expand-text="true">
                <xsl:text>{ m:condition(.) ! (' when ' || . || ', ') }{ m:target-match(.) } must correspond to an entry in the '{@name}' index</xsl:text>
                <xsl:if test="matches(@target,'\S') and not(@target=('.','value()'))">
                    <xsl:text> within the context of its ancestor</xsl:text>
                    <xsl:apply-templates select="ancestor::constraint" mode="rule-context"/>
                </xsl:if>
            </xsl:comment>
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="is-unique" mode="echo.if">
        <xsl:if test="$echo.source">
            <xsl:text expand-text="true">&#xA;     { ancestor::*[exists(ancestor-or-self::constraint)] ! '  ' } </xsl:text>
            <xsl:comment expand-text="true">
                <xsl:text>{ m:condition(.) ! (' when ' || . || ', ') }{ m:target-match(.) } is unique</xsl:text>
                <xsl:if test="matches(@target,'\S') and not(@target=('.','value()'))">
                    <xsl:text> within the context of its ancestor</xsl:text>
                    <xsl:apply-templates select="ancestor::constraint" mode="rule-context"/>
                </xsl:if>
            </xsl:comment>
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
    
    <xsl:function name="m:rule-context" as="xs:string">
        <xsl:param name="whose"/>
        <!-- Insulate XPath here -->
        <xsl:apply-templates select="$whose" mode="rule-context"/>
    </xsl:function>
    
    <xsl:function name="m:prefixed" as="xs:string">
        <xsl:param name="whose"/>
        <!-- Insulate XPath here -->
        <xsl:text expand-text="true">{ $declaration-prefix }:{ $whose/string(.) }</xsl:text>
    </xsl:function>
    
    <!-- produces an "exception clause" based on targeting.
     For example, target group[@id-'ac']/control[@id='ac-2']/part[@name='statement']
    yields exception clause (with prefix 'o')
      not(self::o:part[@name='statement]/ancestor::o:control[@id='ac-2']/ancestor::o:group/@id='ac')
    -->
    <xsl:function name="m:target-exception" as="xs:string?">
        <xsl:param name="whose" as="element()"/>
        <!-- Insulate XPath here -->
        <!-- no-namespace paths have to be expanded to ns? -->
        <xsl:variable name="target-path" as="xs:string">
            <xsl:apply-templates mode="okay-xpath" select="($whose/@target,'.')[1] => m:prefixed-path($declaration-prefix)"/>
        </xsl:variable>
        <xsl:sequence select="$target-path[not(.=('.','value()'))]"/>
    </xsl:function>
    
    <xsl:function name="m:target-match" as="xs:string?">
        <xsl:param name="whose" as="element()"/>
        <!-- Insulate XPath here -->
        <!-- no-namespace paths have to be expanded to ns? -->
        <xsl:variable name="target-path" as="xs:string">
            <xsl:apply-templates mode="okay-xpath" select="($whose/@target,'.')[1] => m:prefixed-path($declaration-prefix)"/>
        </xsl:variable>
        <xsl:sequence select="$target-path[not(.=('.','value()'))]"/>
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
    <xsl:function name="m:condition" as="xs:string?">
        <!-- Insulate XPath here -->
        <xsl:param name="whose" as="element()"/>
        <xsl:variable name="whose-context" as="xs:string?">
            <xsl:if test="matches($whose/@target,'\S') and not($whose/@target = ('.','value()'))">
                <xsl:apply-templates mode="rule-context" select="$whose/ancestor::require/ancestor::constraint"/>
            </xsl:if>
        </xsl:variable>
        <xsl:variable name="predicates" select="$whose/ancestor-or-self::*/@when ! ( $whose-context ! ('ancestor::' || . || '/') || . )"/>
        <xsl:variable name="target-exception" select="m:write-target-exception($whose/@target,$declaration-prefix)"/>
        
        <xsl:if test="exists(($predicates, $target-exception))">
            <xsl:value-of select="string-join(($predicates, $target-exception),' and ')"/>
        </xsl:if>
    </xsl:function>
    
    <!-- similar to m:condition, except relative to an aggregation not a single node -->
    <xsl:function name="m:wrapper-condition" as="xs:string?">
        <!-- Insulate XPath here -->
        <xsl:param name="whose" as="element()"/>
        <xsl:variable name="predicates" select="$whose/ancestor-or-self::*/@when"/>
        
        <xsl:if test="exists($predicates)">
            <xsl:value-of select="string-join($predicates,' and ')"/>
        </xsl:if>
    </xsl:function>
    
    <xsl:function name="m:conditional-plural" as="xs:string?">
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
    
    <xsl:template match="m:index | m:is-unique" mode="make-key">
        <xsl:variable name="context">
            <xsl:apply-templates select=".." mode="rule-context"/>
            <xsl:for-each select="@target[not(.=('.','value()'))]">
                <xsl:text>/</xsl:text>
                <xsl:sequence select="m:target-match(..) => replace('^(\./)+','')"/>
            </xsl:for-each>
        </xsl:variable>
        <XSLT:key name="{@name}" match="{$context}" use="{m:key-value(.)}"/>
    </xsl:template>
    
    <xsl:function name="m:key-value" as="xs:string">
        <xsl:param name="whose" as="element()"/>
        <!-- delimit values with '|' emitting 'string()' for any key-field with no @target or @target=('.','value()') -->
        <xsl:value-of separator="|">
            <xsl:sequence select="$whose/m:key-field/@target/m:prefixed-path((.[not(.=('.','value()'))],'string(.)')[1],$declaration-prefix)"/>
        </xsl:value-of>
    </xsl:function>
</xsl:stylesheet>