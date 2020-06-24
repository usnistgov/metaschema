<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:math="http://www.w3.org/2005/xpath-functions/math"
    xpath-default-namespace="http://csrc.nist.gov/ns/oscal/metaschema/1.0/supermodel"
    xmlns="http://www.w3.org/2005/xpath-functions"
    exclude-result-prefixes="xs math"
    version="3.0">
    
<!-- XXX TO DO XXX
    
    stitch in XML to markdown (see xml-to-markdown.xsl)
    map datatypes to JSON object types 'number' 'boolean' etc.
    implement 'collapsible='yes'"
        
    -->
    
    <xsl:output indent="true"/>
    <xsl:strip-space elements="*"/>
    <xsl:preserve-space elements="flag value"/>
    
    <xsl:variable name="ns" select="/*/@namespace"/>
    
    <!--group assembly field flag value-->
    
    <xsl:template match="group">
        <array>
            <xsl:copy-of select="@key"/>
            <xsl:apply-templates/>
        </array>
    </xsl:template>
    
    <xsl:template match="group[@in-json='BY_KEY']">
        <map>
            <xsl:copy-of select="@key"/>
            <xsl:apply-templates/>
        </map>
    </xsl:template>
    
    <xsl:template match="flag[@key=../@json-key-flag]"/>
    
    <xsl:template match="group[@in-json='SINGLETON_OR_ARRAY'][count(*)=1]">
        <xsl:apply-templates>
            <xsl:with-param name="group-key" select="@key"/>
        </xsl:apply-templates>
    </xsl:template>
    
    <xsl:template priority="2" match="group/assembly | group/field">
        <!-- $group-key is only provided when group/@in-json="SINGLETON_OR_ASSEMBLY" and there is one member of the group -->
        <xsl:param name="group-key" select="()"/>
        <!--@json-key-flag is only available when group/@in-json="BY_KEY"-->
        <xsl:variable name="json-key-flag-name" select="@json-key-flag"/>
        <map>
            <xsl:copy-of select="($group-key,@key)[1]"/>
            <!-- when there's a JSON key flag, we get the key from there -->
            <xsl:for-each select="flag[@key=$json-key-flag-name]">
                <xsl:attribute name="key" select="."/>
            </xsl:for-each>
            <xsl:apply-templates/>
        </map>
    </xsl:template>
    
    <xsl:template priority="3" match="group/field[@in-json='SCALAR']">
        <xsl:param name="group-key" select="()"/>
        <xsl:variable name="json-key-flag-name" select="@json-key-flag"/>
        <!-- with no flags, this field has only its value -->
        <xsl:apply-templates>
            <xsl:with-param name="use-key" select="flag[@key = $json-key-flag-name]"/>
        </xsl:apply-templates>
    </xsl:template>
    
    <!-- Extra object wrapper at the top   -->
    <xsl:template match="/assembly">
        <map>
            <xsl:next-match/>
        </map>
    </xsl:template>
    
    <xsl:template match="assembly">
        <map key="{@key}">
            <xsl:apply-templates/>
        </map>
    </xsl:template>
    
    <xsl:template match="field">
        <map key="{@key}">
            <xsl:apply-templates/>
        </map>
    </xsl:template>
    
    <xsl:template match="field[@in-json='SCALAR']">
        <xsl:apply-templates/>
        <!--
        <!-\- when there are no flags, the field is a string whose value is the value -\->
        <string>
            <xsl:copy-of select="@key"/>
            <xsl:value-of select="value"/>
        </string> -->
    </xsl:template>
    
    <xsl:template match="flag[@key=../value/@key-flag]"/>
    
    <xsl:template match="flag">
        <string>
            <xsl:copy-of select="@key"/>
            <xsl:apply-templates/>
        </string>
    </xsl:template>
    
    <!--Processing values:
     The JSON value type is given on @in-json 
      A key is assigned as follows:
            if the (parent) field has a value key flag, its value is used
            otherwise if the field is a scalar, its key is used, with no key if it has none
            otherwise the nominated key is used --> 
    
    <xsl:template priority="2" match="field[exists(@json-key-flag)]/value">
        <xsl:variable name="key-flag-name" select="../@json-key-flag"/>
        <xsl:element name="{@in-json}" namespace="http://www.w3.org/2005/xpath-functions">
            <xsl:attribute name="key" select="../flag[@key = $key-flag-name]"/>
            <xsl:apply-templates/>
        </xsl:element>
    </xsl:template>
    
    <xsl:template match="field[@in-json='SCALAR'][empty(@key)]/value">
        <!-- A value given on a scalar field with no key gets no key either -->
        <xsl:element name="{@in-json}" namespace="http://www.w3.org/2005/xpath-functions">
            <xsl:apply-templates/>
        </xsl:element>
    </xsl:template>
    
    <xsl:template match="value">
        <xsl:variable name="key-flag-name" select="@key-flag"/>
        <xsl:element name="{(@in-json,'string')[1]}"
            namespace="http://www.w3.org/2005/xpath-functions">
            <xsl:attribute name="key"
                select="(../flag[@key=$key-flag-name],parent::field[@in-json = 'SCALAR']/@key, @key)[1]"/>
            <xsl:apply-templates/>
        </xsl:element>
    </xsl:template>
    
    <xsl:template match="p | ul | ol | pre | h1 | h2 | h3 | h4 | h5 | h6 | table">
        <xsl:apply-templates select="." mode="make-markdown"/>
    </xsl:template>
    
    <xsl:template mode="as-string" match="@* | *">
        <xsl:param name="key" select="local-name()"/>
        <xsl:param name="mandatory" select="false()"/>
        <xsl:if test="$mandatory or matches(., '\S')">
            <string key="{{ $key }}">
                <xsl:value-of select="."/>
            </string>
        </xsl:if>
    </xsl:template>
    
    <xsl:template mode="as-boolean" match="@* | *">
        <xsl:param name="key" select="local-name()"/>
        <xsl:param name="mandatory" select="false()"/>
        <xsl:if test="$mandatory or matches(., '\S')">
            <boolean key="{{ $key }}">
                <xsl:value-of select="."/>
            </boolean>
        </xsl:if>
    </xsl:template>
    
    <xsl:template mode="as-integer" match="@* | *">
        <xsl:param name="key" select="local-name()"/>
        <xsl:param name="mandatory" select="false()"/>
        <xsl:if test="$mandatory or matches(., '\S')">
            <integer key="{{ $key }}">
                <xsl:value-of select="."/>
            </integer>
        </xsl:if>
    </xsl:template>
    
    <xsl:template mode="as-number" match="@* | *">
        <xsl:param name="key" select="local-name()"/>
        <xsl:param name="mandatory" select="false()"/>
        <xsl:if test="$mandatory or matches(., '\S')">
            <number key="{{ $key }}">
                <xsl:value-of select="."/>
            </number>
        </xsl:if>
    </xsl:template>
    
</xsl:stylesheet>