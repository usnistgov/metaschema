<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:anthology="http://csrc.nist.gov/metaschema/ns/anthology"
                xmlns="http://www.w3.org/1999/xhtml"
                version="1.0">

<!-- XSLT produced from Metaschema ... -->
   <xsl:template match="/">
      <html>
         <head>
            <title>Anthology Metaschema [display]</title>
            <xsl:call-template name="css"/>
         </head>
         <body>
            <xsl:apply-templates/>
         </body>
      </html>
   </xsl:template>
   <xsl:template mode="asleep" match="anthology:ANTHOLOGY">
      <div class="ANTHOLOGY">
         <xsl:apply-templates/>
      </div>
   </xsl:template>
   <xsl:template mode="asleep" match="anthology:meta">
      <div class="meta">
         <xsl:apply-templates/>
      </div>
   </xsl:template>
   <xsl:template mode="asleep" match="anthology:remarks">
      <div class="remarks">
         <xsl:apply-templates/>
      </div>
   </xsl:template>
   <xsl:template mode="asleep" match="anthology:piece">
      <div class="piece">
         <xsl:apply-templates/>
      </div>
   </xsl:template>
   <xsl:template mode="asleep" match="anthology:verse">
      <div class="verse">
         <xsl:apply-templates/>
      </div>
   </xsl:template>
   <xsl:template mode="asleep" match="anthology:stanza">
      <div class="stanza">
         <xsl:apply-templates/>
      </div>
   </xsl:template>
   <xsl:template mode="asleep" match="anthology:prose">
      <div class="prose">
         <xsl:apply-templates/>
      </div>
   </xsl:template>
   <xsl:template mode="asleep" match="anthology:back">
      <div class="back">
         <xsl:apply-templates/>
      </div>
   </xsl:template>
   <xsl:template mode="asleep" match="anthology:author-index">
      <div class="author-index">
         <xsl:apply-templates/>
      </div>
   </xsl:template>
   <xsl:template mode="asleep" match="anthology:author">
      <div class="author">
         <xsl:apply-templates/>
      </div>
   </xsl:template>
   <xsl:template mode="asleep" match="anthology:creator">
      <p class="creator">
         <xsl:apply-templates/>
      </p>
   </xsl:template>
   <xsl:template mode="asleep" match="anthology:line">
      <p class="line">
         <xsl:apply-templates/>
      </p>
   </xsl:template>
   <xsl:template mode="asleep" match="anthology:name">
      <p class="name">
         <xsl:apply-templates/>
      </p>
   </xsl:template>
   <xsl:template mode="asleep" match="anthology:dates">
      <p class="dates">
         <xsl:apply-templates/>
      </p>
   </xsl:template>
   <xsl:template mode="asleep" match="anthology:publication">
      <p class="publication">
         <xsl:apply-templates/>
      </p>
   </xsl:template>
   <xsl:template name="css">
      <style type="text/css">
html, body { font-size: 10pt }
div { margin-left: 1rem }
.tag { color: green; font-family: sans-serif; font-size: 80%; font-weight: bold }
.UNKNOWN { color: red; font-family: sans-serif; font-size: 80%; font-weight: bold }
.UNKNOWN .tag { color: darkred }


.meta {  }

.piece {  }

.back {  }

.creator {  }

.remarks {  }

.verse {  }

.prose {  }

.line {  }

.stanza {  }

.author-index {  }

.author {  }

.name {  }

.dates {  }

.publication {  }

</style>
   </xsl:template>
   
   
   
   <xsl:template priority="-0.4"
                 match="anthology:ANTHOLOGY | anthology:meta | anthology:remarks | anthology:piece | anthology:verse | anthology:stanza | anthology:prose | anthology:back | anthology:author-index | anthology:author">
      <div class="{name()}">
         <div class="tag">
            <xsl:value-of select="name()"/>: </div>
         <xsl:apply-templates/>
      </div>
   </xsl:template>
   <xsl:template priority="-0.4"
                 match="anthology:creator | anthology:line | anthology:name | anthology:dates | anthology:publication">
      <p class="{name()}">
         <span class="tag">
            <xsl:value-of select="name()"/>: </span>
         <xsl:apply-templates/>
      </p>
   </xsl:template>
   <!-- mapping HTML subset permitted in markup-multiline elements -->
   <xsl:template priority="1" match="anthology:remarks//* | anthology:prose//*">
      <xsl:element name="{local-name()}" namespace="http://www.w3.org/1999/xhtml">
         <xsl:copy-of select="@*"/>
         <xsl:apply-templates/>
      </xsl:element>
   </xsl:template>
   <xsl:template priority="2" match="anthology:insert">
      <xsl:text>[INSERT </xsl:text>
      <xsl:value-of select="@param-id"/>
      <xsl:text>]</xsl:text>
   </xsl:template>
   <!-- fallback logic catches strays -->
   <xsl:template match="*">
      <p class="UNKNOWN {name()}">
         <span class="tag">
            <xsl:value-of select="name()"/>: </span>
         <xsl:apply-templates/>
      </p>
   </xsl:template>
</xsl:stylesheet>
