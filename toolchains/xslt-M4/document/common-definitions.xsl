<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:m="http://csrc.nist.gov/ns/oscal/metaschema/1.0" xmlns="http://www.w3.org/1999/xhtml"
    xpath-default-namespace="http://csrc.nist.gov/ns/oscal/metaschema/1.0"
    exclude-result-prefixes="#all">

    <xsl:import href="common-reference.xsl"/>
    
    <xsl:variable name="datatype-page" as="xs:string">../../../datatypes</xsl:variable>
    
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

            <xsl:apply-templates select="$definitions" mode="model-view"/>

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
            <a
                href="https://pages.nist.gov/OSCAL/artifacts/xml/schema/oscal_{$file-map(.)}_schema.xsd"
                >oscal_{$file-map(string(.))}_schema.xsd</a>
        </p>
    </xsl:template>

    <xsl:template match="short-name" mode="converter-link" expand-text="true">
        <p>
            <span class="usa-tag">JSON to XML converter</span>
            <a href="https://pages.nist.gov/OSCAL/artifacts/xml/convert/oscal_{$file-map(.)}_json-to-xml-converter.xsl"
                >oscal_{$file-map(string(.))}_json-to-xml-converter.xsl</a>
            <a href="https://github.com/usnistgov/OSCAL/tree/master/xml#converting-oscal-json-content-to-xml"
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

    <xsl:template match="root-name">
        <p>Name at root: <code class="use-name">{ . }</code></p>
    </xsl:template>
    
    <xsl:template match="/METASCHEMA/*/use-name" expand-text="true">
        <p>May use name: <code class="name">{ . }</code></p>
    </xsl:template>
    
    <xsl:template match="use-name" expand-text="true">
        <p>Use name: <code class="name">{ . }</code></p>
    </xsl:template>
    
    <xsl:template match="group-as" expand-text="true">
        <p>Grouping rule: group as <code class="name">{ @name }</code></p>
    </xsl:template>
    
    
    <xsl:template match="define-flag" mode="model"/>
        
    <xsl:template match="define-assembly | define-field" mode="model">
        <xsl:variable name="metaschema-type" select="replace(name(),'^define\-','')"/>
        <xsl:for-each-group select="flag | define-flag | model/*" group-by="true()">
            <details open="open">
                <summary>Property set / contents:</summary>

                <div class="model { $metaschema-type }-model">
                    <xsl:apply-templates select="current-group()" mode="model-view"/>
                </div>
            </details>
        </xsl:for-each-group>
    </xsl:template>

    <xsl:template match="use-name" mode="inline" expand-text="true"> - using name <code>{ . }</code></xsl:template>

    <xsl:template match="group-as" mode="inline" expand-text="true"> - grouped as <code>{ @name }</code></xsl:template>

    <xsl:template match="define-assembly | define-field | define-flag" mode="model-view">
        <xsl:variable name="level" select="count(. | ancestor::define-assembly)"/>
        <div class="model-entry definition { name() }"
            style="margin: 0em; margin-top: 1em; padding: 0.5em; border: thin solid black">
            <div class="definition-header">
                <xsl:element namespace="http://www.w3.org/1999/xhtml" name="h{ $level }"
                    expand-text="true">
                    <xsl:call-template name="mark-id"/>
                    <xsl:attribute name="class">toc{ $level} head</xsl:attribute>
                    <xsl:apply-templates select="." mode="definition-title-text"/>
                </xsl:element>
                <p class="type">
                    <xsl:apply-templates select="." mode="metaschema-type"/>
                </p>
                <xsl:if test="exists(ancestor::model)">
                    <p class="occurrence">
                        <xsl:apply-templates select="." mode="occurrence-code"/>
                    </p>
                </xsl:if>
                <xsl:call-template name="crosslink"/>
                <xsl:apply-templates select="formal-name" mode="in-header"/>
            </div>
            <!-- in no mode for regular contents -->
            <xsl:apply-templates/>
            <!--            -->
            <xsl:apply-templates select="." mode="model"/>
            
            <!--<details>
                <summary>Metaschema source</summary>
                <pre><xsl:value-of select="serialize(., $indenting)"/></pre>
            </details>-->
        </div>
    </xsl:template>
    
    <xsl:template name="crosslink">
        <xsl:comment> crosslink goes here</xsl:comment>
        <xsl:message>not making crosslink...</xsl:message>
    </xsl:template>
    
    <xsl:template match="assembly | field | flag" mode="model-view">
        <xsl:variable name="level" select="count(ancestor-or-self::*[exists(@gi)])"/>
        <xsl:variable name="header-tag" select="if ($level le 6) then ('h' || $level) else 'p'"/>
        <div class="model-entry definition { name() }"
            style="margin: 0em; margin-top: 1em; padding: 0.5em; border: thin solid black">
            <!--<xsl:call-template name="crosslink-to-xml"/>-->
            <!-- generates h1-hx headers picked up by Hugo toc -->
            <div class="instance-header">
                <xsl:element namespace="http://www.w3.org/1999/xhtml" name="h{ $level }"
                expand-text="true">
                <xsl:call-template name="mark-id"/>
                <xsl:attribute name="class">toc{ $level} head</xsl:attribute>
                <xsl:apply-templates select="." mode="definition-title-text"/>
            </xsl:element>
                <p class="type">
                    <xsl:apply-templates select="." mode="metaschema-type"/>
                </p>
                <xsl:if test="exists(ancestor::model)">
                    <p class="occurrence">
                        <xsl:apply-templates select="." mode="occurrence-code"/>
                    </p>
                </xsl:if>
                <xsl:call-template name="crosslink"/>
                <xsl:apply-templates select="formal-name" mode="in-header"/>
            </div>
            <!-- placeholder for what is to come -->
            <xsl:call-template name="link-to-definition"/>
            
        </div>
    </xsl:template>
    
    <xsl:template name="link-to-definition">
        <xsl:comment> link to definition goes here </xsl:comment>
        <xsl:message>not making link to definition...</xsl:message>
    </xsl:template>
    
    
    <xsl:template match="constraint">
        <xsl:variable name="constraints"
            select="descendant::allowed-values | descendant::matches | descendant::has-cardinality | descendant::is-unique | descendant::index-has-key | descendant::index"/>
        <details>
            <summary>Constraint</summary>
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
        <li class="choice">
            <xsl:call-template name="mark-id"/>
            <xsl:text>A choice between: </xsl:text>
            <ul>
                <xsl:apply-templates/>
            </ul>
        </li>
    </xsl:template>

    <xsl:template match="remarks">
        <details class="remarks">
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
        <p class="description">
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