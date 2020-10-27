<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet  version="3.0"
   xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
   xmlns:xs="http://www.w3.org/2001/XMLSchema"
   xmlns:m="http://csrc.nist.gov/ns/oscal/metaschema/1.0"
   xmlns="http://www.w3.org/1999/xhtml"
   
   xpath-default-namespace="http://csrc.nist.gov/ns/oscal/metaschema/1.0"
   exclude-result-prefixes="#all">

   <!-- Purpose: XSLT 3.0 stylesheet for Metaschema display (HTML): XML version -->
   <!-- Input:   Metaschema -->
   <!-- Output:  HTML  -->

   <xsl:mode on-no-match="text-only-copy"/>
   
   <xsl:param name="schema-path" select="document-uri(/)"/>

   <xsl:variable name="metaschema-code" select="/*/short-name || '-xml'"/>

   <xsl:variable name="datatype-page" as="xs:string">../../datatypes</xsl:variable>

   <xsl:strip-space elements="*"/>

   <xsl:preserve-space elements="p li pre i b em strong a code q"/>

   <xsl:output indent="yes"/>


   <!-- Purpose: XSLT 3.0 stylesheet for Metaschema display (HTML): common code -->
   <!-- Input:   Metaschema -->
   <!-- Output:  HTML  -->
   
   <xsl:import href="../../metapath/docs-metapath.xsl"/>
   
   <xsl:import href="../metaschema-htmldoc-xslt1.xsl"/>
   
   <xsl:variable name="home" select="/METASCHEMA"/>
   
   <xsl:variable name="all-references" select="//flag/@name | //model//*/@ref"/>
   
   <xsl:key name="definitions" match="/METASCHEMA/define-flag | /METASCHEMA/define-field | /METASCHEMA/define-assembly" use="@name"/>
   <xsl:key name="references" match="flag"             use="@ref"/>
   <xsl:key name="references" match="field | assembly" use="@ref"/>
   
   <xsl:template match="/">
      <html>
         <head>
            <xsl:call-template name="css"/>
         </head>
         <body>
            <!--<section>
               <xsl:for-each-group select="//constraint/(.|descendant::require)/(child::* except child::require)" group-by="m:path-key((@target,'.')[1])" expand-text="true">
                  <details>
                     <summary>Path key { current-grouping-key() }</summary>
                     <xsl:apply-templates select="current-group()" mode="build-index"/>
                  </details>
               </xsl:for-each-group> 
            </section>-->
            <xsl:apply-templates/>
         </body>
      </html>
   </xsl:template>
   
   <xsl:template mode="build-index" match="*">
      <details class="constraint-index">
         <xsl:apply-templates select=".." mode="constraint-context"/>
         <xsl:apply-templates select="."/>
      </details>
   </xsl:template>
   
   <xsl:template match="*" mode="constraint-context">
      <summary>In <xsl:apply-templates select="ancestor::define-assembly | ancestor::define-field | ancestor::define-flag" mode="read-context"/>
      <xsl:apply-templates select="ancestor::require" mode="read-context"/>
      </summary>
   </xsl:template>
   
   <xsl:template match="define-assembly | define-field | define-flag" mode="read-context">
      <xsl:if test="position() gt 1">/</xsl:if>
      <xsl:apply-templates select="@name"/>
   </xsl:template>
   
   <xsl:template match="require" mode="read-context">
      <xsl:text> when </xsl:text>
      <code>
        <xsl:apply-templates select="@when"/>
      </code>
   </xsl:template>
   
   
   <xsl:template match="METASCHEMA">
      <xsl:variable name="definitions" select="define-assembly | define-field | define-flag"/>
      <div class="{$metaschema-code ! replace(.,'.*-','') }-docs">
         <div class="top-level">
            <p><span class="usa-tag">Schema download</span>
               <xsl:text> </xsl:text>
               <a href="{$schema-path}">
                  <xsl:value-of select="replace($schema-path,'^.*/','')"/></a>
            </p>
            <xsl:apply-templates select="* except $definitions"/>
         </div>
         <xsl:apply-templates select="child::define-assembly" mode="make-definition">
            <xsl:with-param name="make-page-links" tunnel="true" select="true()"/>
         </xsl:apply-templates>
      </div>
   </xsl:template>
   
   
   <xsl:template match="METASCHEMA/schema-name"/>
   
   <xsl:template match="METASCHEMA/namespace">
      <p>
         <span class="label">XML namespace</span>
         <xsl:text> </xsl:text>
         <code>
            <xsl:apply-templates/>
         </code>
      </p>
   </xsl:template>
   
   <xsl:template match="description">
      <p class="description">
         <span class="usa-tag">Description</span>
         <xsl:text> </xsl:text>
         <xsl:apply-templates/>
      </p>
   </xsl:template>
   
   <xsl:template match="define-assembly | define-field | define-flag" mode="link-here">
      <a href="#{@name}"><xsl:value-of select="@name"/></a>
   </xsl:template>
   
   <xsl:template match="*[exists(@ref)]" mode="link-here">
      <a href="#{@ref}"><xsl:value-of select="@ref"/></a>
   </xsl:template>
   
   <xsl:template name="definition-header">
      <xsl:param name="using-names" select="
         if (exists(root-name)) then (root-name,use-name) else (if (exists(use-name)) then use-name else key('references',@name)/use-name)"/>
      <header class="definition-header">
         <xsl:call-template name="cross-links"/>
         <h2 id="{$metaschema-code}_{@name}" class="{substring-after(local-name(),'define-')}-header">
            <xsl:apply-templates select="m:use-name(.)" mode="tag"/>
            <xsl:if test="$using-names"> (</xsl:if>
            <xsl:for-each-group select="$using-names" group-by="string(.)">
               <xsl:if test="position() gt 1">, </xsl:if>
               <code>
                  <xsl:value-of select="current-grouping-key()"/>
               </code>
            </xsl:for-each-group>
            <xsl:if test="$using-names">)</xsl:if>
         </h2>
      </header>
      <xsl:apply-templates select="formal-name" mode="header"/>
   </xsl:template>
   
   <xsl:template match="formal-name" mode="header">
      <p class="formal-name">
         <span class="usa-tag">Name</span>
         <xsl:text> </xsl:text>
         <xsl:apply-templates/>
      </p>
   </xsl:template>
   
   <xsl:template name="remarks-group">
      <!-- can't use xsl:where-populated due to the header :-( -->
      <xsl:for-each-group select="remarks[not(@class != 'xml')]" group-by="true()">
         <details class="remarks-group">
            <summary class="h4"><span class="usa-tag">Remarks</span></summary>
            <xsl:apply-templates select="current-group()"/>
         </details>
      </xsl:for-each-group>
   </xsl:template>
   
   <xsl:template match="code[. = (/*/@name except ancestor::*/@name)]">
      <a href="#{.}">
         <xsl:next-match/>
      </a>
   </xsl:template>
   
   <!--<xsl:template mode="tag" match="@name">
         <code class="tagging"><xsl:value-of select="."/></code>   
      </xsl:template>
      
      <xsl:template mode="tag" match="root-name | use-name">
         <code class="tagging"><xsl:value-of select="."/></code>   
      </xsl:template>-->
   
   
   <!--<xsl:variable name="github-base" as="xs:string">https://github.com/usnistgov/OSCAL/tree/master</xsl:variable>-->
   
   <xsl:template name="report-module"/>
   
   <!--<xsl:template name="report-module-really">
         <xsl:variable name="metaschema-path" select="substring-after(.,'OSCAL/')"/>
      <xsl:for-each select="@module">
         <p class="text-accent-warm-darker" xsl:expand-text="yes">
            <xsl:text>Module defined: </xsl:text>
            <a href="{ $github-base}/{ $metaschema-path}">{
               replace(.,'.*/','') }</a></p>
      </xsl:for-each>
   </xsl:template>-->
   
   <xsl:template match="example[empty(* except (description | remarks))]"/>
   
   
   <xsl:template name="css">
      <style type="text/css">
         <xsl:sequence select="unparsed-text('../hugo-uswds.css','utf-8') ! replace(.,'#xD;','')"/>
      </style>
   </xsl:template>
   
   <xsl:template mode="occurrence-code" match="*">
      <xsl:variable name="minOccurs" select="(@min-occurs,'0')[1]"/>
      <xsl:variable name="maxOccurs" select="(@max-occurs,'1')[1] ! (if (. eq 'unbounded') then '&#x221e;' else .)"/>
      <i class="occurrence">
         <xsl:text>[</xsl:text>
         <xsl:choose>
            <xsl:when test="$minOccurs = $maxOccurs" expand-text="true">{ $minOccurs }</xsl:when>
            <xsl:when test="number($maxOccurs) = number($minOccurs) + 1" expand-text="true">{ $minOccurs } or { $maxOccurs }</xsl:when>
            <xsl:otherwise expand-text="true">{ $minOccurs } to { $maxOccurs }</xsl:otherwise>
         </xsl:choose>
         <xsl:text>]</xsl:text>
      </i>
   </xsl:template>
   
   <!-- Returns true when a field must become an object, not a string, due to having
     flags that must be properties. -->
   <xsl:function name="m:has-properties" as="xs:boolean">
      <xsl:param name="who" as="element()"/>
      <xsl:sequence select="exists($who/(define-flag|flag)[not((@name|@ref)=../(json-key | json-value-key)/@flag-name)])"/>
   </xsl:function>
   
   <!-- ^V^V^V^V^V^V^V^V^V^V^V^V^V^V^V^V^V^V^V^V^V^V^V^V^V^V^V^V^V^V^V^V^V^V^V^V -->

   <xsl:template name="cross-links">
      <xsl:param name="make-page-links" select="false()" tunnel="true"/>
      <xsl:variable name="schema-base" select="replace($metaschema-code,'-xml$','')"/>
      <xsl:if test="$make-page-links">
      <div class="crosslink">
         <a href="../json-schema/#{$schema-base}-json_{ @name}">
            <button class="schema-link">Switch to JSON</button>
         </a>
      </div>
      </xsl:if>
   </xsl:template>

   <xsl:template match="define-flag" mode="make-definition">
      <div class="definition define-flag" id="{@name}">
         <xsl:call-template name="definition-header"/>
         <xsl:apply-templates select="description"/>
         <xsl:apply-templates select="." mode="representation-in-xml"/>
         <xsl:for-each-group select="key('references',@name)/parent::*" group-by="true()">
            <p><xsl:text>This attribute appears on: </xsl:text>
               <xsl:for-each-group select="current-group()" group-by="(@ref|@name)">
                  <xsl:if test="position() gt 1 and last() ne 2">, </xsl:if>
                  <xsl:if test="position() gt 1 and position() eq last()"> and </xsl:if>
                  <xsl:apply-templates select="." mode="link-here"/>
               </xsl:for-each-group>.</p>
         </xsl:for-each-group>
         <xsl:apply-templates select="constraint"/>
         <xsl:call-template name="remarks-group"/>
         <xsl:call-template name="report-module"/>
      </div>
   </xsl:template>

   <xsl:template match="define-field" mode="make-definition">
      <div class="definition define-field" id="{@name}">
         <xsl:call-template name="definition-header"/>
         <xsl:apply-templates select="formal-name | description"/>
         <xsl:apply-templates mode="representation-in-xml" select="."/>
         <xsl:call-template name="appears-in"/>
         <xsl:call-template name="flags-for-field"/>
         <xsl:apply-templates select="constraint"/>
         <xsl:call-template name="remarks-group"/>
         <xsl:apply-templates select="example"/>
         <xsl:call-template name="report-module"/>
      </div>
   </xsl:template>
   
   <xsl:template name="flags-for-field">
      <xsl:variable name="flags" select="flag | define-flag"/>
      <xsl:if test="exists($flags)">
         <xsl:variable name="modal">
            <xsl:choose>
               <xsl:when
                  test="every $f in ($flags)
                        satisfies $f/@required = 'yes'"
                  >must</xsl:when>
               <xsl:otherwise>may</xsl:otherwise>
            </xsl:choose>
         </xsl:variable>
         <xsl:variable name="noun">
            <xsl:choose>
               <xsl:when test="count($flags) gt 1">attributes</xsl:when>
               <xsl:otherwise>the attribute</xsl:otherwise>
            </xsl:choose>
         </xsl:variable>
         <div class="model">
            <p xsl:expand-text="true">The <code>{@name}</code> element { $modal } have { $noun
               }:</p>
            <ul>
               <xsl:apply-templates select="$flags" mode="model"/>
            </ul>
         </div>
      </xsl:if>
   </xsl:template>

   <xsl:template match="define-assembly" mode="make-definition">
      <div class="definition define-assembly" id="{@name}">
         <xsl:call-template name="definition-header"/>
         <xsl:apply-templates select="formal-name | description"/>
         <xsl:for-each select="root-name">
            <h5><code xsl:expand-text="true">{ . }</code> is a root (containing) element in this schema. </h5>
         </xsl:for-each>
         <xsl:call-template name="appears-in"/>
         <xsl:for-each-group select="define-flag | flag" group-by="true()">
            <xsl:where-populated>
               <div class="model attributes">
                  <h4 class="subhead">Attributes:</h4>
                  <ul>
                     <xsl:apply-templates select="current-group()">
                        <xsl:with-param name="make-page-links" tunnel="true" select="false()"/>
                     </xsl:apply-templates>
                  </ul>
               </div>
            </xsl:where-populated>
         </xsl:for-each-group>
         <xsl:apply-templates select="model"/>
         <xsl:apply-templates select="constraint"/>
         <xsl:call-template name="remarks-group"/>
         <xsl:apply-templates select="example"/>
         <xsl:call-template name="report-module"/>
         <xsl:variable name="local-definitions" as="element()*">
            <xsl:apply-templates select="model" mode="make-definition">
               <xsl:with-param tunnel="true" name="make-page-links" select="false()"/>
            </xsl:apply-templates>
         </xsl:variable>
         <xsl:if test="exists($local-definitions)" expand-text="true">
         <details style="background-color: lightsteelblue; border: thin solid midnightblue; padding: 0.5em">
            <summary class="h5 display-face">Local element definitions</summary>
            <xsl:sequence select="$local-definitions"/>
         </details>
         </xsl:if>
      </div>
   </xsl:template>

   <xsl:template name="appears-in">
      <xsl:for-each-group select="key('references', @name)/ancestor::model/parent::*"
         group-by="true()">
         <p><xsl:text>This element appears inside: </xsl:text>
            <xsl:for-each select="current-group()">
               <xsl:if test="position() gt 1 and last() ne 2">, </xsl:if>
               <xsl:if test="position() gt 1 and position() eq last()"> and </xsl:if>
               <xsl:apply-templates select="." mode="link-here"/>
            </xsl:for-each>.</p>
      </xsl:for-each-group>
   </xsl:template>

  <xsl:template match="@name | @ref">
      <code>
         <xsl:value-of select="."/>
      </code>
   </xsl:template>

   <xsl:template match="*[use-name|root-name]/@name | *[use-name]/@ref">
      <code>
         <xsl:apply-templates select="parent::*/use-name"/>
      </code>
   </xsl:template>
   
   
   <xsl:template match="define-flag/@name | flag/@name">
      <code>
         <xsl:value-of select="."/>
      </code>
   </xsl:template>

   <xsl:template match="flag | define-flag">
      <li class="model-entry">
         <p>
            <xsl:apply-templates mode="link-here" select="key('definitions', @ref)"/>
            <xsl:if test="empty(@ref)">
               <a id="{../@name}-{@name}">
                  <xsl:apply-templates select="@name"/>
               </a>
            </xsl:if>
            <xsl:text> attribute </xsl:text>
            <xsl:apply-templates select="." mode="metaschema-type"/>
            <xsl:apply-templates select="." mode="requirement"/>
            <xsl:apply-templates select="if (description) then description else key('definitions', @ref)/description" mode="model"/>
         </p>
         <xsl:call-template name="display-constraints"/>
         <!--<xsl:apply-templates select="constraint"/>-->
         <xsl:apply-templates select="remarks" mode="model"/>
         <!--<details>
            <summary><span class="usa-tag">Definition</span></summary>
            <xsl:apply-templates select="." mode="make-definition"/>
         </details>-->
      </li>
   </xsl:template>

   <xsl:template match="*" mode="requirement">
      <i class="occurrence"> [optional]</i>
   </xsl:template>

   <xsl:template match="*[exists(@required)]" mode="requirement">
      <i class="occurrence"> [required]</i>
   </xsl:template>

   <xsl:template match="model[not(*)]" priority="3"/>

   <xsl:template match="model">
      <div class="model">
         <h4 class="subhead">Contains<xsl:if
               test="count(*) > 1"> (in order)</xsl:if>:</h4>
         <ul>
            <xsl:apply-templates>
               <xsl:with-param name="make-page-links" tunnel="true" select="false()"/>
            </xsl:apply-templates>
         </ul>
      </div>
   </xsl:template>

   <xsl:template match="any">
      <li>Any element (in a foreign namespace)</li>
   </xsl:template>

   <xsl:template match="assembly">
      <li class="model-entry">
         <p>
            <!--<xsl:text>A</xsl:text>
         <xsl:if test="not(translate(substring(@ref, 1, 1), 'AEIOUaeiuo', ''))">n</xsl:if>
         <xsl:text> </xsl:text>-->
            <a href="#{@ref}">
               <xsl:apply-templates select="@ref"/>
            </a>
            <xsl:text expand-text="true"> element{ if (@max-occurs != '1') then 's' else '' } </xsl:text>
            <xsl:apply-templates select="." mode="metaschema-type"/>
            <xsl:apply-templates select="." mode="occurrence-code"/>
            <xsl:apply-templates mode="model"
               select="if (description) then description else key('definitions', @ref)/description"/>
         </p>
         <xsl:apply-templates select="remarks" mode="model"/>
         <xsl:call-template name="display-constraints"/>
      </li>
   </xsl:template>
   
   <xsl:template match="constraint" expand-text="true">
      <details class="constraint-set" style="background-color: lightsteelblue; padding: 0.5em; margin: 0.5em; border: thin solid midnightblue">
         <xsl:variable name="constraints" select=".//allowed-values | .//matches | .//has-cardinality | .//is-unique | .//index-has-key"/>
         <summary class="h4"><span class="usa-tag">{ if (count($constraints) eq 1) then 'constraint' else 'constraints'}</span> Defined in this context:</summary>
         <xsl:apply-templates select="$constraints"/>
      </details>
   </xsl:template>
   
   <xsl:template priority="20" match="has-cardinality | index-has-key | index | matches | allowed-values | is-unique" expand-text="true">
      <xsl:variable name="step-context" select="m:constraint-key(.)"/>
      <xsl:variable name="definition-context" select="string-join(ancestor::*/(root-name,use-name,@name)[1],'/')"/>
      <div class="constraint" style="background-color: lavender; border: thin dotted black; padding: 0.3em; font-size: 90%">
         <p>Constraint: <b>{ local-name() }</b>. Definition context: <code>{ $definition-context }</code>.</p>
         <xsl:for-each-group select="ancestor::require" group-by="true()">
            <xsl:message expand-text="true">holla { ancestor::constraint/parent::*/m:use-name(.) } [{ @when }]</xsl:message>
            <p>
               <xsl:text>Contingency: apply this constraint when the context has </xsl:text>
               <xsl:call-template name="and-code-sequence">
                  <xsl:with-param name="what" select="current-group()/@when"/>
               </xsl:call-template>
            </p>
         </xsl:for-each-group>
         <p><xsl:text>Given target:  </xsl:text>
            <xsl:choose>
               <xsl:when test="exists(@target)"><code>{ @target  }</code></xsl:when>
               <xsl:otherwise>[defaulted]</xsl:otherwise>
            </xsl:choose>.</p>
         <p>Full target: <code>{ string-join(($definition-context,@target),'/') }</code></p>
         <xsl:next-match/>
      </div>
   </xsl:template>
   
   <xsl:template name="and-code-sequence">
      <xsl:param name="what" as="item()*"/>
      <xsl:for-each select="$what[position() lt last()]">
         <code>
            <xsl:value-of select="."/>
         </code>
      </xsl:for-each>
      <xsl:if test="count($what) gt 1"> and </xsl:if>
      <code>
         <xsl:value-of select="$what[last()]"/>
      </code>
   </xsl:template>
   
   <xsl:template priority="3" match="constraint//require">
         <xsl:apply-templates/>
   </xsl:template>
   
    
    <xsl:key name="constraints-for-target" match="index | index-has-key | is-unique | has-cardinality | allowed-values | matches" use="m:constraint-key(.)"/>
   

   
<!-- For multiple targets are given there could be multiple keys -->
   <xsl:function name="m:constraint-key" as="xs:string*">
      <xsl:param name="who" as="element()"/>
      <!--<xsl:value-of select="local-name($who)"/>-->
      <xsl:choose>
         <xsl:when test="$who/@target=('.','value()')">
            <xsl:sequence select="$who/ancestor::constraint/parent::*/m:use-name(.)"/>
         </xsl:when>
         <xsl:when test="empty($who/@target)">
            <xsl:sequence select="$who/ancestor::constraint/parent::*/m:use-name(.)"/>
         </xsl:when>
         <xsl:otherwise>
            <xsl:sequence select="($who/m:express-targets(@target) ! tokenize(.,'/')[last()]) => distinct-values()"/>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:function>
   
   <!--<xsl:function name="m:constraint-key" as="xs:string">
      <xsl:param name="who" as="element()"/>
      <xsl:text>boo</xsl:text>
   </xsl:function>-->
   
   <xsl:template priority="2" match="allowed-values[empty(@target) or @target=('.','value()')]">
      <xsl:choose expand-text="true">
         <xsl:when test="@allow-other and @allow-other='yes'">
            <p><span class="usa-tag">allowed value</span> The value may be locally defined, or one of the following:</p>
         </xsl:when>
         <xsl:otherwise>
            <p><span class="usa-tag">allowed value</span> The value must be one of the following:</p>
         </xsl:otherwise>
      </xsl:choose>
      <ul>
         <xsl:apply-templates/>
      </ul>   
   </xsl:template>
   
   <xsl:template priority="2" match="allowed-values[exists(@target) and not(@target=('.','value()'))]" expand-text="true">
      <xsl:variable name="target" select="@target[not(.=('.','value()'))]"/>
      <xsl:choose expand-text="true">
         <xsl:when test="@allow-other and @allow-other='yes'">
            <p><span class="usa-tag">allowed value</span> On target <code>{ @target }</code>, the value may be locally defined, or one of the following:</p>
         </xsl:when>
         <xsl:otherwise>
            <p><span class="usa-tag">allowed value</span> On target <code>{ @target }</code>, the value must be one of the following:</p>
         </xsl:otherwise>
      </xsl:choose>
      <ul>
         <xsl:apply-templates/>
      </ul>   
   </xsl:template>
   
   <xsl:template priority="2" match="matches[@regex][empty(@target) or @target=('.','value()')]" expand-text="true">
      <xsl:variable name="target" select="@target[not(.=('.','value()'))]"/>
      <p><span class="usa-tag">match constraint</span> In this scope, the values must match the regular expression '{ @regex }'.</p>
   </xsl:template>
   
   <xsl:template priority="2" match="matches[@regex][exists(@target) and not(@target=('.','value()'))]" expand-text="true">
      <p><span class="usa-tag">match constraint</span> In this scope, the value(s) of target(s) <code>{ @target }</code> must match the regular expression '{ @regex }'.</p>
   </xsl:template>
   
   
   
   <xsl:template priority="2" match="matches[@datatype][empty(@target) or @target=('.','value()')]" expand-text="true">
      <p><span class="usa-tag">match constraint</span> In this scope, the value must match the lexical form of the '{ @datatype }' data type.</p>
   </xsl:template>
   
   <xsl:template priority="2" match="matches[@datatype][exists(@target) and not(@target=('.','value()'))]" expand-text="true">
      <p><span class="usa-tag">match constraint</span> In this scope, the value(s) of target(s) <code>{ @target }</code> must match the lexical form of the '{ @datatype }' data type.</p>
   </xsl:template>
   
   <xsl:template priority="2" match="is-unique[empty(@target) or @target=('.','value()')]" expand-text="true">
      <xsl:variable name="target" select="@target[not(.=('.','value()'))]"/>
      <p><span class="usa-tag">uniqueness constraint</span> In this scope, the value must be unique (i.e., occur only once)</p>
   </xsl:template>
   
   <xsl:template priority="2" match="has-cardinality" expand-text="true">
      <p><span class="usa-tag">cardinality constraint</span> Within this scope, the cardinality of <code>{ @target }</code> is constrained:
         minimum <b>{ (@min-occurs,0)[1] }</b>; maximum <b>{ (@max-occurs,'unbounded')[1]}</b>.</p>
   </xsl:template>
   
   <xsl:template priority="2" match="is-unique[exists(@target) or not(@target=('.','value()'))]" expand-text="true">
      <xsl:variable name="target" select="@target[not(.=('.','value()'))]"/>
      <p><span class="usa-tag">uniqueness constraint</span> In this scope, the key (index) value assigned to each target(s) <code>{ @target }</code>
         <xsl:text> must be unique, as constructed from key field(s) </xsl:text>
         <xsl:for-each select="key-field"><xsl:if test="position() gt 1">; </xsl:if><code><xsl:value-of select="@target"/></code></xsl:for-each></p>
   </xsl:template>
   
   <xsl:template priority="2" match="index-has-key[empty(@target) or @target=('.','value()')]" expand-text="true">
      <xsl:variable name="target" select="@target[not(.=('.','value()'))]"/>
      <p><span class="usa-tag">indexing constraint</span> This value must correspond to a listing in the index <code>{ @name }</code>
         <xsl:text> using a key constructed of key field(s) </xsl:text>
         <xsl:for-each select="key-field"><xsl:if test="position() gt 1">; </xsl:if><code><xsl:value-of select="@target"/></code></xsl:for-each>.</p>
      <xsl:apply-templates/>
   </xsl:template>
   
   <xsl:template priority="2" match="index-has-key[exists(@target) and not(@target=('.','value()'))]" expand-text="true">
      <p><span class="usa-tag">indexing constraint</span> In this scope, any <code>{ @target }</code> must appear in the index <code>{ @name }</code>
         <xsl:text> using a key constructed of key field(s) </xsl:text>
         <xsl:for-each select="key-field"><xsl:if test="position() gt 1">; </xsl:if><code><xsl:value-of select="@target"/></code></xsl:for-each>.</p>
      <xsl:apply-templates/>
   </xsl:template>
   
   <xsl:template priority="2" match="index" expand-text="true">
      <p><span class="usa-tag">index definition</span> For this scope, an index <code>{ @name }</code> shall list values returned by <code>{ @target}</code>
         <xsl:text> using keys constructed of key field(s) </xsl:text>
         <xsl:for-each select="key-field"><xsl:if test="position() gt 1">; </xsl:if><code><xsl:value-of select="@target"/></code></xsl:for-each>.</p>
      <xsl:apply-templates/>
   </xsl:template>
   
   <xsl:template match="define-assembly | define-field">
      <li class="model-entry">
         <p>
            <!--<xsl:text>A</xsl:text>
         <xsl:if test="not(translate(substring(@ref, 1, 1), 'AEIOUaeiuo', ''))">n</xsl:if>
         <xsl:text> </xsl:text>-->
            <xsl:apply-templates select="@name"/>
            
            <xsl:text expand-text="true"> element{ if (@max-occurs != '1') then 's' else '' } </xsl:text>
            <xsl:apply-templates select="." mode="metaschema-type"/>
            <xsl:apply-templates select="." mode="occurrence-code"/>
            <xsl:apply-templates mode="model"
               select="if (description) then description else key('definitions', @ref)/description"/>
         </p>
         <xsl:call-template name="display-constraints"/>
         <!--<xsl:apply-templates select="constraint"/>-->
         <xsl:apply-templates select="remarks" mode="model"/>
         <!--<details>
            <summary><span class="usa-tag">Definition</span></summary>
            <xsl:apply-templates select="." mode="make-definition"/>
         </details>-->
      </li>
   </xsl:template>
   
   <xsl:template match="define-field[@as-type='markup-multiline'][@in-xml='UNWRAPPED']">
      <li class="model-entry">
         <p>An optional sequence of prose (markup) elements including <code>p</code>, lists, tables and headers (<code>h1-h6</code>).</p>
         <xsl:call-template name="display-constraints"/>
         <!--<details>
            <summary>Definition</summary>
            <xsl:apply-templates select="." mode="make-definition"/>
         </details>-->
      </li>
   </xsl:template>
   
   <xsl:template match="field">
      <li class="model-entry">
         <p>
            <!--<xsl:text>A</xsl:text>
         <xsl:if test="not(translate(substring(@ref, 1, 1), 'AEIOUaeiuo', ''))">n</xsl:if>
         <xsl:text> </xsl:text>-->
            <xsl:apply-templates select="@ref"/>
            <xsl:text expand-text="true"> element{ if (@max-occurs != '1') then 's' else '' } </xsl:text>
            <xsl:apply-templates select="." mode="metaschema-type"/>
            <xsl:apply-templates select="." mode="occurrence-code"/>
            <xsl:apply-templates mode="model"
               select="if (description) then description else key('definitions', @ref)/description"/>
         </p>
         <xsl:apply-templates select="remarks" mode="model"/>
         <xsl:call-template name="display-constraints"/>
         <!--<details>
            <summary>Definition</summary>
            <xsl:apply-templates select="." mode="make-definition"/>
         </details>-->
      </li>
   </xsl:template>
   
   <xsl:template name="display-constraints">
      <xsl:variable name="context" select="."/>
      <xsl:variable name="applicable-constraints" select="key('constraints-for-target',m:use-name(.))[m:include-constraint(.,$context)]"/>
      <xsl:for-each-group select="$applicable-constraints" group-by="true()">
         <details style="background-color: lemonchiffon; border: thin solid saddlebrown">
            <summary class="subhead">
               <xsl:text>Applicable </xsl:text>
               <xsl:value-of select="if (count(current-group()) eq 1) then 'constraint' else 'constraints'"/>
            </summary>
            <xsl:apply-templates select="current-group()"/>
         </details>
      </xsl:for-each-group>
   </xsl:template>  
   
<!-- key 'constraints-for-target' is too greedy: for a reference appearing in a local definition,
     the definition context can exclude constraints that are defined to apply to the node in other contexts.
     This filter returns 'true' pairwise for any constraint and context-indicating element (whether definition or reference),
     when the two overlap. This must account for when constraints designate multiple targets. -->
   <xsl:function name="m:include-constraint" as="xs:boolean">
      <xsl:param name="constraint" as="element()"/><!-- has-cardinality, matches, allowed-values etc -->
      <xsl:param name="context"    as="element()"/><!-- assembly, field, flag, define-field, define-flag -->
      <xsl:variable name="context-path" select="string-join($context/ancestor-or-self::*/m:use-name(.),'/')"/>
      <xsl:variable name="constraint-context-path" select="string-join($constraint/ancestor-or-self::*/m:use-name(.),'/')"/>
      <xsl:variable name="constraint-targets" as="xs:string*">
         <xsl:choose>
            <xsl:when test="empty($constraint/@target)">
               <xsl:sequence select="$constraint-context-path"/>
            </xsl:when>
            <xsl:otherwise>
               <xsl:sequence select="$constraint/@target/m:express-targets(.) ! string-join(($constraint-context-path,.[normalize-space(.)]),'/')"/>
            </xsl:otherwise>
         </xsl:choose>
      </xsl:variable>
      <xsl:if test="contains($context-path,'responsible-party')">
      <!--<xsl:message expand-text="true">on { name($constraint)}, testing { $context-path } against { string-join($constraint-targets,', ')}</xsl:message>-->
      </xsl:if>
      <xsl:sequence select="some $t in $constraint-targets satisfies
         m:match-paths($t,$context-path)"/>
   </xsl:function>
   
   <xsl:template mode="make-definition" match="field | flag | assembly"/>
   
   <!--<xsl:template mode="make-definition" match="field | flag | assembly"/>
      <xsl:apply-templates select="key('definitions',@ref)" mode="make-definition"/>
   </xsl:template>-->
   
   
   <!-- remarks are kept if @class='xml' or no class is given -->
   <xsl:template match="remarks[@class != 'xml']" priority="2"/>

   <xsl:template match="remarks[@class = 'xml']/p[1]">
      <p class="p">
         <span class="usa-tag">XML</span>
         <xsl:text> </xsl:text>
         <xsl:apply-templates/>
      </p>
   </xsl:template>

   <xsl:template match="remarks/p" mode="model #default">
      <p class="p">
         <xsl:apply-templates/>
      </p>
   </xsl:template>

   <xsl:template match="example">
      <xsl:variable name="example-no" select="'example' || count(.|preceding-sibling::example)"/>
      <div class="example usa-accordion">
         <h3>
            <button class="usa-accordion__button" aria-expanded="true"
               aria-controls="{ ../@name }_{$example-no}_xml">
               <xsl:text>Example</xsl:text>
               <xsl:for-each select="description">: <xsl:apply-templates/></xsl:for-each>
            </button>
         </h3>
         <div id="{ ../@name }_{ $example-no }_xml" class="example-content usa-accordion__content usa-prose">
            <xsl:apply-templates select="remarks"/>
            <pre>
               <!-- 'doe' span can be wiped in post-process, but permits disabling output escaping -->
               <span class="doe">&#xA;{{&lt; highlight xml "linenos=table" > }}&#xA;</span>
               <xsl:apply-templates select="*" mode="as-example"/>
               <span class="doe">&#xA;{{ &lt;/ highlight > }}&#xA;</span>
            </pre>
         </div>
      </div>
   </xsl:template>

   <xsl:template match="text()[not(matches(.,'\S'))]" mode="serialize">
      <xsl:param name="hot" select="false()"/>
      <xsl:if test="$hot">
         <xsl:value-of select="."/>
      </xsl:if>
   </xsl:template>

   <xsl:template match="*" mode="serialize">
<!-- goes $hot when inline markup is found  -->
      <xsl:param name="hot" select="false()"/>
      <!--<xsl:if test="not($hot)">
        <xsl:call-template name="indent-for-pre"/>
      </xsl:if>-->
      <xsl:text>&#xA;&lt;</xsl:text>
      <xsl:value-of select="local-name(.)"/>
      <xsl:for-each select="@*">
         <xsl:text> </xsl:text>
         <xsl:value-of select="local-name()"/>
         <xsl:text>="</xsl:text>
         <xsl:value-of select="."/>
         <xsl:text>"</xsl:text>
      </xsl:for-each>
      <xsl:text>&gt;</xsl:text>

      <xsl:apply-templates mode="serialize">
         <xsl:with-param name="hot" select="$hot or boolean(text()[normalize-space(.)])"/>
      </xsl:apply-templates>

      <!--<xsl:if test="not($hot)">
         <xsl:call-template name="indent-for-pre"/>
      </xsl:if>-->
      <xsl:if test="not(text()[normalize-space(.)])">&#xA;</xsl:if>
      <xsl:text>&lt;/</xsl:text>
      <xsl:value-of select="local-name(.)"/>
      <xsl:text>&gt;</xsl:text>
   </xsl:template>



   <!-- <xsl:template mode="get-example" match="example">
      <xsl:apply-templates select="*" mode="as-example"/>
   </xsl:template>-->

   <!--Not available in SaxonHE.-->
   <!--<xsl:template mode="get-example" match="example[@href castable as xs:anyURI]">
      <xsl:variable name="example">
        <xsl:evaluate context-item="document(@href)" xpath="@path"  namespace-context="."/>
      </xsl:variable>
      <xsl:apply-templates select="$example/*" mode="as-example"/>
   </xsl:template>-->

  <!-- mode as-example filters metaschema elements from elements representing examples -->
   <xsl:template match="m:*" xmlns:m="http://csrc.nist.gov/ns/oscal/metaschema/1.0"
      mode="as-example"/>

   <xsl:template match="*" mode="as-example">
      <xsl:apply-templates select="." mode="serialize"/>
   </xsl:template>


   <xsl:template match="define-flag" mode="representation-in-xml">
      <p>An attribute<xsl:apply-templates select="." mode="metaschema-type"/></p>
   </xsl:template>

   <xsl:template match="define-field" mode="representation-in-xml">
      <xsl:variable name="unwrapped-references" select=".[@in-xml='UNWRAPPED'] | key('references',@name)[@in-xml='UNWRAPPED']"/>
      <p>An element<xsl:apply-templates select="." mode="metaschema-type"/></p>

      <xsl:if test="exists($unwrapped-references)">
         <p>
            <xsl:text>When appearing in </xsl:text>
            <xsl:for-each select="distinct-values($unwrapped-references/ancestor::model/../@name)">
               <xsl:if test="position() gt 1 and last() ne 2">, </xsl:if>
               <xsl:if test="position() gt 1 and position() eq last()"> or </xsl:if>
               <a href="#{ . }" xsl:expand-text="true">{ . }</a>
            </xsl:for-each>
            <xsl:text> this element is </xsl:text>
            <em>implicit</em>
            <xsl:text>; only its contents appear.</xsl:text>
         </p>
      </xsl:if>
   </xsl:template>

   <xsl:template match="field | assembly" mode="metaschema-type">
      <xsl:apply-templates select="key('definitions',@ref)" mode="#current"/>
   </xsl:template>


   <xsl:template mode="metaschema-type" match="flag | define-flag | define-field">
      <xsl:variable name="given-type" select="(@as-type, key('definitions',@ref)/@as-type,'string')[1]"/>
      <xsl:text> </xsl:text>
      <b>
         <xsl:text>(</xsl:text>
         <a href="{$datatype-page}/#{(lower-case($given-type))}">
            <xsl:apply-templates mode="#current" select="$given-type"/>
         </a>
         <xsl:text>)</xsl:text>
      </b>
      <xsl:text> </xsl:text>
   </xsl:template>

   <xsl:template mode="metaschema-type" match="define-assembly"/>

   <xsl:template match="*" mode="metaschema-type">
      <xsl:message>Matching <xsl:value-of select="local-name()"/></xsl:message>
   </xsl:template>

   
   <xsl:function name="m:use-name" as="node()?">
      <xsl:param name="who" as="element()"/>
      <xsl:sequence
         select="$who/(self::define-assembly|self::define-field|self::define-flag|self::assembly|self::field|self::flag)/
         (root-name, use-name, key('definitions',@ref)/(root-name, use-name, @name), @name)[1]"/>
   </xsl:function>
   
   
            
   
</xsl:stylesheet>
