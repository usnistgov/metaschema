<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:math="http://www.w3.org/2005/xpath-functions/math"
    exclude-result-prefixes="xs math"
    xpath-default-namespace="http://www.w3.org/2005/xpath-functions"
    version="3.0">
    
<!-- Execute this query on itself to generate XSD simpleType declarations from
     an analogous set of JSON Schema type definitions
     as defined by and for the JSON Schema generation pipeline
     thus providing us a means to keep the two closely aligned.
    
    -->
    
    
    <!--
  
  x save 'v080' XSD for later diff
  x query metaschema-v090-datatypes.json to produce new JSON datatypes (meta)map
  x integrate with old map
  x generate new XSD prototypes from JSON datatypes
  o extend XSD datatypes with new types (by hand)
      updating old datatypes with new constraints / defs from corresponding new datatypes
  o otherwise leave old datatypes in place (operative) for now
  
  -->
    
    <!-- datatypes are defined for the JSON Schema here -->
    <xsl:import href="make-json-schema-metamap.xsl"/>
    
    <xsl:output indent="true"/>
    
    <!--<xsl:variable name="newdatatypes" select="( unparsed-text('metaschema-v090-datatypes.json') ) => json-to-xml()"/>-->
    
    <!--serialize($mymap, map{"method":"json","indent":true()})-->
    
    <xsl:template match="/" expand-text="true">
        <!--<OUT>{ $newdatatypes => serialize(map{'method':'json','indent':true()} ) }</OUT>-->
        <xs:schema
            xmlns:xs="http://www.w3.org/2001/XMLSchema"
            xmlns:m="http://csrc.nist.gov/ns/oscal/metaschema/1.0"
            
            targetNamespace="http://csrc.nist.gov/ns/oscal/datatypes/1.0"
            elementFormDefault="qualified">
            <xs:annotation id="built-in-types">
                <xs:documentation>Copies of simpleType declarations for querying by
                    routines that need to know about XSD simple types we may use. Any simpleType
                    we support should be listed here for propagation in tools e.g. Metaschema Schematron.</xs:documentation>
                <xs:appinfo>
                    <xs:simpleType name="boolean"/>
                    <xs:simpleType name="base64Binary"/>
                    <!--<xs:simpleType name="string"/>-->
                    <!--<xs:simpleType name="NCName"/>-->
                    <!--<xs:simpleType name="NMTOKENS"/>-->
                    <xs:simpleType name="decimal"/>
                    <!-- Not supporting float or double -->
                    <!--<xs:simpleType name="float"/>
        <xs:simpleType name="double"/>-->
                    <xs:simpleType name="integer"/>
                    <xs:simpleType name="nonNegativeInteger"/>
                    <xs:simpleType name="positiveInteger"/>
                    <!--<xs:simpleType name="ID"/>-->
                    <!--<xs:simpleType name="IDREF"/>-->
                    <!--<xs:simpleType name="IDREFS"/>-->
                    <xs:simpleType name="date"/>
                    <xs:simpleType name="dateTime"/>
                </xs:appinfo>
            </xs:annotation>
            
            <xsl:apply-templates select="$datatypes" mode="spill"/>
            
        </xs:schema>
    </xsl:template>
    
    <xsl:template mode="spill" match="/">
        <xsl:apply-templates/>
    </xsl:template>
    
    <xsl:template match="comment()">
        <xsl:copy-of select="."/>
    </xsl:template>
    
    <xsl:template match="map">
        <xs:simpleType name="{@key}">
            <xsl:apply-templates select="." mode="annotation"/>
            <xs:restriction base="xs:string">
                <xsl:apply-templates select="." mode="ws-collapse"/>
                <xsl:apply-templates/>
            </xs:restriction>
        </xs:simpleType>
    </xsl:template>
    
    <xsl:template match="map" mode="annotation">
        <xsl:where-populated>
            <xs:annotation>
                <xsl:for-each select="string[@key='description']">
                    <xs:documentation>
                        <xsl:apply-templates/>
                    </xs:documentation>
                </xsl:for-each>
            </xs:annotation>
        </xsl:where-populated>
    </xsl:template>
    
    <xsl:template mode="ws-collapse" match="*">
        <xs:whiteSpace value="preserve"/>
    </xsl:template>
    
    <xsl:template match="string[@key='pattern']">
        <xs:pattern value="{ . }"/>
    </xsl:template>
    
    <xsl:template match="string[@key='description']"/>
    
    <xsl:template match="string">
        <xsl:comment expand-text="true"> { @key }: {.} </xsl:comment>
    </xsl:template>
    
</xsl:stylesheet>