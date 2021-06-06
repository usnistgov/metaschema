<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:math="http://www.w3.org/2005/xpath-functions/math"
    xmlns:m="http://csrc.nist.gov/ns/oscal/metaschema/1.0"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xpath-default-namespace="http://csrc.nist.gov/ns/oscal/metaschema/1.0"
    xmlns="http://csrc.nist.gov/ns/oscal/metaschema/1.0"
    exclude-result-prefixes="xs math m xsi"
    version="3.0">

    <xsl:output indent="yes"/>
    
    <xsl:strip-space elements="METASCHEMA define-flag define-field define-assembly remarks model choice"/>
    
    
    
    <!-- ====== ====== ====== ====== ====== ====== ====== ====== ====== ====== ====== ====== -->
    <!-- resolves and writes the reference for a referencing assembly, field or flag
         defined at the top level of its module with global scope
         based on import descendancy: point to the first imported viable target
         'viable' means @name=@ref
         
         A
          B
           C
          D
           E
           C
         
         
     -->
    
    <xsl:mode on-no-match="shallow-copy"/>
    
    <xsl:key name="assembly-by-name" match="METASCHEMA/define-assembly[@scope='global']" use="@name"/>
    <xsl:key name="field-by-name"    match="METASCHEMA/define-field[@scope='global']"    use="@name"/>
    <xsl:key name="flag-by-name"     match="METASCHEMA/define-flag[@scope='global']"     use="@name"/>

    <xsl:template match="METASCHEMA">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:variable name="my-short-name" select="short-name"/>
            <xsl:variable name="clashing-modules" select="descendant::METASCHEMA[short-name=$my-short-name]"/>
            <xsl:if test="exists($clashing-modules)" expand-text="true">
                <EXCEPTION problem-type="metaschema-short-name-clash">The metaschema short-name '{ short-name }' is the same as the short-name of imported { if (count($clashing-modules)=1) then 'module' else 'modules'} '{ ($clashing-modules/@_base-uri => string-join(', ')) }'. Each module's short-name must be unique.</EXCEPTION>
            </xsl:if>
            <xsl:apply-templates/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="METASCHEMA/define-assembly">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:variable name="shadows" select="key('assembly-by-name', @name, parent::METASCHEMA) except ."/>
            <xsl:if test="exists($shadows)" expand-text="true">
                <EXCEPTION problem-type="definition-shadowing">Assembly definition '{ @name }' in module '{ @module }' shadows { if (count($shadows) eq 1) then 'this definition' else 'these definitions'}: { ($shadows ! ('''' || @name || ''' in module ''' || @module || '''') ) => string-join('; ') }</EXCEPTION>
            </xsl:if>
            <xsl:apply-templates/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="METASCHEMA/define-field">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:variable name="shadows" select="key('field-by-name', @name, parent::METASCHEMA) except ."/>
            <xsl:if test="exists($shadows)" expand-text="true">
                <EXCEPTION problem-type="definition-shadowing">Field definition '{ @name }' in module '{ @module }' shadows { if (count($shadows) eq 1) then 'this definition' else 'these definitions'}: { ($shadows ! ('''' || @name || ''' in module ''' || @module || '''') ) => string-join('; ') }</EXCEPTION>
            </xsl:if>
            <xsl:apply-templates/>
            
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="METASCHEMA/define-flag">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:variable name="shadows" select="key('flag-by-name', @name, parent::METASCHEMA) except ."/>
            <xsl:if test="exists($shadows)" expand-text="true">
                <EXCEPTION problem-type="definition-shadowing">Flag definition '{ @name }' in module '{ @module }' shadows { if (count($shadows) eq 1) then 'the definition' else 'these definitions:'} { ($shadows ! ('''' || @name || ''' in module ''' || @module || '''') ) => string-join('; ') }.</EXCEPTION>
            </xsl:if>
            <xsl:apply-templates/>
            
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="assembly/@ref">
        <xsl:copy-of select="."/>
        <xsl:variable name="me" select="."/>
        <xsl:variable name="global-defs" select="key('assembly-by-name', $me, ancestor::METASCHEMA[1])"/>
        <xsl:variable name="local-def"   select="ancestor::METASCHEMA[1]/define-assembly[@scope='local' and @name=$me]"/>
        <xsl:variable name="all-defs"    select="$local-def, $global-defs"/>
        <xsl:for-each select="$all-defs[1]">
            <xsl:attribute name="_key-ref" select="@_key-name"/>
        </xsl:for-each>
        <xsl:if test="empty($all-defs)" expand-text="true">
            <EXCEPTION problem-type="instance-invalid-reference">Target definition not found for assembly reference '{ $me }'.</EXCEPTION>
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="field/@ref">
        <xsl:copy-of select="."/>
        <xsl:variable name="me" select="."/>
        <xsl:variable name="global-defs" select="key('field-by-name', $me, ancestor::METASCHEMA[1])"/>
        <xsl:variable name="local-def"   select="ancestor::METASCHEMA[1]/define-field[@scope='local' and @name=$me]"/>
        <xsl:variable name="all-defs"    select="$local-def, $global-defs"/>
        <xsl:for-each select="$all-defs[1]">
          <xsl:attribute name="_key-ref" select="@_key-name"/>
        </xsl:for-each>
        <xsl:if test="empty($all-defs)" expand-text="true">
            <EXCEPTION problem-type="instance-invalid-reference">Target definition not found for field reference '{ $me }'.</EXCEPTION>
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="flag/@ref">
        <xsl:copy-of select="."/>
        <xsl:variable name="me" select="."/>
        <xsl:variable name="global-defs" select="key('flag-by-name', $me, ancestor::METASCHEMA[1])"/>
        <xsl:variable name="local-def"   select="ancestor::METASCHEMA[1]/define-flag[@scope='local' and @name=$me]"/>
        <xsl:variable name="all-defs"    select="$local-def, $global-defs"/>
        <xsl:for-each select="$all-defs[1]">
            <xsl:attribute name="_key-ref" select="@_key-name"/>
        </xsl:for-each>
        <xsl:if test="empty($all-defs)" expand-text="true">
            <EXCEPTION problem-type="instance-invalid-reference">Target definition not found for flag reference '{ $me }'.</EXCEPTION>
        </xsl:if>
    </xsl:template>
    
    
    
</xsl:stylesheet>