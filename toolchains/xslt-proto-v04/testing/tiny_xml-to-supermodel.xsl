<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:m="http://csrc.nist.gov/ns/oscal/metaschema/1.0"
                xmlns="http://csrc.nist.gov/ns/oscal/metaschema/1.0/supermodel"
                version="3.0"
                xpath-default-namespace="http://csrc.nist.gov/metaschema/ns/tiny"
                exclude-result-prefixes="#all">
   <xsl:strip-space elements="TINY"/>
   <!-- METASCHEMA conversion stylesheet supports XML -> METASCHEMA/SUPERMODEL conversion -->
   <!-- ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ -->
   <!-- METASCHEMA: NIST Tiny Testing Metaschema (version 0.1) in namespace "http://csrc.nist.gov/metaschema/ns/tiny"-->
   <xsl:template match="TINY">
      <assembly name="tiny" key="TINY" gi="TINY">
         <xsl:if test=". is /*">
            <xsl:attribute name="namespace">http://csrc.nist.gov/metaschema/ns/tiny</xsl:attribute>
         </xsl:if>
         <xsl:apply-templates select="@id-flag"/>
         <xsl:apply-templates select="string-field"/>
         <xsl:apply-templates select="object-field"/>
         <xsl:for-each-group select="TINY" group-by="true()">
            <group in-json="ARRAY" key="more-tiny">
               <xsl:apply-templates select="current-group()"/>
            </group>
         </xsl:for-each-group>
      </assembly>
   </xsl:template>
   <xsl:template match="@id-flag">
      <flag as-type="string" name="id-flag" key="id-flag" gi="id-flag">
         <xsl:value-of select="."/>
      </flag>
   </xsl:template>
   <xsl:template match="string-field">
      <field name="string-field"
             key="string-field"
             gi="string-field"
             in-json="SCALAR">
         <value as-type="string" key="STRVALUE" in-json="string">
            <xsl:value-of select="."/>
         </value>
      </field>
   </xsl:template>
   <xsl:template match="object-field">
      <field name="object-field" key="object-field" gi="object-field">
         <xsl:apply-templates select="@id-flag"/>
         <value as-type="boolean" key="boolean-value" in-json="boolean">
            <xsl:value-of select="."/>
         </value>
      </field>
   </xsl:template>
   <xsl:template match="*" mode="cast-prose">
      <xsl:element name="{ local-name() }"
                   namespace="http://csrc.nist.gov/ns/oscal/metaschema/1.0/supermodel">
         <xsl:copy-of select="@*"/>
         <xsl:apply-templates mode="#current"/>
      </xsl:element>
   </xsl:template>
</xsl:stylesheet>
