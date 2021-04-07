<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:math="http://www.w3.org/2005/xpath-functions/math"
    xpath-default-namespace="http://csrc.nist.gov/ns/oscal/metaschema/1.0/supermodel"
    xmlns="http://www.w3.org/2005/xpath-functions"
    exclude-result-prefixes="xs math"
    default-mode="write-json"
    version="3.0">
    
<!-- XXX TO DO XXX
    
    stitch in XML to markdown (see xml-to-markdown.xsl)
    map datatypes to JSON object types 'number' 'boolean' etc.
    implement 'collapsible='yes'"
        
    -->
    
    <xsl:output indent="true"/>
    
    <xsl:strip-space elements="model assembly"/>
    
    <xsl:variable name="ns" select="/*/@namespace"/>
    
    <!--group assembly field flag value-->
    
    <xsl:template match="group" mode="write-json">
        <array>
            <xsl:copy-of select="@key"/>
            <xsl:apply-templates mode="#current"/>
        </array>
    </xsl:template>
    
    <xsl:template match="group[@in-json='BY_KEY']" mode="write-json">
        <map>
            <xsl:copy-of select="@key"/>
            <xsl:apply-templates mode="#current"/>
        </map>
    </xsl:template>
    
    <xsl:template match="flag[@key=../@json-key-flag]" mode="write-json"/>
    
    <xsl:template match="group[@in-json='SINGLETON_OR_ARRAY'][count(*)=1]" mode="write-json">
        <xsl:apply-templates mode="write-json">
            <xsl:with-param name="group-key" select="@key"/>
        </xsl:apply-templates>
    </xsl:template>
    
    <xsl:template priority="2" match="group/assembly | group/field" mode="write-json">
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
            <xsl:apply-templates mode="#current"/>
        </map>
    </xsl:template>
    
    <xsl:template priority="3" match="group/field[@in-json='SCALAR']" mode="write-json">
        <xsl:param name="group-key" select="()"/>
        <xsl:variable name="json-key-flag-name" select="@json-key-flag"/>
        <!-- with no flags, this field has only its value -->
        <xsl:apply-templates mode="write-json">
            <xsl:with-param name="use-key" select="flag[@key = $json-key-flag-name]"/>
        </xsl:apply-templates>
    </xsl:template>
    
    <!-- Extra object wrapper at the top   -->
    <xsl:template match="/assembly" mode="write-json">
        <map>
            <xsl:next-match/>
        </map>
    </xsl:template>
    
    <xsl:template match="assembly" mode="write-json">
        <map key="{@key}">
            <xsl:apply-templates mode="#current"/>
        </map>
    </xsl:template>
    
    <xsl:template match="field" mode="write-json">
        <map key="{@key}">
            <xsl:apply-templates mode="#current"/>
        </map>
    </xsl:template>
    
    <xsl:template match="field[@in-json='SCALAR']" mode="write-json">
        <xsl:apply-templates mode="#current"/>
        <!--
        <!-\- when there are no flags, the field is a string whose value is the value -\->
        <string>
            <xsl:copy-of select="@key"/>
            <xsl:value-of select="value"/>
        </string> -->
    </xsl:template>
    
    <xsl:template match="flag[@key=../value/@key-flag]" mode="write-json"/>
    
    <xsl:template match="flag" mode="write-json">
        <xsl:element name="{(@in-json[matches(.,'\S')],'string')[1]}"
            namespace="http://www.w3.org/2005/xpath-functions">
            <xsl:copy-of select="@key"/>
            <xsl:apply-templates mode="#current"/>
        </xsl:element>
    </xsl:template>
    
    <!--Processing values:
     The JSON value type is given on @in-json 
      A key is assigned as follows:
            if the (parent) field has a value key flag, its value is used
            otherwise if the field is a scalar, its key is used, with no key if it has none
            otherwise the nominated key is used --> 
    
    <xsl:template priority="2" match="field[exists(@json-key-flag)]/value" mode="write-json">
        <xsl:variable name="key-flag-name" select="../@json-key-flag"/>
        <xsl:element name="{@in-json}" namespace="http://www.w3.org/2005/xpath-functions">
            <xsl:attribute name="key" select="../flag[@key = $key-flag-name]"/>
            <xsl:apply-templates mode="#current"/>
        </xsl:element>
    </xsl:template>
    
    <!--<xsl:template match="field[@in-json='SCALAR'][empty(@key)]/value" mode="write-json">
        <!-\- A value given on a scalar field with no key gets no key either -\->
        <xsl:element name="{@in-json}" namespace="http://www.w3.org/2005/xpath-functions">
            <xsl:apply-templates mode="#current"/>
        </xsl:element>
    </xsl:template>-->
    
    <xsl:template match="value" mode="write-json">
        <xsl:variable name="key-flag-name" select="@key-flag"/>
        <xsl:element name="{(@in-json[matches(.,'\S')],'string')[1]}"
            namespace="http://www.w3.org/2005/xpath-functions">
            <xsl:copy-of
                select="((../flag[@key=$key-flag-name],parent::field[@in-json = 'SCALAR'])/@key, @key)[1]"/>
            <xsl:apply-templates select="." mode="cast-data"/>
        </xsl:element>
    </xsl:template>
    
    <xsl:template match="*" mode="cast-data">
        <xsl:value-of select="."/>
    </xsl:template>
    
    <!--<xsl:template match="value[@as-type='markup-line']" mode="write-json">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:apply-templates select="." mode="cast-data"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="value[@as-type='markup-multiline']" mode="write-json">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:apply-templates select="." mode="cast-data"/>
        </xsl:copy>
    </xsl:template>
    -->
    
    <xsl:template match="value[@as-type='markup-line']" mode="cast-data">
        <xsl:apply-templates mode="md"/>
    </xsl:template>
    
    <xsl:template match="value[@as-type='markup-multiline']" mode="cast-data">
        <xsl:variable name="lines" as="node()*">
            <xsl:apply-templates select="*" mode="md"/>
        </xsl:variable>
        <xsl:value-of select="$lines/self::* => string-join('&#xA;')"/>
    </xsl:template>
    
    
    <xsl:template name="conditional-lf">
        <xsl:variable name="predecessor"
            select="preceding-sibling::p | preceding-sibling::ul | preceding-sibling::ol | preceding-sibling::table | preceding-sibling::pre"/>
        <xsl:if test="exists($predecessor)">
            <string/>
        </xsl:if>
    </xsl:template>
    
    <xsl:template mode="md" match="text()[empty(ancestor::pre)]">
        <xsl:variable name="escaped">
        <xsl:value-of select="replace(., '([`~\^\*&quot;])', '\\$1')"/>
        </xsl:variable>
        <xsl:value-of select="replace($escaped,'\s+',' ')"/>
    </xsl:template>
    
    <xsl:template mode="md" match="text()">
        <!-- Escapes go here       -->
        <!-- prefixes ` ~ ^ * with char E0000 from Unicode PUA -->
        <!--<xsl:value-of select="replace(., '([`~\^\*''&quot;])', '&#xE0000;$1')"/>-->
        <!-- prefixes ` ~ ^ * ' " with reverse solidus -->
        <xsl:value-of select="replace(., '([`~\^\*&quot;])', '\\$1')"/>
        <!--<xsl:value-of select="."/>-->
    </xsl:template>
    
    
    <xsl:template mode="md" match="p">
        <xsl:call-template name="conditional-lf"/>
        <string>
            <xsl:apply-templates mode="md"/>
        </string>
    </xsl:template>
    
    <xsl:template mode="md" match="h1 | h2 | h3 | h4 | h5 | h6">
        <xsl:call-template name="conditional-lf"/>
        <string>
            <xsl:apply-templates select="." mode="mark"/>
            <xsl:apply-templates mode="md"/>
        </string>
    </xsl:template>
    
    <xsl:template mode="mark" match="h1"># </xsl:template>
    <xsl:template mode="mark" match="h2">## </xsl:template>
    <xsl:template mode="mark" match="h3">### </xsl:template>
    <xsl:template mode="mark" match="h4">#### </xsl:template>
    <xsl:template mode="mark" match="h5">##### </xsl:template>
    <xsl:template mode="mark" match="h6">###### </xsl:template>
    
    <xsl:template mode="md" match="table">
        <xsl:call-template name="conditional-lf"/>
        <xsl:apply-templates select="*" mode="md"/>
    </xsl:template>
    
    <xsl:template mode="md" match="tr">
        <string>
            <xsl:apply-templates select="*" mode="md"/>
        </string>
        <xsl:if test="empty(preceding-sibling::tr)">
            <string>
                <xsl:text>|</xsl:text>
                <xsl:for-each select="th | td">
                    <xsl:text> --- |</xsl:text>
                </xsl:for-each>
            </string>
        </xsl:if>
    </xsl:template>
    
    <xsl:template mode="md" match="th | td">
        <xsl:if test="empty(preceding-sibling::*)">|</xsl:if>
        <xsl:text> </xsl:text>
        <xsl:apply-templates mode="md"/>
        <xsl:text> |</xsl:text>
    </xsl:template>
    
    <xsl:template mode="md" priority="1" match="pre">
        <xsl:call-template name="conditional-lf"/>
        <string>```</string>
        <string>
            <xsl:apply-templates mode="md"/>
        </string>
        <string>```</string>
    </xsl:template>
    
    <xsl:template mode="md" priority="1" match="ul | ol">
        <xsl:call-template name="conditional-lf"/>
        <xsl:apply-templates mode="md"/>
        <string/>
    </xsl:template>
    
    <xsl:template mode="md" match="ul//ul | ol//ol | ol//ul | ul//ol">
        <xsl:apply-templates mode="md"/>
    </xsl:template>
    
    <xsl:template mode="md" match="li">
        <string>
            <xsl:for-each select="(../ancestor::ul | ../ancestor::ol)">
                <xsl:text>&#32;&#32;</xsl:text>
            </xsl:for-each>
            <xsl:text>* </xsl:text>
            <xsl:apply-templates mode="md"/>
        </string>
    </xsl:template>
    <!-- Since XProc doesn't support character maps we do this in XSLT -   -->
    
    <xsl:template mode="md" match="ol/li">
        <string>
            <xsl:for-each select="(../ancestor::ul | ../ancestor::ol)">
                <xsl:text xml:space="preserve">&#32;&#32;</xsl:text>
            </xsl:for-each>
            <xsl:text>1. </xsl:text>
            <xsl:apply-templates mode="md"/>
        </string>
    </xsl:template>
    <!-- Since XProc doesn't support character maps we do this in XSLT -   -->
    
    <xsl:template mode="md" match="code | span[contains(@class, 'code')]">
        <xsl:text>`</xsl:text>
        <xsl:apply-templates mode="md"/>
        <xsl:text>`</xsl:text>
    </xsl:template>
    
    <xsl:template mode="md" match="em | i">
        <xsl:text>*</xsl:text>
        <xsl:apply-templates mode="md"/>
        <xsl:text>*</xsl:text>
    </xsl:template>
    
    <xsl:template mode="md" match="strong | b">
        <xsl:text>**</xsl:text>
        <xsl:apply-templates mode="md"/>
        <xsl:text>**</xsl:text>
    </xsl:template>
    
    <xsl:template mode="md" match="q">
        <xsl:text>"</xsl:text>
        <xsl:apply-templates mode="md"/>
        <xsl:text>"</xsl:text>
    </xsl:template>
    
    <!-- <insert type="param" id-ref="ac-1_prm_1"/> -->
    <xsl:template mode="md" match="insert">
        <xsl:text>{{ insert: </xsl:text>
        <xsl:value-of select="@type, @id-ref" separator=", "/>
        <xsl:text> }}</xsl:text>
    </xsl:template>
    
    <xsl:template mode="md" match="a">
        <xsl:text>[</xsl:text>
        <xsl:value-of select="."/>
        <xsl:text>]</xsl:text>
        <xsl:text>(</xsl:text>
        <xsl:value-of select="@href"/>
        <xsl:text>)</xsl:text>
    </xsl:template>
    <!--![alt](src.jpg "title")-->
    
    <xsl:template mode="md" match="img">
        <xsl:text>![</xsl:text>
        <xsl:value-of select="(@alt,@src)[1]"/>
        <xsl:text>]</xsl:text>
        <xsl:text>(</xsl:text>
        <xsl:value-of select="@src"/>
        <xsl:for-each select="@title">
            <xsl:text expand-text="true"> "{.}"</xsl:text>
        </xsl:for-each>
        <xsl:text>)</xsl:text>
    </xsl:template>
    
        
</xsl:stylesheet>