<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet  version="3.0"
xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
xmlns:xs="http://www.w3.org/2001/XMLSchema"
xmlns:m="http://csrc.nist.gov/ns/oscal/metaschema/1.0"
xmlns="http://www.w3.org/1999/xhtml"

xpath-default-namespace="http://csrc.nist.gov/ns/oscal/metaschema/1.0"
exclude-result-prefixes="#all">

<xsl:output indent="true"/>
   
   <xsl:import href="../common-definitions.xsl"/>
    
   <xsl:param name="json-definitions-page">json/definitions</xsl:param>
   <xsl:param name="xml-definitions-page">xml/definitions</xsl:param>
   
   <xsl:template match="METASCHEMA/namespace"/>
   
   <xsl:template match="METASCHEMA/json-base-uri" expand-text="true">
      <p>
         <span class="usa-tag">JSON Base URI</span>
         <xsl:text> </xsl:text>
         <code>{ . }</code>
      </p>
   </xsl:template>
   
   <xsl:template match="short-name" mode="schema-link" expand-text="true">
      <p>
         <span class="usa-tag">JSON Schema</span>
         <xsl:text> </xsl:text>
         <a
            href="/artifacts/json/schema/oscal_{$file-map(.)}_schema.json"
            >oscal_{$file-map(string(.))}_schema.json</a>
      </p>
   </xsl:template>
   
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
   
   
   
<!-- fields with flags become objects with properties, one of which holds the nominal
     field value - it is represented by a proxy -->
   <xsl:template match="define-field[exists(flag|define-flag)]" mode="model">
      <xsl:variable name="level" select="count(. | ancestor::define-assembly | ancestor::define-field)"/>
      <xsl:variable name="value-name" as="xs:string">
         <xsl:apply-templates select="." mode="get-field-value-name"/>
      </xsl:variable>
      <xsl:variable as="element()" name="value-property-proxy" expand-text="true">
         <m:define-flag name="{$value-name}" value-proxy="true" required="yes">
            <xsl:attribute name="_metaschema-json-id" select="@_metaschema-json-id || '/' || $value-name"/>
            <xsl:copy-of select="@as-type | @_metaschema-xml-id"/>
            <m:formal-name>{ formal-name } Value</m:formal-name>
            <xsl:apply-templates select="." mode="get-field-value-description"/>
         </m:define-flag>
   </xsl:variable>
      <xsl:variable name="metaschema-type" select="'field'"/>
      <xsl:for-each-group select="flag | define-flag | $value-property-proxy" group-by="true()" expand-text="true">
         <details open="open">
            <summary>{ if (count(current-group()) ne 1) then 'Properties' else 'Property' } ({ count(current-group()) })</summary>
            <div class="model { $metaschema-type }-model">
               <xsl:apply-templates select="current-group()" mode="model-view">
                  <!-- we pass in $level so the proxy has one -->
                  <xsl:with-param name="level" select="$level + 1"/>
               </xsl:apply-templates>
            </div>
         </details>
      </xsl:for-each-group>
   </xsl:template>
   
   <xsl:template match="*" mode="get-field-value-name" as="xs:string">STRVALUE</xsl:template>
   
   <xsl:template match="*[@as-type=('markup-line','markup-multiline')]" mode="get-field-value-name" as="xs:string">RICHTEXT</xsl:template>
   
   <xsl:template match="*[exists(json-value-key)]" mode="get-field-value-name" as="xs:string">
      <xsl:value-of select="json-value-key"/>   
   </xsl:template>
   
   <xsl:template priority="2" match="*[exists(json-value-key/@flag-name)]" mode="get-field-value-name"  as="xs:string">
      <xsl:value-of select="'{' || json-value-key/@flag-name || '}'"/>
   </xsl:template>
   
   <xsl:template match="*" mode="get-field-value-description">
      <m:description>This property provides the (nominal) value for this object as a whole.</m:description>
   </xsl:template>
   
   <xsl:template priority="2" match="*[exists(json-value-key/@flag-name)]" mode="get-field-value-description">
      <m:description>A property whose name is distinct from assigned properties for this object is taken as its (nominal) value, while its key is taken to be the value of the <code><xsl:value-of select="json-value-key/@flag-name"/></code> property.</m:description>
   </xsl:template>
   
   <xsl:template match="short-name" mode="converter-link" expand-text="true">
      <p>
         <span class="usa-tag">XML to JSON converter</span>
         <xsl:text> </xsl:text>
         <a href="/artifacts/json/convert/oscal_{$file-map(.)}_xml-to-json-converter.xsl"
            >oscal_{$file-map(string(.))}_xml-to-json-converter.xsl</a>
         <xsl:text> </xsl:text>
         <a href="https://github.com/usnistgov/OSCAL/tree/main/json#converting-oscal-xml-content-to-json"
            >(How do I use the converter to convert OSCAL XML to JSON)</a>
      </p>
   </xsl:template>
   
   <xsl:template name="reference-class">
      <xsl:attribute name="class">json-definition</xsl:attribute>
   </xsl:template>
   
   <xsl:template name="mark-id">
      <xsl:attribute name="id" select="@_metaschema-json-id"/>
   </xsl:template>
    
   <!-- writes '../' times the number of steps in $outline-page  -->
   <xsl:variable name="path-to-common">
      <xsl:for-each select="tokenize($xml-definitions-page,'/')">../</xsl:for-each>
   </xsl:variable>
   <xsl:variable name="xml-definitions-link" select="$path-to-common || $xml-definitions-page"/>
   
   <xsl:template name="remarks-group">
      <xsl:param name="these-remarks" select="child::remarks" as="element(remarks)*"/>
      <xsl:for-each-group select="$these-remarks[not(contains-token(@class,'xml'))]" group-by="true()">
         <div class="remarks-group usa-prose">
            <details open="open">
               <summary class="subhead">Remarks</summary>
               <xsl:apply-templates select="current-group()" mode="produce"/>
            </details>
         </div>
      </xsl:for-each-group>
   </xsl:template>
   
   <xsl:template match="group-as" expand-text="true">
      <p><span class="usa-tag">group as</span>&#xA0;<code class="name">{ @name }</code></p>
   </xsl:template>
   
   <xsl:template match="assembly" mode="link-to-definition">
      <xsl:variable name="definition" select="key('assembly-definition-by-name',@_key-ref)"/>
      <p class="definition-link">
         <a href="#{$definition/@_metaschema-json-id}">See definition</a>
      </p>
   </xsl:template>
   
   <xsl:template match="field" mode="link-to-definition">
      <xsl:variable name="definition" select="key('field-definition-by-name',@_key-ref)"/>
      <p class="definition-link">
         <a href="#{$definition/@_metaschema-json-id}">See definition</a>
      </p>
   </xsl:template>
   
   <xsl:template match="flag" mode="link-to-definition">
      <xsl:variable name="definition" select="key('flag-definition-by-name',@_key-ref)"/>
      <p class="definition-link">
         <a href="#{$definition/@_metaschema-json-id}">See definition</a>
      </p>
   </xsl:template>
   
   <!-- Crosslink heads to XML page  -->
   <xsl:template name="crosslink">
      <div class="crosslink">
         <a class="usa-button" href="{$xml-definitions-link}#{@_metaschema-xml-id}">Switch to XML</a>
      </div>
   </xsl:template>
   
   <xsl:template mode="metaschema-type" match="define-assembly">
      <xsl:text expand-text="true">assembly</xsl:text><br class="br" />
      <xsl:text> </xsl:text>
   </xsl:template>
   
   <xsl:template mode="metaschema-type" match="assembly | field | flag">
      <xsl:variable name="definition" as="element()">
         <xsl:apply-templates select="." mode="find-definition"/>
      </xsl:variable>
      <xsl:apply-templates select="$definition" mode="metaschema-type"/>
      <br class="br"/>
      <xsl:if test="exists($definition)">
         <xsl:text> </xsl:text>
         <a class="definition-link" href="#{ @_metaschema-json-id }">(global definition)</a>
      </xsl:if>
   </xsl:template>
   
   <xsl:template match="*" mode="report-context" expand-text="true">
      <xsl:for-each select="@target[matches(.,'\S')][not(.=('.','value()')) ]">
         <xsl:text> for </xsl:text>
         <code class="path">{ . }</code>
      </xsl:for-each>
   </xsl:template>
   
</xsl:stylesheet>