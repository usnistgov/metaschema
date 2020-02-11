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
    
    <xsl:variable name="verbose-warnings" as="xs:string">no</xsl:variable>
    <xsl:variable name="verbose" select="lower-case($verbose-warnings)=('yes','y','1','true')"/>
    
    <xsl:variable name="root-name" select="/METASCHEMA/@root/string(.)"/>
    
    <xsl:variable name="target-ns" select="/METASCHEMA/namespace/string()"/>
    
    <xsl:key name="definition-by-name" match="define-flag | define-field | define-assembly" use="@name"/>

    <xsl:template match="/">
        <xsl:apply-templates mode="digest"/>
    </xsl:template>
        
    <!-- ====== ====== ====== ====== ====== ====== ====== ====== ====== ====== ====== ====== -->
    <!-- Pass Three: filter definitions (1) - keep definitions actually used, with all docs
          (i.e. drops definitions 'never picked for a team') -->
    <!-- Also consolidates documentation - definitions that are kept, are also annotated
           with applicable 'augment' elements i.e. those belonging to ancestor metaschemas
           in the import hierarchy. -->
    
    <!--NOTE: The version 1.0 Metaschema had a nice feature whereby definitions that were never actually used
    in models assembled from the nominal root, were no longer collected. We no longer do this, since
    in the present model, all definitions at the top level are potential valid entry points.
    
    -->
    
    
    <xsl:mode name="digest" on-no-match="shallow-copy"/>
    
    <xsl:template match="METASCHEMA//METASCHEMA" priority="5" mode="digest">
        <xsl:apply-templates mode="#current"/>
    </xsl:template>
    
    <xsl:template match="formal-name//text() | description//text() | p//text()" mode="digest">
        <xsl:value-of select="replace(.,'\s+',' ')"/>
    </xsl:template>
    
    <!-- Dropping metaschema superstructure from sub modules -->
    <xsl:template match="METASCHEMA//METASCHEMA/*" mode="digest"/>

    <xsl:template priority="10" match="define-assembly | define-field | define-flag" mode="digest">
             <xsl:copy>
                <xsl:call-template name="mark-module"/>
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

    <xsl:template mode="digest" match="flag | field">
        <xsl:copy>
            <xsl:copy-of select="key('definition-by-name',(@name|@ref))/@as-type"/>
            <!-- Allowing local datatype to override the definition's datatype -->
            <xsl:copy-of select="@*"/>
            <xsl:apply-templates mode="#current"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template name="mark-module">
        <xsl:copy-of select="ancestor-or-self::METASCHEMA/@module"/>
    </xsl:template>
    
<!-- CODE ARCHIVE === superseded by new rule that any top-level declaration is an entry point for formal validity -
        
     Mode 'collect references' collects a set of strings naming definitions
     we actually need, by traversing the definitions tree from the root;
     recursive models are accounted for
    
    <xsl:template match="define-assembly" mode="collect-references">
        <xsl:param name="ref-stack" tunnel="yes" required="yes"/>
        <xsl:if test="not(@name = $ref-stack)">
            <xsl:sequence select="@name, flag/@ref"/>
            <xsl:apply-templates select="model" mode="#current">
                <xsl:with-param tunnel="true" name="ref-stack" select="$ref-stack,@name"/>
            </xsl:apply-templates>
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="define-field" mode="collect-references">
        <xsl:sequence select="@name, flag/@ref"/>
    </xsl:template>
    
    <xsl:template match="model | model//*" mode="collect-references">
        <xsl:apply-templates mode="#current"/>  
    </xsl:template>
    
    <!- - Matching inside the $distinct-definitions variable, so traversing only applicable definitions - ->
    <xsl:template priority="10" match="field | assembly" mode="collect-references">
        <xsl:apply-templates select="key('definition-by-name',@ref,root())" mode="#current"/>
    </xsl:template>
        
    <!- -hitting anything but a define-assembly, we are done collecting references- ->
    <xsl:template match="* | text()" mode="collect-references"/>
     -->
</xsl:stylesheet>