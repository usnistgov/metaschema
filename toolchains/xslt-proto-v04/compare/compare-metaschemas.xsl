<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:math="http://www.w3.org/2005/xpath-functions/math"
    xmlns:m="http://csrc.nist.gov/ns/oscal/metaschema/1.0"
    xmlns="http://www.w3.org/1999/xhtml"
    
    expand-text="true"
    xpath-default-namespace="http://csrc.nist.gov/ns/oscal/metaschema/1.0"
    exclude-result-prefixes="#all"
    version="3.0">
    
    <xsl:param as="xs:string" name="new-label">[new]</xsl:param>
    <xsl:param as="xs:string" name="old-label">[old]</xsl:param>
    
    <xsl:variable name="new.label"><b class="new label">{ $new-label }</b></xsl:variable>
    <xsl:variable name="old.label"><b class="old label">{ $old-label }</b></xsl:variable>
    
    <xsl:template match="/" >
        <html>
            <style type="text/css">

body > * {{ margin-top: 1ex }}
details {{ padding: 0.5ex; border: thin solid black; margin-top: 0.5ex }}

.brief {{ font-size: smaller; border: thin solid black; padding: 1ex }}

.changed {{ background-color: pink }}
.new     {{ background-color: lemonchiffon }}

.same h4 {{ display: none }}


.label {{ font-family: sans-serif; font-weight: bold; font-size: 80% }}

            </style>
               <xsl:apply-templates/>
        </html>
    </xsl:template>
    
    <xsl:template match="compare" priority="5">
        <xsl:variable name="METASCHEMA1" select="METASCHEMA[1]"/>
        <body>
        <xsl:apply-templates select="$METASCHEMA1">
            <xsl:with-param tunnel="true" name="comparand" select="METASCHEMA except $METASCHEMA1"/>
        </xsl:apply-templates>
        </body>
    </xsl:template>
    
    <xsl:function name="m:definitions" as="element()*">
        <xsl:param name="metaschema" as="element(METASCHEMA)"/>
        <xsl:sequence select="$metaschema/(define-assembly | define-field | define-flag)"/>
    </xsl:function>
    
    <!-- Matches only top-level declarations -->
    <xsl:key name="correspondents-by-name"
        match="METASCHEMA/define-assembly | METASCHEMA/define-flag | METASCHEMA/define-field" use="@name">
        
    </xsl:key>
    <xsl:template match="METASCHEMA">
        <xsl:param tunnel="true" name="comparand" as="element(METASCHEMA)"/>
        <xsl:variable name="new" select="."/>
        <xsl:variable name="old" select="$comparand"/>
        
        <div class="summary">
            <p class="brief">Comparing { short-name}:{ schema-version } ('{ $new.label }') with {$comparand ! (short-name || ':' || schema-version) } ('{ $old.label }') </p>
            <xsl:for-each-group group-by="true()" select="m:definitions($old)[not(@name=m:definitions($new)/@name)]">
                <div>
                    <h5>Found in { $old.label} not { $new.label }: { string-join(current-group()/@name,', ')} </h5>
                </div>
            </xsl:for-each-group>
            <xsl:for-each-group group-by="true()" select="m:definitions($new)[not(@name=m:definitions($old)/@name)]">
                <div>
                    <h5>Found in { $new.label} not { $old.label}: { string-join(current-group()/@name,', ')} </h5>
                </div>
            </xsl:for-each-group>
            <xsl:for-each-group group-by="true()" select="$old/define-assembly">
                <div>
                    <h5>Assemblies in { $old.label}: { string-join(current-group()/(root-name,use-name,@name)[1],' ') } </h5>
                </div>
            </xsl:for-each-group>
            <xsl:for-each-group group-by="true()" select="$new/define-assembly">
                <div>
                    <h5>Assemblies in { $new.label}: { string-join(current-group()/(root-name,use-name,@name)[1],' ')} </h5>
                </div>
            </xsl:for-each-group>
            <xsl:for-each-group group-by="true()" select="($old | $new)/define-assembly">
                <div>
                    <h5>Assemblies in either/both: { string-join(distinct-values( current-group()/(root-name,use-name,@name)[1]), ' ')} </h5>
                </div>
            </xsl:for-each-group>
            
            <xsl:apply-templates/>
        </div>
    </xsl:template>
    
    <xsl:template match="METASCHEMA/*"/>
    
    <xsl:template priority="2" match="METASCHEMA/schema-name | METASCHEMA/short-name">
        <p class="{local-name()}">
            <xsl:apply-templates/>
        </p>
    </xsl:template>
    
    <xsl:key name="global-by-name" match="define-assembly | define-field | define-flag" use="@name"/>
    
    <xsl:template match="define-flag" priority="2">
        <xsl:param tunnel="true" name="comparand" as="element(METASCHEMA)"/>
        <xsl:variable name="me" select="."/>
        <xsl:variable name="partner" select="$comparand/key('global-by-name',$me/@name,.)" as="element()?"/>
        <xsl:variable name="new.sig" select="m:signature($me)"/>
        <xsl:variable name="old.sig" select="$partner/m:signature(.)"/>
        <xsl:variable name="status">
            <xsl:choose>
                <xsl:when test="empty($partner)">new</xsl:when>
                <xsl:when test="$new.sig = $old.sig">same</xsl:when>
                <xsl:otherwise>changed</xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <details id="flag_{@name}" class="matched-{count($partner)} { $status }">
            <summary><code>{ @name }</code>: { formal-name } { @as-type ! (' as type ' || .) } </summary>
 
        </details>
    </xsl:template>
    
    <xsl:template match="define-assembly | define-field" priority="2">
        <xsl:param tunnel="true" name="comparand" as="element(METASCHEMA)"/>
        <xsl:variable name="me" select="."/>
        <xsl:variable name="partner" select="$comparand/key('global-by-name',$me/@name,.)" as="element()?"/>
        <xsl:variable name="new.sig" select="m:signature($me)"/>
        <xsl:variable name="old.sig" select="$partner/m:signature(.)"/>
        <xsl:variable name="status">
            <xsl:choose>
                <xsl:when test="empty($partner)">new</xsl:when>
                <xsl:when test="$new.sig = $old.sig">same</xsl:when>
                <xsl:otherwise>changed</xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <details id="assembly_{@name}" class="matched-{count($partner)} { $status }">
            <summary><code>{ @name }</code>: { formal-name } { @as-type ! (' with value type ' || .) } </summary>
            
            <div>
                <div class="comparison">
                    <xsl:if test="exists($partner)">
                    <p class="was">
                        <span class="label">{ $old.label } flag{ if (count($partner/flag) eq 1) then '' else 's' }: </span>
                        <xsl:apply-templates select="$partner/flag">
                            <xsl:with-param name="partner" select="$me" tunnel="true"/>
                        </xsl:apply-templates>
                        <xsl:if test="empty($partner/flag)"> [none]</xsl:if>
                    </p>
                    </xsl:if>
                    <p class="now">
                        <span class="label">{ $new.label } flag{ if (count($me/flag) eq 1) then '' else 's' }: </span>
                        <xsl:apply-templates select="$me/flag">
                            <xsl:with-param name="partner" select="$partner" tunnel="true"/>
                            <xsl:with-param name="tag-as" tunnel="true">**$1**</xsl:with-param>
                        </xsl:apply-templates> 
                        <xsl:if test="empty($me/flag)"> [none]</xsl:if>
                    </p>
                </div>
                <xsl:for-each select="self::define-assembly">
                        <div class="comparison">
                            <xsl:if test="exists($partner)">
                                <p class="was">
                            <span class="label">{ $old.label } model: </span>
                            <xsl:apply-templates select="$partner/model">
                                <xsl:with-param name="partner" select="$me" tunnel="true"/>
                            </xsl:apply-templates>
                        </p>
                            </xsl:if>
                        <p class="now">
                            <span class="label">{ $new.label } model: </span>
                            <xsl:apply-templates select="$me/model">
                                <xsl:with-param name="partner" select="$partner" tunnel="true"/>
                                <xsl:with-param name="tag-as" tunnel="true">**$1**</xsl:with-param>
                            </xsl:apply-templates>
                        </p>
                    </div>
                </xsl:for-each>
            </div>
            <!--<xsl:apply-templates select="model"/>
            <xsl:choose>
                <xsl:when test="$status='new'"><h4>New in { $new.label }</h4></xsl:when>
                <xsl:otherwise>
                    <h4>{ $old.label } signature: <code class="sig old">{ $old.sig }</code></h4>
                    <h4>{ $new.label } signature: <code class="sig old">{ $old.sig }</code></h4>
                </xsl:otherwise>
            </xsl:choose>-->
            
        </details>
    </xsl:template>
    
    <xsl:template match="model">
             <xsl:apply-templates/>
    </xsl:template>
    
    <xsl:template priority="5" match="model//choice">
        (<i>A choice:</i>
                <xsl:apply-templates/>
            )
    </xsl:template>
    
    <xsl:template match="model//* | flag">
        <xsl:param tunnel="true" name="partner" select="()"/>
        <xsl:param tunnel="true" name="tag-as" select="'*$1*'"/>
        <xsl:variable name="n" select="@ref | @name"/>
        <xsl:variable name="tagged-name" as="xs:string">
            <xsl:choose>
                <xsl:when test="empty($partner//*[(@name | @ref) = $n])">
                    <xsl:sequence select="replace($n, '^(.+)$', $tag-as)"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:sequence select="string($n)"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:if test="not(position() eq 1)">, </xsl:if>
        <xsl:value-of select="$tagged-name"/>
        <xsl:apply-templates select="." mode="cardinality"/>
        <xsl:if test="empty(self::flag)">
            <xsl:text> ({ local-name() })</xsl:text>
        </xsl:if>
    </xsl:template>
    
    <xsl:template mode="cardinality" match="*[@min-occurs='0' or empty(@min-occurs)][@max-occurs='unbounded']">\*</xsl:template>
    <xsl:template mode="cardinality" match="*[@min-occurs='1'][@max-occurs='unbounded']">*</xsl:template>
    <xsl:template mode="cardinality" match="*[@min-occurs='0' or empty(@min-occurs)][empty(@max-occurs) or @max-occurs='1']">?</xsl:template>
    <xsl:template mode="cardinality" match="*[@min-occurs='1'][empty(@max-occurs) or @max-occurs='1']"/>
    <xsl:template mode="cardinality" match="*">[{@min-occurs}-{@max-occurs}]</xsl:template>
    
    <xsl:function name="m:signature" as="xs:string">
        <xsl:param name="whose" as="element()"/>
        <xsl:value-of>
            <xsl:sequence select="substring-after(name($whose), 'define-')"/>
            <xsl:text>:</xsl:text>
            <xsl:sequence select="$whose/@name"/>
            <xsl:text>|</xsl:text>
            <xsl:sequence select="string-join(( $whose/(flag/@ref | define-flag/@name) ),':')"/>
            <xsl:text>|</xsl:text>
            <xsl:sequence
                select="string-join(( $whose/(model//assembly/@ref | model/field/@ref | model/define-assembly/@name | model/define-field/@name) ),':')"/>
            <xsl:sequence select="$whose/@as-type/string()"/>
        </xsl:value-of>
    </xsl:function>
    
</xsl:stylesheet>