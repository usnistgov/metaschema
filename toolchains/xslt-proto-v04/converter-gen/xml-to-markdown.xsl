<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:m="http://csrc.nist.gov/ns/oscal/metaschema/1.0"
    xpath-default-namespace="http://csrc.nist.gov/ns/oscal/metaschema/1.0"
    version="3.0"
    
    xmlns:XSLT="http://csrc.nist.gov/ns/oscal/metaschema/xslt-alias"
    
    xmlns="http://www.w3.org/2005/xpath-functions">
    
<!-- Purpose: Convert XML to markdown. Note that namespace bindings must be given. -->



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

        <!--<XSLT:key name="parameters" match="param" use="@id"/>-->

        <xsl:template name="conditional-lf">
            <xsl:variable name="predecessor"
                select="preceding-sibling::p | preceding-sibling::ul | preceding-sibling::ol | preceding-sibling::table | preceding-sibling::pre"/>
            <xsl:if test="exists($predecessor)">
                <string/>
            </xsl:if>
        </xsl:template>

        <xsl:template mode="md" match="p | link | part/*">
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
                <xsl:for-each select="../ancestor::ul">
                    <xsl:text>&#32;&#32;</xsl:text>
                </xsl:for-each>
                <xsl:text>* </xsl:text>
                <xsl:apply-templates mode="md"/>
            </string>
        </xsl:template>
        <!-- Since XProc doesn't support character maps we do this in XSLT -   -->

        <xsl:template mode="md" match="ol/li">
            <string/>
            <string>
                <xsl:for-each select="../ancestor::ul">
                    <xsl:text>&#32;&#32;</xsl:text>
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

        <!-- <insert param-id="ac-1_prm_1"/> -->
        <xsl:template mode="md" match="insert">
            <xsl:text>{{ </xsl:text>
            <xsl:value-of select="@param-id"/>
            <xsl:text> }}</xsl:text>
        </xsl:template>

        <xsl:key name="element-by-id" match="*[exists(@id)]" use="@id"/>

        <xsl:template mode="md" match="a">
            <xsl:text>[</xsl:text>
            <xsl:value-of select="."/>
            <xsl:text>]</xsl:text>
            <xsl:text>(</xsl:text>
            <xsl:value-of select="@href"/>
            <xsl:text>)</xsl:text>
        </xsl:template>

<!-- See top level template match="/" for XSLT:template match="text()" mode="md" -->
    
    
</xsl:stylesheet>