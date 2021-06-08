<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:math="http://www.w3.org/2005/xpath-functions/math"
    xmlns="http://csrc.nist.gov/ns/oscal/metaschema/1.0"
    xpath-default-namespace="http://csrc.nist.gov/ns/oscal/metaschema/1.0"
    xmlns:html="http://www.w3.org/1999/xhtml"
    
    exclude-result-prefixes="#all"
    version="3.0">
    
    <xsl:output indent="true"/>
    <xsl:mode on-no-match="shallow-copy"/>
    
    <xsl:template match="/METASCHEMA">
        <map namespace="{child::namespace ! normalize-space(.) }"
            prefix="{child::short-name ! normalize-space(.) }">
            <metadata>
                <xsl:copy-of copy-namespaces="no" select="* except (define-assembly | define-field | define-flag)"/>
            </metadata>
            <xsl:apply-templates select="child::*[exists(root-name)]" mode="build"/>
        </map>
    </xsl:template>
    
    <xsl:key name="global-assemblies" match="METASCHEMA/define-assembly" use="@_key-name"/>
    <xsl:key name="global-fields"     match="METASCHEMA/define-field"    use="@_key-name"/>
    <xsl:key name="global-flags"      match="METASCHEMA/define-flag"     use="@_key-name"/>
    
    <xsl:template match="define-assembly | define-field" mode="build">
        <xsl:param name="visited" select="()" tunnel="true"/>
        <xsl:param name="reference" select="."/>
        
        <!-- properties can be given on the reference or on the definition itself, and a reference
             can overload its definition -->
        <xsl:variable name="minOccurs"    select="($reference/@min-occurs,@min-occurs,'0')[1]"/>
        <xsl:variable name="maxOccurs"    select="($reference/@max-occurs,@max-occurs,'1')[1]"/>
        <xsl:variable name="type"         select="$reference => local-name() => replace('^define-','')"/>
        <xsl:variable name="using-name"   select="$reference/@_using-name"/>
        <xsl:variable name="group-name"   select="($reference/group-as/@name,group-as/@name)[1]"/>
        <xsl:variable name="group-json"   select="($reference/group-as/@in-json,group-as/@in-json)[1]"/>
        <xsl:variable name="group-xml"    select="($reference/group-as/@in-xml,group-as/@in-xml)[1]"/>
        <xsl:variable name="in-xml"       select="$reference/@in-xml"/>
        <xsl:variable name="with-remarks" select="$reference/remarks"/>
        
        <xsl:element name="{ $type }" namespace="http://csrc.nist.gov/ns/oscal/metaschema/1.0">
            <xsl:for-each select="self::define-assembly[empty(model)]">
                <xsl:attribute name="as-type">empty</xsl:attribute>
            </xsl:for-each>
            <xsl:attribute name="scope" select="if (exists(parent::METASCHEMA)) then 'global' else 'local'"/>
            <xsl:if test="@_key-name = $visited">
                <xsl:attribute name="recursive">true</xsl:attribute>
            </xsl:if>
            
            <xsl:apply-templates select="@*"            mode="build"/>
            <xsl:apply-templates select="$reference/@*" mode="build"/>
            
            <xsl:if test="not($in-xml='UNWRAPPED')">
              <xsl:attribute name="gi"  select="($using-name, root-name, use-name,@name)[1]"/>
            </xsl:if>
            <xsl:attribute name="key" select="($using-name, root-name, use-name,@name)[1]"/>
            
            <xsl:attribute name="min-occurs" select="$minOccurs"/>
            <xsl:attribute name="max-occurs" select="$maxOccurs"/>
            <xsl:if test="exists(root-name) and not(@_key-name=$visited)">
                <xsl:attribute name="min-occurs" select="'1'"/>
            </xsl:if>
            <xsl:for-each select="$in-xml"><!-- UNWRAPPED or WITH_WRAPPER - supports unwrapped markup-multiline fields -->
                <xsl:attribute name="in-xml" select="."/>
            </xsl:for-each>
            <xsl:for-each select="$group-xml"><!-- GROUPED or UNGROUPED - introduces a grouping element for the group -->
                <xsl:attribute name="group-xml" select="."/>
            </xsl:for-each>
            <xsl:for-each select="$group-json"><!-- ARRAY (default), SINGLETON_OR_ARRAY, BY_KEY --> 
                <xsl:attribute name="group-json" select="."/>
            </xsl:for-each>
            <xsl:apply-templates select="($reference/json-key,json-key)[1]" mode="build"/>
            <xsl:apply-templates select="($reference/json-value-key,json-value-key)[1]" mode="build"/>
            <xsl:for-each select="$group-name">
                <xsl:attribute name="group-name" select="."/>
            </xsl:for-each>
            <xsl:apply-templates select="formal-name | description"/>
            <xsl:if test="not(@_key-name = $visited)">
                <xsl:apply-templates select="define-flag | flag" mode="build"/>
                <xsl:apply-templates select="model" mode="build">
                    <xsl:with-param name="visited" tunnel="true" select="$visited, string(@_key-name)"/>
                </xsl:apply-templates>
                <xsl:variable name="value-keyname">
                    <xsl:apply-templates select="." mode="value-keyname"/>
                </xsl:variable>
                <!-- We produce 'value' nodes even when there will be no such node in the resulting
                     field, for the sake of a binding location for path mapping logic. -->
                <xsl:for-each select="self::define-field">
                    <value as-type="{(@as-type,'string')[1]}">
                        <xsl:for-each select="(@_metaschema-xml-id|@_metaschema-json-id)">
                            <xsl:attribute name="{ name(.) }" select=". || '/' || $value-keyname"/>
                        </xsl:for-each>
                        <xsl:apply-templates select="." mode="value-key"/>
                    </value>
                </xsl:for-each>
            </xsl:if>
            <xsl:apply-templates select="constraint"/>
            <xsl:apply-templates select="remarks, $with-remarks"/>
        </xsl:element>
    </xsl:template>
    
    <xsl:template match="define-flag" mode="build">
        <xsl:param   name="reference" select="."/>
        
        <xsl:variable name="given-type"   select="$reference/@as-type"/>
        <xsl:variable name="is-required"  select="($reference/@required | @required) ='yes'"/>
        <xsl:variable name="using-name"   select="$reference/(use-name,@ref)[1]"/>
        <xsl:variable name="with-remarks" select="$reference/remarks"/>
        
        <flag max-occurs="1" min-occurs="{if ($is-required) then 1 else 0}" as-type="{ ($given-type,@as-type, 'string')[1] }">
            
            <xsl:apply-templates select="@*"            mode="build"/>
            <xsl:apply-templates select="$reference/@*" mode="build"/>
            
            <xsl:for-each select="parent::METASCHEMA">
                <xsl:attribute name="scope">global</xsl:attribute>
            </xsl:for-each>
            
            <xsl:attribute name="gi"  select="($using-name,use-name,@name,@ref)[1]"/>
            <xsl:attribute name="key" select="($using-name,use-name,@name,@ref)[1]"/>
            
            <xsl:apply-templates select="formal-name | description"/>
            <xsl:apply-templates select="constraint"/>
            <xsl:apply-templates select="remarks, $with-remarks"/>
        </flag>
    </xsl:template>

    <xsl:template match="assembly/remarks | field/remarks | flag-remarks">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:attribute name="class">in-use</xsl:attribute>
            <xsl:apply-templates mode="#current"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template mode="build" match="json-value-key[matches(@flag-name,'\S')]">
        <xsl:attribute name="json-value-flag" select="@flag-name"/>
    </xsl:template>
    
    <!--<xsl:template mode="build" match="json-value-key">
        <xsl:attribute name="{ local-name() }" select="."/>
    </xsl:template>-->
    
    <xsl:template mode="build" match="json-key">
        <xsl:attribute name="json-key-flag" select="@flag-name"/>
    </xsl:template>
    
    <xsl:template match="@module | @ref" mode="build"/>
    
    <xsl:template match="@*" mode="build">
        <xsl:copy-of select="."/>
    </xsl:template>
    
    
    <!--<xsl:template match="define-field/@as-type" mode="build"/>-->
    
    <xsl:template match="choice" mode="build">
        <choice>
            <xsl:apply-templates mode="#current"/>
        </choice>
    </xsl:template>
    
    <xsl:template mode="build" match="model//assembly">
        <xsl:apply-templates mode="build" select="key('global-assemblies', @_key-ref)">
            <xsl:with-param name="reference" select="."/>
        </xsl:apply-templates>
    </xsl:template>
    
    <xsl:template mode="build" match="model//field">
        <xsl:apply-templates mode="build" select="key('global-fields', @_key-ref)">
            <xsl:with-param name="reference" select="."/>
        </xsl:apply-templates>
    </xsl:template>
    
    <xsl:template mode="build" match="flag">
        <xsl:apply-templates mode="build" select="key('global-flags', @_key-ref)">
            <xsl:with-param name="reference" select="."/>
        </xsl:apply-templates>
    </xsl:template>
    
    <!--<xsl:template mode="build" match="model//assembly">
        <xsl:apply-templates mode="build" select="key('global-assemblies', @ref)">
            <xsl:with-param name="minOccurs" select="(@min-occurs,'0')[1]"/>
            <xsl:with-param name="maxOccurs" select="(@max-occurs,'1')[1]"/>
            <xsl:with-param name="group-name" select="group-as/@name"/>
            <xsl:with-param name="group-json" select="group-as/@in-json"/>
            <xsl:with-param name="group-xml" select="group-as/@in-xml"/>
            <xsl:with-param name="in-xml" select="@in-xml"/>
            <xsl:with-param name="using-name" select="use-name"/>
            <xsl:with-param name="with-remarks" select="remarks"/>
        </xsl:apply-templates>
    </xsl:template>-->
    
    
    <!--<xsl:template mode="build" match="model//field">
        <xsl:apply-templates mode="build" select="key('global-fields', @ref)">
            <xsl:with-param name="minOccurs" select="(@min-occurs,'0')[1]"/>
            <xsl:with-param name="maxOccurs" select="(@max-occurs,'1')[1]"/>
            <xsl:with-param name="group-name" select="group-as/@name"/>
            <xsl:with-param name="group-json" select="group-as/@in-json"/>
            <xsl:with-param name="group-xml" select="group-as/@in-xml"/>
            <xsl:with-param name="in-xml" select="@in-xml"/>
            <xsl:with-param name="using-name" select="use-name"/>
            <xsl:with-param name="with-remarks" select="remarks"/>
        </xsl:apply-templates>
    </xsl:template>-->
    
    <!--<xsl:template mode="build" match="flag">
        <xsl:apply-templates mode="build" select="key('global-flags', @ref)">
            <xsl:with-param name="minOccurs" select="(@min-occurs,'0')[1]"/>
            <xsl:with-param name="maxOccurs" select="(@max-occurs,'1')[1]"/>
            <xsl:with-param name="group-name" select="group-as/@name"/>
            <xsl:with-param name="group-json" select="group-as/@in-json"/>
            <xsl:with-param name="group-xml" select="group-as/@in-xml"/>
            <xsl:with-param name="in-xml" select="@in-xml"/>
            <xsl:with-param name="using-name" select="(use-name,@ref)[1]"/>
            <xsl:with-param name="with-remarks" select="remarks"/>
            <xsl:with-param name="given-type" select="@as-type"/>
        </xsl:apply-templates>
    </xsl:template>-->
    
    <xsl:template match="constraint" mode="build">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:copy-of select="*"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="text()" mode="build"/>
    
    <xsl:variable name="string-value-label">STRVALUE</xsl:variable>
    <xsl:variable name="markdown-value-label">RICHTEXT</xsl:variable>
    <xsl:variable name="markdown-multiline-label">PROSE</xsl:variable>

    <xsl:template priority="3" match="define-field[exists(json-value-key/@flag-name)]" mode="value-key">
        <xsl:attribute name="key-flag" select="json-value-key/@flag-name"/>
    </xsl:template>

    <!-- When a field has no flags not designated as a json-value-flag, it is 'naked'; its value is given without a key
         (in target JSON it will be the value of a (scalar) property, not a value on a property of an object property. -->
    
    <xsl:template mode="value-key" priority="3" match="define-field[empty(flag[not(@ref=../json-value-key/@flag-name)] | define-flag[not(@ref=../json-value-key/@flag-name)])]"/>
    
    <xsl:template match="define-field" mode="value-key">
        <xsl:attribute name="key">
          <xsl:apply-templates select="." mode="value-keyname"/>
        </xsl:attribute>
    </xsl:template>
    
    <xsl:template priority="2" match="define-field[exists(json-value-key)]" mode="value-keyname">
        <xsl:value-of select="json-value-key"/>
    </xsl:template>
    
    <xsl:template match="define-field[@as-type='markup-line']" mode="value-keyname">
        <xsl:value-of select="$markdown-value-label"/>
    </xsl:template>
    
    <xsl:template match="define-field[@as-type='markup-multiline']" mode="value-keyname">
        <xsl:value-of select="$markdown-multiline-label"/>
    </xsl:template>
    
    
    <xsl:template match="define-field" mode="value-keyname">
        <xsl:value-of select="$string-value-label"/>
    </xsl:template>
    
    
</xsl:stylesheet>