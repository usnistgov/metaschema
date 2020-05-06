<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:m="http://csrc.nist.gov/ns/oscal/metaschema/1.0"
    xpath-default-namespace="http://csrc.nist.gov/ns/oscal/metaschema/1.0/supermodel"
    xmlns="http://www.w3.org/2005/xpath-functions">

    <!-- Purpose: Convert XML to markdown. Note that namespace bindings must be given. -->

    <!--<XSLT:key name="parameters" match="param" use="@id"/>-->

    <!--Supermodel copied through ...-->
    <xsl:mode on-no-match="shallow-copy"/>

    <xsl:template match="value[@as-type = ('markup-line', 'markup-multiline')]">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:apply-templates mode="md"/>
        </xsl:copy>
    </xsl:template>

    <xsl:template name="conditional-lf">
        <xsl:value-of select="preceding-sibling::*[1]/'&#xA;'"/>
    </xsl:template>

    <xsl:template mode="md" match="p">
        <xsl:call-template name="conditional-lf"/>
        <xsl:text>&#xA;</xsl:text>
        <xsl:apply-templates mode="md"/>
    </xsl:template>

    <xsl:template mode="md" match="h1 | h2 | h3 | h4 | h5 | h6">
        <xsl:call-template name="conditional-lf"/>
        <xsl:text>&#xA;</xsl:text>
        <xsl:apply-templates select="." mode="mark"/>
        <xsl:apply-templates mode="md"/>
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
        <xsl:text>&#xA;</xsl:text>
        <xsl:apply-templates select="*" mode="md"/>
        <xsl:if test="empty(preceding-sibling::tr)">
            <xsl:text>&#xA;</xsl:text>
            <xsl:text>|</xsl:text>
            <xsl:for-each select="th | td">
                <xsl:text> --- |</xsl:text>
            </xsl:for-each>
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
        <xsl:text>&#xA;```&#xA;</xsl:text>

        <xsl:apply-templates mode="md"/>
        <xsl:text>&#xA;```&#xA;</xsl:text>
    </xsl:template>

    <xsl:template mode="md" priority="1" match="ul | ol">
        <xsl:call-template name="conditional-lf"/>
        <xsl:apply-templates mode="md"/>
        <xsl:text>&#xA;</xsl:text>
    </xsl:template>

    <xsl:template mode="md" match="ul//ul | ol//ol | ol//ul | ul//ol">
        <xsl:apply-templates mode="md"/>
    </xsl:template>

    <xsl:template mode="md" match="li">
        <xsl:text>&#xA;</xsl:text>
        <xsl:for-each select="../ancestor::ul">
            <xsl:text>  </xsl:text>
        </xsl:for-each>
        <xsl:text>* </xsl:text>
        <xsl:apply-templates mode="md"/>
    </xsl:template>
    <!-- Since XProc doesn't support character maps we do this in XSLT -   -->

    <xsl:template mode="md" match="ol/li">
        <xsl:text>&#xA;&#xA;</xsl:text>
        <xsl:for-each select="../ancestor::ul">
            <xsl:text>  </xsl:text>
        </xsl:for-each>
        <xsl:text>1. </xsl:text>
        <xsl:apply-templates mode="md"/>

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

    <!-- <insert param-id="ac-1_prm_1"/> -->
    <xsl:template mode="md" match="insert">
        <xsl:text>{{ </xsl:text>
        <xsl:value-of select="@param-id"/>
        <xsl:text> }}</xsl:text>
    </xsl:template>

    <xsl:key name="element-by-id" match="*[exists(@id)]" use="@id"/>

    <xsl:template mode="md" match="a">
        <xsl:text>[</xsl:text>
        <xsl:apply-templates mode="md"/>
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
    
    <xsl:template mode="md" match="text()">
        <!-- Escapes go here       -->
        <!-- prefixes ` ~ ^ * with char E0000 from Unicode PUA -->
        <!--<xsl:value-of select="replace(., '([`~\^\*''&quot;])', '&#xE0000;$1')"/>-->
        <!-- prefixes ` ~ ^ * ' " with reverse solidus -->
        <xsl:value-of select="replace(., '([`~\^\*&quot;])', '\\$1')"/>
        <!--<xsl:value-of select="."/>-->
    </xsl:template>
    
</xsl:stylesheet>
