<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:m="http://csrc.nist.gov/ns/oscal/metaschema/1.0"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xpath-default-namespace="http://csrc.nist.gov/ns/oscal/metaschema/1.0"
                version="3.0">
   <xsl:variable name="type-map" as="element()*">
      <type as-type="base64">Base64Datatype</type>
      <type as-type="boolean">BooleanDatatype</type>
      <type as-type="date">DateDatatype</type>
      <type as-type="date-time">DateTimeDatatype</type>
      <type as-type="date-time-with-timezone">DateTimeWithTimezoneDatatype</type>
      <type as-type="date-with-timezone">DateWithTimezoneDatatype</type>
      <type as-type="day-time-duration">DayTimeDurationDatatype</type>
      <type as-type="decimal">DecimalDatatype</type>
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
      <type prefer="base64" as-type="base64Binary">Base64Datatype</type>
      <type prefer="date-time" as-type="dateTime">DateTimeDatatype</type>
      <type prefer="date-time-with-timezone" as-type="dateTime-with-timezone">DateTimeWithTimezoneDatatype</type>
      <type prefer="email-address" as-type="email">EmailAddressDatatype</type>
      <type prefer="non-negative-integer" as-type="nonNegativeInteger">NonNegativeIntegerDatatype</type>
      <type prefer="positive-integer" as-type="positiveInteger">PositiveIntegerDatatype</type>
   </xsl:variable>
   <xsl:function name="m:datatype-validate" as="xs:boolean">
      <xsl:param name="value" as="item()"/>
      <xsl:param name="nominal-type" as="item()?"/>
      <xsl:variable name="assigned-type" select="$type-map[@as-type=$nominal-type]"/>
      <xsl:variable name="proxy" as="element()">
         <xsl:element namespace="http://csrc.nist.gov/ns/oscal/metaschema/1.0"
                      name="{($assigned-type,'StringDatatype')[1]}"
                      expand-text="true">{$value}</xsl:element>
      </xsl:variable>
      <xsl:apply-templates select="$proxy" mode="m:validate-type"/>
   </xsl:function>
   <xsl:template match="*" mode="m:validate-type" as="xs:boolean">
      <xsl:sequence select="true()"/>
   </xsl:template>
   <xsl:template match="m:Base64Datatype" mode="m:validate-type" as="xs:boolean">
      <xsl:variable name="extra">
         <xsl:sequence select="matches(.,'^\S(.*\S)?$')"/>
      </xsl:variable>
      <xsl:sequence select="(. castable as xs:base64Binary) and $extra"/>
   </xsl:template>
   <xsl:template match="m:BooleanDatatype" mode="m:validate-type" as="xs:boolean">
      <xsl:variable name="extra">
         <xsl:sequence select="matches(.,'^\S(.*\S)?$')"/>
      </xsl:variable>
      <xsl:sequence select="(. castable as xs:boolean) and $extra"/>
   </xsl:template>
   <xsl:template match="m:DateDatatype" mode="m:validate-type" as="xs:boolean">
      <xsl:variable name="extra">
         <xsl:sequence select="matches(.,'^(((2000|2400|2800|(19|2[0-9](0[48]|[2468][048]|[13579][26])))-02-29)|(((19|2[0-9])[0-9]{2})-02-(0[1-9]|1[0-9]|2[0-8]))|(((19|2[0-9])[0-9]{2})-(0[13578]|10|12)-(0[1-9]|[12][0-9]|3[01]))|(((19|2[0-9])[0-9]{2})-(0[469]|11)-(0[1-9]|[12][0-9]|30)))(Z|[+-][0-9]{2}:[0-9]{2})?$')"/>
      </xsl:variable>
      <xsl:sequence select="(. castable as xs:date) and $extra"/>
   </xsl:template>
   <xsl:template match="m:DateWithTimezoneDatatype"
                 mode="m:validate-type"
                 as="xs:boolean">
      <xsl:variable name="extra">
         <xsl:sequence select="matches(.,'^(((2000|2400|2800|(19|2[0-9](0[48]|[2468][048]|[13579][26])))-02-29)|(((19|2[0-9])[0-9]{2})-02-(0[1-9]|1[0-9]|2[0-8]))|(((19|2[0-9])[0-9]{2})-(0[13578]|10|12)-(0[1-9]|[12][0-9]|3[01]))|(((19|2[0-9])[0-9]{2})-(0[469]|11)-(0[1-9]|[12][0-9]|30)))(Z|[+-][0-9]{2}:[0-9]{2})$')"/>
      </xsl:variable>
      <xsl:sequence select="m:datatype-validate(.,'DateDatatype') and $extra"/>
   </xsl:template>
   <xsl:template match="m:DateTimeDatatype" mode="m:validate-type" as="xs:boolean">
      <xsl:variable name="extra">
         <xsl:sequence select="matches(.,'^(((2000|2400|2800|(19|2[0-9](0[48]|[2468][048]|[13579][26])))-02-29)|(((19|2[0-9])[0-9]{2})-02-(0[1-9]|1[0-9]|2[0-8]))|(((19|2[0-9])[0-9]{2})-(0[13578]|10|12)-(0[1-9]|[12][0-9]|3[01]))|(((19|2[0-9])[0-9]{2})-(0[469]|11)-(0[1-9]|[12][0-9]|30)))T((2[0-3]|[01][0-9]):([0-5][0-9]):([0-5][0-9])(\.[0-9]+)?)(Z|[+-][0-9]{2}:[0-9]{2})?$')"/>
      </xsl:variable>
      <xsl:sequence select="(. castable as xs:dateTime) and $extra"/>
   </xsl:template>
   <xsl:template match="m:DateTimeWithTimezoneDatatype"
                 mode="m:validate-type"
                 as="xs:boolean">
      <xsl:variable name="extra">
         <xsl:sequence select="matches(.,'^(((2000|2400|2800|(19|2[0-9](0[48]|[2468][048]|[13579][26])))-02-29)|(((19|2[0-9])[0-9]{2})-02-(0[1-9]|1[0-9]|2[0-8]))|(((19|2[0-9])[0-9]{2})-(0[13578]|10|12)-(0[1-9]|[12][0-9]|3[01]))|(((19|2[0-9])[0-9]{2})-(0[469]|11)-(0[1-9]|[12][0-9]|30)))T((2[0-3]|[01][0-9]):([0-5][0-9]):([0-5][0-9])(\.[0-9]+)?)(Z|[+-][0-9]{2}:[0-9]{2})$')"/>
      </xsl:variable>
      <xsl:sequence select="m:datatype-validate(.,'DateTimeDatatype') and $extra"/>
   </xsl:template>
   <xsl:template match="m:DayTimeDurationDatatype"
                 mode="m:validate-type"
                 as="xs:boolean">
      <xsl:variable name="extra">
         <xsl:sequence select="matches(.,'^[-+]?P([-+]?[0-9]+D)?(T([-+]?[0-9]+H)?([-+]?[0-9]+M)?([-+]?[0-9]+([.,][0-9]{0,9})?S)?)?$')"/>
      </xsl:variable>
      <xsl:sequence select="(. castable as xs:duration) and $extra"/>
   </xsl:template>
   <xsl:template match="m:DecimalDatatype" mode="m:validate-type" as="xs:boolean">
      <xsl:variable name="extra">
         <xsl:sequence select="matches(.,'^\S(.*\S)?$')"/>
      </xsl:variable>
      <xsl:sequence select="(. castable as xs:decimal) and $extra"/>
   </xsl:template>
   <xsl:template match="m:EmailAddressDatatype"
                 mode="m:validate-type"
                 as="xs:boolean">
      <xsl:variable name="extra">
         <xsl:sequence select="matches(.,'^\S.*@.*\S$')"/>
      </xsl:variable>
      <xsl:sequence select="m:datatype-validate(.,'StringDatatype') and $extra"/>
   </xsl:template>
   <xsl:template match="m:HostnameDatatype" mode="m:validate-type" as="xs:boolean">
      <xsl:variable name="extra" select="true()"/>
      <xsl:sequence select="m:datatype-validate(.,'StringDatatype') and $extra"/>
   </xsl:template>
   <xsl:template match="m:IntegerDatatype" mode="m:validate-type" as="xs:boolean">
      <xsl:variable name="extra">
         <xsl:sequence select="matches(.,'^\S(.*\S)?$')"/>
      </xsl:variable>
      <xsl:sequence select="(. castable as xs:integer) and $extra"/>
   </xsl:template>
   <xsl:template match="m:IPV4AddressDatatype"
                 mode="m:validate-type"
                 as="xs:boolean">
      <xsl:variable name="extra">
         <xsl:sequence select="matches(.,'^((25[0-5]|2[0-4][0-9]|1[0-9][0-9]|[1-9][0-9]|[0-9]).){3}(25[0-5]|2[0-4][0-9]|1[0-9][0-9]|[1-9][0-9]|[0-9])$')"/>
      </xsl:variable>
      <xsl:sequence select="m:datatype-validate(.,'StringDatatype') and $extra"/>
   </xsl:template>
   <xsl:template match="m:IPV6AddressDatatype"
                 mode="m:validate-type"
                 as="xs:boolean">
      <xsl:variable name="extra">
         <xsl:sequence select="matches(.,'^(([0-9a-fA-F]{1,4}:){7,7}[0-9a-fA-F]{1,4}|([0-9a-fA-F]{1,4}:){1,7}:|([0-9a-fA-F]{1,4}:){1,6}:[0-9a-fA-F]{1,4}|([0-9a-fA-F]{1,4}:){1,5}(:[0-9a-fA-F]{1,4}){1,2}|([0-9a-fA-F]{1,4}:){1,4}(:[0-9a-fA-F]{1,4}){1,3}|([0-9a-fA-F]{1,4}:){1,3}(:[0-9a-fA-F]{1,4}){1,4}|([0-9a-fA-F]{1,4}:){1,2}(:[0-9a-fA-F]{1,4}){1,5}|[0-9a-fA-F]{1,4}:((:[0-9a-fA-F]{1,4}){1,6})|:((:[0-9a-fA-F]{1,4}){1,7}|:)|[fF][eE]80:(:[0-9a-fA-F]{0,4}){0,4}%[0-9a-zA-Z]{1,}|::([fF]{4}(:0{1,4}){0,1}:){0,1}((25[0-5]|2[0-4][0-9]|1[0-9][0-9]|[1-9][0-9]|[0-9]).){3,3}(25[0-5]|2[0-4][0-9]|1[0-9][0-9]|[1-9][0-9]|[0-9])|([0-9a-fA-F]{1,4}:){1,4}:((25[0-5]|2[0-4][0-9]|1[0-9][0-9]|[1-9][0-9]|[0-9]).){3,3}(25[0-5]|2[0-4][0-9]|1[0-9][0-9]|[1-9][0-9]|[0-9]))$')"/>
      </xsl:variable>
      <xsl:sequence select="(. castable as xs:string) and $extra"/>
   </xsl:template>
   <xsl:template match="m:NonNegativeIntegerDatatype"
                 mode="m:validate-type"
                 as="xs:boolean">
      <xsl:variable name="extra">
         <xsl:sequence select="matches(.,'^\S(.*\S)?$')"/>
      </xsl:variable>
      <xsl:sequence select="(. castable as xs:nonNegativeInteger) and $extra"/>
   </xsl:template>
   <xsl:template match="m:PositiveIntegerDatatype"
                 mode="m:validate-type"
                 as="xs:boolean">
      <xsl:variable name="extra">
         <xsl:sequence select="matches(.,'^\S(.*\S)?$')"/>
      </xsl:variable>
      <xsl:sequence select="(. castable as xs:positiveInteger) and $extra"/>
   </xsl:template>
   <xsl:template match="m:StringDatatype" mode="m:validate-type" as="xs:boolean">
      <xsl:variable name="extra">
         <xsl:sequence select="matches(.,'^\S(.*\S)?$')"/>
      </xsl:variable>
      <xsl:sequence select="(. castable as xs:string) and $extra"/>
   </xsl:template>
   <xsl:template match="m:TokenDatatype" mode="m:validate-type" as="xs:boolean">
      <xsl:variable name="extra">
         <xsl:sequence select="matches(.,'^(\p{L}|_)(\p{L}|\p{N}|[.\-_])*$')"/>
      </xsl:variable>
      <xsl:sequence select="m:datatype-validate(.,'StringDatatype') and $extra"/>
   </xsl:template>
   <xsl:template match="m:URIDatatype" mode="m:validate-type" as="xs:boolean">
      <xsl:variable name="extra">
         <xsl:sequence select="matches(.,'^[a-zA-Z][a-zA-Z0-9+\-.]+:.*\S$')"/>
      </xsl:variable>
      <xsl:sequence select="(. castable as xs:anyURI) and $extra"/>
   </xsl:template>
   <xsl:template match="m:URIReferenceDatatype"
                 mode="m:validate-type"
                 as="xs:boolean">
      <xsl:variable name="extra">
         <xsl:sequence select="matches(.,'^\S(.*\S)?$')"/>
      </xsl:variable>
      <xsl:sequence select="(. castable as xs:anyURI) and $extra"/>
   </xsl:template>
   <xsl:template match="m:UUIDDatatype" mode="m:validate-type" as="xs:boolean">
      <xsl:variable name="extra">
         <xsl:sequence select="matches(.,'^[0-9A-Fa-f]{8}-[0-9A-Fa-f]{4}-[45][0-9A-Fa-f]{3}-[89ABab][0-9A-Fa-f]{3}-[0-9A-Fa-f]{12}$')"/>
      </xsl:variable>
      <xsl:sequence select="m:datatype-validate(.,'StringDatatype') and $extra"/>
   </xsl:template>
</xsl:stylesheet>
