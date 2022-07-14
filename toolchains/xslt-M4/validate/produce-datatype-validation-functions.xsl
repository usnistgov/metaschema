<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:m="http://csrc.nist.gov/ns/oscal/metaschema/1.0"
    xpath-default-namespace="http://csrc.nist.gov/ns/oscal/metaschema/1.0"
    version="3.0"
    
    xmlns:XSLT="http://csrc.nist.gov/ns/oscal/metaschema/xslt-alias">
    

    <!-- Runs on itself.
         Calls data from ../../../build/metaschema/xml/produce-xsd.xsl and
                         ../../../build/metaschema/xml/oscal-datatypes.xsd
    
    to produce a function library for validating datatypes -->
    <xsl:output indent="yes"/>
    <xsl:strip-space elements="*"/>
    
    <xsl:namespace-alias stylesheet-prefix="XSLT" result-prefix="xsl"/>
    
    <xsl:variable name="type-definitions" select="document('../../../schema/xml/metaschema-datatypes.xsd')//xs:simpleType"/>
    
    <xsl:variable name="type-map" select="document('../schema-gen/make-metaschema-xsd.xsl')/*/xsl:variable[@name='type-map']/*"/>
    
    <xsl:template match="/">
        <XSLT:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
            xmlns:xs="http://www.w3.org/2001/XMLSchema"
            xpath-default-namespace="http://csrc.nist.gov/ns/oscal/metaschema/1.0" version="3.0">
            <XSLT:variable name="type-map" as="element()*">
                <xsl:copy-of select="$type-map" copy-namespaces="no"/>
            </XSLT:variable>
            <XSLT:function name="m:datatype-validate" as="xs:boolean">
                <XSLT:param name="value" as="item()"/>
                <XSLT:param name="nominal-type" as="item()?"/>
                <XSLT:variable name="assigned-type" select="$type-map[@as-type=$nominal-type]"/>
                <!--<XSLT:variable name="type-definition" select="$type-definitions/*/xs:simpleType[@name=$assigned-type]"/>-->
                <!--<XSLT:variable name="test-type" as="xs:string">
                    <XSLT:choose>
                        <XSLT:when test="empty($nominal-type)">string</XSLT:when>
                        <XSLT:when test="$nominal-type = ('IDREFS', 'NMTOKENS')">string</XSLT:when>
                        <XSLT:when test="$nominal-type = ('ID', 'IDREF')">NCName</XSLT:when>
                        <XSLT:otherwise expand-text="yes">{ $nominal-type }</XSLT:otherwise>
                    </XSLT:choose>
                </XSLT:variable>-->
                <XSLT:variable name="proxy" as="element()">
                    <XSLT:element namespace="http://csrc.nist.gov/ns/oscal/metaschema/1.0"
                        name="{{($assigned-type,'StringDatatype')[1]}}" expand-text="true">{$value}</XSLT:element>
                </XSLT:variable>
                <XSLT:apply-templates select="$proxy" mode="m:validate-type"/>
            </XSLT:function>

            <XSLT:template match="*" mode="m:validate-type" as="xs:boolean">
                <XSLT:sequence select="true()"/>
            </XSLT:template>
            
            <xsl:apply-templates select="$type-definitions" mode="m:make-template"/>

        </XSLT:stylesheet>
    </xsl:template>
    
    <!-- fallback shouldn't fire   -->
    <xsl:template match="xs:simpleType" mode="m:make-template">
        <XSLT:template match="m:{@name}" mode="m:validate-type" as="xs:boolean">
            <XSLT:sequence select=". castable as xs:{(xs:restriction/@base,@name)[1]}"/>
        </XSLT:template>
    </xsl:template>
    
    <xsl:template priority="101" match="xs:simpleType[starts-with(xs:restriction/@base,'xs:')]" mode="m:make-template">
        <XSLT:template match="m:{@name}" mode="m:validate-type" as="xs:boolean">
            <XSLT:variable name="extra">
                <xsl:apply-templates mode="#current"/>
                <xsl:on-empty>
                    <xsl:attribute name="select">true()</xsl:attribute>
                </xsl:on-empty>
            </XSLT:variable>
            <XSLT:sequence select="(. castable as {xs:restriction/@base}) and $extra"/>
        </XSLT:template>
    </xsl:template>
    
    <xsl:template match="xs:simpleType[xs:restriction]" mode="m:make-template">
        <XSLT:template match="m:{@name}" mode="m:validate-type" as="xs:boolean">
            <XSLT:variable name="extra">
                <xsl:apply-templates mode="#current"/>
                <xsl:on-empty>
                    <xsl:attribute name="select">true()</xsl:attribute>
                </xsl:on-empty>
            </XSLT:variable>
            <XSLT:sequence select="m:datatype-validate(.,'{xs:restriction/@base}') and $extra"/>
        </XSLT:template>
    </xsl:template>
    
    <xsl:template match="*" mode="m:make-template"/>
    
    <xsl:template match="xs:restriction" mode="m:make-template">
      <xsl:apply-templates mode="#current"/>
    </xsl:template>

    <xsl:template match="xs:pattern" mode="m:make-template">
        <XSLT:sequence select="matches(.,'^{@value}$')"/>
    </xsl:template>

<!--<xs:simpleType name="ip-v6-address">
        <xs:annotation>
            <xs:documentation>The ip-v6-address type specifies an IPv6 address represented in 8 hextets separated by colons.</xs:documentation>
            <xs:documentation>This is based on the pattern provided here: https://stackoverflow.com/questions/53497/regular-expression-that-matches-valid-ipv6-addresses with some customizations.</xs:documentation>
        </xs:annotation>
        <xs:restriction base="xs:string">
            <xs:whiteSpace value="collapse"/>
            <xs:pattern value="(([0-9a-fA-F]{1,4}:){7,7}[0-9a-fA-F]{1,4}|([0-9a-fA-F]{1,4}:){1,7}:|([0-9a-fA-F]{1,4}:){1,6}:[0-9a-fA-F]{1,4}|([0-9a-fA-F]{1,4}:){1,5}(:[0-9a-fA-F]{1,4}){1,2}|([0-9a-fA-F]{1,4}:){1,4}(:[0-9a-fA-F]{1,4}){1,3}|([0-9a-fA-F]{1,4}:){1,3}(:[0-9a-fA-F]{1,4}){1,4}|([0-9a-fA-F]{1,4}:){1,2}(:[0-9a-fA-F]{1,4}){1,5}|[0-9a-fA-F]{1,4}:((:[0-9a-fA-F]{1,4}){1,6})|:((:[0-9a-fA-F]{1,4}){1,7}|:)|[fF][eE]80:(:[0-9a-fA-F]{0,4}){0,4}%[0-9a-zA-Z]{1,}|::([fF]{4}(:0{1,4}){0,1}:){0,1}((25[0-5]|2[0-4][0-9]|1[0-9][0-9]|[1-9][0-9]|[0-9]).){3,3}(25[0-5]|2[0-4][0-9]|1[0-9][0-9]|[1-9][0-9]|[0-9])|([0-9a-fA-F]{1,4}:){1,4}:((25[0-5]|2[0-4][0-9]|1[0-9][0-9]|[1-9][0-9]|[0-9]).){3,3}(25[0-5]|2[0-4][0-9]|1[0-9][0-9]|[1-9][0-9]|[0-9]))"/>
        </xs:restriction>
    </xs:simpleType>
    -->
</xsl:stylesheet>
