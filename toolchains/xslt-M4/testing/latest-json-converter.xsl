<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:m="http://csrc.nist.gov/ns/oscal/metaschema/1.0"
                xmlns="http://csrc.nist.gov/ns/oscal/metaschema/1.0/supermodel"
                xmlns:j="http://www.w3.org/2005/xpath-functions"
                version="3.0"
                exclude-result-prefixes="#all">
<!-- JSON to XML conversion: pipeline -->
<!-- Processing architecture -->
   <xsl:param name="file" as="xs:string"/>
   <xsl:param name="produce" as="xs:string">xml</xsl:param>
   <xsl:template name="from-json">
      <xsl:if test="not(unparsed-text-available($file))" expand-text="true">
         <nm:ERROR xmlns:nm="http://csrc.nist.gov/ns/metaschema">No file found at { $file }</nm:ERROR>
      </xsl:if>
      <xsl:call-template name="from-xdm-json-xml">
         <xsl:with-param name="source">
            <xsl:try xmlns:err="http://www.w3.org/2005/xqt-errors"
                     select="unparsed-text($file) ! json-to-xml(.)">
               <xsl:catch>
                  <nm:ERROR xmlns:nm="http://csrc.nist.gov/ns/metaschema" code="{ $err:code }">{{ $err:description }}</nm:ERROR>
               </xsl:catch>
            </xsl:try>
         </xsl:with-param>
      </xsl:call-template>
   </xsl:template>
   <xsl:template match="/" name="from-xdm-json-xml">
      <xsl:param name="source" select="/"/>
      <xsl:variable name="supermodel">
         <xsl:apply-templates select="$source"/>
      </xsl:variable>
      <xsl:choose>
         <xsl:when test="$produce = 'supermodel'">
            <xsl:sequence select="$supermodel"/>
         </xsl:when>
         <xsl:otherwise>
            <xsl:apply-templates select="$supermodel" mode="write-xml"/>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:template>
   <!-- JSON to XML conversion: object filters -->
   <xsl:strip-space elements="j:map j:array"/>
   <!-- METASCHEMA conversion stylesheet supports JSON -> METASCHEMA/SUPERMODEL conversion -->
   <!-- ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ -->
   <!-- METASCHEMA: NIST Metaschema Everything (version 1.0) in namespace "http://csrc.nist.gov/metaschema/ns/everything"-->
   <xsl:template match="(j:map[@key='EVERYTHING'] | j:array[@key='everything-recursive']/j:map)">
      <xsl:param name="with-key" select="true()"/>
      <!-- Cf XML match="EVERYTHING" -->
      <assembly name="everything" gi="EVERYTHING">
         <xsl:if test="$with-key">
            <xsl:attribute name="key">EVERYTHING</xsl:attribute>
         </xsl:if>
         <xsl:if test=". is /*">
            <xsl:attribute name="namespace">http://csrc.nist.gov/metaschema/ns/everything</xsl:attribute>
         </xsl:if>
         <xsl:apply-templates select="*[@key='id']"/>
         <xsl:apply-templates select="*[@key='field-1only']"/>
         <xsl:apply-templates select="*[@key='field-base64']"/>
         <xsl:apply-templates select="*[@key='field-boolean']"/>
         <xsl:apply-templates select="*[@key='field-named-value']"/>
         <xsl:apply-templates select="*[@key='markup-line']"/>
         <xsl:apply-templates select="*[@key='groupable-simple-fields']"/>
         <xsl:apply-templates select="*[@key='groupable-flagged-fields']"/>
         <xsl:apply-templates select="*[@key='wrapped-fields']"/>
         <xsl:apply-templates select="*[@key='keyed-fields']"/>
         <xsl:apply-templates select="*[@key='dynamic-value-key-fields']"/>
         <xsl:apply-templates select="*[@key='wrapped-prose']"/>
         <xsl:apply-templates select="*[@key='loose-prose']"/>
         <xsl:apply-templates select="*[@key='ASSEMBLY-1ONLY']"/>
         <xsl:apply-templates select="*[@key='groupable-assemblies']"/>
         <xsl:apply-templates select="*[@key='wrapped-assemblies']"/>
         <xsl:apply-templates select="*[@key='keyed-assemblies']"/>
         <xsl:apply-templates select="*[@key='everything-recursive']"/>
      </assembly>
   </xsl:template>
   <xsl:template match="(j:map[@key='EVERYTHING'] | j:array[@key='everything-recursive']/j:map)/j:string[@key='id'] | j:map[@key='field-named-value']/j:string[@key='id'] | j:map[@key='keyed-fields']/j:string/@key | (j:array[@key='dynamic-value-key-fields']/j:map | j:map[@key='dynamic-value-key-fields'])/j:string[not(@key=('id','color'))]/@key | j:map[@key='keyed-assemblies']/j:map/@key"><!-- Cf XML match="EVERYTHING/@id | field-named-value/@id | field-by-key/@id | field-dynamic-value-key/@id | assembly-by-key/@id" -->
      <flag in-json="string"
            as-type="string"
            name="id"
            key="id"
            gi="id">
         <xsl:value-of select="."/>
      </flag>
   </xsl:template>
   <xsl:template match="(j:map[@key='EVERYTHING'] | j:array[@key='everything-recursive']/j:map)/j:string[@key='id'] | j:map[@key='field-named-value']/j:string[@key='id'] | j:map[@key='keyed-fields']/j:string/@key | (j:array[@key='dynamic-value-key-fields']/j:map | j:map[@key='dynamic-value-key-fields'])/j:string[not(@key=('id','color'))]/@key | j:map[@key='keyed-assemblies']/j:map/@key"
                 mode="keep-value-property"
                 priority="count(ancestor-or-self::*)"><!-- Not keeping the flag here. --></xsl:template>
   <xsl:template match="j:map[@key='field-1only']">
      <xsl:param name="with-key" select="true()"/>
      <!-- Cf XML match="field-1only" -->
      <field name="field-1only" gi="field-1only">
         <xsl:if test="$with-key">
            <xsl:attribute name="key">field-1only</xsl:attribute>
         </xsl:if>
         <xsl:apply-templates select="*[@key='simple-flag']"/>
         <xsl:apply-templates select="*[@key='integer-flag']"/>
         <xsl:apply-templates select="." mode="get-value-property"/>
      </field>
   </xsl:template>
   <xsl:template match="j:map[@key='field-1only']" mode="get-value-property">
      <value as-type="string" key="STRVALUE" in-json="string">
         <xsl:apply-templates mode="keep-value-property"/>
      </value>
   </xsl:template>
   <xsl:template match="j:map[@key='field-1only']/j:string[@key='simple-flag'] | (j:array[@key='groupable-simple-fields']/j:map | j:map[@key='groupable-simple-fields'])/j:string[@key='simple-flag']"><!-- Cf XML match="field-1only/@simple-flag | field-simple-groupable/@simple-flag" -->
      <flag in-json="string"
            as-type="string"
            name="simple-flag"
            key="simple-flag"
            gi="simple-flag">
         <xsl:value-of select="."/>
      </flag>
   </xsl:template>
   <xsl:template match="j:map[@key='field-1only']/j:string[@key='simple-flag'] | (j:array[@key='groupable-simple-fields']/j:map | j:map[@key='groupable-simple-fields'])/j:string[@key='simple-flag']"
                 mode="keep-value-property"
                 priority="count(ancestor-or-self::*)"><!-- Not keeping the flag here. --></xsl:template>
   <xsl:template match="j:map[@key='field-1only']/j:number[@key='integer-flag'] | (j:array[@key='groupable-simple-fields']/j:map | j:map[@key='groupable-simple-fields'])/j:number[@key='integer-flag']"><!-- Cf XML match="field-1only/@integer-flag | field-simple-groupable/@integer-flag" -->
      <flag in-json="number"
            as-type="integer"
            name="integer-flag"
            key="integer-flag"
            gi="integer-flag">
         <xsl:value-of select="."/>
      </flag>
   </xsl:template>
   <xsl:template match="j:map[@key='field-1only']/j:number[@key='integer-flag'] | (j:array[@key='groupable-simple-fields']/j:map | j:map[@key='groupable-simple-fields'])/j:number[@key='integer-flag']"
                 mode="keep-value-property"
                 priority="count(ancestor-or-self::*)"><!-- Not keeping the flag here. --></xsl:template>
   <xsl:template match="j:string[@key='field-base64']">
      <xsl:param name="with-key" select="true()"/>
      <!-- Cf XML match="field-base64" -->
      <field name="field-base64" gi="field-base64" in-json="SCALAR">
         <xsl:if test="$with-key">
            <xsl:attribute name="key">field-base64</xsl:attribute>
         </xsl:if>
         <xsl:apply-templates select="." mode="get-value-property"/>
      </field>
   </xsl:template>
   <xsl:template match="j:string[@key='field-base64']"
                 mode="get-value-property"
                 priority="count(ancestor-or-self::*)">
      <value as-type="base64Binary" in-json="string">
         <xsl:value-of select="."/>
      </value>
   </xsl:template>
   <xsl:template match="j:boolean[@key='field-boolean']">
      <xsl:param name="with-key" select="true()"/>
      <!-- Cf XML match="field-boolean" -->
      <field name="field-boolean" gi="field-boolean" in-json="SCALAR">
         <xsl:if test="$with-key">
            <xsl:attribute name="key">field-boolean</xsl:attribute>
         </xsl:if>
         <xsl:apply-templates select="." mode="get-value-property"/>
      </field>
   </xsl:template>
   <xsl:template match="j:boolean[@key='field-boolean']"
                 mode="get-value-property"
                 priority="count(ancestor-or-self::*)">
      <value as-type="boolean" in-json="boolean">
         <xsl:value-of select="."/>
      </value>
   </xsl:template>
   <xsl:template match="j:map[@key='field-named-value']">
      <xsl:param name="with-key" select="true()"/>
      <!-- Cf XML match="field-named-value" -->
      <field name="field-named-value" gi="field-named-value">
         <xsl:if test="$with-key">
            <xsl:attribute name="key">field-named-value</xsl:attribute>
         </xsl:if>
         <xsl:apply-templates select="*[@key='id']"/>
         <xsl:apply-templates select="." mode="get-value-property"/>
      </field>
   </xsl:template>
   <xsl:template match="j:map[@key='field-named-value']" mode="get-value-property">
      <value as-type="string" key="CUSTOM-VALUE-KEY" in-json="string">
         <xsl:apply-templates mode="keep-value-property"/>
      </value>
   </xsl:template>
   <xsl:template match="j:string[@key='markup-line']">
      <xsl:param name="with-key" select="true()"/>
      <!-- Cf XML match="markup-line" -->
      <field name="markup-line" gi="markup-line" in-json="SCALAR">
         <xsl:if test="$with-key">
            <xsl:attribute name="key">markup-line</xsl:attribute>
         </xsl:if>
         <xsl:apply-templates select="." mode="get-value-property"/>
      </field>
   </xsl:template>
   <xsl:template match="j:string[@key='markup-line']" mode="get-value-property">
      <value as-type="markup-multiline" in-json="string">
         <xsl:call-template name="parse-markdown">
            <xsl:with-param name="markdown-str" select="string(.)"/>
         </xsl:call-template>
      </value>
   </xsl:template>
   <xsl:template match="(j:array[@key='groupable-simple-fields']/j:map | j:map[@key='groupable-simple-fields'])">
      <xsl:param name="with-key" select="true()"/>
      <!-- Cf XML match="field-simple-groupable" -->
      <field name="field-simple-groupable" gi="field-simple-groupable">
         <xsl:apply-templates select="*[@key='simple-flag']"/>
         <xsl:apply-templates select="*[@key='integer-flag']"/>
         <xsl:apply-templates select="." mode="get-value-property"/>
      </field>
   </xsl:template>
   <xsl:template match="(j:array[@key='groupable-simple-fields']/j:map | j:map[@key='groupable-simple-fields'])"
                 mode="get-value-property">
      <value as-type="string" key="STRVALUE" in-json="string">
         <xsl:apply-templates mode="keep-value-property"/>
      </value>
   </xsl:template>
   <xsl:template match="(j:array[@key='groupable-flagged-fields']/j:map | j:map[@key='groupable-flagged-fields'])">
      <xsl:param name="with-key" select="true()"/>
      <!-- Cf XML match="field-flagged-groupable" -->
      <field name="field-flagged-groupable" gi="field-flagged-groupable">
         <xsl:apply-templates select="*[@key='flagged-date']"/>
         <xsl:apply-templates select="*[@key='flagged-decimal']"/>
         <xsl:apply-templates select="." mode="get-value-property"/>
      </field>
   </xsl:template>
   <xsl:template match="(j:array[@key='groupable-flagged-fields']/j:map | j:map[@key='groupable-flagged-fields'])"
                 mode="get-value-property">
      <value as-type="string" key="STRVALUE" in-json="string">
         <xsl:apply-templates mode="keep-value-property"/>
      </value>
   </xsl:template>
   <xsl:template match="(j:array[@key='groupable-flagged-fields']/j:map | j:map[@key='groupable-flagged-fields'])/j:string[@key='flagged-date']"><!-- Cf XML match="field-flagged-groupable/@flagged-date" -->
      <flag in-json="string"
            as-type="date"
            name="flagged-date"
            key="flagged-date"
            gi="flagged-date">
         <xsl:value-of select="."/>
      </flag>
   </xsl:template>
   <xsl:template match="(j:array[@key='groupable-flagged-fields']/j:map | j:map[@key='groupable-flagged-fields'])/j:string[@key='flagged-date']"
                 mode="keep-value-property"
                 priority="count(ancestor-or-self::*)"><!-- Not keeping the flag here. --></xsl:template>
   <xsl:template match="(j:array[@key='groupable-flagged-fields']/j:map | j:map[@key='groupable-flagged-fields'])/j:number[@key='flagged-decimal']"><!-- Cf XML match="field-flagged-groupable/@flagged-decimal" -->
      <flag in-json="number"
            as-type="decimal"
            name="flagged-decimal"
            key="flagged-decimal"
            gi="flagged-decimal">
         <xsl:value-of select="."/>
      </flag>
   </xsl:template>
   <xsl:template match="(j:array[@key='groupable-flagged-fields']/j:map | j:map[@key='groupable-flagged-fields'])/j:number[@key='flagged-decimal']"
                 mode="keep-value-property"
                 priority="count(ancestor-or-self::*)"><!-- Not keeping the flag here. --></xsl:template>
   <xsl:template match="j:array[@key='wrapped-fields']/j:string">
      <xsl:param name="with-key" select="true()"/>
      <!-- Cf XML match="field-wrappable" -->
      <field name="field-wrappable" gi="field-wrappable" in-json="SCALAR">
         <xsl:apply-templates select="." mode="get-value-property"/>
      </field>
   </xsl:template>
   <xsl:template match="j:array[@key='wrapped-fields']" priority="3">
      <xsl:param name="with-key" select="true()"/>
      <!-- Cf XML match="wrapped-fields" -->
      <group name="wrapped-fields" gi="wrapped-fields" group-json="ARRAY">
         <xsl:if test="$with-key">
            <xsl:attribute name="key">wrapped-fields</xsl:attribute>
         </xsl:if>
         <xsl:apply-templates select="*[@key='']"/>
      </group>
   </xsl:template>
   <xsl:template match="j:array[@key='wrapped-fields']/j:string"
                 mode="get-value-property"
                 priority="count(ancestor-or-self::*)">
      <value as-type="string" in-json="string">
         <xsl:value-of select="."/>
      </value>
   </xsl:template>
   <xsl:template match="j:map[@key='keyed-fields']/j:string">
      <xsl:param name="with-key" select="true()"/>
      <!-- Cf XML match="field-by-key" -->
      <field name="field-by-key"
             gi="field-by-key"
             json-key-flag="id"
             in-json="SCALAR">
         <flag as-type="string" scope="global" name="id" key="id" gi="id">
            <xsl:value-of select="@key"/>
         </flag>
         <xsl:apply-templates select="*[@key='id']"/>
         <xsl:apply-templates select="." mode="get-value-property"/>
      </field>
   </xsl:template>
   <xsl:template match="j:map[@key='keyed-fields']/j:string" mode="get-value-property">
      <value as-type="string" key="STRVALUE" in-json="string">
         <xsl:apply-templates mode="keep-value-property"/>
      </value>
   </xsl:template>
   <xsl:template match="(j:array[@key='dynamic-value-key-fields']/j:map | j:map[@key='dynamic-value-key-fields'])">
      <xsl:param name="with-key" select="true()"/>
      <!-- Cf XML match="field-dynamic-value-key" -->
      <field name="field-dynamic-value-key" gi="field-dynamic-value-key">
         <xsl:apply-templates select="*[@key='id']"/>
         <xsl:apply-templates select="*[@key='color']"/>
         <xsl:apply-templates select="." mode="get-value-property"/>
      </field>
   </xsl:template>
   <xsl:template match="(j:array[@key='dynamic-value-key-fields']/j:map | j:map[@key='dynamic-value-key-fields'])"
                 mode="get-value-property">
      <flag as-type="string" scope="global" name="id" key="id" gi="id">
         <xsl:value-of select="*[not(@key=())]/@key"/>
      </flag>
      <value as-type="string" key-flag="id" in-json="string">
         <xsl:apply-templates mode="keep-value-property"/>
      </value>
   </xsl:template>
   <xsl:template match="(j:array[@key='dynamic-value-key-fields']/j:map | j:map[@key='dynamic-value-key-fields'])/j:string[@key='color']"><!-- Cf XML match="field-dynamic-value-key/@color" -->
      <flag in-json="string"
            as-type="string"
            name="color"
            key="color"
            gi="color">
         <xsl:value-of select="."/>
      </flag>
   </xsl:template>
   <xsl:template match="(j:array[@key='dynamic-value-key-fields']/j:map | j:map[@key='dynamic-value-key-fields'])/j:string[@key='color']"
                 mode="keep-value-property"
                 priority="count(ancestor-or-self::*)"><!-- Not keeping the flag here. --></xsl:template>
   <xsl:template match="j:string[@key='wrapped-prose']">
      <xsl:param name="with-key" select="true()"/>
      <!-- Cf XML match="wrapped-prose" -->
      <field name="wrapped-prose" gi="wrapped-prose" in-json="SCALAR">
         <xsl:if test="$with-key">
            <xsl:attribute name="key">wrapped-prose</xsl:attribute>
         </xsl:if>
         <xsl:apply-templates select="." mode="get-value-property"/>
      </field>
   </xsl:template>
   <xsl:template match="j:string[@key='wrapped-prose']" mode="get-value-property">
      <value as-type="markup-multiline" in-json="string">
         <xsl:call-template name="parse-markdown">
            <xsl:with-param name="markdown-str" select="string(.)"/>
         </xsl:call-template>
      </value>
   </xsl:template>
   <xsl:template match="j:string[@key='loose-prose']">
      <field scope="global" name="loose-prose" key="loose-prose">
         <value as-type="markup-multiline" in-json="string">
            <xsl:value-of select="."/>
         </value>
      </field>
   </xsl:template>
   <xsl:template match="j:map[@key='ASSEMBLY-1ONLY']">
      <xsl:param name="with-key" select="true()"/>
      <!-- Cf XML match="ASSEMBLY-1ONLY" -->
      <assembly name="assembly-1only" gi="ASSEMBLY-1ONLY">
         <xsl:if test="$with-key">
            <xsl:attribute name="key">ASSEMBLY-1ONLY</xsl:attribute>
         </xsl:if>
         <xsl:apply-templates select="*[@key='field-1only']"/>
         <xsl:apply-templates select="*[@key='ASSEMBLY-1ONLY']"/>
      </assembly>
   </xsl:template>
   <xsl:template match="(j:array[@key='groupable-assemblies']/j:map | j:map[@key='groupable-assemblies'])">
      <xsl:param name="with-key" select="true()"/>
      <!-- Cf XML match="assembly-groupable" -->
      <assembly name="assembly-groupable" gi="assembly-groupable">
         <xsl:apply-templates select="*[@key='groupable-simple-fields']"/>
         <xsl:apply-templates select="*[@key='groupable-assemblies']"/>
      </assembly>
   </xsl:template>
   <xsl:template match="j:array[@key='wrapped-assemblies']/j:map">
      <xsl:param name="with-key" select="true()"/>
      <!-- Cf XML match="assembly-wrappable" -->
      <assembly name="assembly-wrappable" gi="assembly-wrappable">
         <xsl:apply-templates select="*[@key='wrapped-fields']"/>
         <xsl:apply-templates select="*[@key='wrapped-assemblies']"/>
      </assembly>
   </xsl:template>
   <xsl:template match="j:array[@key='wrapped-assemblies']" priority="3">
      <xsl:param name="with-key" select="true()"/>
      <!-- Cf XML match="wrapped-assemblies" -->
      <group name="wrapped-assemblies"
             gi="wrapped-assemblies"
             group-json="ARRAY">
         <xsl:if test="$with-key">
            <xsl:attribute name="key">wrapped-assemblies</xsl:attribute>
         </xsl:if>
         <xsl:apply-templates select="*[@key='']"/>
      </group>
   </xsl:template>
   <xsl:template match="j:map[@key='keyed-assemblies']/j:map">
      <xsl:param name="with-key" select="true()"/>
      <!-- Cf XML match="assembly-by-key" -->
      <assembly name="assembly-by-key" gi="assembly-by-key" json-key-flag="id">
         <flag as-type="string" scope="global" name="id" key="id" gi="id">
            <xsl:value-of select="@key"/>
         </flag>
         <xsl:apply-templates select="*[@key='id']"/>
         <xsl:apply-templates select="*[@key='keyed-fields']"/>
         <xsl:apply-templates select="*[@key='keyed-assemblies']"/>
      </assembly>
   </xsl:template>
   <!-- by default, fields traverse their properties to find a value -->
   <xsl:template match="*" mode="get-value-property">
      <xsl:apply-templates mode="keep-value-property"/>
   </xsl:template>
   <xsl:template match="*" mode="keep-value-property">
      <xsl:value-of select="."/>
   </xsl:template>
   <!-- JSON to XML conversion: Markdown to markup inferencing -->
   <xsl:template match="*" mode="copy mark-structures build-structures infer-inlines">
      <xsl:copy>
         <xsl:copy-of select="@*"/>
         <xsl:apply-templates mode="#current"/>
      </xsl:copy>
   </xsl:template>
   <xsl:template mode="parse-block"
                 priority="1"
                 match="p[exists(@code)]"
                 expand-text="true">
      <pre>
         <code>
            <xsl:for-each select="@code[not(.='code')]">
               <xsl:attribute name="class">language-{.}</xsl:attribute>
            </xsl:for-each>
            <xsl:value-of select="string(.)"/>
         </code>
      </pre>
   </xsl:template>
   <xsl:template mode="parse-block" match="p" expand-text="true">
      <xsl:for-each select="tokenize(string(.),'\n\s*\n')[normalize-space(.)]">
         <p>
            <xsl:value-of select="replace(.,'^\s*\n','')"/>
         </p>
      </xsl:for-each>
   </xsl:template>
   <xsl:template mode="mark-structures" priority="5" match="p[m:is-table(.)]">
      <xsl:variable name="rows">
         <xsl:for-each select="tokenize(string(.),'\s*\n')">
            <tr>
               <xsl:value-of select="."/>
            </tr>
         </xsl:for-each>
      </xsl:variable>
      <table>
         <xsl:apply-templates select="$rows/tr" mode="make-row"/>
      </table>
   </xsl:template>
   <xsl:template match="tr[m:is-table-row-demarcator(string(.))]"
                 priority="5"
                 mode="make-row"/>
   <xsl:template match="tr" mode="make-row">
      <tr>
         <xsl:for-each select="tokenize(string(.), '\s*\|\s*')[not(position() = (1,last())) ]">
            <td>
               <xsl:value-of select="."/>
            </td>
         </xsl:for-each>
      </tr>
   </xsl:template>
   <xsl:template match="tr[some $f in (following-sibling::tr) satisfies m:is-table-row-demarcator(string($f))]"
                 mode="make-row">
      <tr>
         <xsl:for-each select="tokenize(string(.), '\s*\|\s*')[not(position() = (1,last())) ]">
            <th>
               <xsl:value-of select="."/>
            </th>
         </xsl:for-each>
      </tr>
   </xsl:template>
   <xsl:template mode="mark-structures" match="p[matches(.,'^#')]">
        <!-- 's' flag is dot-matches-all, so \n does not impede -->
      <p header-level="{ replace(.,'[^#].*$','','s') ! string-length(.) }">
         <xsl:value-of select="replace(.,'^#+\s*','') ! replace(.,'\s+$','')"/>
      </p>
   </xsl:template>
   <xsl:variable name="li-regex" as="xs:string">^\s*(\*|\d+\.)\s</xsl:variable>
   <xsl:template mode="mark-structures" match="p[matches(.,$li-regex)]">
      <list>
         <xsl:for-each-group group-starting-with=".[matches(.,$li-regex)]"
                             select="tokenize(., '\n')">
            <li level="{ replace(.,'\S.*$','') ! floor(string-length(.) div 2)}"
                type="{ if (matches(.,'\s*\d')) then 'ol' else 'ul' }">
               <xsl:for-each select="current-group()[normalize-space(.)]">
                  <xsl:if test="not(position() eq 1)">
                     <br/>
                  </xsl:if>
                  <xsl:value-of select="replace(., $li-regex, '')"/>
               </xsl:for-each>
            </li>
         </xsl:for-each-group>
      </list>
   </xsl:template>
   <xsl:template mode="build-structures" match="p[@header-level]">
      <xsl:variable name="level" select="(@header-level[6 &gt;= .],6)[1]"/>
      <xsl:element name="h{$level}"
                   namespace="http://csrc.nist.gov/ns/oscal/metaschema/1.0/supermodel">
         <xsl:value-of select="."/>
      </xsl:element>
   </xsl:template>
   <xsl:template mode="build-structures" match="list" name="nest-lists">
        <!-- Starting at level 0 and grouping  -->
        <!--        -->
      <xsl:param name="level" select="0"/>
      <xsl:param name="group" select="li"/>
      <xsl:variable name="this-type" select="$group[1]/@type"/>
      <!--first, splitting ul from ol groups -->
      <!--<xsl:for-each-group select="$group" group-starting-with="*[@level = $level and not(@type = preceding-sibling::*[1]/@type)]">-->
      <!--<xsl:for-each-group select="$group" group-starting-with="*[@level = $level]">-->
      <xsl:element name="{ $group[1]/@type }"
                   namespace="http://csrc.nist.gov/ns/oscal/metaschema/1.0/supermodel">
         <xsl:for-each-group select="$group"
                             group-starting-with="li[(@level = $level) or not(@type = preceding-sibling::*[1]/@type)]">
            <xsl:choose>
               <xsl:when test="@level = $level (: checking first item in group :)">
                  <li>
                            <!--<xsl:copy-of select="@level"/>-->
                     <xsl:apply-templates mode="copy"/>
                     <xsl:if test="current-group()/@level &gt; $level (: go deeper? :)">
                        <xsl:call-template name="nest-lists">
                           <xsl:with-param name="level" select="$level + 1"/>
                           <xsl:with-param name="group" select="current-group()[@level &gt; $level]"/>
                        </xsl:call-template>
                     </xsl:if>
                  </li>
               </xsl:when>
               <xsl:otherwise>
                        <!-- fallback for skipping levels -->
                  <li>
                                <!-- level="{$level}"-->
                     <xsl:call-template name="nest-lists">
                        <xsl:with-param name="level" select="$level + 1"/>
                        <xsl:with-param name="group" select="current-group()"/>
                     </xsl:call-template>
                  </li>
               </xsl:otherwise>
            </xsl:choose>
         </xsl:for-each-group>
      </xsl:element>
      <!--</xsl:for-each-group>-->
   </xsl:template>
   <xsl:template match="pre//text()" mode="infer-inlines">
      <xsl:copy-of select="."/>
   </xsl:template>
   <xsl:template match="text()" mode="infer-inlines">
      <xsl:variable name="markup">
         <xsl:apply-templates select="$tag-replacements/rules" mode="replacements">
            <xsl:with-param name="original" tunnel="yes" as="text()" select="."/>
         </xsl:apply-templates>
      </xsl:variable>
      <xsl:try select="parse-xml-fragment($markup)">
         <xsl:catch select="."/>
      </xsl:try>
   </xsl:template>
   <xsl:template match="rules" as="xs:string" mode="replacements">

        <!-- Original is only provided for processing text nodes -->
      <xsl:param name="original" as="text()?" tunnel="yes"/>
      <xsl:param name="starting" as="xs:string" select="string($original)"/>
      <xsl:iterate select="*">
         <xsl:param name="original" select="$original" as="text()?"/>
         <xsl:param name="str" select="$starting" as="xs:string"/>
         <xsl:on-completion select="$str"/>
         <xsl:next-iteration>
            <xsl:with-param name="str">
               <xsl:apply-templates select="." mode="replacements">
                  <xsl:with-param name="str" select="$str"/>
               </xsl:apply-templates>
            </xsl:with-param>
         </xsl:next-iteration>
      </xsl:iterate>
   </xsl:template>
   <xsl:template match="replace" expand-text="true" mode="replacements">
      <xsl:param name="str" as="xs:string"/>
      <!--<xsl:value-of>replace({$str},{@match},{string(.)})</xsl:value-of>-->
      <!-- 's' sets dot-matches-all       -->
      <xsl:sequence select="replace($str, @match, string(.),'s')"/>
      <!--<xsl:copy-of select="."/>-->
   </xsl:template>
   <xsl:variable name="tag-replacements">
      <rules>
            <!-- first, literal replacements -->
         <replace match="&amp;">&amp;amp;</replace>
         <replace match="&lt;">&amp;lt;</replace>
         <!-- next, explicit escape sequences -->
         <replace match="\\&#34;">&amp;quot;</replace>
         <!--<replace match="\\&#39;">&amp;apos;</replace>-->
         <replace match="\\\*">&amp;#x2A;</replace>
         <replace match="\\`">&amp;#x60;</replace>
         <replace match="\\~">&amp;#x7E;</replace>
         <replace match="\\^">&amp;#x5E;</replace>
         <!-- then, replacements based on $tag-specification -->
         <xsl:for-each select="$tag-specification/*">
            <xsl:variable name="match-expr">
               <xsl:apply-templates select="." mode="write-match"/>
            </xsl:variable>
            <xsl:variable name="repl-expr">
               <xsl:apply-templates select="." mode="write-replace"/>
            </xsl:variable>
            <replace match="{$match-expr}">
               <xsl:sequence select="$repl-expr"/>
            </replace>
         </xsl:for-each>
      </rules>
   </xsl:variable>
   <xsl:variable name="tag-specification" as="element(tag-spec)">
      <tag-spec>
            <!-- The XML notation represents the substitution by showing both delimiters and tags  -->
            <!-- Note that text contents are regex notation for matching so * must be \* -->
         <q>"<text/>"</q>
         <img alt="!\[{{$noclosebracket}}\]" src="\({{$nocloseparen}}\)"/>
         <insert param-id="\{{\{{{{$nws}}\}}\}}"/>
         <a href="\[{{$nocloseparen}}\]">\(<text not="\)"/>\)</a>
         <code>`<text/>`</code>
         <strong>
            <em>\*\*\*<text/>\*\*\*</em>
         </strong>
         <strong>\*\*<text/>\*\*</strong>
         <em>\*<text/>\*</em>
         <sub>~<text/>~</sub>
         <sup>\^<text/>\^</sup>
      </tag-spec>
   </xsl:variable>
   <xsl:template match="*" mode="write-replace">
        <!-- we can write an open/close pair even for an empty element b/c
             it will be parsed and serialized -->
      <xsl:text>&lt;</xsl:text>
      <xsl:value-of select="local-name()"/>
      <!-- forcing the namespace! -->
      <xsl:text> xmlns="http://csrc.nist.gov/ns/oscal/metaschema/1.0/supermodel"</xsl:text>
      <!-- coercing the order to ensure correct formation of regegex       -->
      <xsl:apply-templates mode="#current" select="@*"/>
      <xsl:text>&gt;</xsl:text>
      <xsl:apply-templates mode="#current" select="*"/>
      <xsl:text>&lt;/</xsl:text>
      <xsl:value-of select="local-name()"/>
      <xsl:text>&gt;</xsl:text>
   </xsl:template>
   <xsl:template match="*" mode="write-match">
      <xsl:apply-templates select="@*, node()" mode="write-match"/>
   </xsl:template>
   <xsl:template match="@*[matches(., '\{\$text\}')]" mode="write-match">
      <xsl:value-of select="replace(., '\{\$text\}', '(.*)?')"/>
   </xsl:template>
   <xsl:template match="@*[matches(., '\{\$nocloseparen\}')]" mode="write-match">
      <xsl:value-of select="replace(., '\{\$nocloseparen\}', '([^\\(]*)?')"/>
   </xsl:template>
   <xsl:template match="@*[matches(., '\{\$noclosebracket\}')]" mode="write-match">
      <xsl:value-of select="replace(., '\{\$noclosebracket\}', '([^\\[]*)?')"/>
   </xsl:template>
   <xsl:template match="@*[matches(., '\{\$nws\}')]" mode="write-match">
        <!--<xsl:value-of select="."/>-->
        <!--<xsl:value-of select="replace(., '\{\$nws\}', '(\S*)?')"/>-->
      <xsl:value-of select="replace(., '\{\$nws\}', '\\s*(\\S+)?\\s*')"/>
   </xsl:template>
   <xsl:template match="text" mode="write-replace">
      <xsl:text>$1</xsl:text>
   </xsl:template>
   <xsl:template match="insert/@param-id" mode="write-replace">
      <xsl:text> param-id='$1'</xsl:text>
   </xsl:template>
   <xsl:template match="a/@href" mode="write-replace">
      <xsl:text> href='$2'</xsl:text>
      <!--<xsl:value-of select="replace(.,'\{\$insert\}','\$2')"/>-->
   </xsl:template>
   <xsl:template match="img/@alt" mode="write-replace">
      <xsl:text> alt='$1'</xsl:text>
      <!--<xsl:value-of select="replace(.,'\{\$insert\}','\$2')"/>-->
   </xsl:template>
   <xsl:template match="img/@src" mode="write-replace">
      <xsl:text> src='$2'</xsl:text>
      <!--<xsl:value-of select="replace(.,'\{\$insert\}','\$2')"/>-->
   </xsl:template>
   <xsl:template match="text" mode="write-match">
      <xsl:text>(.*?)</xsl:text>
   </xsl:template>
   <xsl:template match="text[@not]" mode="write-match">
      <xsl:text expand-text="true">([^{ @not }]*?)</xsl:text>
   </xsl:template>
   <!-- JSON to XML conversion: Supermodel serialization as XML -->
   <xsl:strip-space xmlns:s="http://csrc.nist.gov/ns/oscal/metaschema/1.0/supermodel"
                    elements="s:*"/>
   <xsl:preserve-space xmlns:s="http://csrc.nist.gov/ns/oscal/metaschema/1.0/supermodel"
                       elements="s:flag s:value"/>
   <xsl:mode xmlns:s="http://csrc.nist.gov/ns/oscal/metaschema/1.0/supermodel"
             name="write-xml"/>
   <xsl:template xmlns:s="http://csrc.nist.gov/ns/oscal/metaschema/1.0/supermodel"
                 match="s:*[exists(@gi)]"
                 mode="write-xml">
      <xsl:element name="{@gi}" namespace="http://csrc.nist.gov/metaschema/ns/everything">
            <!-- putting flags first in case of disarranged inputs -->
         <xsl:apply-templates select="s:flag, (* except s:flag)" mode="write-xml"/>
      </xsl:element>
   </xsl:template>
   <xsl:template xmlns:s="http://csrc.nist.gov/ns/oscal/metaschema/1.0/supermodel"
                 match="s:value[@as-type=('markup-line','markup-multiline')]"
                 mode="write-xml">
      <xsl:apply-templates mode="cast-prose"/>
   </xsl:template>
   <xsl:template xmlns:s="http://csrc.nist.gov/ns/oscal/metaschema/1.0/supermodel"
                 match="p | ul | ol | pre | h1 | h2 | h3 | h4 | h5 | h6 | table"
                 xpath-default-namespace="http://csrc.nist.gov/ns/oscal/metaschema/1.0/supermodel">
      <xsl:apply-templates select="." mode="cast-prose"/>
   </xsl:template>
   <xsl:template xmlns:s="http://csrc.nist.gov/ns/oscal/metaschema/1.0/supermodel"
                 priority="2"
                 match="s:flag"
                 mode="write-xml">
      <xsl:attribute name="{@gi}">
         <xsl:value-of select="."/>
      </xsl:attribute>
   </xsl:template>
   <xsl:template xmlns:s="http://csrc.nist.gov/ns/oscal/metaschema/1.0/supermodel"
                 match="*"
                 mode="cast-prose">
      <xsl:element name="{local-name()}"
                   namespace="http://csrc.nist.gov/metaschema/ns/everything">
         <xsl:copy-of select="@*"/>
         <xsl:apply-templates mode="#current"/>
      </xsl:element>
   </xsl:template>
</xsl:stylesheet>
