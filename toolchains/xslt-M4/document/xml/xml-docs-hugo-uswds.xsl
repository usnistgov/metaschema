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


<!-- TO DO:
   hide list of attributes on section title when "Attributes" is expanded
   expand Remarks to be open on page load (closable)
   
   into Hugo
     generate and provide to Hugo 'partial' file
     update CSS and test binding
   next integrate into CI/CD script
   
   -->
   
   
   <xsl:mode on-no-match="text-only-copy"/>
   
   <!--<xsl:param name="schema-path" select="document-uri(/)"/>-->
   
<!--  XXX TO DO XXX -->
   <xsl:param name="content-converter-path" select="'#'"/>
   
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
   
   <xsl:key name="using-name" match="flag | field | assembly | define-flag | define-field | define-assembly" use="m:use-name(.)"/>
   
   <xsl:variable name="file-map" as="map(xs:string, text())">
      <xsl:map>
         <xsl:map-entry key="'oscal-catalog'"  >catalog</xsl:map-entry>
         <xsl:map-entry key="'oscal-profile'"  >profile</xsl:map-entry>
         <xsl:map-entry key="'oscal-component'">component</xsl:map-entry>
         <xsl:map-entry key="'oscal-ssp'"      >ssp</xsl:map-entry>
         <xsl:map-entry key="'oscal-poam'"     >poam</xsl:map-entry>
         <xsl:map-entry key="'oscal-ap'"       >assessment-plan</xsl:map-entry>
         <xsl:map-entry key="'oscal-ar'"       >assessment-result</xsl:map-entry>
      </xsl:map>
   </xsl:variable>
   
   <xsl:template match="short-name" mode="schema-link" expand-text="true">
      <a href="https://pages.nist.gov/OSCAL/artifacts/xml/schema/oscal_{$file-map(.)}_schema.xsd">oscal_{$file-map(string(.))}_schema.xsd</a>
   </xsl:template>
   
   <xsl:template match="short-name" mode="converter-link" expand-text="true">
      <a href="https://pages.nist.gov/OSCAL/artifacts/xml/convert/oscal_{$file-map(.)}_json-to-xml-converter.xsl">oscal_{$file-map(string(.))}_json-to-xml-converter.xsl</a>
   </xsl:template>
   
   <xsl:template match="/" mode="make-page">
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
   
   
   
   <xsl:template match="METASCHEMA">
      <xsl:variable name="definitions" select="define-assembly | define-field | define-flag"/>
      <div class="{$metaschema-code ! replace(.,'.*-','') }-docs">
         <!--<xsl:apply-templates select="short-name" mode="schema-link"/>
             <xsl:apply-templates select="short-name" mode="converter-link"/>-->
         <xsl:apply-templates select="* except $definitions"/>
         <xsl:apply-templates select="child::define-assembly | child::define-field" mode="make-definition">
            <xsl:sort select="m:use-name(.)"/>
            <xsl:with-param name="make-page-links" tunnel="true" select="true()"/>
         </xsl:apply-templates>
      </div>
   </xsl:template>
   
   <xsl:template match="METASCHEMA/schema-name"/>
   
   <xsl:template match="METASCHEMA/namespace">
      <p>
         <span class="usa-tag">XML namespace</span>
         <xsl:text> </xsl:text>
         <code>
            <xsl:apply-templates/>
         </code>
      </p>
   </xsl:template>
   
   <xsl:template match="description">
      <xsl:variable name="is-global" select="exists(parent::*/parent::METASCHEMA)"/>
      <p class="description{ ' global'[$is-global]}">
         <!--<span class="usa-tag">Description</span>
         <xsl:text> </xsl:text>-->
         <xsl:apply-templates/>
      </p>
   </xsl:template>
   
   <xsl:template match="*" mode="link-here">
      <!-- forcing names in top-down order     -->
      <a href="#local_{string-join( (ancestor::*|.)/(@name|@ref),'-')}" class="name-link"><xsl:value-of select="m:use-name(.)"/></a>
   </xsl:template>
   
   <xsl:template match="METASCHEMA/define-assembly | METASCHEMA/define-field" mode="link-here">
      <a href="#global_{@name}" class="name-link"><xsl:value-of select="m:use-name(.)"/></a>
   </xsl:template>
   
   <xsl:template name="definition-header">
      <xsl:param name="using-names"
         select="if (exists(root-name)) then (root-name, use-name)
            else (if (exists(use-name)) then use-name
               else key('references', @name)/(use-name, @ref)[1])"/>
      <div class="definition-header">
         <xsl:call-template name="cross-links"/>
         <h2 class="toc1" id="global_{@name}_h2">
            <span class="defining">
               <xsl:for-each-group select="$using-names" group-by="string(.)">
                  <xsl:if test="position() gt 1">, </xsl:if>
                  <span class="usename">
                     <xsl:value-of select="current-grouping-key()"/>
                  </span>
               </xsl:for-each-group>
            </span>
         </h2>
         <xsl:for-each select="formal-name">
            <p>
               <span class="usa-tag">formal name</span>
               <xsl:text> </xsl:text>
               <span class="frmname">
                  <xsl:apply-templates/>
               </span>
            </p>
         </xsl:for-each>
      </div>
   </xsl:template>
   
   <xsl:template name="remarks-group">
      <!-- can't use xsl:where-populated due to the header :-( -->
      <xsl:for-each-group select="remarks[not(@class != 'xml')]" group-by="true()">
         <div class="remarks-group">
            <details open="open">
            <summary class="subhead">Remarks</summary>
            <xsl:apply-templates select="current-group()"/>
         </details>
         </div>
      </xsl:for-each-group>
   </xsl:template>
   
   <xsl:template match="code[. = (/*/@name except ancestor::*/@name)]">
      <a href="#{.}">
         <xsl:next-match/>
      </a>
   </xsl:template>
   
   
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
      <style type="text/css" class="doe">
         <xsl:sequence select="unparsed-text('../hugo-uswds.css','utf-8') ! replace(.,'#xD;','')"/>
      </style>
   </xsl:template>
   
   <xsl:template mode="occurrence-code" match="*">
      <xsl:variable name="minOccurs" select="(@min-occurs,'0')[1]"/>
      <xsl:variable name="maxOccurs" select="(@max-occurs,'1')[1] ! (if (. eq 'unbounded') then '&#x221e;' else .)"/>
      <span class="cardinality">
         <xsl:text>[</xsl:text>
         <xsl:choose>
            <xsl:when test="$minOccurs = $maxOccurs" expand-text="true">{ $minOccurs }</xsl:when>
            <xsl:when test="number($maxOccurs) = number($minOccurs) + 1" expand-text="true">{ $minOccurs } or { $maxOccurs }</xsl:when>
            <xsl:otherwise expand-text="true">{ $minOccurs } to { $maxOccurs }</xsl:otherwise>
         </xsl:choose>
         <xsl:text>]</xsl:text>
      </span>
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
      <div class="definition define-flag" id="global_{@name}">
         <xsl:call-template name="definition-header"/>
         <xsl:apply-templates select="description"/>
         <xsl:apply-templates select="." mode="representation-in-xml"/>
         <xsl:for-each-group select="key('references',@name)/parent::*" group-by="true()">
            <p><xsl:text>This attribute appears on: </xsl:text>
               <xsl:for-each-group select="current-group()" group-by="@name">
                  <xsl:if test="position() gt 1 and last() ne 2">, </xsl:if>
                  <xsl:if test="position() gt 1 and position() eq last()"> and </xsl:if>
                  <xsl:apply-templates select="." mode="link-here"/>
               </xsl:for-each-group>.</p>
         </xsl:for-each-group>
         <xsl:call-template name="remarks-group"/>
         <xsl:call-template name="report-module"/>
      </div>
   </xsl:template>

   <xsl:template match="define-field" mode="make-definition">
      <div class="definition define-field" id="global_{@name}">
         <xsl:call-template name="definition-header"/>
         <xsl:apply-templates select="formal-name | description"/>
         <xsl:apply-templates mode="representation-in-xml" select="."/>
         <xsl:call-template name="appears-in"/>
         <xsl:call-template name="remarks-group"/>
         <xsl:call-template name="flags-for-field"/>
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
               <xsl:apply-templates select="$flags"/>
            </ul>
         </div>
      </xsl:if>
   </xsl:template>

   <xsl:template match="define-assembly" mode="make-definition">
      <div class="definition define-assembly" id="global_{@name}">
         <xsl:call-template name="definition-header"/>
         <xsl:apply-templates select="formal-name | description"/>
         <xsl:for-each select="root-name">
            <h5><code xsl:expand-text="true">{ . }</code> is a root (containing) element in this schema. </h5>
         </xsl:for-each>
         <xsl:call-template name="appears-in"/>
         <xsl:call-template name="remarks-group"/>
         <xsl:for-each-group select="define-flag | flag" group-by="true()" expand-text="true">
               <div class="model attributes">
                  <h4 class="subhead">{ if (count(current-group()) eq 1) then 'Attribute' else 'Attributes' } ({ count(current-group()) })</h4>
                  <ul>
                     <xsl:apply-templates select="current-group()">
                        <xsl:with-param name="make-page-links" tunnel="true" select="false()"/>
                     </xsl:apply-templates>
                  </ul>
               </div>
         </xsl:for-each-group>
         <xsl:apply-templates select="model"/>
         <xsl:apply-templates select="example"/>
         <xsl:call-template name="report-module"/>
      </div>
   </xsl:template>

   <xsl:template name="appears-in">
      <xsl:variable name="flag-references" select="key('references', @name)/self::flag"/>
      <xsl:variable name="field-references" select="key('references', @name)/self::field"/>
      <xsl:variable name="assembly-references" select="key('references', @name)/self::assembly"/>
      <xsl:variable name="references" select="$flag-references | $field-references | $assembly-references"/>
      <xsl:variable name="homonyms" select="key('using-name', m:use-name(.)) except (. | $references)"/>
      <xsl:call-template name="link-paragraph">
         <xsl:with-param name="link-to" select="$field-references | $assembly-references"/>
         <xsl:with-param name="statement">This element appears inside </xsl:with-param>
      </xsl:call-template>
      <xsl:call-template name="link-paragraph">
         <xsl:with-param name="link-to" select="$flag-references"/>
         <xsl:with-param name="statement">An attribute of this name is also defined for </xsl:with-param>
      </xsl:call-template>
      <xsl:call-template name="link-paragraph">
         <xsl:with-param name="link-to" select="$homonyms/self::define-field | $homonyms/self::define-assembly"/>
         <xsl:with-param name="statement">An element of this name is also defined for </xsl:with-param>
      </xsl:call-template>
   </xsl:template>
   
   <xsl:template name="link-paragraph">
      <xsl:param name="link-to"/>
      <xsl:param name="statement"/>
      <xsl:for-each-group select="$link-to" group-by="true()">
         <p><xsl:text expand-text="true">{ $statement }</xsl:text>
            <xsl:for-each
               select="current-group()/ancestor::*[self::define-field | self::define-assembly][1]">
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
   
<!-- list item templates  -->
   
   <xsl:template match="flag | define-flag">
      <li class="model-entry">
         <xsl:call-template name="model-description"/>
      </li>
   </xsl:template>
   
   <xsl:template match="field | define-field | assembly | define-assembly">
      <li class="model-entry">
         <xsl:call-template name="model-description"/>
      </li>
   </xsl:template>
   
   <xsl:template match="define-field[@as-type='markup-multiline'][@in-xml='UNWRAPPED']">
      <li class="model-entry">
         <p>An optional sequence of prose (markup) elements including <code>p</code>, lists, tables and headers (<code>h1-h6</code>).</p>
         <xsl:call-template name="model-description"/>
      </li>
   </xsl:template>
   
   <xsl:template match="*" mode="requirement"> [optional]</xsl:template>

   <xsl:template match="*[exists(@required)]" mode="requirement"> [required]</xsl:template>

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

   <xsl:template name="model-description">
      <xsl:apply-templates select="." mode="model-description"/>
   </xsl:template> 

   <xsl:template match="*" mode="model-description" expand-text="true">
      <xsl:message>UNEXPECTED MATCH ON { local-name() }</xsl:message>
   </xsl:template>
   
   <xsl:template match="*[exists(@ref)]" mode="model-description" expand-text="true">
      <xsl:param    name="make-page-links" tunnel="true" select="true()"/>
      <xsl:param    name="make-model-links" tunnel="true" select="true()"/>
      <xsl:variable name="definition" select="key('definitions', @ref)"/>
      <xsl:variable name="is-a-flag" select="exists(self::flag)"/>
      <xsl:variable name="too-deep" select="exists(ancestor::model[2])"/>
      <xsl:if test="empty($definition)">
         <xsl:message>NO DEFINITION FOUND FOR { local-name() }</xsl:message>
      </xsl:if>
      <div class="model-descr" tabindex="0">
         <div class="model-summary">
            <h3 class="usename{ ' toc2'[$make-model-links and not($is-a-flag) and not($too-deep)] }">
               <xsl:if test="$make-model-links">
                  <xsl:attribute name="id" select="'#local_' || string-join(ancestor-or-self::*/(@name|@ref), '-') || '_ref-h3'"/>
               </xsl:if>
               <xsl:value-of select="m:use-name(.)"/>
            </h3>
            <!--<h3 class="usename{ ' toc2'[not($is-a-flag) and not($too-deep)] }" id="#local_{string-join( ancestor-or-self::*/(@name|@ref),'-')}_ref-h3">{ m:use-name(.) }</h3>-->
            <!--<h3 class="usename{ ' toc2'[not($is-a-flag) and not($too-deep)] }">{ m:use-name(.) }</h3>-->
            <span class="mtyp">
               <xsl:apply-templates select="." mode="metaschema-type"/>
               <xsl:if test="empty($definition)">&#xA0;</xsl:if>
            </span>
            <span class="occurrence">
               <!-- should be 'requirement' with mode 'requirement' for flags -->
               <xsl:apply-templates select="self::flag | self::define-flag" mode="requirement"/>
               <xsl:apply-templates select=". except (self::flag | self::define-flag)"
                  mode="occurrence-code"/>
            </span>
            <span class="frmname">{ $definition/formal-name
               }{'&#xA0;'[empty($definition/formal-name)] }</span>
         </div>
         <xsl:apply-templates select="$definition/description"/>
         <xsl:apply-templates mode="make-link-to-global" select="."/>
         <xsl:for-each-group group-by="true()" select="remarks">
            <div class="remarks-group">
               <details open="open">
                  <summary class="subhead">Remarks (local)</summary>
                  <xsl:apply-templates select="current-group()"/>
               </details>
            </div>
         </xsl:for-each-group>
         <xsl:for-each-group group-by="true()" select="$definition/remarks">
            <div class="remarks-group">
               <details open="open">
                  <summary class="subhead">Remarks (general)</summary>
                  <xsl:apply-templates select="current-group()"/>
               </details>
            </div>
         </xsl:for-each-group>
         
         <xsl:call-template name="display-attributes">
            <xsl:with-param name="definition" select="$definition"/>
         </xsl:call-template>
         <!--<xsl:apply-templates mode="make-contents" select="."/>-->
         <xsl:call-template name="display-applicable-constraints"/>
      </div>
   </xsl:template>
      
   <xsl:template match="define-assembly | define-field | define-flag" mode="model-description" expand-text="true">
      <xsl:param    name="make-page-links" tunnel="true" select="true()"/>
      <xsl:param    name="make-model-links" tunnel="true" select="true()"/>
      <xsl:variable name="definition" select="."/>
      <xsl:variable name="is-local" select="empty(parent::METASCHEMA)"/>
      <xsl:variable name="too-deep" select="exists(ancestor::model[2])"/>
      <xsl:variable name="is-a-flag" select="exists(self::define-flag)"/>
      <div class="model-descr" tabindex="0">
         <xsl:if test="$make-model-links">
            <xsl:attribute name="id" select="'#local_' || string-join( ancestor-or-self::*/@name,'-')"/>
         </xsl:if>
         <div class="model-summary{ ' definition-header'[$is-local] }">
            <h3 class="usename{ ' toc2'[$make-model-links and not($is-a-flag) and not($too-deep)] }">
               <xsl:if test="$make-model-links">
                  <xsl:attribute name="id" select="'#local_' || string-join(ancestor-or-self::*/@name, '-') || '_def-h3'"/>
               </xsl:if>
               <xsl:value-of select="m:use-name(.)"/>
            </h3>
            <span class="mtyp">
               <xsl:apply-templates select="." mode="metaschema-type"/>
               <xsl:if test="empty($definition)">&#xA0;</xsl:if>
            </span>
            <span class="occurrence">
               <!-- should be 'requirement' with mode 'requirement' for flags -->
               <xsl:apply-templates select="self::flag | self::define-flag" mode="requirement"/>
               <xsl:apply-templates select=". except (self::flag | self::define-flag)"
                  mode="occurrence-code"/>
            </span>            
            <span class="frmname">{ $definition/formal-name }{'&#xA0;'[empty($definition/formal-name)] }</span>
         </div>
         <xsl:apply-templates select="$definition/description"/>
         <xsl:apply-templates mode="make-link-to-global" select="."/>
         <xsl:for-each-group group-by="true()" select="remarks">
            <div class="remarks-group">
               <details open="open">
                  <summary class="subhead">Remarks</summary>
                  <xsl:apply-templates select="current-group()"/>
               </details>
            </div>
         </xsl:for-each-group>    
   
         <xsl:call-template name="display-attributes">
            <xsl:with-param name="definition" select="$definition"/>
         </xsl:call-template>
         
         
         <xsl:apply-templates mode="make-contents" select="."/>
         <xsl:call-template name="display-applicable-constraints"/>
      </div>
   </xsl:template>
   
   <xsl:template name="display-attributes">
      <xsl:param name="definition" select="."/>
      <xsl:for-each-group select="$definition/(define-flag | flag)" group-by="true()" expand-text="true">
         <div class="attributes">
            <details open="open">
               <summary  class="subhead">
                  <xsl:text>{ if (count(current-group()) eq 1) then 'Attribute' else 'Attributes' } ({ count(current-group()) }): </xsl:text>
                  <xsl:for-each select="current-group()">
                     <xsl:if test="not(position() eq 1)">, </xsl:if>
                     <code>{ m:use-name(.) }</code>
                  </xsl:for-each></summary>
               <ul>
                  <xsl:apply-templates select="current-group()">
                     <xsl:with-param name="make-page-links" tunnel="true" select="false()"/>
                  </xsl:apply-templates>
               </ul>
            </details>
         </div>
      </xsl:for-each-group>
   </xsl:template>
   
   
   <xsl:template match="flag | define-flag | define-field | define-assembly" mode="make-link-to-global"/>
   
   <xsl:template match="*" mode="make-link-to-global" expand-text="true">
      <div class="deflink">
         <a href="#global_{@ref}">Link to <code>{ m:use-name(.) }</code> global definition to see contents.</a>
      </div>
   </xsl:template>
   
   <!-- Showing model contents only for local assembly definitions. -->
   <xsl:template match="*" mode="make-contents"/>
   
   <xsl:template match="define-assembly" mode="make-contents" expand-text="true">
      <xsl:apply-templates select="model" mode="#current"/>
   </xsl:template>
   
   <xsl:template match="define-assembly/model" mode="make-contents">
      <!-- for local define-assembly only, we dump -->
      <details open="open">
         <summary class="subhead">Element content<xsl:if test="count(*) > 1">s (in
            order)</xsl:if></summary>
         <ul>
            <xsl:apply-templates>
               <xsl:with-param name="make-page-links" tunnel="true" select="false()"/>
            </xsl:apply-templates>
         </ul>
      </details>
   </xsl:template>
      
   
   <xsl:template match="constraint" expand-text="true">
      <details  open="open" class="constraint-set">
         <xsl:variable name="constraints" select=".//allowed-values | .//matches | .//has-cardinality | .//is-unique | .//index-has-key | .//index"/>
         <summary class="subhead"><span class="usa-tag">{ if (count($constraints) eq 1) then 'constraint' else 'constraints'}</span> Defined in this context:</summary>
         <xsl:apply-templates select="$constraints"/>
      </details>
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
   
   <xsl:template match="*" mode="report-context" expand-text="true">
      <code>
         <xsl:for-each select="ancestor::define-field | ancestor::define-assembly">
            <xsl:if test="exists(ancestor::define-field | ancestor::define-assembly)">/</xsl:if>
            <xsl:value-of select="m:use-name(.)"/>
         </xsl:for-each>
         <xsl:for-each select="ancestor::define-flag">
            <xsl:if test="exists(ancestor::define-field | ancestor::define-assembly)">/</xsl:if>
            <xsl:text>@</xsl:text>
            <xsl:value-of select="m:use-name(.)"/>
         </xsl:for-each>
         <xsl:for-each select="ancestor::require">[{@when}]</xsl:for-each>
         <xsl:apply-templates select="." mode="report-target"/>
      </code>
   </xsl:template>
   
   <xsl:template match="*" mode="report-target">
      <xsl:text>/</xsl:text>
      <xsl:value-of select="@target"/>
   </xsl:template>
   
   <xsl:template priority="3" mode="report-target" match="has-cardinality"/>
   
   <xsl:template priority="2" mode="report-target" match="*[empty(@target) or @target=('.','value()')]"/>
   
   <xsl:template priority="2" match="allowed-values" expand-text="true">
      <xsl:variable name="enums" select="enum"/>
      <div class="constraint">
         <p>
            <span class="usa-tag">constraint</span>
            <xsl:apply-templates select="." mode="report-context"/>
            <span class="cnstr-tag">allowed value{ 's'[count($enums) gt 1] }</span>
            <xsl:for-each select="enum">
               <xsl:if test="position() gt 1"> | </xsl:if>
               <strong>{ @value }</strong>
            </xsl:for-each>
         </p>
         <xsl:choose expand-text="true">
            <xsl:when test="@allow-other and @allow-other = 'yes'">
               <p>The value may be locally defined, or { 'one of '[count($enums) gt 1] }the
                  following ({count($enums)}):</p>
            </xsl:when>
            <xsl:otherwise>
               <p>The value must be one of the following ({count(enum)}):</p>
            </xsl:otherwise>
         </xsl:choose>
         <ul>
            <xsl:apply-templates/>
         </ul>
      </div>
   </xsl:template>
   
   <xsl:template priority="2" match="matches[@regex]" expand-text="true">
      <xsl:variable name="target" select="@target[not(.=('.','value()'))]"/>
      <div class="constraint">
         <p>
            <span class="usa-tag">constraint</span>
          <xsl:apply-templates select="." mode="report-context"/>
            <span class="cnstr-tag">match</span>
         <xsl:text expand-text="true"> a target (value) must match the regular expression '{ @regex }'.</xsl:text></p>
      </div>
   </xsl:template>
   
   
   <xsl:template priority="2" match="matches[@datatype]" expand-text="true">
      <div class="constraint">
         <p>
            <span class="usa-tag">constraint</span>
            <xsl:apply-templates select="." mode="report-context"/>
            <span class="cnstr-tag">match</span>
         <xsl:text>the target value must match the lexical form of the '{ @datatype }' data type.</xsl:text></p>
      </div>
   </xsl:template>
   
   <xsl:template priority="2" match="is-unique">
      <xsl:variable name="target" select="@target[not(.=('.','value()'))]"/>
      <div class="constraint">
         <p>
            <span class="usa-tag">constraint</span>
            <xsl:apply-templates select="." mode="report-context"/>
            <span class="cnstr-tag">uniqueness rule</span>
           <xsl:text>: any target value must be unique (i.e., occur only once)</xsl:text>
         </p>
      </div>
   </xsl:template>
   
   <xsl:template priority="2" match="has-cardinality" expand-text="true">
      <div class="constraint">
         <p>
            <span class="usa-tag">constraint</span>
            <xsl:apply-templates select="." mode="report-context"/>
            <span class="cnstr-tag">cardinality rule</span>
            <xsl:text> the cardinality of  </xsl:text>
            <code>{ @target }</code>
            <xsl:text> is constrained: </xsl:text>
            <b>{ (@min-occurs,0)[1] }</b>
            <xsl:text>; maximum </xsl:text>
            <b>{ (@max-occurs,'unbounded')[1]}</b>.</p>
      </div>
   </xsl:template>
   
   <xsl:template priority="2" match="index-has-key" expand-text="true">
      <xsl:variable name="target" select="@target[not(.=('.','value()'))]"/>
      <div class="constraint">
         <p>
            <span class="usa-tag">constraint</span>
            <xsl:apply-templates select="." mode="report-context"/>
            <span class="cnstr-tag">index rule</span>
            <xsl:text>this value must correspond to a listing in the index </xsl:text>
              <code>{ @name }</code>
            <xsl:text> using a key constructed of key field(s) </xsl:text>
            <xsl:for-each select="key-field">
               <xsl:if test="position() gt 1">; </xsl:if>
               <code>
                  <xsl:value-of select="@target"/>
               </code>
            </xsl:for-each>
         </p>
      </div>
   </xsl:template>
   
   <xsl:template priority="2" match="index" expand-text="true">
      <div class="constraint">
         <p>
            <span class="usa-tag">constraint</span>
            <xsl:apply-templates select="." mode="report-context"/>
            <span class="cnstr-tag">index definition</span>
            <xsl:text> an index </xsl:text>
            <code>{ @name }</code>
            <xsl:text> shall list values returned by targets </xsl:text>
            <code>{ @target }</code>
            <xsl:text> using keys constructed of key field(s) </xsl:text>
            <xsl:for-each select="key-field">
               <xsl:if test="position() gt 1">; </xsl:if>
               <code>
                  <xsl:value-of select="@target"/>
               </code>
            </xsl:for-each>
         </p>
      </div>
   </xsl:template>
   
   <!-- Only display allowed-values for now -->
   <xsl:template name="display-applicable-constraints">
      <xsl:variable name="context" select="."/>
      <xsl:variable name="applicable-constraints" select="key('constraints-for-target',m:use-name(.))[m:include-constraint(.,$context)]"/>
      <xsl:for-each-group select="$applicable-constraints" group-by="true()" expand-text="true">
         <div class="constraints">
            <xsl:apply-templates select="$applicable-constraints/self::allowed-values"/>
            <!--<xsl:for-each-group select="$applicable-constraints except $applicable-constraints/self::allowed-values" group-by="true()">
               <details>
                  <summary class="subhead">Applicable { if (count(current-group()) eq 1) then 'constraint' else 'constraints' } ({ count(current-group()) })</summary>
                  <xsl:apply-templates select="current-group()"/>
               </details>
            </xsl:for-each-group>-->
         </div>
      </xsl:for-each-group>
   </xsl:template>  
   
<!-- key 'constraints-for-target' is too greedy: for a reference appearing in a local definition,
     the definition context can exclude constraints that are defined to apply to the node in other contexts.
     This filter returns 'true' pairwise for any constraint and context-indicating element (whether definition or reference),
     when the two overlap. This must account for when constraints designate multiple targets. -->
   <xsl:function name="m:include-constraint" as="xs:boolean">
      <xsl:param name="constraint" as="element()"/><!-- has-cardinality, matches, allowed-values etc -->
      <xsl:param name="context"    as="element()"/><!-- assembly, field, flag, define-assembly, define-field, define-flag -->
      <xsl:variable name="context-path" select="string-join($context/(ancestor::* | .) ! m:use-name(.),'/')"/>
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
      <!-- debugging <xsl:if test="contains($context-path,'control')">
         <xsl:message expand-text="true">on { name($constraint)}, testing { $context-path } against { string-join($constraint-targets,', ')} getting { m:match-paths($constraint-targets[1],$context-path)}</xsl:message>
      </xsl:if>-->
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

   <xsl:template match="example"/>
   
   <xsl:template match="example" mode="dev">
      <xsl:variable name="example-no" select="'example' || count(.|preceding-sibling::example)"/>
      <div class="example usa-accordion">
         <h4>
            <button class="usa-accordion__button" aria-expanded="true"
               aria-controls="{ ../@name }_{$example-no}_xml">
               <xsl:text>Example</xsl:text>
               <xsl:for-each select="description">: <xsl:apply-templates/></xsl:for-each>
            </button>
         </h4>
         <div id="{ m:use-name(..) }_{ $example-no }_xml" class="example-content usa-accordion__content usa-prose">
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

  <!-- mode as-example filters metaschema elements from elements representing examples -->
   <xsl:template match="m:*" xmlns:m="http://csrc.nist.gov/ns/oscal/metaschema/1.0"
      mode="as-example"/>

   <xsl:template match="*" mode="as-example">
      <xsl:apply-templates select="." mode="serialize"/>
   </xsl:template>


   <xsl:template match="define-flag" mode="representation-in-xml">
      <p>An attribute <xsl:apply-templates select="." mode="metaschema-type"/>.</p>
   </xsl:template>

   <xsl:template match="define-field" mode="representation-in-xml">
      <xsl:variable name="unwrapped-occurrences" select=".[@in-xml='UNWRAPPED'] | key('references',@name)[@in-xml='UNWRAPPED']"/>
      <xsl:variable name="my-type">
         <xsl:apply-templates select="." mode="metaschema-type"/>
      </xsl:variable>
      <p>An element with a value of type <xsl:sequence select="$my-type"/>.</p>
      <xsl:if test="normalize-space($my-type)='markup-multiline'">
      <p>As such, this element permits an <em>block-level HTML markup</em> subset, syntactically well-formed as XML (i.e. following XML syntax rules), including HTML elements <code>p</code>, <code>ul</code>, <code>ol</code> and others, along with a simple subset of inline <q>face</q> markup such as bold and italics. This format is designed for the relatively unconstrained capture of simple <q>free text</q>, i.e. without formatting or <q>decoration</q> that might serve as ad-hoc and uncontrolled semantic encoding not subject to detection, regularization or validation.</p>
      <p>This data construct is designed to be minimalistic for purposes of ease of development and interchange. It will not fit all operational scenarios; when <xsl:apply-templates select="." mode="metaschema-type"/> is not adequate for purposes of necessary (informational) fidelity to information encoded in source formats (and subsequently converted into OSCAL), alternative strategies are available for such data capture. Users and stakeholders who expose requirements in this area are encouraged to provide feedback and request guidance.</p>
      </xsl:if>
      <xsl:if test="exists($unwrapped-occurrences)">
         <p>
            <xsl:text>When appearing in </xsl:text>
            <xsl:for-each select="distinct-values($unwrapped-occurrences/ancestor::model/m:use-name(..))">
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
      <xsl:variable name="given-type" select="(@as-type, key('definitions', @ref)/@as-type, 'string')[1]"/>
      <a href="{$datatype-page}/#{(lower-case($given-type))}">
         <xsl:apply-templates mode="#current" select="$given-type"/>
      </a>
   </xsl:template>

   <xsl:template mode="metaschema-type" match="define-assembly">element</xsl:template>
   
   <xsl:template mode="metaschema-type" match="METASCHEMA/define-assembly"><a href="#global_{@name}">element (globally&#xA0;defined)</a></xsl:template>
   
   <xsl:template match="*" mode="metaschema-type">
      <xsl:message>Matching <xsl:value-of select="local-name()"/></xsl:message>
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
   
   <xsl:template match="define-assembly | define-field" mode="read-context">
      <xsl:if test="position() gt 1">/</xsl:if>
      <xsl:apply-templates select="@name"/>
   </xsl:template>
   
   <xsl:template match="define-flag" mode="read-context">
      <xsl:if test="position() gt 1">/@</xsl:if>
      <xsl:apply-templates select="@name"/>
   </xsl:template>
   
   <xsl:template match="require" mode="read-context">
      <xsl:text> when </xsl:text>
      <code>
         <xsl:apply-templates select="@when"/>
      </code>
   </xsl:template>
   
   <xsl:function name="m:use-name" as="xs:string?">
      <xsl:param name="who" as="element()"/>
      <xsl:variable name="definition" select="($who/key('definitions',@ref),$who)[1]"/>
      <xsl:value-of
         select="($who/self::any/'(ANY)', $who/root-name, $who/use-name, $definition/root-name, $definition/use-name, $definition/@name, '-')[1]"/>
   </xsl:function>
   
</xsl:stylesheet>
