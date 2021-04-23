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
   
   <xsl:template match="/*">
      <html>
         <head>
            <xsl:call-template name="hugo-css"/>
         </head>
         <body>
            <div id="toc">
               <xsl:apply-templates select="." mode="toc"/>
            </div>
            <main>
               <xsl:apply-templates/>   
            </main>
            
         </body>
      </html>
   </xsl:template>
   
   
   <xsl:template match="/div" name="toc-level" mode="toc">
      <ul class="toc">
         <xsl:apply-templates select="section" mode="#current"/>
      </ul>
   </xsl:template>
   
   <xsl:template match="section" mode="toc">
            <xsl:variable name="head" select="*[starts-with(@class,'toc')]"/>
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

div#toc { width: 24%; float: left; z-index: 2; position: fixed; overflow: scroll; height: 100% }
div#toc * { margin: 0em }

main { padding-left: 25% }

h1, h2, h3, h4, h5, h6 { font-family: monospace; font-size: 140%; font-weight: bold }

.json-obj { margin-top: 2em; border-top: thin solid black }

.json-obj * { margin-top: 0.4em }

.json-obj .json-obj { margin-top: 2em  }

.obj-name { font-family: sans-serif; font-weight: bold; font-size: 120% }

.obj-desc  { padding: 0.5em; border: thin dotted black; list-style-position: outside }    


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
 
</style>
   </xsl:template>
   

   
</xsl:stylesheet>
