<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0"
   xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
   xmlns:xs="http://www.w3.org/2001/XMLSchema"
   xmlns="http://www.w3.org/1999/xhtml"
   xpath-default-namespace="http://csrc.nist.gov/ns/oscal/metaschema/1.0"
   xmlns:m="http://csrc.nist.gov/ns/oscal/metaschema/1.0"
   exclude-result-prefixes="#all">

   <xsl:template match="/*">
      <div>
         <xsl:apply-templates/>
      </div>
   </xsl:template>
   
   <xsl:template match="schema-name"/>
   
   <xsl:template match="schema-version" expand-text="true">
      <h2><span class="usa-tag">Schema version:</span> { . }</h2>
   </xsl:template>
   
   <xsl:template match="*[exists(@key)]" expand-text="true">
      <xsl:variable name="level" select="count(ancestor-or-self::*[exists(@key)])"/>
      <div style="margin:0.2em; border: thin solid black; padding: 0.2em; padding-left: 1em">
         <xsl:element namespace="http://www.w3.org/1999/xhtml" name="h{ $level }">
            <xsl:attribute expand-text="true" name="style">margin: 0em</xsl:attribute>
            <xsl:attribute expand-text="true" name="id">{ generate-id() }</xsl:attribute>
            <xsl:attribute expand-text="true" name="class">toc{ $level}</xsl:attribute>
            <xsl:value-of select="@key"/>
            <xsl:text> ({ local-name() })</xsl:text>
         </xsl:element>
         <xsl:apply-templates select="." mode="produce-for-object"/>
      </div>
   </xsl:template>
   
   <xsl:template match="*" mode="produce-for-object" expand-text="true">
      <details style="padding-left: 1em">
         <summary>{ @formal-name }</summary>
         <p>(More about { @key } ...)</p>
      </details>
      <xsl:apply-templates select="*"/>
   </xsl:template>

   <xsl:template match="array" mode="produce-for-object" expand-text="true">
      <xsl:variable name="array-of" select="*[1]"/>
      <p>A sequence of { $array-of/@formal-name } { $array-of/name()}s</p>
      <details style="padding-left: 1em">
         <summary>{ $array-of/@formal-name }</summary>
         <p>(More about { $array-of/@name } ...)</p>
      </details>
      <xsl:apply-templates select="*"/>
   </xsl:template>
   
   
</xsl:stylesheet>
