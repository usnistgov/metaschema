<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:math="http://www.w3.org/2005/xpath-functions/math"
    xmlns:m="http://csrc.nist.gov/ns/oscal/metaschema/1.0"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xpath-default-namespace="http://csrc.nist.gov/ns/oscal/metaschema/1.0"
    exclude-result-prefixes="xs math m xsi"
    version="3.0">

    <xsl:output indent="yes"/>
    
    <xsl:strip-space elements="METASCHEMA define-flag define-field define-assembly remarks model choice"/>
    
    <xsl:variable name="show-warnings" as="xs:string">no</xsl:variable>
    <xsl:variable name="verbose" select="lower-case($show-warnings)=('yes','y','1','true')"/>
    
    <xsl:variable name="target-ns" select="/METASCHEMA/namespace/string()"/>
    
    <xsl:key name="flag-definition-by-name"     match="METASCHEMA/define-flag" use="@_key-name"/>
    <xsl:key name="field-definition-by-name"    match="METASCHEMA/define-flag" use="@_key-name"/>
    <xsl:key name="assembly-definition-by-name" match="METASCHEMA/define-flag" use="@_key-name"/>
    
    <xsl:template match="/">
        <xsl:apply-templates mode="digest"/>
    </xsl:template>
        
    <!-- ====== ====== ====== ====== ====== ====== ====== ====== ====== ====== ====== ====== -->
    <!-- Pass Four: filter definitions (1) - Flattens, normalizes and expands examples. -->
    
    <xsl:mode name="digest" on-no-match="shallow-copy"/>
    
    <xsl:template match="METASCHEMA//METASCHEMA" priority="5" mode="digest">
        <xsl:apply-templates mode="#current"/>
    </xsl:template>
    
<!--    <xsl:template match="METASCHEMA//METASCHEMA//root-name" priority="5" mode="digest"/>    
-->    
    <xsl:template match="formal-name//text() | description//text() | p//text()" mode="digest">
        <xsl:value-of select="replace(.,'\s+',' ')"/>
    </xsl:template>
    
    <!-- Dropping metaschema superstructure from sub modules -->
    <xsl:template match="METASCHEMA//METASCHEMA/schema-name"    mode="digest"/>
    <xsl:template match="METASCHEMA//METASCHEMA/schema-version" mode="digest"/>
    <xsl:template match="METASCHEMA//METASCHEMA/short-name"     mode="digest"/>
    <xsl:template match="METASCHEMA//METASCHEMA/namespace"      mode="digest"/>
    <xsl:template match="METASCHEMA//METASCHEMA/remarks"        mode="digest"/>
    
    <xsl:template priority="10" match="define-assembly | define-field | define-flag" mode="digest">
             <xsl:copy>
                <xsl:copy-of select="@*"/>
                <xsl:apply-templates mode="#current"/>
            </xsl:copy>
    </xsl:template>
    
    <xsl:template priority="10" mode="digest" match="example/description | example/remarks">
        <xsl:copy-of select="."/>
    </xsl:template>
    
    <!-- Casting all examples into the master metaschema's declared namespace. -->
    <xsl:template mode="digest" match="example//* | example//*">
        <xsl:element name="{ local-name() }" namespace="{ $target-ns }">
            <xsl:copy-of select="@*"/>
            <xsl:apply-templates mode="#current"/>
        </xsl:element>
    </xsl:template>

    <xsl:template mode="digest" match="field">
        <xsl:copy>
            <xsl:copy-of select="key('field-definition-by-name',@_key-ref)/@as-type"/>
            <!-- Allowing local datatype to override the definition's datatype -->
            <xsl:copy-of select="@*"/>
            <xsl:apply-templates mode="#current"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template mode="digest" match="flag">
        <xsl:copy>
            <xsl:copy-of select="key('flag-definition-by-name',@_key-ref)/@as-type"/>
            <!-- Allowing local datatype to override the definition's datatype -->
            <xsl:copy-of select="@*"/>
            <xsl:apply-templates mode="#current"/>
        </xsl:copy>
    </xsl:template>
    
   
</xsl:stylesheet>