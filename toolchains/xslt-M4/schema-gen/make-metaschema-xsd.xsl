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
<!-- Input:   A (composed) metaschema -->
<!-- Output:  An XSD, with embedded documentation -->

<!-- nb The schema and Schematron for the metaschema format is essential
        for validating constraints assumed by this transformation. -->

    <xsl:output indent="yes"/>

    <xsl:strip-space elements="METASCHEMA define-assembly define-field define-flag model choice allowed-values remarks"/>
    
    <xsl:variable name="target-namespace" select="string(/METASCHEMA/namespace)"/>
        
    <xsl:key name="global-assembly-by-name" match="/METASCHEMA/define-assembly" use="@_key-name"/>
    <xsl:key name="global-field-by-name"    match="/METASCHEMA/define-field"    use="@_key-name"/>
    <xsl:key name="global-flag-by-name"     match="/METASCHEMA/define-flag"     use="@_key-name"/>
    
    <xsl:variable name="metaschema" select="/"/>
    
    <!-- Produces intermediate results, w/o namespace alignment -->
    <!-- entry template -->
    
    <xsl:param name="verbose" select="'no'" as="xs:string"/>
    <xsl:variable name="noisy" select="$verbose = ('yes','true')"/>
    
    <!--MAIN ACTION HERE -->
    
    
    <!--<xsl:variable name="prose-module-xsd" select="document('oscal-prose-module.xsd')"/>-->
   
   
    <xsl:variable name="prose-modules" as="element()*">
        <module>../../../schema/xml/metaschema-markup-multiline.xsd</module>
        <module>../../../schema/xml/metaschema-markup-line.xsd</module>
        <module>../../../schema/xml/metaschema-prose-base.xsd</module>
    </xsl:variable>
   
    <xsl:variable name="atomictype-modules" as="element()*">
        <module>../../../schema/xml/metaschema-datatypes.xsd</module>
    </xsl:variable>
    
    <xsl:variable name="type-map" as="element()*">
        <type as-type="base64">Base64Datatype</type>
        <type as-type="boolean">BooleanDatatype</type>
        <type as-type="date">DateDatatype</type>
        <type as-type="date-time">DateTimeDatatype</type>
        <type as-type="date-time-with-timezone">DateTimeWithTimezoneDatatype</type>
        <type as-type="date-with-timezone">DateWithTimezoneDatatype</type>
        <type as-type="day-time-duration">DayTimeDurationDatatype</type>
        <type as-type="decimal">DecimalDatatype</type>
        <!-- Not supporting float or double -->
        <!--<xs:enumeration as-type="float">float</xs:enumeration> -->
        <!--<xs:enumeration as-type="double">double</xs:enumeration> -->
        <type as-type="email-address">EmailAddressDatatype</type>
        <type as-type="hostname">HostnameDatatype</type>
        <type as-type="integer">IntegerDatatype</type>
        <type as-type="ip-v4-address">IPV4AddressDatatype</type>
        <type as-type="ip-v6-address">IPV6AddressDatatype</type>
        <type as-type="non-negative-integer">NonNegativeIntegerDatatype</type>
        <type as-type="positive-integer">PositiveIntegerDatatype</type>
        <type as-type="string">StringDatatype</type>
        <type as-type="token">TokenDatatype</type>
        <type as-type="uri">URIDatatype</type>
        <type as-type="uri-reference">URIReferenceDatatype</type>
        <type as-type="uuid">UUIDDatatype</type>
        
        <!-- these old names are permitted for now, while only deprecated       -->
        <!--../../../schema/xml/metaschema.xsd line 1052 inside  /*/xs:simpleType[@name='SimpleDatatypesType']> -->
        <type prefer="base64" as-type="base64Binary">Base64Datatype</type>
        <type prefer="date-time" as-type="dateTime">DateTimeDatatype</type>
        <type prefer="date-time-with-timezone" as-type="dateTime-with-timezone">DateTimeWithTimezoneDatatype</type>
        <type prefer="email-address" as-type="email">EmailAddressDatatype</type>
        <type prefer="non-negative-integer" as-type="nonNegativeInteger">NonNegativeIntegerDatatype</type>
        <type prefer="positive-integer" as-type="positiveInteger">PositiveIntegerDatatype</type>
    </xsl:variable>
    
    <xsl:variable name="prose-xsd-definitions" select="$prose-modules/document(string(.))/*/*"/>
    
    <xsl:variable name="types-library"    select="$atomictype-modules/document(string(.))/*"/>
    
    <xsl:template match="/" name="build-schema">
        <xsl:for-each select="$metaschema//EXCEPTION[$noisy]">
            <xsl:message expand-text="true">Metaschema composition exception reported{ @problem-type/' (' || . || ')'}: { normalize-space() }</xsl:message>
        </xsl:for-each>
        <xs:schema elementFormDefault="qualified" targetNamespace="{ $target-namespace }">
            <xsl:namespace name="m">http://csrc.nist.gov/ns/oscal/metaschema/1.0</xsl:namespace>
            <xsl:namespace name="" select="$target-namespace"/>
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
                <xsl:apply-templates mode="acquire-prose" select="$prose-xsd-definitions"/>
            </xsl:if>
            
            <!--<xsl:message expand-text="true">Types in library: { $types-library/xs:simpleType/@name }</xsl:message>-->
            <xsl:variable name="all-used-types" select="//@as-type => distinct-values()"/>
            <xsl:variable name="used-atomic-types" select="$type-map[@as-type = $all-used-types]"/>
            <xsl:copy-of select="$types-library/xs:simpleType[@name = $used-atomic-types]"/>
        </xs:schema>
    </xsl:template>
    
    <xsl:template match="namespace | json-base-uri"/>
        
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
    
    <xsl:function name="m:local-key-name" as="xs:string?">
        <xsl:param name="whose" as="element()"/>
        <xsl:sequence select="$whose/@_key-name/replace(.,':','-')"/>
    </xsl:function>
    
    <xsl:template match="INFO"/>
    
    <xsl:template match="EXCEPTION">
        <xsl:comment expand-text="true">{ local-name()}{ (@info-type | @problem-type)/(' (' || . || ')' ) }: { . } </xsl:comment>
        <!--<xs:annotation xsl:expand-text="true">
            <xs:appinfo>
                <xsl:apply-templates/>
            </xs:appinfo>
        </xs:annotation>-->
    </xsl:template>
    
    <xsl:template match="/METASCHEMA/schema-name | /METASCHEMA/short-name |
        /METASCHEMA/schema-version | /METASCHEMA/remarks"/>
    
    <xsl:template match="define-assembly">
        <xsl:variable name="whose" select="."/>
        
        <xsl:for-each select="child::root-name">
            <xs:element name="{.}" type="{ m:local-key-name(..) }-ASSEMBLY"/>
            <!--<xs:element name="{.}" type="{$declaration-prefix}:{ m:local-key-name(..) }-ASSEMBLY"/>-->
        </xsl:for-each>
        
        <xs:complexType>
            <xsl:if test="parent::METASCHEMA">
                <xsl:attribute name="name" expand-text="true">{ m:local-key-name(.) }-ASSEMBLY</xsl:attribute>
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
                    <xsl:element name="b" namespace="{$target-namespace}">{ group-as/@name }</xsl:element>
                    <xsl:text>: A group of '{ @name }' elements</xsl:text>
                </xs:documentation>
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
        <xs:unique name="{ m:local-key-name($whose) }-{ m:local-key-name($whose/..) }-keys">
<!--            <xs:selector xpath="{ $declaration-prefix}:{ m:local-key-name($whose/..) }"/>-->
            <xs:selector xpath="{ m:local-key-name($whose/..) }"/>
            <xs:field xpath="@{ @flag-ref }"/>
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
            <xsl:variable name="datatype" select="(@as-type/string(), 'string') => head()"/>
            <xs:restriction base="xs:string">
                <!-- replace @base with correct base for type -->
                <xsl:call-template name="assign-datatype">
                    <xsl:with-param name="assign-to-attribute" as="xs:NCName">base</xsl:with-param>
                    <xsl:with-param name="datatype" as="xs:NCName" select="xs:NCName($datatype)"/>
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
            <xsl:variable name="datatype" select="(@as-type/string(), 'string') => head()"/>
            <xs:simpleContent>
                <xs:extension base="xs:string">
                    <!-- replace @base with correct base for type -->
                    <xsl:call-template name="assign-datatype">
                        <xsl:with-param name="assign-to-attribute" as="xs:NCName">base</xsl:with-param>
                        <xsl:with-param name="datatype" as="xs:NCName" select="xs:NCName($datatype)"/>
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
            <xsl:attribute name="name" select="@_key-name/replace(.,':','-') || '-FIELD'"/>
        </xsl:if>
    </xsl:template>

    <xsl:template priority="5" match="define-field[@as-type = 'markup-line']">
        <xs:complexType mixed="true">
            <xsl:call-template name="name-global-field-type"/>
            <xsl:apply-templates select="." mode="annotated"/>
            <!--<xs:group ref="{$declaration-prefix}:everything-inline"/>-->
            <xs:complexContent>
                <xs:extension base="MarkupLineDatatype">
                    <xsl:apply-templates select="define-flag | flag"/>
                </xs:extension>
            </xs:complexContent>
        </xs:complexType>
    </xsl:template>
    
    <xsl:template priority="5" match="define-field[@as-type='markup-multiline']">
        <xs:complexType>
                <xsl:call-template name="name-global-field-type"/>
            <xsl:apply-templates select="." mode="annotated"/>
            <!--<xs:group ref="{$declaration-prefix}:PROSE" maxOccurs="unbounded" minOccurs="0"/>-->
                <xs:complexContent>
                    <xs:extension base="MarkupMultilineDatatype">
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
        <xsl:element name="b" namespace="{$target-namespace}"><xsl:apply-templates/></xsl:element>
        <xsl:for-each select="../description">: </xsl:for-each>
    </xsl:template>
    
    <xsl:template match="model">
        <xs:sequence>
            <xsl:apply-templates/>
        </xs:sequence>
    </xsl:template>
    
    <xsl:template match="any">
        <xs:any namespace="##other" processContents="lax" minOccurs="0" maxOccurs="unbounded"/>
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
        <xsl:variable name="decl" select="key('global-field-by-name',@_key-ref)"/>
        <xsl:variable name="gi" select="(use-name,$decl/use-name,@ref)[1]"/>
        <xsl:call-template name="declare-element-as-type">
            <xsl:with-param name="decl" select="$decl"/>
            <xsl:with-param name="gi" select="$gi"/>
            <xsl:with-param name="type" select="m:local-key-name($decl) || '-FIELD'"></xsl:with-param>
        </xsl:call-template>
    </xsl:template>
    
    <xsl:template match="assembly">
        <xsl:variable name="decl" select="key('global-assembly-by-name',@_key-ref)"/>
        <xsl:variable name="gi" select="(use-name,$decl/use-name,@ref)[1]"/>
        <xsl:call-template name="declare-element-as-type">
            <xsl:with-param name="decl" select="$decl"/>
            <xsl:with-param name="gi" select="$gi"/>
            <xsl:with-param name="type" select="m:local-key-name(($decl,.)[1]) || '-ASSEMBLY'"/>
        </xsl:call-template>
    </xsl:template>
    
    <xsl:template name="declare-element-as-type">
        <xsl:param name="decl" select="()"/>
        <xsl:param name="gi" required="yes"/>
        <xsl:param name="type" required="yes"/>
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
            <xsl:variable name="decl" select="key('global-field-by-name',self::field/@_key-ref) | key('global-assembly-by-name',self::assembly/@_key-ref)"/>
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
        <xs:group ref="blockElementGroup" maxOccurs="unbounded" minOccurs="0"/>
        <!--<xs:group ref="{$declaration-prefix}:PROSE" maxOccurs="unbounded" minOccurs="0"/>-->
    </xsl:template>
    
    <!-- No wrapper, just prose elements -->
    <xsl:template match="field[@in-xml='UNWRAPPED'][key('global-field-by-name',@_key-ref)/@as-type='markup-multiline']">
        <xs:group ref="blockElementGroup" maxOccurs="unbounded" minOccurs="0"/>
    </xsl:template>
    
    <!-- With wrapper -->
    <xsl:template match="field[not(@in-xml='UNWRAPPED')][key('global-field-by-name',@_key-ref)/@as-type='markup-multiline']">
        <xsl:variable name="decl" select="key('global-field-by-name',@_key-ref)"/>
        <xsl:variable name="gi" select="(use-name,$decl/use-name,@ref)[1]"/>
        <xs:element name="{ $gi }"
            minOccurs="{ if (exists(@min-occurs)) then @min-occurs else 0 }"
            maxOccurs="{ if (exists(@max-occurs)) then @max-occurs else 1 }">
            <xsl:apply-templates select="key('global-field-by-name',@_key-ref)" mode="annotated"/>
            <xs:complexType>
                <xs:group ref="blockElementGroup" maxOccurs="unbounded" minOccurs="0"/>
              <!--<xs:group ref="{$declaration-prefix}:PROSE" maxOccurs="unbounded" minOccurs="0"/>-->
            </xs:complexType>
        </xs:element>
    </xsl:template>
    
    
    <xsl:template match="flag">
        <xsl:variable name="decl" select="key('global-flag-by-name',@_key-ref)"/>
        <xsl:variable name="gi" select="(use-name,$decl/use-name,@ref)[1]"/>
        <xsl:variable name="datatype" select="(@as-type,$decl/@as-type,'string')[1]"/>
        <!--<xsl:variable name="value-list" select="(constraint/allowed-values,key('global-flag-by-name',@ref)/constraint/allowed-values)[1]"/>-->
        <xs:attribute name="{ $gi }">
            
            <xsl:if test="(@required='yes') or (@name=(../json-key/@flag-ref,../json-value-key-flag/@flag-ref))">
                <xsl:attribute name="use">required</xsl:attribute>
            </xsl:if>
            <!-- annotate as datatype or string unless an exclusive value-list is given -->
            <!--<xsl:if test="empty($value-list)">-->
                <!-- overriding string datatype on attribute -->
                <xsl:call-template name="assign-datatype">
                    <xsl:with-param name="datatype" as="xs:NCName" select="xs:NCName($datatype)"/>
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
            <xsl:if test="(@required='yes') or (@name=(../json-key/@flag-ref,../json-value-key-flag/@flag-ref))">
                <xsl:attribute name="use">required</xsl:attribute>
            </xsl:if>
            <!--<xsl:if test="empty($value-list)">-->
                <!-- overriding string datatype on attribute -->
                <xsl:call-template name="assign-datatype">                    
                    <xsl:with-param name="datatype" as="xs:NCName" select="xs:NCName($datatype)"/>
                </xsl:call-template>
            <!--</xsl:if>-->
            <xsl:apply-templates select="." mode="annotated"/>
            <!--<xsl:apply-templates select="$value-list">
                <xsl:with-param name="datatype" select="$datatype"/>
            </xsl:apply-templates>-->
        </xs:attribute>
    </xsl:template>
    
    <xsl:template name="assign-datatype">
        <xsl:param name="assign-to-attribute" as="xs:NCName?" select="xs:NCName('type')"/>
        <xsl:param name="datatype" as="xs:NCName"/>
        <xsl:variable name="oscal-type" select="$type-map[@as-type=$datatype]"/>
        <xsl:attribute name="{ $assign-to-attribute }" expand-text="true"
            select="string($oscal-type)"/>
        <xsl:if test="empty($oscal-type)">
            <xsl:message expand-text="true">Seeing no oscal-type for datatype '{ $datatype }'</xsl:message>
        </xsl:if>
        <!--<xsl:variable name="oscal-types" select="$datatype[. = $types-library/xs:simpleType/@name]"/>-->
        <!--<xsl:for-each select="$oscal-types">
            <xsl:attribute name="{ $assign-to-attribute }" expand-text="true"
                select="concat($declaration-prefix, ':', .)"/>
        </xsl:for-each>-->
        <!--<xsl:variable name="xsd-types" select="$datatype[. = $types-library/xs:annotation[@id='built-in-types']/xs:appinfo/xs:simpleType/@name]"/>
        <xsl:for-each select="$xsd-types">
            <xsl:attribute name="{ $assign-to-attribute }" expand-text="true" select="concat('xs:', .)"/>
        </xsl:for-each>-->
            <!--ERROR SOMEHOW IF NO TYPE-->
        <!--<xsl:if test="empty(($oscal-types,$xsd-types))">
            <xsl:attribute name="{ $assign-to-attribute }" expand-text="true"
                select="concat($declaration-prefix, ':', $datatype)"/>
        </xsl:if>-->
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
                    
                    <xsl:with-param name="assign-to-attribute" as="xs:NCName">memberTypes</xsl:with-param>
                    <xsl:with-param name="datatype" as="xs:NCName" select="xs:NCName($datatype)"/>
                </xsl:call-template>
                <xs:simpleType>
                    <xs:restriction base="xs:{$datatype}">
                        <xsl:call-template name="assign-datatype">
                            <xsl:with-param name="assign-to-attribute" as="xs:NCName">base</xsl:with-param>
                            <xsl:with-param name="datatype" as="xs:NCName" select="xs:NCName($datatype)"/>
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
                        <xsl:element name="p" namespace="{$target-namespace}">
                            <xsl:apply-templates/>
                        </xsl:element>
                    </xs:documentation>
                </xs:annotation>
            </xsl:if>
        </xs:enumeration>
    </xsl:template> 
    
    <xsl:mode name="acquire-prose" on-no-match="shallow-copy"/>
    
    <xsl:template match="xs:schema" mode="acquire-prose">
            <xsl:apply-templates mode="#current"/>
    </xsl:template>
    
    <xsl:template match="xs:include" mode="acquire-prose"/>
    
    <xsl:template match="@ref | @type | @base" mode="acquire-prose">
        <xsl:attribute name="{ name() }">
            <!--<xsl:if test="not(matches(.,':'))" expand-text="true">{ $declaration-prefix }:</xsl:if>-->
            <xsl:text expand-text="true">{ string(.) }</xsl:text>
        </xsl:attribute>
    </xsl:template>
    
    <xsl:mode name="copy" on-no-match="shallow-copy"/>
    
    <xsl:template match="m:*" mode="copy">
        <xsl:element name="m:{local-name(.)}" namespace="{namespace-uri(.)}">
            <xsl:apply-templates mode="#current"/>
        </xsl:element>
    </xsl:template>
    
   <!-- <xsl:template mode="copy" match="remarks">
        <xsl:copy copy-namespaces="no">
            <xsl:copy-of select="@*"/>
            <xsl:namespace name="boo">boo</xsl:namespace>
            <xsl:apply-templates/>
        </xsl:copy>
    </xsl:template>-->
        
    <!-- copying contents of remarks we pull them out into no-namespace -->
    <xsl:template mode="copy" match="remarks//* | formal-name//* | description//*">
        <xsl:element name="{local-name()}" namespace="{$target-namespace}">
            <xsl:copy-of select="@*"/>
            <xsl:apply-templates mode="#current"/>
        </xsl:element>
    </xsl:template>
    
    
</xsl:stylesheet>