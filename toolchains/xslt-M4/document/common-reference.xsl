<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0"
   xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
   xmlns:xs="http://www.w3.org/2001/XMLSchema"
   xmlns="http://www.w3.org/1999/xhtml"
   xpath-default-namespace="http://csrc.nist.gov/ns/oscal/metaschema/1.0"
   xmlns:m="http://csrc.nist.gov/ns/oscal/metaschema/1.0"
   exclude-result-prefixes="#all">
   
   <xsl:import href="../metapath/docs-metapath.xsl"/>
   
   <xsl:template mode="produce-matching-constraints" match="constraint">
      <!-- $applying-to is the node to which the constraint applies (or not) - 
           by default the parent of the constraint
           but the template will be called for all the constraint's descendants as well -->
      <xsl:param name="applying-to" select="parent::*"/>
      <xsl:variable name="constraints" select=".//allowed-values | .//matches | .//has-cardinality | .//is-unique | .//index-has-key | .//index"/>
      <xsl:where-populated>
      <details>
         <summary>Constraints</summary>
         <xsl:apply-templates mode="produce-matching-constraints" select="$constraints">
            <xsl:with-param name="applying-to" select="$applying-to"/>
         </xsl:apply-templates>
      </details>
      </xsl:where-populated>
      
   </xsl:template>
   
   <xsl:template match="constraint//*" mode="produce-matching-constraints" expand-text="true">
      <xsl:param name="applying-to" select="parent::*"/>
      <xsl:variable name="apply-to-path" select="$applying-to/@_tree-xml-id/m:express-targets(.)"/>
      <xsl:variable name="target-path" select="(ancestor::constraint/parent::*/@_tree-xml-id, (@target,'.')[1]) => string-join('/')"/>

      <xsl:if test="m:any-match($apply-to-path, $target-path)">
         <xsl:apply-templates select="." mode="produce"/>
      </xsl:if>
      
   </xsl:template>
   
   
   <xsl:template match="constraint" mode="produce" expand-text="true">
      <xsl:variable name="constraints" select=".//allowed-values | .//matches | .//has-cardinality | .//is-unique | .//index-has-key | .//index"/>
      <xsl:for-each-group select="$constraints" group-by="true()">
         <details  open="open" class="constraint-set">
            <summary class="subhead"><span class="usa-tag">{ if (count($constraints) eq 1) then 'constraint' else 'constraints'}</span> defined in this context ({ count($constraints) }):</summary>
            <xsl:apply-templates select="current-group()" mode="#current"/>
         </details>
      </xsl:for-each-group>
   </xsl:template>
   
   <xsl:template mode="produce" priority="2" match="allowed-values" expand-text="true">
      <xsl:variable name="enums" select="enum"/>
      <div class="constraint">
         <p><span class="cnstr-tag">Allowed value{ 's'[count($enums) gt 1] }</span>
            <xsl:for-each select="@target[not(.=('.','value()')) ]">
               <xsl:text>  for </xsl:text>
               <span class="path">{ . }</span>
            </xsl:for-each>
            <xsl:text> defined on </xsl:text>
            <xsl:apply-templates select="." mode="report-context"/>
         </p>
         <xsl:choose expand-text="true">
            <xsl:when test="@allow-other and @allow-other = 'yes'">
               <p>The value <b>may be locally defined</b>, or { 'one of '[count($enums) gt 1] }the following:</p>
            </xsl:when>
            <xsl:otherwise>
               <p>The value <b>must</b> be one of the following:</p>
            </xsl:otherwise>
         </xsl:choose>
         <ul>
            <xsl:apply-templates mode="#current"/>
         </ul>
      </div>
   </xsl:template>
   
   <xsl:template match="*" mode="report-context" expand-text="true">
      <span class="path">{ ancestor::constraint/../@_tree-xml-id }</span>
   </xsl:template>
   
   <xsl:template match="allowed-values/enum" mode="produce">
      <li><strong><xsl:value-of select="@value"/></strong><xsl:if test="node()">: <xsl:apply-templates mode="#current"/></xsl:if></li>     
   </xsl:template>
   
   <xsl:template mode="produce" priority="2" match="matches[@regex]" expand-text="true">
      <xsl:variable name="target" select="@target[not(.=('.','value()'))]"/>
      <div class="constraint">
         <p>
            <span class="usa-tag">constraint</span>
            <xsl:apply-templates select="." mode="report-context"/>
            <span class="cnstr-tag">match</span>
            <xsl:text expand-text="true"> a target (value) must match the regular expression '{ @regex }'.</xsl:text></p>
      </div>
   </xsl:template>
   
   
   <xsl:template mode="produce" priority="2" match="matches[@datatype]" expand-text="true">
      <div class="constraint">
         <p>
            <span class="usa-tag">constraint</span>
            <xsl:apply-templates select="." mode="report-context"/>
            <span class="cnstr-tag">match</span>
            <xsl:text>the target value must match the lexical form of the '{ @datatype }' data type.</xsl:text></p>
      </div>
   </xsl:template>
   
   <xsl:template mode="produce" priority="2" match="is-unique">
      <xsl:variable name="target" select="@target[not(.=('.','value()'))]"/>
      <div class="constraint">
         <p>
            <span class="usa-tag">constraint</span>
            <xsl:apply-templates select="." mode="report-context"/>
            <span class="cnstr-tag">uniqueness rule</span>
            <xsl:text>: any target value must be unique (i.e., occur only once)</xsl:text>
         </p>
      </div>
   </xsl:template>
   
   <xsl:template mode="produce" priority="2" match="has-cardinality" expand-text="true">
      <div class="constraint">
         <p>
            <span class="usa-tag">constraint</span>
            <xsl:apply-templates select="." mode="report-context"/>
            <span class="cnstr-tag">cardinality rule</span>
            <xsl:text> the cardinality of  </xsl:text>
            <code>{ @target }</code>
            <xsl:text> is constrained: </xsl:text>
            <b>{ (@min-occurs,0)[1] }</b>
            <xsl:text>; maximum </xsl:text>
            <b>{ (@max-occurs,'unbounded')[1]}</b>.</p>
      </div>
   </xsl:template>
   
   <xsl:template mode="produce" priority="2" match="index-has-key" expand-text="true">
      <xsl:variable name="target" select="@target[not(.=('.','value()'))]"/>
      <div class="constraint">
         <p>
            <span class="usa-tag">constraint</span>
            <xsl:apply-templates select="." mode="report-context"/>
            <span class="cnstr-tag">index rule</span>
            <xsl:text>this value must correspond to a listing in the index </xsl:text>
            <code>{ @name }</code>
            <xsl:text> using a key constructed of key field(s) </xsl:text>
            <xsl:for-each select="key-field">
               <xsl:if test="position() gt 1">; </xsl:if>
               <code>
                  <xsl:value-of select="@target"/>
               </code>
            </xsl:for-each>
         </p>
      </div>
   </xsl:template>
   
   <xsl:template mode="produce" priority="2" match="index" expand-text="true">
      <div class="constraint">
         <p>
            <span class="usa-tag">constraint</span>
            <xsl:apply-templates select="." mode="report-context"/>
            <span class="cnstr-tag">index definition</span>
            <xsl:text> an index </xsl:text>
            <code>{ @name }</code>
            <xsl:text> shall list values returned by targets </xsl:text>
            <code>{ @target }</code>
            <xsl:text> using keys constructed of key field(s) </xsl:text>
            <xsl:for-each select="key-field">
               <xsl:if test="position() gt 1">; </xsl:if>
               <code>
                  <xsl:value-of select="@target"/>
               </code>
            </xsl:for-each>
         </p>
      </div>
   </xsl:template>
   
   
   <xsl:template match="description" mode="produce">
      <p class="description">
         <xsl:apply-templates/>
      </p>
   </xsl:template>
   
   <xsl:template match="remarks" mode="produce">
      <div class="remarks{ @class ! (' ' || .)}">
         <xsl:if test="@class='in-use'"><p class="nb">(In use)</p></xsl:if>
         <xsl:apply-templates/>
      </div>
   </xsl:template>
   
   <!-- in no mode, cast to XHTML namespace -->
   <xsl:template match="description//* | remarks//*">
      <xsl:element name="{ local-name() }" namespace="http://www.w3.org/1999/xhtml">
         <xsl:apply-templates/>
      </xsl:element>
   </xsl:template>
   
   <!-- XXX consolidate this w/ JSON code? -->
   <xsl:template mode="occurrence-code" match="*">
      <xsl:param name="require-member" select="false()"/>
      <xsl:variable name="minOccurs" as="xs:string">
         <xsl:choose>
            <xsl:when expand-text="true" test="$require-member">{ (@min-occurs[not(.='0')], '1')[1] }</xsl:when>
            <xsl:otherwise expand-text="true"                  >{ (@min-occurs, '0')[1] }</xsl:otherwise>
         </xsl:choose>
      </xsl:variable>
      <xsl:variable name="maxOccurs" as="xs:string">
         <xsl:choose>
            <xsl:when test="@max-occurs = 'unbounded'">&#x221e;</xsl:when>
            <xsl:otherwise expand-text="true">{ (@max-occurs, '1')[1] }</xsl:otherwise>
         </xsl:choose>
      </xsl:variable>
      <span class="cardinality">
         <xsl:text>[</xsl:text>
         <xsl:choose>
            <xsl:when test="$minOccurs = $maxOccurs" expand-text="true">{ $minOccurs }</xsl:when>
            <xsl:when test="number($maxOccurs) = number($minOccurs) + 1" expand-text="true">{ $minOccurs } or { $maxOccurs }</xsl:when>
            <xsl:otherwise expand-text="true">{ $minOccurs } to { $maxOccurs }</xsl:otherwise>
         </xsl:choose>
         <xsl:text>]</xsl:text>
      </span>
   </xsl:template>
   
   
</xsl:stylesheet>