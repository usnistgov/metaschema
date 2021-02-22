<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:math="http://www.w3.org/2005/xpath-functions/math"
    xmlns:m="http://csrc.nist.gov/ns/oscal/metaschema/1.0"
    xpath-default-namespace="http://csrc.nist.gov/ns/oscal/metaschema/1.0"
    exclude-result-prefixes="xs math m"
    version="3.0"
    
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">

    
<!-- Purpose: Produce an XSD Schema representing constraints declared in a metaschema -->
<!-- Input:   A Metaschema -->
<!-- Output:  An XSD, with embedded documentation -->

<!-- nb The schema and Schematron for the metaschema format is essential
        for validating constraints assumed by this transformation. -->

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
        <xs:schema elementFormDefault="qualified" targetNamespace="{ $target-namespace }">
            <xsl:namespace name="m">http://csrc.nist.gov/ns/oscal/metaschema/1.0</xsl:namespace>
            <xsl:namespace name="{$declaration-prefix}" select="$target-namespace"/>
            <xsl:for-each select="$metaschema/METASCHEMA/schema-version">
                <xsl:attribute name="version" select="normalize-space(.)"/>
            </xsl:for-each>
            <xs:annotation>
                <xs:appinfo>
                    <xsl:apply-templates select="$metaschema/METASCHEMA/*"
                        mode="top-level-docs"/>
                </xs:appinfo>
            </xs:annotation>
            <xsl:apply-templates select="$metaschema/METASCHEMA/*"/>
            
            <xsl:if test="$metaschema//@as-type = ('markup-line', 'markup-multiline')">
                <!--<xsl:if test="$metaschema//@as-type = 'markup-multiline'">
                    <xs:group name="PROSE">
                        <xs:choice>
                            <xs:element ref="oscal-prose:h1"/>
                            <xs:element ref="oscal-prose:h2"/>
                            <xs:element ref="oscal-prose:h3"/>
                            <xs:element ref="oscal-prose:h4"/>
                            <xs:element ref="oscal-prose:h5"/>
                            <xs:element ref="oscal-prose:h6"/>
                            <xs:element ref="oscal-prose:p"/>
                            <xs:element ref="oscal-prose:ul"/>
                            <xs:element ref="oscal-prose:ol"/>
                            <xs:element ref="oscal-prose:pre"/>
                            <xs:element ref="oscal-prose:table"/>
                        </xs:choice>
                    </xs:group>
                </xsl:if>-->
                <xsl:apply-templates mode="acquire-prose" select="document('oscal-prose-module.xsd')"/>
            </xsl:if>
            <xsl:variable name="all-types" select="$metaschema//@as-type"/>
            
            <xsl:copy-of select="$types-library/xs:simpleType[@name = $all-types]"/>
        </xs:schema>
    </xsl:template>
    
    <xsl:variable name="types-library" select="document('oscal-datatypes.xsd')/*"/>
    
    <xsl:template match="namespace"/>
        
    <xsl:template mode="top-level-docs" match="*"/>
    
    <xsl:template mode="top-level-docs" match="/METASCHEMA/schema-name | /METASCHEMA/short-name |
        /METASCHEMA/schema-version | /METASCHEMA/remarks">
        <xsl:apply-templates mode="copy" select="."/>
    </xsl:template>
    
    <xsl:template mode="top-level-docs" match="/METASCHEMA/define-assembly[exists(root-name)]">
        <xsl:for-each select="root-name">
            <m:root>
                <xsl:apply-templates/>
            </m:root>
        </xsl:for-each>
    </xsl:template>
    
    <xsl:template match="/METASCHEMA/schema-name | /METASCHEMA/short-name |
        /METASCHEMA/schema-version | /METASCHEMA/remarks"/>
    
    <xsl:template match="define-assembly">
        <xsl:variable name="whose" select="."/>
        
        <xsl:for-each select="child::root-name">
            <xs:element name="{.}" type="{$declaration-prefix}:{../@name}-ASSEMBLY"/>
        </xsl:for-each>
        
        <xs:complexType>
            <xsl:if test="parent::METASCHEMA">
                <xsl:attribute name="name" expand-text="true">{@name}-ASSEMBLY</xsl:attribute>
            </xsl:if>
            <xsl:apply-templates select="." mode="annotated"/>
            <xsl:apply-templates select="model"/>
            <xsl:apply-templates select="flag | define-flag"/>
        </xs:complexType>
    </xsl:template>
    
    <xsl:template priority="11"
        match="model//define-field[group-as/@in-xml='GROUPED'] |
               model//define-assembly[group-as/@in-xml='GROUPED']">
        <xs:element name="{group-as/@name}"
            minOccurs="{ if (@min-occurs != '0') then 1 else 0 }"
            maxOccurs="1">
            <xs:annotation xsl:expand-text="true">
                <xs:appinfo>
                    <m:formal-name>{ group-as/@name }</m:formal-name>
                    <m:description>A group of '{ @name }' elements</m:description>
                </xs:appinfo>
                <xs:documentation>
                    <b>{ group-as/@name }</b>: A group of '{ @name }' elements</xs:documentation>
            </xs:annotation>
            <xs:complexType>
                <xs:sequence>
                    <xsl:next-match/>
                </xs:sequence>
            </xs:complexType>
            <xsl:apply-templates select="json-key" mode="uniqueness-constraint">
                <xsl:with-param name="whose" select="."/>
            </xsl:apply-templates>
        </xs:element>
    </xsl:template>
    
    <xsl:template match="json-key" mode="uniqueness-constraint">
        <xsl:param name="whose"  select="(ancestor::define-assembly | ancestor::define-field)[last()]"/>
        <xs:unique name="{ $whose/@name}-{ ../@name }-keys">
            <xs:selector xpath="{ $declaration-prefix}:{../@name }"/>
            <xs:field xpath="@{ @flag-name }"/>
        </xs:unique>
    </xsl:template>
    
    
    <xsl:template priority="10" match="model//define-assembly | model//define-field">
        <xsl:variable name="gi" select="(use-name,@name)[1]"/>
        <xs:element name="{$gi}" 
            minOccurs="{ if (exists(@min-occurs)) then @min-occurs else 0 }"
            maxOccurs="{ if (exists(@max-occurs)) then @max-occurs else 1 }">
            <xsl:next-match/>
        </xs:element>
    </xsl:template>
    
    <xsl:template match="define-field[empty(flag|define-flag)]">
        <xs:simpleType>
            <xsl:call-template name="name-global-field-type"/>
            <xsl:apply-templates select="." mode="annotated"/>
            <xsl:variable name="datatype">
                <xsl:choose>
                    <!--<xsl:when test="exists(constraint/allowed-values)">
                        <xsl:value-of select="concat(@name,'-FIELD-VALUE-ENUMERATION')"/>
                    </xsl:when>-->
                    <xsl:when test="exists(@as-type)">
                        <xsl:value-of select="@as-type"/>
                    </xsl:when>
                    <xsl:otherwise>string</xsl:otherwise>
                </xsl:choose>
            </xsl:variable>
            <xs:restriction base="xs:string">
                <!-- replace @base with correct base for type -->
                <xsl:call-template name="assign-datatype">
                    <xsl:with-param name="assign-to-attribute">base</xsl:with-param>
                    <xsl:with-param name="datatype" select="$datatype"/>
                </xsl:call-template>
            </xs:restriction>
        </xs:simpleType>
        <!--<xsl:apply-templates select="constraint/allowed-values">
            <xsl:with-param name="simpletype-name" select="@name || '-FIELD-VALUE-ENUMERATION'"/>
        </xsl:apply-templates>-->
    </xsl:template>
    
    <xsl:template match="define-field">
        <xs:complexType>
            <xsl:call-template name="name-global-field-type"/>
            <xsl:apply-templates select="." mode="annotated"/>
            <xsl:variable name="datatype">
                <xsl:choose>
                    <!--<xsl:when test="exists(constraint/allowed-values)">
                        <xsl:value-of select="concat(@name,'-FIELD-VALUE-ENUMERATION')"/>
                    </xsl:when>-->
                    <xsl:when test="exists(@as-type)">
                        <xsl:value-of select="@as-type"/>
                    </xsl:when>
                    <xsl:otherwise>string</xsl:otherwise>
                </xsl:choose>
            </xsl:variable>
                <xs:simpleContent>
                    <xs:extension base="xs:string">
                        <!-- replace @base with correct base for type -->
                        <xsl:call-template name="assign-datatype">
                            <xsl:with-param name="assign-to-attribute">base</xsl:with-param>
                            <xsl:with-param name="datatype" select="$datatype"/>
                        </xsl:call-template>
                        <xsl:apply-templates select="define-flag | flag"/>
                    </xs:extension>
                </xs:simpleContent>
        </xs:complexType>
        <!--<xsl:apply-templates select="constraint/allowed-values">
            <xsl:with-param name="simpletype-name" select="@name || '-FIELD-VALUE-ENUMERATION'"/>
        </xsl:apply-templates>-->
    </xsl:template>
    
    <xsl:template name="name-global-field-type">
        <xsl:if test="parent::METASCHEMA">
            <xsl:attribute name="name" select="@name || '-FIELD'"/>
        </xsl:if>
    </xsl:template>

    <xsl:template priority="5" match="define-field[@as-type='markup-line']">
            <xs:complexType mixed="true">
                <xsl:call-template name="name-global-field-type"/>
                <!--<xs:group ref="{$declaration-prefix}:everything-inline"/>-->
                <xs:complexContent>
                    <xs:extension base="{$declaration-prefix}:markupLineType">
                        
                <xsl:apply-templates select="define-flag | flag"/>
                    </xs:extension>
                </xs:complexContent>
            </xs:complexType>
    </xsl:template>
    
    <xsl:template priority="5" match="define-field[@as-type='markup-multiline']">
            <xs:complexType>
                <xsl:call-template name="name-global-field-type"/>
                <!--<xs:group ref="{$declaration-prefix}:PROSE" maxOccurs="unbounded" minOccurs="0"/>-->
                <xs:complexContent>
                    <xs:extension base="{$declaration-prefix}:markupMultilineType">
                        <xsl:apply-templates select="define-flag | flag"/>
                    </xs:extension>
                </xs:complexContent>
            </xs:complexType>
    </xsl:template>
    
    <xsl:template priority="6" match="METASCHEMA/define-field[@as-type='markup-multiline'][not(@in-xml='WITH_WRAPPER')]"/>

   <!-- Flags become attributes; this schema defines them all locally. -->
    <xsl:template match="define-flag"/>

    <!-- Extra coverage -->
    <xsl:template mode="annotated" priority="5"
        match="define-flag[empty(formal-name | description)] |
        define-field[empty(formal-name | description)] |
        define-assembly[empty(formal-name | description)] |
        flag[empty(formal-name | description)]"/>

    <xsl:template mode="annotated" match="*"/>
    
    <xsl:template match="define-flag | define-field | define-assembly" mode="annotated">
        <xs:annotation>
            <xs:appinfo>
                <xsl:apply-templates select="formal-name, description" mode="copy"/>
            </xs:appinfo>
            <xs:documentation>
                <xsl:apply-templates select="formal-name, description"/>
            </xs:documentation>
        </xs:annotation>
    </xsl:template>
    
    <xsl:template match="formal-name">
        <b><xsl:apply-templates/></b>
        <xsl:for-each select="../description">: </xsl:for-each>
    </xsl:template>
    
    <xsl:template match="model">
        <xs:sequence>
            <xsl:apply-templates/>
        </xs:sequence>
    </xsl:template>
    
    <xsl:template match="any">
        <xs:any namespace="##other" processContents="lax"/>
    </xsl:template>
    
    <!--<xsl:template priority="10" match="model[exists(@ref)]">
        <xsl:apply-templates select="key('global-assembly-by-name',@ref)/model"/>
    </xsl:template>-->
    
    <xsl:template match="choice">
        <xs:choice>
            <xsl:apply-templates/>
        </xs:choice>
    </xsl:template>

    <xsl:template match="field">
        <xsl:variable name="decl" select="key('global-field-by-name',@ref)"/>
        <xsl:variable name="gi" select="(use-name,$decl/use-name,@ref)[1]"/>
        <xsl:call-template name="declare-element-as-type">
            <xsl:with-param name="decl" select="$decl"/>
            <xsl:with-param name="gi" select="$gi"/>
            <xsl:with-param name="type" select="$declaration-prefix || ':' || @ref || '-FIELD'"></xsl:with-param>
        </xsl:call-template>
    </xsl:template>
    
    <xsl:template match="assembly">
        <xsl:variable name="decl" select="key('global-assembly-by-name',@ref)"/>
        <xsl:variable name="gi" select="(use-name,$decl/root-name,$decl/use-name,@ref)[1]"/>
        <xsl:call-template name="declare-element-as-type">
            <xsl:with-param name="decl" select="$decl"/>
            <xsl:with-param name="gi" select="$gi"/>
            <xsl:with-param name="type" select="$declaration-prefix || ':' || @ref || '-ASSEMBLY'"/>
        </xsl:call-template>
    </xsl:template>
    
    <xsl:template name="declare-element-as-type">
        <xsl:param name="decl" select="()"/>
        <xsl:param name="gi" required="yes"/>
        <xsl:param name="type" select="@ref"/>
        <xs:element name="{$gi}" type="{$type}"
            minOccurs="{ if (exists(@min-occurs)) then @min-occurs else 0 }"
            maxOccurs="{ if (exists(@max-occurs)) then @max-occurs else 1 }">
            <!-- producing xs:unique to govern attributes that will be promoted to keys -->
            <!-- this works over and above XSD type validation e.g. ID -->
            <!--<xsl:apply-templates select="$decl" mode="annotated"/>-->
            <!--<xsl:apply-templates select="$decl/json-key" mode="uniqueness-constraint"/>-->
        </xs:element>
    </xsl:template>
    
    <xsl:template priority="5" match="field[group-as/@in-xml='GROUPED'] | assembly[group-as/@in-xml='GROUPED']">
        <xs:element name="{group-as/@name}"
            minOccurs="{ if (@min-occurs != '0') then 1 else 0 }"
            maxOccurs="1">
            <xsl:variable name="decl" select="key('global-field-by-name',self::field/@ref) | key('global-assembly-by-name',self::assembly/@ref)"/>
            <!--<xsl:apply-templates select="$decl" mode="annotated"/>-->
            <xs:complexType>
                <xs:sequence>
                  <xsl:next-match/>
                </xs:sequence>
            </xs:complexType>
            <xsl:apply-templates select="$decl/json-key" mode="uniqueness-constraint"/>
        </xs:element>
    </xsl:template>
    
    <!-- TODO XXX switch default behavior ...   -->
    
    <xsl:template priority="11" match="model//define-field[@in-xml='UNWRAPPED'][@as-type='markup-multiline']">
        <xs:group ref="{$declaration-prefix}:blockElementGroup" maxOccurs="unbounded" minOccurs="0"/>
        <!--<xs:group ref="{$declaration-prefix}:PROSE" maxOccurs="unbounded" minOccurs="0"/>-->
    </xsl:template>
    
    <!-- No wrapper, just prose elements -->
    <xsl:template match="field[@in-xml='UNWRAPPED'][key('global-field-by-name',@ref)/@as-type='markup-multiline']">
        <xs:group ref="{$declaration-prefix}:blockElementGroup" maxOccurs="unbounded" minOccurs="0"/>
    </xsl:template>
    
    <!-- With wrapper -->
    <xsl:template match="field[not(@in-xml='UNWRAPPED')][key('global-field-by-name',@ref)/@as-type='markup-multiline']">
        <xsl:variable name="decl" select="key('global-field-by-name',@ref)"/>
        <xsl:variable name="gi" select="(use-name,$decl/use-name,@ref)[1]"/>
        <xs:element name="{ $gi }"
            minOccurs="{ if (exists(@min-occurs)) then @min-occurs else 0 }"
            maxOccurs="{ if (exists(@max-occurs)) then @max-occurs else 1 }">
            <xsl:apply-templates select="key('global-field-by-name',@ref)" mode="annotated"/>
            <xs:complexType>
                <xs:group ref="{$declaration-prefix}:blockElementGroup" maxOccurs="unbounded" minOccurs="0"/>
              <!--<xs:group ref="{$declaration-prefix}:PROSE" maxOccurs="unbounded" minOccurs="0"/>-->
            </xs:complexType>
        </xs:element>
    </xsl:template>
    
    
    <xsl:template match="flag">
        <xsl:variable name="decl" select="key('global-flag-by-name',@ref)"/>
        <xsl:variable name="gi" select="(use-name,$decl/use-name,@ref)[1]"/>
        <xsl:variable name="datatype" select="(@as-type,$decl/@as-type,'string')[1]"/>
        <!--<xsl:variable name="value-list" select="(constraint/allowed-values,key('global-flag-by-name',@ref)/constraint/allowed-values)[1]"/>-->
        <xs:attribute name="{ $gi }">
            
            <xsl:if test="(@required='yes') or (@name=(../json-key/@flag-name,../json-value-key/@flag-name))">
                <xsl:attribute name="use">required</xsl:attribute>
            </xsl:if>
            <!-- annotate as datatype or string unless an exclusive value-list is given -->
            <!--<xsl:if test="empty($value-list)">-->
                <!-- overriding string datatype on attribute -->
                <xsl:call-template name="assign-datatype">
                    <xsl:with-param name="datatype" select="$datatype"/>
                </xsl:call-template>
            <!--</xsl:if>-->
            <xsl:apply-templates select="$decl" mode="annotated"/>
            
            <!--<xsl:apply-templates select="$value-list">
                <xsl:with-param name="datatype" select="$datatype"/>
            </xsl:apply-templates>-->
        </xs:attribute>
    </xsl:template>
    
    
    <xsl:template match="define-assembly/define-flag | define-field/define-flag">
        <xsl:variable name="gi" select="(use-name,@name)[1]"/>
        <xsl:variable name="datatype" select="(@as-type,'string')[1]"/>
        <!--<xsl:variable name="value-list" select="constraint/allowed-values"/>-->
        <xs:attribute name="{ $gi }">
            <xsl:if test="(@required='yes') or (@name=(../json-key/@flag-name,../json-value-key/@flag-name))">
                <xsl:attribute name="use">required</xsl:attribute>
            </xsl:if>
            <!--<xsl:if test="empty($value-list)">-->
                <!-- overriding string datatype on attribute -->
                <xsl:call-template name="assign-datatype">
                    <xsl:with-param name="datatype" select="$datatype"/>
                </xsl:call-template>
            <!--</xsl:if>-->
            <xsl:apply-templates select="." mode="annotated"/>
            <!--<xsl:apply-templates select="$value-list">
                <xsl:with-param name="datatype" select="$datatype"/>
            </xsl:apply-templates>-->
        </xs:attribute>
    </xsl:template>
    
    <xsl:template name="assign-datatype">
        <xsl:param name="assign-to-attribute" as="xs:string?">type</xsl:param>
        <xsl:param name="datatype"/>
        <xsl:variable name="oscal-types" select="$datatype[. = $types-library/xs:simpleType/@name]"/>
        <xsl:for-each select="$oscal-types">
            <xsl:attribute name="{ $assign-to-attribute }" expand-text="true"
                select="concat($declaration-prefix, ':', .)"/>
        </xsl:for-each>
        <xsl:variable name="xsd-types" select="$datatype[. = $types-library/xs:annotation[@id='built-in-types']/xs:appinfo/xs:simpleType/@name]"/>
        <xsl:for-each select="$xsd-types">
            <xsl:attribute name="{ $assign-to-attribute }" expand-text="true" select="concat('xs:', .)"/>
        </xsl:for-each>
        <xsl:if test="empty(($oscal-types,$xsd-types))">
            <xsl:attribute name="{ $assign-to-attribute }" expand-text="true"
                select="concat($declaration-prefix, ':', $datatype)"/>
        </xsl:if>
        
    </xsl:template>

    <!-- When allow-other=yes, we union the enumeration with the declared datatype -->        
    <xsl:template match="allowed-values[@allow-other='yes']">
        <xsl:param name="datatype" as="xs:string">string</xsl:param>
        <xsl:param name="simpletype-name" as="xs:string?"/>
        <xs:simpleType>
            <xsl:for-each select="$simpletype-name">
                <xsl:attribute name="name">
                    <xsl:value-of select="."/>
                </xsl:attribute>
            </xsl:for-each>
            <xs:union memberTypes="xs:{$datatype}">
                <xsl:call-template name="assign-datatype">
                    <xsl:with-param name="datatype" select="$datatype"/>
                    <xsl:with-param name="assign-to-attribute">memberTypes</xsl:with-param>
                </xsl:call-template>
                <xs:simpleType>
                    <xs:restriction base="xs:{$datatype}">
                        <xsl:call-template name="assign-datatype">
                            <xsl:with-param name="datatype" select="$datatype"/>
                            <xsl:with-param name="assign-to-attribute">base</xsl:with-param>
                        </xsl:call-template>
                        <xsl:apply-templates/>
                    </xs:restriction>
                </xs:simpleType>
            </xs:union>
        </xs:simpleType>
    </xsl:template>
    
    <xsl:template match="allowed-values">
        <xsl:param name="datatype" select="(../@as-type,'string')[1]"/>
        <xsl:param name="simpletype-name" as="xs:string?"/>
        <xs:simpleType>
            <xsl:for-each select="$simpletype-name">
                <xsl:attribute name="name">
                    <xsl:value-of select="."/>
                </xsl:attribute>
            </xsl:for-each>
            <xs:restriction base="xs:{$datatype}">
                <xsl:apply-templates/>
            </xs:restriction>
        </xs:simpleType>
    </xsl:template>
    
    <xsl:template match="allowed-values/enum">
        <xs:enumeration value="{@value}">
            <xsl:if test="matches(.,'\S')">
                <xs:annotation>
                    <xs:documentation>
                        <p>
                            <xsl:apply-templates/>
                        </p>
                    </xs:documentation>
                </xs:annotation>
            </xsl:if>
        </xs:enumeration>
    </xsl:template> 
    
    <xsl:mode name="acquire-prose" on-no-match="shallow-copy"/>
    
    <xsl:template match="xs:schema" mode="acquire-prose">
            <xsl:apply-templates mode="#current"/>
    </xsl:template>
    
    <xsl:template match="@ref | @type | @base" mode="acquire-prose">
        <xsl:attribute name="{ name() }">
            <xsl:if test="not(matches(.,':'))" expand-text="true">{ $declaration-prefix }:</xsl:if>
            <xsl:text expand-text="true">{ string(.) }</xsl:text>
        </xsl:attribute>
    </xsl:template>
    
    <xsl:mode name="copy" on-no-match="shallow-copy"/>
    
    <xsl:template match="m:*" mode="copy">
        <xsl:element name="m:{local-name(.)}" namespace="{namespace-uri(.)}">
            <xsl:apply-templates mode="#current"/>
        </xsl:element>
    </xsl:template>

    <!-- copying contents of remarks we pull them out into no-namespace -->
    <xsl:template mode="copy" match="remarks//*">
        <xsl:element name="{local-name()}">
            <xsl:copy-of select="@*"/>
            <xsl:apply-templates mode="#current"/>
        </xsl:element>
    </xsl:template>
    
    
</xsl:stylesheet>