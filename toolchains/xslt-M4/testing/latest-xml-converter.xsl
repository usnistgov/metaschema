<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:m="http://csrc.nist.gov/ns/oscal/metaschema/1.0"
                xmlns="http://csrc.nist.gov/ns/oscal/metaschema/1.0/supermodel"
                version="3.0"
                exclude-result-prefixes="#all"
                xpath-default-namespace="http://csrc.nist.gov/metaschema/ns/everything">
   <xsl:strip-space elements="EVERYTHING ASSEMBLY-1ONLY assembly-groupable assembly-wrappable assembly-by-key"/>
   <!-- METASCHEMA conversion stylesheet supports XML -> METASCHEMA/SUPERMODEL conversion -->
   <!-- ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ -->
   <!-- METASCHEMA: NIST Metaschema Everything (version 1.0) in namespace "http://csrc.nist.gov/metaschema/ns/everything"-->
   <xsl:template match="EVERYTHING">
      <xsl:param name="with-key" select="true()"/>
      <assembly name="everything" gi="EVERYTHING">
         <xsl:if test="$with-key">
            <xsl:attribute name="key">EVERYTHING</xsl:attribute>
         </xsl:if>
         <xsl:if test=". is /*">
            <xsl:attribute name="namespace">http://csrc.nist.gov/metaschema/ns/everything</xsl:attribute>
         </xsl:if>
         <xsl:apply-templates select="@id"/>
         <xsl:apply-templates select="field-1only"/>
         <xsl:apply-templates select="field-base64"/>
         <xsl:apply-templates select="field-boolean"/>
         <xsl:apply-templates select="field-named-value"/>
         <xsl:apply-templates select="markup-line"/>
         <xsl:for-each-group select="field-simple-groupable" group-by="true()">
            <group in-json="SINGLETON_OR_ARRAY" key="groupable-simple-fields">
               <xsl:apply-templates select="current-group()">
                  <xsl:with-param name="with-key" select="false()"/>
               </xsl:apply-templates>
            </group>
         </xsl:for-each-group>
         <xsl:for-each-group select="field-flagged-groupable" group-by="true()">
            <group in-json="SINGLETON_OR_ARRAY" key="groupable-flagged-fields">
               <xsl:apply-templates select="current-group()">
                  <xsl:with-param name="with-key" select="false()"/>
               </xsl:apply-templates>
            </group>
         </xsl:for-each-group>
         <xsl:apply-templates select="wrapped-fields"/>
         <xsl:for-each-group select="field-by-key" group-by="true()">
            <group in-json="BY_KEY" key="keyed-fields">
               <xsl:apply-templates select="current-group()">
                  <xsl:with-param name="with-key" select="false()"/>
               </xsl:apply-templates>
            </group>
         </xsl:for-each-group>
         <xsl:for-each-group select="field-dynamic-value-key" group-by="true()">
            <group in-json="SINGLETON_OR_ARRAY" key="dynamic-value-key-fields">
               <xsl:apply-templates select="current-group()">
                  <xsl:with-param name="with-key" select="false()"/>
               </xsl:apply-templates>
            </group>
         </xsl:for-each-group>
         <xsl:apply-templates select="wrapped-prose"/>
         <xsl:for-each-group select="p | ul | ol | pre | h1 | h2 | h3 | h4 | h5 | h6 | table"
                             group-by="true()">
            <field in-json="SCALAR" name="loose-prose" key="loose-prose">
               <value in-json="string" as-type="markup-multiline">
                  <xsl:apply-templates select="current-group()" mode="cast-prose"/>
               </value>
            </field>
         </xsl:for-each-group>
         <xsl:apply-templates select="ASSEMBLY-1ONLY"/>
         <xsl:for-each-group select="assembly-groupable" group-by="true()">
            <group in-json="SINGLETON_OR_ARRAY" key="groupable-assemblies">
               <xsl:apply-templates select="current-group()">
                  <xsl:with-param name="with-key" select="false()"/>
               </xsl:apply-templates>
            </group>
         </xsl:for-each-group>
         <xsl:apply-templates select="wrapped-assemblies"/>
         <xsl:for-each-group select="assembly-by-key" group-by="true()">
            <group in-json="BY_KEY" key="keyed-assemblies">
               <xsl:apply-templates select="current-group()">
                  <xsl:with-param name="with-key" select="false()"/>
               </xsl:apply-templates>
            </group>
         </xsl:for-each-group>
         <xsl:for-each-group select="EVERYTHING" group-by="true()">
            <group in-json="ARRAY" key="everything-recursive">
               <xsl:apply-templates select="current-group()">
                  <xsl:with-param name="with-key" select="false()"/>
               </xsl:apply-templates>
            </group>
         </xsl:for-each-group>
      </assembly>
   </xsl:template>
   <xsl:template match="EVERYTHING/@id | field-named-value/@id | field-by-key/@id | field-dynamic-value-key/@id | assembly-by-key/@id">
      <flag in-json="string"
            as-type="string"
            name="id"
            key="id"
            gi="id">
         <xsl:value-of select="."/>
      </flag>
   </xsl:template>
   <xsl:template match="field-1only">
      <xsl:param name="with-key" select="true()"/>
      <field name="field-1only" gi="field-1only">
         <xsl:if test="$with-key">
            <xsl:attribute name="key">field-1only</xsl:attribute>
         </xsl:if>
         <xsl:apply-templates select="@simple-flag"/>
         <xsl:apply-templates select="@integer-flag"/>
         <value as-type="string" key="STRVALUE" in-json="string">
            <xsl:value-of select="."/>
         </value>
      </field>
   </xsl:template>
   <xsl:template match="field-1only/@simple-flag | field-simple-groupable/@simple-flag">
      <flag in-json="string"
            as-type="string"
            name="simple-flag"
            key="simple-flag"
            gi="simple-flag">
         <xsl:value-of select="."/>
      </flag>
   </xsl:template>
   <xsl:template match="field-1only/@integer-flag | field-simple-groupable/@integer-flag">
      <flag in-json="number"
            as-type="integer"
            name="integer-flag"
            key="integer-flag"
            gi="integer-flag">
         <xsl:value-of select="."/>
      </flag>
   </xsl:template>
   <xsl:template match="field-base64">
      <xsl:param name="with-key" select="true()"/>
      <field name="field-base64" gi="field-base64" in-json="SCALAR">
         <xsl:if test="$with-key">
            <xsl:attribute name="key">field-base64</xsl:attribute>
         </xsl:if>
         <value as-type="base64Binary" in-json="string">
            <xsl:value-of select="."/>
         </value>
      </field>
   </xsl:template>
   <xsl:template match="field-boolean">
      <xsl:param name="with-key" select="true()"/>
      <field name="field-boolean" gi="field-boolean" in-json="SCALAR">
         <xsl:if test="$with-key">
            <xsl:attribute name="key">field-boolean</xsl:attribute>
         </xsl:if>
         <value as-type="boolean" in-json="boolean">
            <xsl:value-of select="."/>
         </value>
      </field>
   </xsl:template>
   <xsl:template match="field-named-value">
      <xsl:param name="with-key" select="true()"/>
      <field name="field-named-value" gi="field-named-value">
         <xsl:if test="$with-key">
            <xsl:attribute name="key">field-named-value</xsl:attribute>
         </xsl:if>
         <xsl:apply-templates select="@id"/>
         <value as-type="string" key="CUSTOM-VALUE-KEY" in-json="string">
            <xsl:value-of select="."/>
         </value>
      </field>
   </xsl:template>
   <xsl:template match="markup-line">
      <xsl:param name="with-key" select="true()"/>
      <field name="markup-line" gi="markup-line" in-json="SCALAR">
         <xsl:if test="$with-key">
            <xsl:attribute name="key">markup-line</xsl:attribute>
         </xsl:if>
         <value as-type="markup-line" in-json="string">
            <xsl:apply-templates mode="cast-prose"/>
         </value>
      </field>
   </xsl:template>
   <xsl:template match="field-simple-groupable">
      <xsl:param name="with-key" select="true()"/>
      <field name="field-simple-groupable" gi="field-simple-groupable">
         <xsl:apply-templates select="@simple-flag"/>
         <xsl:apply-templates select="@integer-flag"/>
         <value as-type="string" key="STRVALUE" in-json="string">
            <xsl:value-of select="."/>
         </value>
      </field>
   </xsl:template>
   <xsl:template match="field-flagged-groupable">
      <xsl:param name="with-key" select="true()"/>
      <field name="field-flagged-groupable" gi="field-flagged-groupable">
         <xsl:apply-templates select="@flagged-date"/>
         <xsl:apply-templates select="@flagged-decimal"/>
         <value as-type="string" key="STRVALUE" in-json="string">
            <xsl:value-of select="."/>
         </value>
      </field>
   </xsl:template>
   <xsl:template match="field-wrappable">
      <xsl:param name="with-key" select="true()"/>
      <field name="field-wrappable" gi="field-wrappable" in-json="SCALAR">
         <value as-type="string" in-json="string">
            <xsl:value-of select="."/>
         </value>
      </field>
   </xsl:template>
   <xsl:template match="wrapped-fields" priority="10">
      <xsl:param name="with-key" select="true()"/>
      <group name="wrapped-fields" gi="wrapped-fields" group-json="ARRAY">
         <xsl:if test="$with-key">
            <xsl:attribute name="key">wrapped-fields</xsl:attribute>
         </xsl:if>
         <xsl:apply-templates select="field-wrappable"/>
      </group>
   </xsl:template>
   <xsl:template match="field-by-key">
      <xsl:param name="with-key" select="true()"/>
      <field name="field-by-key"
             gi="field-by-key"
             json-key-flag="id"
             in-json="SCALAR">
         <xsl:apply-templates select="@id"/>
         <value as-type="string" key="STRVALUE" in-json="string">
            <xsl:value-of select="."/>
         </value>
      </field>
   </xsl:template>
   <xsl:template match="field-dynamic-value-key">
      <xsl:param name="with-key" select="true()"/>
      <field name="field-dynamic-value-key" gi="field-dynamic-value-key">
         <xsl:apply-templates select="@id"/>
         <xsl:apply-templates select="@color"/>
         <value as-type="string" key-flag="id" in-json="string">
            <xsl:value-of select="."/>
         </value>
      </field>
   </xsl:template>
   <xsl:template match="wrapped-prose">
      <xsl:param name="with-key" select="true()"/>
      <field name="wrapped-prose" gi="wrapped-prose" in-json="SCALAR">
         <xsl:if test="$with-key">
            <xsl:attribute name="key">wrapped-prose</xsl:attribute>
         </xsl:if>
         <value as-type="markup-multiline" in-json="string">
            <xsl:for-each-group select="p | ul | ol | pre | h1 | h2 | h3 | h4 | h5 | h6 | table"
                                group-by="true()">
               <xsl:apply-templates select="current-group()" mode="cast-prose"/>
            </xsl:for-each-group>
         </value>
      </field>
   </xsl:template>
   <xsl:template match="ASSEMBLY-1ONLY">
      <xsl:param name="with-key" select="true()"/>
      <assembly name="assembly-1only" gi="ASSEMBLY-1ONLY">
         <xsl:if test="$with-key">
            <xsl:attribute name="key">ASSEMBLY-1ONLY</xsl:attribute>
         </xsl:if>
         <xsl:apply-templates select="field-1only"/>
         <xsl:apply-templates select="ASSEMBLY-1ONLY"/>
      </assembly>
   </xsl:template>
   <xsl:template match="assembly-groupable">
      <xsl:param name="with-key" select="true()"/>
      <assembly name="assembly-groupable" gi="assembly-groupable">
         <xsl:for-each-group select="field-simple-groupable" group-by="true()">
            <group in-json="SINGLETON_OR_ARRAY" key="groupable-simple-fields">
               <xsl:apply-templates select="current-group()">
                  <xsl:with-param name="with-key" select="false()"/>
               </xsl:apply-templates>
            </group>
         </xsl:for-each-group>
         <xsl:for-each-group select="assembly-groupable" group-by="true()">
            <group in-json="SINGLETON_OR_ARRAY" key="groupable-assemblies">
               <xsl:apply-templates select="current-group()">
                  <xsl:with-param name="with-key" select="false()"/>
               </xsl:apply-templates>
            </group>
         </xsl:for-each-group>
      </assembly>
   </xsl:template>
   <xsl:template match="assembly-wrappable">
      <xsl:param name="with-key" select="true()"/>
      <assembly name="assembly-wrappable" gi="assembly-wrappable">
         <xsl:apply-templates select="wrapped-fields"/>
         <xsl:apply-templates select="wrapped-assemblies"/>
      </assembly>
   </xsl:template>
   <xsl:template match="wrapped-assemblies" priority="10">
      <xsl:param name="with-key" select="true()"/>
      <group name="wrapped-assemblies"
             gi="wrapped-assemblies"
             group-json="ARRAY">
         <xsl:if test="$with-key">
            <xsl:attribute name="key">wrapped-assemblies</xsl:attribute>
         </xsl:if>
         <xsl:apply-templates select="assembly-wrappable"/>
      </group>
   </xsl:template>
   <xsl:template match="assembly-by-key">
      <xsl:param name="with-key" select="true()"/>
      <assembly name="assembly-by-key" gi="assembly-by-key" json-key-flag="id">
         <xsl:apply-templates select="@id"/>
         <xsl:for-each-group select="field-by-key" group-by="true()">
            <group in-json="BY_KEY" key="keyed-fields">
               <xsl:apply-templates select="current-group()">
                  <xsl:with-param name="with-key" select="false()"/>
               </xsl:apply-templates>
            </group>
         </xsl:for-each-group>
         <xsl:for-each-group select="assembly-by-key" group-by="true()">
            <group in-json="BY_KEY" key="keyed-assemblies">
               <xsl:apply-templates select="current-group()">
                  <xsl:with-param name="with-key" select="false()"/>
               </xsl:apply-templates>
            </group>
         </xsl:for-each-group>
      </assembly>
   </xsl:template>
   <xsl:template match="field-flagged-groupable/@flagged-date">
      <flag in-json="string"
            as-type="date"
            name="flagged-date"
            key="flagged-date"
            gi="flagged-date">
         <xsl:value-of select="."/>
      </flag>
   </xsl:template>
   <xsl:template match="field-flagged-groupable/@flagged-decimal">
      <flag in-json="number"
            as-type="decimal"
            name="flagged-decimal"
            key="flagged-decimal"
            gi="flagged-decimal">
         <xsl:value-of select="."/>
      </flag>
   </xsl:template>
   <xsl:template match="field-dynamic-value-key/@color">
      <flag in-json="string"
            as-type="string"
            name="color"
            key="color"
            gi="color">
         <xsl:value-of select="."/>
      </flag>
   </xsl:template>
   <xsl:template match="*" mode="cast-prose">
      <xsl:element name="{ local-name() }"
                   namespace="http://csrc.nist.gov/ns/oscal/metaschema/1.0/supermodel">
         <xsl:copy-of select="@*"/>
         <xsl:apply-templates mode="#current"/>
      </xsl:element>
   </xsl:template>
</xsl:stylesheet>
