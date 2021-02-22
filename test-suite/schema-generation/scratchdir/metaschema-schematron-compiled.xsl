<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<xsl:stylesheet xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:xsd="http://www.w3.org/2001/XMLSchema"
                xmlns:saxon="http://saxon.sf.net/"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:schold="http://www.ascc.net/xml/schematron"
                xmlns:iso="http://purl.oclc.org/dsdl/schematron"
                xmlns:xhtml="http://www.w3.org/1999/xhtml"
                xmlns:m="http://csrc.nist.gov/ns/oscal/metaschema/1.0"
                xmlns:nm="http://csrc.nist.gov/ns/metaschema"
                version="2.0"><!--Implementers: please note that overriding process-prolog or process-root is 
    the preferred method for meta-stylesheets to use where possible. -->
   <xsl:param name="archiveDirParameter"/>
   <xsl:param name="archiveNameParameter"/>
   <xsl:param name="fileNameParameter"/>
   <xsl:param name="fileDirParameter"/>
   <xsl:variable name="document-uri">
      <xsl:value-of select="document-uri(/)"/>
   </xsl:variable>
   <!--PHASES-->
   <!--PROLOG-->
   <xsl:output xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
               method="xml"
               omit-xml-declaration="no"
               standalone="yes"
               indent="yes"/>
   <!--XSD TYPES FOR XSLT2-->
   <!--KEYS AND FUNCTIONS-->
   <xsl:key name="index-by-name" match="m:index | m:is-unique" use="@name"/>
   <xsl:key name="definition-by-name"
            match="m:METASCHEMA/m:define-assembly |         m:METASCHEMA/m:define-field | m:METASCHEMA/m:define-flag"
            use="@name"/>
   <xsl:key name="definition-for-reference"
            match="m:METASCHEMA/m:define-assembly"
            use="@name || ':ASSEMBLY'"/>
   <xsl:key name="definition-for-reference"
            match="m:METASCHEMA/m:define-field"
            use="@name || ':FIELD'"/>
   <xsl:key name="definition-for-reference"
            match="m:METASCHEMA/m:define-flag"
            use="@name || ':FLAG'"/>
   <xsl:key name="references-to-definition"
            match="m:assembly"
            use="@ref || ':ASSEMBLY'"/>
   <xsl:key name="references-to-definition"
            match="m:field"
            use="@ref || ':FIELD'"/>
   <xsl:key name="references-to-definition"
            match="m:flag"
            use="@ref || ':FLAG'"/>
   <xsl:function xmlns:sch="http://purl.oclc.org/dsdl/schematron"
                 xmlns:sqf="http://www.schematron-quickfix.com/validator/process"
                 xmlns:oscal="http://csrc.nist.gov/ns/oscal/1.0"
                 name="nm:definition-for-reference"
                 as="element()?">
      <xsl:param name="who" as="element()"/>
      <xsl:variable name="really-who"
                    select="$who/(self::m:assembly | self::m:field | self::m:flag)"/>
      <xsl:variable name="tag" expand-text="true">{ $really-who/@ref }:{ local-name($really-who) =&gt; upper-case() }</xsl:variable>
      <xsl:sequence select="key('definition-for-reference',$tag,$composed-metaschema)"/>
   </xsl:function>
   <xsl:function xmlns:sch="http://purl.oclc.org/dsdl/schematron"
                 xmlns:sqf="http://www.schematron-quickfix.com/validator/process"
                 xmlns:oscal="http://csrc.nist.gov/ns/oscal/1.0"
                 name="nm:references-to-definition"
                 as="element()*">
      <xsl:param name="who" as="element()"/>
      <xsl:variable name="really-who"
                    select="$who/(self::m:define-assembly | self::m:define-field | self::m:define-flag)"/>
      <xsl:variable name="tag" expand-text="true">{ $really-who/@name }:{ substring-after(local-name($really-who),'define-') =&gt; upper-case() }</xsl:variable>
      <xsl:sequence select="$really-who/key('references-to-definition',$tag,$composed-metaschema)"/>
   </xsl:function>
   <xsl:function xmlns:sch="http://purl.oclc.org/dsdl/schematron"
                 xmlns:sqf="http://www.schematron-quickfix.com/validator/process"
                 xmlns:oscal="http://csrc.nist.gov/ns/oscal/1.0"
                 name="nm:sort"
                 as="item()*">
      <xsl:param name="seq" as="item()*"/>
      <xsl:for-each select="$seq">
         <xsl:sort select="."/>
         <xsl:sequence select="."/>
      </xsl:for-each>
    '</xsl:function>
   <xsl:function xmlns:sch="http://purl.oclc.org/dsdl/schematron"
                 xmlns:sqf="http://www.schematron-quickfix.com/validator/process"
                 xmlns:oscal="http://csrc.nist.gov/ns/oscal/1.0"
                 name="nm:identifiers"
                 as="xs:string*">
      <xsl:param name="who" as="element()"/>
      <xsl:apply-templates select="$who" mode="nm:get-identifiers"/>
   </xsl:function>
   <!--DEFAULT RULES-->
   <!--MODE: SCHEMATRON-SELECT-FULL-PATH-->
   <!--This mode can be used to generate an ugly though full XPath for locators-->
   <xsl:template match="*" mode="schematron-select-full-path">
      <xsl:apply-templates select="." mode="schematron-get-full-path"/>
   </xsl:template>
   <!--MODE: SCHEMATRON-FULL-PATH-->
   <!--This mode can be used to generate an ugly though full XPath for locators-->
   <xsl:template match="*" mode="schematron-get-full-path">
      <xsl:apply-templates select="parent::*" mode="schematron-get-full-path"/>
      <xsl:text>/</xsl:text>
      <xsl:choose>
         <xsl:when test="namespace-uri()=''">
            <xsl:value-of select="name()"/>
         </xsl:when>
         <xsl:otherwise>
            <xsl:text>*:</xsl:text>
            <xsl:value-of select="local-name()"/>
            <xsl:text>[namespace-uri()='</xsl:text>
            <xsl:value-of select="namespace-uri()"/>
            <xsl:text>']</xsl:text>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:variable name="preceding"
                    select="count(preceding-sibling::*[local-name()=local-name(current())                                   and namespace-uri() = namespace-uri(current())])"/>
      <xsl:text>[</xsl:text>
      <xsl:value-of select="1+ $preceding"/>
      <xsl:text>]</xsl:text>
   </xsl:template>
   <xsl:template match="@*" mode="schematron-get-full-path">
      <xsl:apply-templates select="parent::*" mode="schematron-get-full-path"/>
      <xsl:text>/</xsl:text>
      <xsl:choose>
         <xsl:when test="namespace-uri()=''">@<xsl:value-of select="name()"/>
         </xsl:when>
         <xsl:otherwise>
            <xsl:text>@*[local-name()='</xsl:text>
            <xsl:value-of select="local-name()"/>
            <xsl:text>' and namespace-uri()='</xsl:text>
            <xsl:value-of select="namespace-uri()"/>
            <xsl:text>']</xsl:text>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:template>
   <!--MODE: SCHEMATRON-FULL-PATH-2-->
   <!--This mode can be used to generate prefixed XPath for humans-->
   <xsl:template match="node() | @*" mode="schematron-get-full-path-2">
      <xsl:for-each select="ancestor-or-self::*">
         <xsl:text>/</xsl:text>
         <xsl:value-of select="name(.)"/>
         <xsl:if test="preceding-sibling::*[name(.)=name(current())]">
            <xsl:text>[</xsl:text>
            <xsl:value-of select="count(preceding-sibling::*[name(.)=name(current())])+1"/>
            <xsl:text>]</xsl:text>
         </xsl:if>
      </xsl:for-each>
      <xsl:if test="not(self::*)">
         <xsl:text/>/@<xsl:value-of select="name(.)"/>
      </xsl:if>
   </xsl:template>
   <!--MODE: SCHEMATRON-FULL-PATH-3-->
   <!--This mode can be used to generate prefixed XPath for humans 
	(Top-level element has index)-->
   <xsl:template match="node() | @*" mode="schematron-get-full-path-3">
      <xsl:for-each select="ancestor-or-self::*">
         <xsl:text>/</xsl:text>
         <xsl:value-of select="name(.)"/>
         <xsl:if test="parent::*">
            <xsl:text>[</xsl:text>
            <xsl:value-of select="count(preceding-sibling::*[name(.)=name(current())])+1"/>
            <xsl:text>]</xsl:text>
         </xsl:if>
      </xsl:for-each>
      <xsl:if test="not(self::*)">
         <xsl:text/>/@<xsl:value-of select="name(.)"/>
      </xsl:if>
   </xsl:template>
   <!--MODE: GENERATE-ID-FROM-PATH -->
   <xsl:template match="/" mode="generate-id-from-path"/>
   <xsl:template match="text()" mode="generate-id-from-path">
      <xsl:apply-templates select="parent::*" mode="generate-id-from-path"/>
      <xsl:value-of select="concat('.text-', 1+count(preceding-sibling::text()), '-')"/>
   </xsl:template>
   <xsl:template match="comment()" mode="generate-id-from-path">
      <xsl:apply-templates select="parent::*" mode="generate-id-from-path"/>
      <xsl:value-of select="concat('.comment-', 1+count(preceding-sibling::comment()), '-')"/>
   </xsl:template>
   <xsl:template match="processing-instruction()" mode="generate-id-from-path">
      <xsl:apply-templates select="parent::*" mode="generate-id-from-path"/>
      <xsl:value-of select="concat('.processing-instruction-', 1+count(preceding-sibling::processing-instruction()), '-')"/>
   </xsl:template>
   <xsl:template match="@*" mode="generate-id-from-path">
      <xsl:apply-templates select="parent::*" mode="generate-id-from-path"/>
      <xsl:value-of select="concat('.@', name())"/>
   </xsl:template>
   <xsl:template match="*" mode="generate-id-from-path" priority="-0.5">
      <xsl:apply-templates select="parent::*" mode="generate-id-from-path"/>
      <xsl:text>.</xsl:text>
      <xsl:value-of select="concat('.',name(),'-',1+count(preceding-sibling::*[name()=name(current())]),'-')"/>
   </xsl:template>
   <!--MODE: GENERATE-ID-2 -->
   <xsl:template match="/" mode="generate-id-2">U</xsl:template>
   <xsl:template match="*" mode="generate-id-2" priority="2">
      <xsl:text>U</xsl:text>
      <xsl:number level="multiple" count="*"/>
   </xsl:template>
   <xsl:template match="node()" mode="generate-id-2">
      <xsl:text>U.</xsl:text>
      <xsl:number level="multiple" count="*"/>
      <xsl:text>n</xsl:text>
      <xsl:number count="node()"/>
   </xsl:template>
   <xsl:template match="@*" mode="generate-id-2">
      <xsl:text>U.</xsl:text>
      <xsl:number level="multiple" count="*"/>
      <xsl:text>_</xsl:text>
      <xsl:value-of select="string-length(local-name(.))"/>
      <xsl:text>_</xsl:text>
      <xsl:value-of select="translate(name(),':','.')"/>
   </xsl:template>
   <!--Strip characters-->
   <xsl:template match="text()" priority="-1"/>
   <!--SCHEMA SETUP-->
   <xsl:template match="/">
      <svrl:schematron-output xmlns:svrl="http://purl.oclc.org/dsdl/svrl" title="" schemaVersion="">
         <xsl:comment>
            <xsl:value-of select="$archiveDirParameter"/>   
		 <xsl:value-of select="$archiveNameParameter"/>  
		 <xsl:value-of select="$fileNameParameter"/>  
		 <xsl:value-of select="$fileDirParameter"/>
         </xsl:comment>
         <svrl:ns-prefix-in-attribute-values uri="http://csrc.nist.gov/ns/oscal/metaschema/1.0" prefix="m"/>
         <svrl:ns-prefix-in-attribute-values uri="http://csrc.nist.gov/ns/metaschema" prefix="nm"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">top-level-and-schema-docs</xsl:attribute>
            <xsl:attribute name="name">top-level-and-schema-docs</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M6"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">definitions-and-name-clashes</xsl:attribute>
            <xsl:attribute name="name">definitions-and-name-clashes</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M7"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">flags_and_keys_and_datatypes</xsl:attribute>
            <xsl:attribute name="name">flags_and_keys_and_datatypes</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M8"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">schema-docs</xsl:attribute>
            <xsl:attribute name="name">schema-docs</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M10"/>
      </svrl:schematron-output>
   </xsl:template>
   <!--SCHEMATRON PATTERNS-->
   <xsl:import xmlns:sch="http://purl.oclc.org/dsdl/schematron"
               xmlns:sqf="http://www.schematron-quickfix.com/validator/process"
               xmlns:oscal="http://csrc.nist.gov/ns/oscal/1.0"
               href="metaschema-validation-support.xsl"/>
   <xsl:import xmlns:sch="http://purl.oclc.org/dsdl/schematron"
               xmlns:sqf="http://www.schematron-quickfix.com/validator/process"
               xmlns:oscal="http://csrc.nist.gov/ns/oscal/1.0"
               href="oscal-datatypes-check.xsl"/>
   <xsl:variable xmlns:sch="http://purl.oclc.org/dsdl/schematron"
                 xmlns:sqf="http://www.schematron-quickfix.com/validator/process"
                 xmlns:oscal="http://csrc.nist.gov/ns/oscal/1.0"
                 name="composed-metaschema"
                 select="nm:compose-metaschema(/)"/>
   <xsl:param name="metaschema-is-abstract" select="/m:METASCHEMA/@abstract='yes'"/>
   <!--PATTERN top-level-and-schema-docs-->
   <!--RULE -->
   <xsl:template match="/m:METASCHEMA" priority="1003" mode="M6">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="/m:METASCHEMA"/>
      <!--ASSERT warning-->
      <xsl:choose>
         <xsl:when test="exists(m:schema-version)"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="exists(m:schema-version)">
               <xsl:attribute name="role">warning</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Metaschema schema version must be set for any top-level metaschema</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="exists(m:define-assembly/m:root-name) or @abstract='yes'"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="exists(m:define-assembly/m:root-name) or @abstract='yes'">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Unless marked as @abstract='yes', a metaschema should have at least one assembly with a root-name.</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M6"/>
   </xsl:template>
   <!--RULE -->
   <xsl:template match="/m:METASCHEMA/m:title" priority="1002" mode="M6">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="/m:METASCHEMA/m:title"/>
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M6"/>
   </xsl:template>
   <!--RULE -->
   <xsl:template match="/m:METASCHEMA/m:import" priority="1001" mode="M6">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="/m:METASCHEMA/m:import"/>
      <!--REPORT warning-->
      <xsl:if test="document-uri(/) = resolve-uri(@href,document-uri(/))">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 test="document-uri(/) = resolve-uri(@href,document-uri(/))">
            <xsl:attribute name="role">warning</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Schema can't import itself</svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="exists(document(@href)/m:METASCHEMA)"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="exists(document(@href)/m:METASCHEMA)">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Can't find a metaschema at <xsl:text/>
                  <xsl:value-of select="@href"/>
                  <xsl:text/>
               </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M6"/>
   </xsl:template>
   <!--RULE -->
   <xsl:template match="/m:METASCHEMA/m:define-assembly/m:root-name"
                 priority="1000"
                 mode="M6">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="/m:METASCHEMA/m:define-assembly/m:root-name"/>
      <!--REPORT -->
      <xsl:if test="$metaschema-is-abstract">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="$metaschema-is-abstract">
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Assembly should not be defined as a root when /METASCHEMA/@abstract='yes'</svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M6"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M6"/>
   <xsl:template match="@*|node()" priority="-2" mode="M6">
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M6"/>
   </xsl:template>
   <!--PATTERN definitions-and-name-clashes-->
   <!--RULE -->
   <xsl:template match="m:METASCHEMA/m:define-assembly | m:METASCHEMA/m:define-field | m:METASCHEMA/m:define-flag"
                 priority="1002"
                 mode="M7">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="m:METASCHEMA/m:define-assembly | m:METASCHEMA/m:define-field | m:METASCHEMA/m:define-flag"/>
      <xsl:variable name="references" select="nm:references-to-definition(.)"/>
      <!--REPORT -->
      <xsl:if test="@name=(../*/@name except @name)">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 test="@name=(../*/@name except @name)">
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Definition for '<xsl:text/>
               <xsl:value-of select="@name"/>
               <xsl:text/>' clashes in this metaschema: not a good idea.</svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <!--ASSERT warning-->
      <xsl:choose>
         <xsl:when test="exists($references | self::m:define-assembly/m:root-name) or $metaschema-is-abstract"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="exists($references | self::m:define-assembly/m:root-name) or $metaschema-is-abstract">
               <xsl:attribute name="role">warning</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Orphan <xsl:text/>
                  <xsl:value-of select="substring-after(local-name(),'define-')"/>
                  <xsl:text/> '<xsl:text/>
                  <xsl:value-of select="@name"/>
                  <xsl:text/>' is never used in the composed metaschema</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="not($references/m:group-as/@in-json='BY_KEY') or exists(m:json-key)"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="not($references/m:group-as/@in-json='BY_KEY') or exists(m:json-key)">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
                  <xsl:text/>
                  <xsl:value-of select="substring-after(local-name(),             'define-')"/>
                  <xsl:text/> is assigned a json key, but no 'json-key' is given</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--REPORT -->
      <xsl:if test="@name=('RICHTEXT','STRVALUE','PROSE')">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 test="@name=('RICHTEXT','STRVALUE','PROSE')">
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Names "STRVALUE", "RICHTEXT" or "PROSE" are reserved.</svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M7"/>
   </xsl:template>
   <!--RULE -->
   <xsl:template match="m:define-assembly | m:define-field"
                 priority="1001"
                 mode="M7">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="m:define-assembly | m:define-field"/>
      <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="matches(m:group-as/@name,'\S') or number((@max-occurs,1)[1])=1"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="matches(m:group-as/@name,'\S') or number((@max-occurs,1)[1])=1">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Unless @max-occurs is 1, a group name must be given with a local assembly definition.</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M7"/>
   </xsl:template>
   <!--RULE -->
   <xsl:template match="m:group-as" priority="1000" mode="M7">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="m:group-as"/>
      <xsl:variable name="name" select="@name"/>
      <!--REPORT -->
      <xsl:if test="../@max-occurs/number() = 1">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 test="../@max-occurs/number() = 1">
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>"group-as" should not be given when max-occurs is 1.</svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <xsl:variable name="def"
                    select="parent::m:define-field | parent::m:define-assembly | nm:definition-for-reference(parent::*)"/>
      <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="$metaschema-is-abstract or not(@in-json='BY_KEY') or $def/m:json-key/@flag-name = $def/(m:flag/@ref|m:define-flag/@name)"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="$metaschema-is-abstract or not(@in-json='BY_KEY') or $def/m:json-key/@flag-name = $def/(m:flag/@ref|m:define-flag/@name)">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Cannot group by key since the definition of <xsl:text/>
                  <xsl:value-of select="name(..)"/>
                  <xsl:text/> '<xsl:text/>
                  <xsl:value-of select="../@ref"/>
                  <xsl:text/>' has no json-key specified. Consider adding a json-key to the '<xsl:text/>
                  <xsl:value-of select="../@ref"/>
                  <xsl:text/>' definition, or using a different 'in-json' setting.</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="(@in-json='ARRAY') or not(@in-xml='GROUPED')"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="(@in-json='ARRAY') or not(@in-xml='GROUPED')">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>When @in-xml='GROUPED', @in-json must be 'ARRAY'.</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M7"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M7"/>
   <xsl:template match="@*|node()" priority="-2" mode="M7">
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M7"/>
   </xsl:template>
   <!--PATTERN flags_and_keys_and_datatypes-->
   <!--RULE -->
   <xsl:template match="m:field | m:assembly" priority="1007" mode="M8">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="m:field | m:assembly"/>
      <xsl:variable name="def" select="nm:definition-for-reference(.)"/>
      <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="empty($def) or (m:group-as/@in-json='BY_KEY') or empty($def/m:json-key)"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="empty($def) or (m:group-as/@in-json='BY_KEY') or empty($def/m:json-key)">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Target definition for <xsl:text/>
                  <xsl:value-of select="@ref"/>
                  <xsl:text/> designates a json key, so the invocation should have group-as/@in-json='BY_KEY'</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="matches(m:group-as/@name,'\S') or not((@max-occurs/number() gt 1) or (@max-occurs='unbounded'))"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="matches(m:group-as/@name,'\S') or not((@max-occurs/number() gt 1) or (@max-occurs='unbounded'))">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Unless @max-occurs is 1, a grouping name (group-as/@name) must be given</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="not(@in-xml='UNWRAPPED') or not($def/@as-type='markup-multiline') or not(preceding-sibling::*[@in-xml='UNWRAPPED']/nm:definition-for-reference(.)/@as-type='markup-multiline')"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="not(@in-xml='UNWRAPPED') or not($def/@as-type='markup-multiline') or not(preceding-sibling::*[@in-xml='UNWRAPPED']/nm:definition-for-reference(.)/@as-type='markup-multiline')">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Only one field may be marked as 'markup-multiline' (without xml wrapping) within a model.</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--REPORT -->
      <xsl:if test="(@in-xml='UNWRAPPED') and (@max-occurs!='1')">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 test="(@in-xml='UNWRAPPED') and (@max-occurs!='1')">
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>An 'unwrapped' field must have a max occurrence of 1</svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="$def/@as-type='markup-multiline' or not(@in-xml='UNWRAPPED')"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="$def/@as-type='markup-multiline' or not(@in-xml='UNWRAPPED')">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Only 'markup-multiline' fields may be unwrapped in XML.</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M8"/>
   </xsl:template>
   <!--RULE -->
   <xsl:template match="m:flag | m:define-field/m:define-flag | m:define-assembly/m:define-flag"
                 priority="1006"
                 mode="M8">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="m:flag | m:define-field/m:define-flag | m:define-assembly/m:define-flag"/>
      <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="not((@name | @ref) = ../m:json-value-key/@flag-name) or @required = 'yes'"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="not((@name | @ref) = ../m:json-value-key/@flag-name) or @required = 'yes'">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>A flag declared as a value key must be required (@required='yes')</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="not((@name | @ref) = ../m:json-key/@flag-name) or @required = 'yes'"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="not((@name | @ref) = ../m:json-key/@flag-name) or @required = 'yes'">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>A flag declared as a key must be required (@required='yes')</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="not(parent::m:define-field[@as-type='markup-multiline']/nm:references-to-definition(.)/@in-xml='UNWRAPPED')"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="not(parent::m:define-field[@as-type='markup-multiline']/nm:references-to-definition(.)/@in-xml='UNWRAPPED')">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Multiline markup fields must have no flags, unless always used with a wrapper - put your flags on an assembly with an unwrapped multiline field</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M8"/>
   </xsl:template>
   <!--RULE -->
   <xsl:template match="m:json-key" priority="1005" mode="M8">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="m:json-key"/>
      <xsl:variable name="json-key-flag-name" select="@flag-name"/>
      <xsl:variable name="json-key-flag"
                    select="../m:flag[@ref=$json-key-flag-name] |../m:define-flag[@name=$json-key-flag-name]"/>
      <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="exists($json-key-flag)"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="exists($json-key-flag)">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>JSON key indicates no flag on this <xsl:text/>
                  <xsl:value-of select="substring-after(local-name(..),'define-')"/>
                  <xsl:text/>
                  <xsl:if xmlns:sch="http://purl.oclc.org/dsdl/schematron"
                          xmlns:sqf="http://www.schematron-quickfix.com/validator/process"
                          xmlns:oscal="http://csrc.nist.gov/ns/oscal/1.0"
                          test="exists(../m:flag | ../m:define-flag)">Should be (one of) <xsl:value-of select="../m:flag/@ref | ../m:define-flag/@name" separator=", "/>
                  </xsl:if>
               </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M8"/>
   </xsl:template>
   <!--RULE -->
   <xsl:template match="m:json-value-key" priority="1004" mode="M8">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="m:json-value-key"/>
      <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="empty(@flag-name) or (@flag-name != ../(m:flag/@ref | m:define-flag/@name) )"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="empty(@flag-name) or (@flag-name != ../(m:flag/@ref | m:define-flag/@name) )">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
                  <xsl:text/>
                  <xsl:value-of select="name(.)"/>
                  <xsl:text/> as flag/<xsl:text/>
                  <xsl:value-of select="@flag-name"/>
                  <xsl:text/> will be inoperative as the value will be given the field key -- no other flags are given <xsl:value-of xmlns:sch="http://purl.oclc.org/dsdl/schematron"
                                xmlns:sqf="http://www.schematron-quickfix.com/validator/process"
                                xmlns:oscal="http://csrc.nist.gov/ns/oscal/1.0"
                                select="../(m:flag|m:define-flag)/@ref"
                                separator=", "/>
               </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--REPORT -->
      <xsl:if test="exists(@flag-name) and matches(.,'\S')">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 test="exists(@flag-name) and matches(.,'\S')">
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>JSON value key may be set to a value or a flag's value, but not both.</svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="empty(@flag-name) or @flag-name = (../m:flag/@ref|../m:define-flag/@name)"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="empty(@flag-name) or @flag-name = (../m:flag/@ref|../m:define-flag/@name)">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>flag '<xsl:text/>
                  <xsl:value-of select="@flag-name"/>
                  <xsl:text/>' not found for JSON value key</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M8"/>
   </xsl:template>
   <!--RULE -->
   <xsl:template match="m:allowed-values/m:enum" priority="1003" mode="M8">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="m:allowed-values/m:enum"/>
      <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="not(@value = preceding-sibling::*/@value)"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="not(@value = preceding-sibling::*/@value)">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Allowed value '<xsl:text/>
                  <xsl:value-of select="@value"/>
                  <xsl:text/>' may only be specified once for flag '<xsl:text/>
                  <xsl:value-of select="../../@name"/>
                  <xsl:text/>'.</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="m:datatype-validate(@value,../../@as-type)"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="m:datatype-validate(@value,../../@as-type)">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Value '<xsl:text/>
                  <xsl:value-of select="@value"/>
                  <xsl:text/>' is not a valid token of type <xsl:text/>
                  <xsl:value-of select="../../@as-type"/>
                  <xsl:text/>
               </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M8"/>
   </xsl:template>
   <!--RULE -->
   <xsl:template match="m:index | m:is-unique" priority="1002" mode="M8">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="m:index | m:is-unique"/>
      <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="count(key('index-by-name',@name))=1"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="count(key('index-by-name',@name))=1">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Only one index or uniqueness assertion may be named '<xsl:text/>
                  <xsl:value-of select="@name"/>
                  <xsl:text/>'</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M8"/>
   </xsl:template>
   <!--RULE -->
   <xsl:template match="m:index-has-key" priority="1001" mode="M8">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="m:index-has-key"/>
      <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="count(key('index-by-name',@name)/self::m:index)=1"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="count(key('index-by-name',@name)/self::m:index)=1">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>No '<xsl:text/>
                  <xsl:value-of select="@name"/>
                  <xsl:text/>' index is defined.</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M8"/>
   </xsl:template>
   <!--RULE -->
   <xsl:template match="m:key-field" priority="1000" mode="M8">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="m:key-field"/>
      <!--REPORT -->
      <xsl:if test="@target = preceding-sibling::*/@target">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 test="@target = preceding-sibling::*/@target">
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Index key field target '<xsl:text/>
               <xsl:value-of select="@target"/>
               <xsl:text/>' is already declared.</svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M8"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M8"/>
   <xsl:template match="@*|node()" priority="-2" mode="M8">
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M8"/>
   </xsl:template>
   <!--PATTERN schema-docs-->
   <!--RULE -->
   <xsl:template match="m:define-assembly | m:define-field | m:define-flag"
                 priority="1001"
                 mode="M10">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="m:define-assembly | m:define-field | m:define-flag"/>
      <!--ASSERT warning-->
      <xsl:choose>
         <xsl:when test="exists(m:formal-name)"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="exists(m:formal-name)">
               <xsl:attribute name="role">warning</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Formal name missing from <xsl:text/>
                  <xsl:value-of select="name(.)"/>
                  <xsl:text/>
               </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT warning-->
      <xsl:choose>
         <xsl:when test="exists(m:description)"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="exists(m:description)">
               <xsl:attribute name="role">warning</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Short description missing from <xsl:text/>
                  <xsl:value-of select="name(.)"/>
                  <xsl:text/>
               </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT warning-->
      <xsl:choose>
         <xsl:when test="empty(self::m:define-assembly) or exists(m:model)"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="empty(self::m:define-assembly) or exists(m:model)">
               <xsl:attribute name="role">warning</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>model missing from <xsl:text/>
                  <xsl:value-of select="name(.)"/>
                  <xsl:text/>
               </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M10"/>
   </xsl:template>
   <!--RULE -->
   <xsl:template match="m:p | m:li | m:pre" priority="1000" mode="M10">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="m:p | m:li | m:pre"/>
      <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="matches(.,'\S')"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="matches(.,'\S')">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Empty <name xmlns:sch="http://purl.oclc.org/dsdl/schematron"
                        xmlns:sqf="http://www.schematron-quickfix.com/validator/process"
                        xmlns:oscal="http://csrc.nist.gov/ns/oscal/1.0"/> (is likely to distort rendition)</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--REPORT warning-->
      <xsl:if test="not(matches(.,'\w'))">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="not(matches(.,'\w'))">
            <xsl:attribute name="role">warning</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Not much here is there</svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M10"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M10"/>
   <xsl:template match="@*|node()" priority="-2" mode="M10">
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M10"/>
   </xsl:template>
   <xsl:template xmlns:sch="http://purl.oclc.org/dsdl/schematron"
                 xmlns:sqf="http://www.schematron-quickfix.com/validator/process"
                 xmlns:oscal="http://csrc.nist.gov/ns/oscal/1.0"
                 match="m:define-assembly | m:define-field | m:define-flag"
                 mode="nm:get-identifiers">
      <xsl:sequence select="m:root-name,(m:use-name,@name)[1], m:group-as/@name"/>
   </xsl:template>
   <xsl:template xmlns:sch="http://purl.oclc.org/dsdl/schematron"
                 xmlns:sqf="http://www.schematron-quickfix.com/validator/process"
                 xmlns:oscal="http://csrc.nist.gov/ns/oscal/1.0"
                 match="m:assembly[exists(m:use-name)] |                          m:field[exists(m:use-name)] |                          m:flag[exists(m:use-name)]"
                 mode="nm:get-identifiers">
      <xsl:sequence select="m:use-name, m:group-as/@name"/>
   </xsl:template>
   <xsl:template xmlns:sch="http://purl.oclc.org/dsdl/schematron"
                 xmlns:sqf="http://www.schematron-quickfix.com/validator/process"
                 xmlns:oscal="http://csrc.nist.gov/ns/oscal/1.0"
                 match="m:assembly | m:field | m:flag"
                 mode="nm:get-identifiers">
      <xsl:sequence select="m:group-as/@name"/>
      <xsl:apply-templates select="nm:definition-for-reference(.)" mode="#current"/>
   </xsl:template>
   <xsl:template xmlns:sch="http://purl.oclc.org/dsdl/schematron"
                 xmlns:sqf="http://www.schematron-quickfix.com/validator/process"
                 xmlns:oscal="http://csrc.nist.gov/ns/oscal/1.0"
                 match="*"
                 mode="nm:get-identifiers"/>
</xsl:stylesheet>
