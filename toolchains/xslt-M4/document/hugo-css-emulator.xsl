<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0"
   xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
   xmlns:xs="http://www.w3.org/2001/XMLSchema"
   xmlns="http://www.w3.org/1999/xhtml"
   xpath-default-namespace="http://www.w3.org/1999/xhtml"
   xmlns:m="http://csrc.nist.gov/ns/oscal/metaschema/1.0"
   exclude-result-prefixes="#all">

   <!-- produces an HTML 'stub' to be inserted into Hugo -->
   
   <xsl:mode on-no-match="shallow-copy"/>
   
   <xsl:param name="with-toc" as="xs:string">yes</xsl:param>
   
   <xsl:variable name="including-toc" select="not($with-toc=('no','0','false'))"/>
   
  <xsl:param name="metaschema-code" select="'oscal'"/>
  <xsl:param name="format" select="'xml'"/>
  
   <xsl:template match="/*">
      <html>
         <head>
            <xsl:call-template name="hugo-css"/>
         </head>
         <body>
           <div id="banner">
               <button class="nav-button"><a href="{ $metaschema-code }-{ $format }-outline.html">Outline</a></button>
               <button class="nav-button"><a href="{ $metaschema-code }-{ $format }-reference.html">Reference</a></button>
               <button class="nav-button"><a href="{ $metaschema-code }-{ $format }-index.html">Index</a></button>
               <button class="nav-button"><a href="{ $metaschema-code }-{ $format }-definitions.html">Definitions</a></button>
           </div>
            <xsl:if test="$including-toc">
               <div id="toc">
                  <xsl:apply-templates select="." mode="toc"/>
               </div>
            </xsl:if>
            <div id="main">
               <xsl:apply-templates/>
            </div>

         </body>
      </html>
   </xsl:template>
   
   
   <xsl:template match="/div" name="toc-level" mode="toc">
      <ul class="toc">
         <xsl:apply-templates select="section" mode="#current"/>
      </ul>
   </xsl:template>
   
   <xsl:template match="section" mode="toc">
     <xsl:variable name="head" select="*[starts-with(@class,'toc')] | *[@class='definition-header']/*[starts-with(@class,'toc')]"/>
            <li>
               <xsl:for-each select="$head" expand-text="true">
                  <p><a href="#{ $head/@id }">{ . }</a></p>
               </xsl:for-each>
               <xsl:where-populated>
                  <xsl:call-template name="toc-level"/>
               </xsl:where-populated>
            </li>
   </xsl:template>
     
   
   <xsl:template match="h1 | h2 | h3 | h4 | h5 | h6" priority="10">
      <xsl:copy>
         <xsl:copy-of select="@*"/>
         <xsl:apply-templates/>
      </xsl:copy>
   </xsl:template>
   
   <xsl:template match="*[matches(local-name(),'^h[0-9]+$')]">
      <h6>
         <xsl:copy-of select="@*"/>
         <xsl:apply-templates/>
      </h6>
   </xsl:template>

   <xsl:template name="hugo-css" xml:space="preserve">
<style type="text/css">

div#toc { width: 24%; float: left; z-index: 2; position: fixed; overflow: scroll; height: 100%; top: 3.5em }
div#toc * { margin: 0em }

div#banner { width: 100%; z-index: 2; position: fixed }
div#banner * { margin: 0em }

div#main { padding-left: 25%; top: 3.5em; position: absolute }

.xml-element, .xml-attribute, .json-obj { padding: 0.5em; border-top: thin solid black }

.xml-element, .xml-attribute .json-obj * { margin-top: 0.4em }

.xml-element .xml-element,
.xml-element .xml-attribute,
.json-obj .json-obj { margin-top: 1em; margin-left: 1em; padding-left: 1em; border-left: medium dotted darkgrey  }

.xml-element   .head,
.xml-attribute .head,
.json-obj      .head  { margin-top: 0em }

.obj-name { font-family: sans-serif; font-weight: bold; font-size: 120% }

.obj-desc p { margin: 0em }

.obj-matrix { background-color: #d9e8f6; padding: 0.4em;
    display: grid;
    grid-template-columns: 4fr 1fr 4fr 2fr;
    grid-gap: 0.5em;
    margin-top: 0.5em }

.occurrence { font-style: italic }

.path { font-family: monospace }

.nb { font-style: italic }

.usa-tag { font-family: sans-serif;
    font-size: .93rem;
    color: #fff;
    text-transform: uppercase;
    background-color: #565c65;
    border-radius: 2px;
    margin-right: .25rem;
    padding: 1px .5rem; }

<!-- ~~~ -->

.definition-header { background-color: #f0f0f0; padding: 0.5rem }
.defining          { color: #07648d }

button.schema-link { font-family: sans-serif;
    color: #fff;
    background-color: #005ea2;
    border-radius: .25rem;
    cursor: pointer;
    display: inline-block;
    font-weight: 700;
    margin-right: .5rem;
    padding: .75rem 1.25rem;
    text-align: center;
    text-decoration: none;
    width: 100%;}
    
summary { display: list-item; cursor: pointer; list-style-position: outside; margin-left: 1em }

.OM-entry summary { line-height: 1.5 }

summary:focus { outline: none }

.field-header, .assembly-header, .flag-header {
  clear: inherit;
}

.label { @extend .usa-tag }

li.model-entry h3 { margin: 0em }


h1, h2, h3, h4, h5, h6 { font-family: sans-serif ) }

body > div > section { margin-top: 1em }
.definition-header * { margin: 0em; clear: left }

.model-summary * { margin: 0em }

.crosslink { float: right }


/* Schema Model Map styles */

.OM-entry { font-family: monospace }

div.OM-map {
  margin-top: 0ex;
  margin-bottom: 0ex;
}

.OM-entry p { margin-top: 0em }

div.OM-map {
  hyphens: none;
  margin-left: 2em; }

div.OM-choice { margin-left: 4em; margin-top: 0em }

.OM-entry {
  padding-right: 0.5rem;
  margin-top: 0rem;
}

.OM-entry span.sq { display: inline-block }

.nobr { white-space: nowrap }

.OM-entry:hover {
}

div.OM-map p {
  margin: 0ex; }

div.OM-map > p:last-child { margin-left: -2em }

.OM-line { display: block
//  padding-left: 1em
}

.OM-lit {
  font-family: sans-serif;
  font-weight: normal;
  font-style: normal; }

span.OM-emph {
  font-family: sans-serif;
  font-weight: normal;
  font-style: italic; }

p.OM-entry > span { display: inline-block }

span.OM-cardinality {
  font-family: sans-serif;
  font-weight: normal;
  font-style: normal;
  @extend .text-base }

div.as-xml span.OM-cardinality {   padding-left: 1em }

p.indented { margin-left: 4em }

span.OM-datatype { font-family: sans-serif;
  font-style: italic;
  font-size: smaller }

.OM-name {
    font-style: normal;
    font-family: monospace;
  
   }

.OM-ref {
    @extend .text-primary;
    font-style: normal;
    font-size: 90%;
    font-family: monospace;
   }


.OM-map a {
  text-decoration: none }

.OM-gloss { font-style: italic }

OM-map a:visited {
  color: inherit }

a.OM-name:hover {
  text-decoration: underline; }

details[open] summary .show-closed {
    display: none; }

details:not([open]) summary .show-closed {
    display: inline; }


.define-assembly,
.define-field,
.define-flag { display: block
}

.formal-name {
  font-weight: bold;
  margin: 0.5em 0em
}

.syntax-boxes { display: flex; flex-direction: row; flex-wrap: wrap; gap: 1em }


.subhead {
    font-size: 80%;
    font-family: sans-serif;
 
}

.display-face {
font-family: sans-serif;
  }

.occurrence { @extend .font-sans-sm; font-style: italic }

.model {
    margin-top: 1em
}

.model .model {
    margin-top: 0.5ex
}

.example {
    margin-top: 1em
}

.code {
    display: inline;
}

.q {
    display: inline;
}
.em {
    display: inline;
}
.strong {
    display: inline;
}


a {
    text-decoration: none
}
a:hover {
    text-decoration: underline
}

ul.e_map {
  font-family: monospace;
  list-style-type: none;
  margin: 0em
}

.map_label {
  font-family: monospace;
  color: darkgrey
}

.model-descr div { margin: 0.5em 0em }
.model-summary { display: grid;
      grid-template-columns: 2fr 1fr 1fr 4fr;
      grid-gap: 0.5em; margin: 0em 0em 0.5em 0em }

.usename { font-family: monospace;
   }

.frmname { font-family: sans-serif; font-weight: bold }

.mtyp    { font-size: smaller }

.deflink { font-style: italic; font-size: smaller; font-family: sans-serif;  }
.deflink code { font-style: normal }

.name-link { @include u-font-family('mono'); font-weight: bold }

// div.constraints { }

div.constraint { font-size: smaller;
  @extend .border-base-light;
  @extend .bg-base-lightest;
  @extend .border-y;
  @extend .margin-top-05;
  @extend .padding-x-05;
    //    max-height: 2.6em;
    //    overflow: clip;
  }

// div.constraint:hover { max-height: unset; transition-duration: 2s }

div.constraint * { margin: 0em; }

.description {
//  @extend .bg-primary-lighter;
//  @extend .border-primary-darker;
  padding: 0.5em; font-size: 90% }

.global.description { display: block // keeping the syntax-checker quiet
//  @extend .bg-accent-cool-light;
//  @extend .border-accent-cool-dark
}

.model-entry .description {
    font-size: 80%;
    margin: 0em 0em
}

.nav-button {
        background-color: #005ea2;
        color: white;
        border-radius: .25rem;
        padding: .75rem 1.25rem;
        text-align: center;
        text-decoration: none;
        display: inline-block;
        font-family: sans-serif;
        margin: 0.2em;
        cursor: pointer }
        
.nav-button a,
.nav-button a.visited,
.nav-button a:hover { color: white }

</style>
   </xsl:template>
   

   
</xsl:stylesheet>
