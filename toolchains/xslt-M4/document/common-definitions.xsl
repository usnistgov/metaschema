<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:m="http://csrc.nist.gov/ns/oscal/metaschema/1.0" xmlns="http://www.w3.org/1999/xhtml"
    xpath-default-namespace="http://csrc.nist.gov/ns/oscal/metaschema/1.0"
    exclude-result-prefixes="#all">

    <xsl:variable name="indenting" as="element()"
        xmlns:output="http://www.w3.org/2010/xslt-xquery-serialization">
        <output:serialization-parameters>
            <output:indent value="yes"/>
        </output:serialization-parameters>
    </xsl:variable>

    <xsl:param name="json-reference-page">../../json/reference</xsl:param>
    <xsl:param name="xml-map-page">../outline</xsl:param>

    <xsl:template match="/METASCHEMA" priority="10">
        <div>
            <xsl:apply-templates/>
        </div>
    </xsl:template>


    <xsl:template match="*" expand-text="true">
        <div class="{ name() }">
            <p class="element-label">
                <span class="lbl">{ name(. )}</span>
            </p>
            <xsl:apply-templates/>
        </div>
    </xsl:template>

    <xsl:template match="*[exists(text()[matches(., '\S')])]" priority="-0.1" expand-text="true">
        <p class="{ name(.) }">
            <span class="lbl">{ name(. )}</span>
            <xsl:apply-templates/>
        </p>
    </xsl:template>


    <xsl:template match="METASCHEMA">
        <xsl:variable name="definitions" select="define-assembly | define-field | define-flag"/>
        <div>
            <xsl:apply-templates select="* except (remarks | $definitions)"/>
            <xsl:apply-templates select="short-name" mode="schema-link"/>
            <xsl:apply-templates select="short-name" mode="converter-link"/>
            <xsl:apply-templates select="remarks"/>

            <xsl:apply-templates select="$definitions"/>

        </div>
    </xsl:template>

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
            <a
                href="https://pages.nist.gov/OSCAL/artifacts/xml/convert/oscal_{$file-map(.)}_json-to-xml-converter.xsl"
                >oscal_{$file-map(string(.))}_json-to-xml-converter.xsl</a>
            <a
                href="https://github.com/usnistgov/OSCAL/tree/master/xml#converting-oscal-json-content-to-xml"
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


    <xsl:template match="/*/define-assembly | /*/define-field | /*/define-flag">
        <xsl:variable name="level" select="count(. | ancestor::define-assembly)"/>
        <section class="definition { name() }"
            style="margin: 0em; margin-top: 1em; padding: 0.5em; border: thin solid black">
            <!--<xsl:call-template name="crosslink-to-xml"/>-->
            <!-- generates h1-hx headers picked up by Hugo toc -->
            <xsl:element namespace="http://www.w3.org/1999/xhtml" name="h{ $level }"
                expand-text="true">
                <!--<xsl:attribute name="id" select="@_json-path"/>-->
                <xsl:attribute name="class">toc{ $level} head</xsl:attribute>
                <xsl:apply-templates select="." mode="definition-title-text"/>
            </xsl:element>

            <xsl:apply-templates/>
            <xsl:apply-templates select="." mode="model"/>

            <details>
                <summary>Metaschema source</summary>
                <pre><xsl:value-of select="serialize(., $indenting)"/></pre>
            </details>
        </section>
    </xsl:template>

    <!-- Handled from parent in mode 'model' -->
    <xsl:template match="flag | define-flag | model"/>

    <xsl:template mode="definition-title-text" match="define-assembly" expand-text="true">Assembly
            <code>{ @name }</code></xsl:template>

    <xsl:template mode="definition-title-text" match="define-flag" expand-text="true">Flag <code>{
            @name }</code></xsl:template>

    <xsl:template mode="definition-title-text" match="define-field" expand-text="true">Field <code>{
            @name }</code></xsl:template>



    <xsl:template match="define-assembly | define-field" mode="model">
        <ul class="model">
            <xsl:apply-templates select="flag | define-flag" mode="model-view"/>
            <xsl:apply-templates select="model/*" mode="model-view"/>
        </ul>
    </xsl:template>

    <xsl:template match="define-flag" mode="model"/>

    <!--<xsl:template match="description" mode="model">
        <xsl:text> </xsl:text>
        <span class="model-description">
            <xsl:apply-templates/>
        </span>
    </xsl:template>-->



    <xsl:template match="use-name" mode="inline" expand-text="true"> - using name <code>{ . }</code></xsl:template>

    <xsl:template match="group-as" mode="inline" expand-text="true"> - grouped as <code>{ @name }</code></xsl:template>

    <xsl:template match="field" mode="model-view" expand-text="true">
        <li>Field (reference) <code>{ @ref }</code>
            <xsl:apply-templates select="use-name | group-as" mode="inline"/>
        </li>
    </xsl:template>

    <xsl:template match="flag" mode="model-view" expand-text="true">
        <li>Flag (reference) <code>{ @ref }</code>
            <xsl:apply-templates select="use-name | group-as" mode="inline"/></li>
    </xsl:template>

    <xsl:template match="assembly" mode="model-view" expand-text="true">
        <li>Assembly (reference) <code>{ @ref }</code>
            <xsl:apply-templates select="use-name | group-as" mode="inline"/>
        </li>
    </xsl:template>

    <xsl:template match="define-field" mode="model-view" expand-text="true">
        <li>Field (defined inline) <code>{ @name }</code>
            <xsl:apply-templates select="use-name | group-as" mode="inline"/>
        </li>
    </xsl:template>

    <xsl:template match="define-flag" mode="model-view" expand-text="true">
        <li>Flag (defined inline) <code>{ @name }</code>
            <xsl:apply-templates select="use-name | group-as" mode="inline"/></li>

    </xsl:template>

    <xsl:template match="define-assembly" mode="model-view" expand-text="true">
        <li>Assembly (defined inline) <code>{ @name }</code>
            <xsl:apply-templates select="use-name | group-as" mode="inline"/></li>
    </xsl:template>

    <xsl:template priority="5" match="choice">
        <li class="choice">A choice between: <ul>
                <xsl:apply-templates/>
            </ul>
        </li>
    </xsl:template>

    <!--<xsl:template  match="example">
      <div class="example">
         <pre class="example font-mono-sm">
           <xsl:apply-templates select="*" mode="serialize"/>
         </pre>
      </div>
   </xsl:template>-->

    <!--<xsl:template match="prose">
        <li class="prose">Prose contents (paragraphs and lists)</li>
    </xsl:template>
    
    <xsl:template match="allowed-values" name="allowed-values">
        <xsl:choose>
            <xsl:when test="@allow-other and @allow-other='yes'">
                <p>The value may be locally defined, or one of the following:</p>
            </xsl:when>
            <xsl:otherwise>
                <p>The value must be one of the following:</p>
            </xsl:otherwise>
        </xsl:choose>
        <ul>
            <xsl:apply-templates/>
        </ul>   
    </xsl:template>
    
    <xsl:template match="allowed-values/enum">
        <li><strong><xsl:value-of select="@value"/></strong><xsl:if test="node()">: <xsl:apply-templates/></xsl:if></li>     
    </xsl:template>-->

    <xsl:template match="remarks">
        <div class="remarks">
            <xsl:apply-templates/>
        </div>
    </xsl:template>


    <xsl:template match="formal-name" expand-text="true">
        <p class="formal-name" style="font-family: sans-serif; font-weight: bold">{ . }</p>
    </xsl:template>

    <!--<xsl:template match="formal-name" mode="inline">
        <b class="formal-name">
            <xsl:apply-templates/>
        </b>
    </xsl:template>-->

    <xsl:template match="description">
        <p class="description">
            <xsl:apply-templates/>
        </p>
    </xsl:template>

    <!-- <xsl:template match="example/description">
        <p class="description">
            <xsl:apply-templates/>
        </p>
    </xsl:template>-->

    <!--<xsl:template match="example/remarks">
      <div class="remarks">
          <xsl:apply-templates/>
      </div>
   </xsl:template>-->

    <xsl:template match="p">
        <p class="p">
            <xsl:apply-templates/>
        </p>
    </xsl:template>


    <xsl:template match="code">
        <code>
            <xsl:apply-templates/>
        </code>
    </xsl:template>

    <xsl:template match="q">
        <q>
            <xsl:apply-templates/>
        </q>
    </xsl:template>

    <xsl:template match="em | strong | b | i | u">
        <xsl:element name="{local-name(.)}" namespace="http://www.w3.org/1999/xhtml">
            <xsl:apply-templates/>
        </xsl:element>
    </xsl:template>

    <xsl:template match="a">
        <a href="{@href}">
            <xsl:apply-templates/>
        </a>
    </xsl:template>



</xsl:stylesheet>