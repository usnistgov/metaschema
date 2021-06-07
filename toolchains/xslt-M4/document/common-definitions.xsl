<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:m="http://csrc.nist.gov/ns/oscal/metaschema/1.0" xmlns="http://www.w3.org/1999/xhtml"
    xpath-default-namespace="http://csrc.nist.gov/ns/oscal/metaschema/1.0"
    exclude-result-prefixes="#all">

    <xsl:import href="common-reference.xsl"/>
    
    <xsl:key name="assembly-definition-by-name" match="/METASCHEMA/define-assembly" use="@_key-name"/>
    <xsl:key name="field-definition-by-name" match="/METASCHEMA/define-field"       use="@_key-name"/>
    <xsl:key name="flag-definition-by-name" match="/METASCHEMA/define-flag"         use="@_key-name"/>
    
    <xsl:variable name="datatype-page" as="xs:string">/reference/datatypes</xsl:variable>
    
    <xsl:variable name="indenting" as="element()"
        xmlns:output="http://www.w3.org/2010/xslt-xquery-serialization">
        <output:serialization-parameters>
            <output:indent value="yes"/>
        </output:serialization-parameters>
    </xsl:variable>

    <xsl:template match="METASCHEMA">
        <xsl:variable name="definitions" select="define-assembly | define-field | define-flag"/>
        <div>
            <xsl:call-template name="reference-class"/>
            <xsl:apply-templates select="* except (remarks | $definitions)"/>
            <xsl:apply-templates select="short-name" mode="schema-link"/>
            <xsl:apply-templates select="short-name" mode="converter-link"/>
            <xsl:apply-templates select="remarks"/>

            <xsl:apply-templates select="$definitions" mode="model-view">
                <!--<xsl:sort select="(root-name,use-name,@name)[1]"/>-->
            </xsl:apply-templates>

        </div>
    </xsl:template>
    
    <xsl:template name="reference-class"/>

    <xsl:template match="METASCHEMA/schema-name">
        <p>
            <span class="usa-tag">OSCAL model</span>
            <xsl:text> </xsl:text>
            <xsl:apply-templates/>
        </p>
    </xsl:template>

    <xsl:template match="METASCHEMA/namespace">
        <p>
            <span class="usa-tag">XML namespace</span>
            <xsl:text> </xsl:text>
            <code>
                <xsl:apply-templates/>
            </code>
        </p>
    </xsl:template>

    <xsl:variable name="file-map" as="map(xs:string, text())">
        <xsl:map>
            <xsl:map-entry key="'oscal-catalog'">catalog</xsl:map-entry>
            <xsl:map-entry key="'oscal-profile'">profile</xsl:map-entry>
            <xsl:map-entry key="'oscal-component-definition'">component</xsl:map-entry>
            <xsl:map-entry key="'oscal-ssp'">ssp</xsl:map-entry>
            <xsl:map-entry key="'oscal-poam'">poam</xsl:map-entry>
            <xsl:map-entry key="'oscal-ap'">assessment-plan</xsl:map-entry>
            <xsl:map-entry key="'oscal-ar'">assessment-results</xsl:map-entry>
        </xsl:map>
    </xsl:variable>

    <xsl:template match="short-name" mode="schema-link" expand-text="true">
        <p>
            <span class="usa-tag">XML Schema</span>
            <xsl:text> </xsl:text>
            <a
                href="/artifacts/xml/schema/oscal_{$file-map(.)}_schema.xsd"
                >oscal_{$file-map(string(.))}_schema.xsd</a>
        </p>
    </xsl:template>

    <xsl:template match="short-name" mode="converter-link" expand-text="true">
        <p>
            <span class="usa-tag">JSON to XML converter</span>
            <xsl:text> </xsl:text>
            <a href="/artifacts/xml/convert/oscal_{$file-map(.)}_json-to-xml-converter.xsl"
                >oscal_{$file-map(string(.))}_json-to-xml-converter.xsl</a>
            <a href="https://github.com/usnistgov/OSCAL/tree/main/xml#converting-oscal-json-content-to-xml"
                >(How do I use the converter to convert OSCAL JSON to XML?)</a>
        </p>
    </xsl:template>


    <xsl:template match="METASCHEMA/short-name">
        <p>
            <span class="usa-tag">Short name</span>
            <xsl:text> </xsl:text>
            <xsl:apply-templates/>
        </p>
    </xsl:template>

    <xsl:template match="METASCHEMA/schema-version">
        <p>
            <span class="usa-tag">Version</span>
            <xsl:text> </xsl:text>
            <xsl:apply-templates/>
        </p>
    </xsl:template>


    <xsl:template name="mark-id"/>
    
    
    <!-- Dropped in default traversal; handled from parent in mode 'model' -->
    <xsl:template match="flag | define-flag | model"/>

    <xsl:template mode="definition-title-text"
        match="define-assembly | assembly" expand-text="true">{ (use-name,@name,@ref)[1] }</xsl:template>

    <xsl:template mode="definition-title-text"
        match="define-flag | flag" expand-text="true">{ (use-name,@name,@ref)[1] }</xsl:template>

    <xsl:template mode="definition-title-text"
        match="define-field | field" expand-text="true">{ (use-name,@name,@ref)[1] }</xsl:template>

    <xsl:template match="root-name" expand-text="true">
        <p><span class="usa-tag">root name</span>&#xA0;<code class="name">{ . }</code></p>
    </xsl:template>
    
    <xsl:template match="json-key" expand-text="true">
        <p><span class="usa-tag">object key</span>&#xA0;<code class="name">{ . }</code></p>
    </xsl:template>
    
    <xsl:template match="json-value-key" expand-text="true">
        <p><span class="usa-tag">value key</span>&#xA0;<code class="name">{ . }</code></p>
    </xsl:template>
    
    <xsl:template match="json-key[@flag-name]" expand-text="true">
        <p><span class="usa-tag">object key flag</span>&#xA0;<code class="name">{ @flag-name }</code></p>
    </xsl:template>
    
    <xsl:template match="json-value-key[@flag-name]" expand-text="true">
        <p><span class="usa-tag">value key flag</span>&#xA0;<code class="name">{ @flag-name }</code></p>
    </xsl:template>
    
    <xsl:template match="use-name" expand-text="true">
        <p><span class="usa-tag">use name</span>&#xA0;<code class="name">{ . }</code></p>
    </xsl:template>
    
    <xsl:template match="group-as" expand-text="true">
        <xsl:message>unexpected match</xsl:message>
    </xsl:template>
    
    <xsl:template match="example"/>
    
    <!-- References get specialized treatment -->
    <xsl:template match="assembly | field | flag" mode="model"/>
    
    <xsl:template match="define-flag" mode="model"/>
    
    <xsl:template match="define-assembly | define-field" mode="model">
        <xsl:variable name="metaschema-type" select="replace(name(),'^define\-','')"/>
        <xsl:for-each-group select="flag | define-flag | model/*" group-by="true()" expand-text="true">
            <details open="open">
                <summary>{ if (count(current-group()) ne 1) then 'Properties' else 'Property' } ({ count(current-group()) })</summary>

                <div class="model { $metaschema-type }-model">
                    <xsl:apply-templates select="current-group()" mode="model-view"/>
                </div>
            </details>
        </xsl:for-each-group>
    </xsl:template>

    <xsl:template match="define-assembly | define-field | define-flag | assembly | field | flag" mode="model-view">
        <xsl:variable name="level" select="count(. | ancestor::define-assembly | ancestor::define-field)"/>
        <xsl:variable name="is-inline" select="exists(ancestor::model)"/>
        <xsl:variable name="header-tag" select="if ($level le 6) then ('h' || $level) else 'p'"/>
        <xsl:variable name="definition" as="element()">
            <xsl:apply-templates select="." mode="find-definition"/>
        </xsl:variable>
        <div class="model-entry definition { name() }">
            <div class="{ if ($is-inline) then 'instance-header' else 'definition-header' }">
                <xsl:element namespace="http://www.w3.org/1999/xhtml" name="{ $header-tag }"
                    expand-text="true">
                    <xsl:call-template name="mark-id"/>
                    <xsl:attribute name="class">toc{ $level} name</xsl:attribute>
                    <xsl:apply-templates select="." mode="definition-title-text"/>
                </xsl:element>
                <p class="type">
                    <xsl:apply-templates select="$definition" mode="metaschema-type"/>
                </p>
                <xsl:if test="$is-inline">
                    <p class="occurrence">
                        <xsl:apply-templates select="." mode="occurrence-code"/>
                    </p>
                </xsl:if>
                <xsl:call-template name="crosslink"/>
                <xsl:apply-templates select="$definition/formal-name" mode="in-header"/>
            </div>
            <xsl:where-populated>
                <div class="body">
                    <!-- in no mode for regular contents including use-name, group-as etc. -->
                    
<!-- split out to control order; include group-as, json-key etc. etc. from definitions                   -->
                    <!-- pick up a description from the definition if none is present -->
                    <xsl:apply-templates select="(.,$definition)[1]/description"/>

                    <xsl:apply-templates select="(.|$definition)/(root-name, use-name, group-as, json-value-key, json-key)"/>
                    <xsl:call-template name="remarks-group">
                        <xsl:with-param name="these-remarks" select="$definition/remarks, remarks"/>
                    </xsl:call-template>
                    <xsl:apply-templates select="constraint"/>
                    
                    <!--  description | root-name | remarks | use-name | group-as | constraint | json-value-key | flag | example -->
                    <!-- emits contents only for define-assembly and define-field -->
                    <xsl:apply-templates select="." mode="model"/>
                    <!-- emits contents only for references -->
                    <xsl:apply-templates select="." mode="link-to-definition"/>
                </div>
            </xsl:where-populated>
        </div>
    </xsl:template>
    
    <xsl:template name="remarks-group">
        <xsl:param name="these-remarks" select="child::remarks"/>
        
        <xsl:comment> remarks group goes here</xsl:comment>
        <xsl:message> remarks-group override failing...</xsl:message>
    </xsl:template>
    
    <xsl:template name="crosslink">
        <xsl:comment> crosslink goes here</xsl:comment>
        <xsl:message>not making crosslink...</xsl:message>
    </xsl:template>
    

    
    <xsl:template mode="find-definition" as="element()" match="define-assembly | define-field | define-flag">
        <xsl:sequence select="."/>
    </xsl:template>
    
    <xsl:template mode="find-definition" as="element()" match="assembly">
        <xsl:sequence select="key('assembly-definition-by-name',@_key-ref)"/>
    </xsl:template>
    
    <xsl:template mode="find-definition" as="element()" match="field">
        <xsl:sequence select="key('field-definition-by-name',@_key-ref)"/>
    </xsl:template>
    
    <xsl:template mode="find-definition" as="element()" match="flag">
        <xsl:sequence select="key('flag-definition-by-name',@_key-ref)"/>
    </xsl:template>
    
    <!-- Don't need links to themselves. -->
    <xsl:template match="define-assembly | define-field | define-flag" mode="link-to-definition"/>
        
    <xsl:template match="*" mode="link-to-definition">
        <xsl:comment> link to definition goes here </xsl:comment>
        <xsl:message>not making link to definition...</xsl:message>
    </xsl:template>
    
    
    <xsl:template match="constraint">
        <xsl:variable name="constraints"
            select="descendant::allowed-values | descendant::matches | descendant::has-cardinality | descendant::is-unique | descendant::index-has-key | descendant::index"/>
        <details>
            <summary>
                <xsl:text expand-text="true">Constraint{ if (count($constraints) ne 1) then 's' else '' } ({ count($constraints) })</xsl:text>
            </summary>
            <xsl:apply-templates/>
        </details>
    </xsl:template>

    <xsl:template match="constraint//*">
        <!-- use mode in imported XSLT       -->
        <xsl:apply-templates select="." mode="produce-constraint"/>
    </xsl:template>
   
    <!-- override this -->
    <xsl:template mode="metaschema-type" match="*" expand-text="true">{ local-name() }</xsl:template>
        
    <!-- expect overriding XSLT to provide metaschema type with appropriate link  -->
    <xsl:template mode="metaschema-type" match="*[exists(@as-type)]" expand-text="true">
        <a href="{$datatype-page}/#{(lower-case(@as-type))}">{ @as-type }</a>
    </xsl:template>
    
    <xsl:template priority="5" match="choice">
        <div class="choice">
            <xsl:call-template name="mark-id"/>
            <p>A choice between: </p>
            <xsl:apply-templates/>
        </div>
    </xsl:template>

    <xsl:template match="remarks">
        <details class="remarks" open="open">
            <summary>Remarks</summary>
            <xsl:apply-templates/>
        </details>
    </xsl:template>

    <xsl:template match="formal-name" mode="in-header">
        <p class="formal-name">
          <xsl:apply-templates/>
        </p>
    </xsl:template>

    <!--Dropped in regular traversal b/c acquired in 'in-header' mode-->
    <xsl:template match="formal-name"/>
    
    
    <xsl:template match="description">
        <p class="description"><span class="usa-tag">description</span>
            <xsl:text> </xsl:text>
            <xsl:apply-templates/>
        </p>
    </xsl:template>

    <xsl:template match="p">
        <p class="p">
            <xsl:apply-templates/>
        </p>
    </xsl:template>

   <xsl:template match="em | strong | b | i | u | q | code | a">
        <xsl:element name="{local-name(.)}" namespace="http://www.w3.org/1999/xhtml">
            <xsl:copy-of select="@*"/>
            <xsl:apply-templates/>
        </xsl:element>
    </xsl:template>

</xsl:stylesheet>