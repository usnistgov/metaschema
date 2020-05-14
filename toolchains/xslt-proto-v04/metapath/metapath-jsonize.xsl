<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
                      xmlns="http://csrc.nist.gov/ns/oscal/metaschema/1.0"
                    xmlns:m="http://csrc.nist.gov/ns/oscal/metaschema/1.0"
    xpath-default-namespace="http://csrc.nist.gov/ns/oscal/metaschema/1.0"
    xmlns:p="metapath01"
    exclude-result-prefixes="#all"
    expand-text="true">
    
    <xsl:import href="parse-metapath.xsl"/>
<!--
     Supports rewriting XPath expressions addressing XML as paths into equivalent JSON
       based on a Metaschema mapping given as a definition map
     
     KEEPING IN MIND THAT ANY STEP OR PATH MAY RETURN SEVERAL EQUIVALENTS
       and that paths must be metaschema-context-aware
       
     x Deliver the equivalent step for a step
       assemblies
         ungrouped
         grouped
           both as singletons, and in arrays
           in arrays only
         grouped by key
       fields
         ungrouped
           without flags (strings)
           with flags (maps)
         grouped
           both singletons, and in arrays
             without flags (strings)
             with flags (maps)
           in arrays only
             without flags (strings)
             with flags (maps)
         grouped by key
           without flags not the key flag (strings)
           with flags (maps)
       flags
         appearing explicitly
         appearing as keys

     o deliver the equivalent path for a path
         steps interpolated with axes
         steps inside predicates (filter expressions)
         support recursion e.g. paths like 'sequence/group/sequence/group/sequence'
    
    -->
    
    <xsl:output indent="yes"/>
    
    <xsl:key name="obj-by-gi" match="*" use="@gi"/>
    <xsl:key name="obj-by-gi" match="/model" use="'/'"/>
    
    <!--TYPES OF OBJECTS
      standalone assemblies and fields (singletons)
        bring back field value objects (strings), not field objects
      standalone flags (same, but @ in XML)
      assembly and field members of groups
        both arrays and objects, or addressed by key
        
      edge cases ...
       for terminal steps in a path to a field, traversal to the field value....
       when a json-key is given, traversal to its flag should return the key
       when a json-value-key is given, traversal to the field value must be provided
        
        -->
    
    <xsl:param name="px" as="xs:string">j</xsl:param>
    
    <xsl:param name="definition-map" select="document('../testing/tiny_definition-map.xml')"/>
    
    <!-- We have to detect wildcards on path steps with no node name (XML GI) -->
    <xsl:variable name="wildcard" as="xs:string+" select="'*','node()'"/>
    
    <xsl:variable name="tests">
        <test>string-field</test>
        <test>object-field</test>
        <!--<test>//EVERYTHING//field-by-key</test>
        <test>field-groupable[with-child/grandchild and x]</test>
        <test>assembly-by-key</test>
        <test>/</test>                <!-\- returns /map-\->
        <test>field-boolean</test>                <!-\- returns /map-\->
        <test>id</test>                <!-\- returns /map-\->
        <test>EVERYTHING</test>       <!-\- returns map[@key='EVERYTHING'] -\->
        <test>field-1only</test>      <!-\- returns *[@key='field-1only'] or string[@key='field-1only']-\->
        <test>field-named-value</test><!-\- returns map[@key='field-named-value']/string[@key='CUSTOM-VALUE-KEY'] -\->
        <test>X</test><!-\- returns nada -\->-->
    </xsl:variable>
    
    <xsl:template match="/">
        <all-tests>
          <xsl:apply-templates select="$tests" mode="testing"/>
        </all-tests>
    </xsl:template>
    
    <!-- testing steps only -->
    <!--<xsl:template match="test" mode="testing">
        <xsl:variable name="every" as="element()*">
            <xsl:apply-templates select="key('obj-by-gi',.,$map)" mode="cast-node-test"/>
        </xsl:variable>
        <test expr="{.}">
            <xsl:for-each-group select="$every" group-by="string(.)">
                <xsl:sequence select="."/>
            </xsl:for-each-group>
            
            <!-\-<xsl:sequence select="p:parse-XPath(.)"/>-\->
        </test>
    </xsl:template>-->
    
    <xsl:template match="test" mode="testing">
        <xsl:variable name="map" select="m:path-map(string(.))"/>
            <test expr="{.}" expand="{string($map)}">
                <xsl:sequence select="m:jsonize-path(.)"/>
                <!--<xsl:sequence select="p:parse-XPath(.)"/>-->
        </test>
    </xsl:template>
    
    <xsl:template match="/model" mode="cast-node-test">
        <expr>/{$px}:map</expr>
    </xsl:template>
    
    <xsl:template match="assembly[exists(@key)]" mode="cast-node-test">
        <expr>{$px}:map[@key='{@key}']</expr>
    </xsl:template>
    
    <xsl:template match="group[@group-json='BY_KEY']/assembly" mode="cast-node-test">
        <expr>{$px}:*[@key='{../@key}']/{$px}:map</expr>
    </xsl:template>
    
    <xsl:template match="group[@group-json='ARRAY']/assembly" mode="cast-node-test">
        <expr>{$px}:array[@key='{../@key}']/{$px}:map</expr>
    </xsl:template>
    
    <!-- Catches assembly grouped as SINGLETON-OR-ARRAY -->
    <xsl:template match="assembly" mode="cast-node-test">
        <expr>{$px}:assembly[@key='{../@key}']/{$px}:map</expr>
        <expr>{$px}:map[@key='{../@key}']</expr>
    </xsl:template>
    
    <xsl:template match="field[exists(@key)]" mode="cast-node-test">
        <xsl:variable name="type">
            <xsl:apply-templates select="." mode="object-type"/>
        </xsl:variable>
        <expr>{$px}:{$type}[@key='{@key}']</expr>
    </xsl:template>
    
    <xsl:template match="group[@group-json='BY_KEY']/field" mode="cast-node-test">
        <xsl:variable name="type">
            <xsl:apply-templates select="." mode="object-type"/>
        </xsl:variable>
        <expr>{$px}:*[@key='{../@key}']/{$px}:{$type}</expr>
    </xsl:template>
    
    <xsl:template match="group[@group-json='ARRAY']/field" mode="cast-node-test">
        <xsl:variable name="type">
            <xsl:apply-templates select="." mode="object-type"/>
        </xsl:variable>
        <expr>{$px}:array[@key='{../@key}']/{$px}:{$type}</expr>
    </xsl:template>
    
    <!-- Catches assembly grouped as SINGLETON-OR-ARRAY -->
    <xsl:template match="field" mode="cast-node-test">
        <xsl:variable name="type">
            <xsl:apply-templates select="." mode="object-type"/>
        </xsl:variable>
        <expr>{$px}:assembly[@key='{../@key}']/{$px}:{$type}</expr>
        <expr>{$px}:{$type}[@key='{../@key}']</expr>
    </xsl:template>
    
    <xsl:template match="flag" mode="cast-node-test">
        <xsl:variable name="type">
            <xsl:apply-templates select="." mode="object-type"/>
        </xsl:variable>
        <expr>{$px}:{$type}[@key='{@key}']</expr>
    </xsl:template>
    
    <xsl:template match="flag[@key = ../@json-key-flag]" mode="cast-node-test">
        <xsl:variable name="grandparent-type">
            <xsl:apply-templates select="../.." mode="object-type"/>
        </xsl:variable>
        <xsl:variable name="parent-type">
            <xsl:apply-templates select=".." mode="object-type"/>
        </xsl:variable>
        
        <expr>{$px}:{$grandparent-type}[@key='{../../@key}']/{$px}:{$parent-type}/@key</expr>
    </xsl:template>
    
    <xsl:template match="*" mode="cast-node-test">
        <expr>{$px}:*[@key='{../@key}']</expr>
    </xsl:template>
    
    <!-- object-type returns
      map for any field with flags not designated as json-key-flag
      appropriate data type for any other fields or flags (string, number, boolean)-->
      
    <xsl:template match="*" mode="object-type">map</xsl:template>

    <xsl:template match="field[flag/@key != @json-key-flag]" mode="object-type">map</xsl:template>
    
    <xsl:template match="field" mode="object-type">
      <xsl:apply-templates select="value/@as-type" mode="json-type"/>
    </xsl:template>
    
    <xsl:template match="flag" mode="object-type">
        <xsl:apply-templates select="@as-type" mode="json-type"/>
    </xsl:template>
    
    <!-- In the JSON representation all values are strings unless mapped otherwise. -->
    <xsl:template match="@as-type" mode="json-type">string</xsl:template>
    
    <xsl:template match="@as-type[. = 'boolean']" mode="json-type">boolean</xsl:template>
    
    <xsl:variable name="integer-types" as="element()*">
        <type>integer</type>
        <type>positiveInteger</type>
        <type>nonNegativeInteger</type>
    </xsl:variable>
    
    <xsl:template match="@as-type[. = $integer-types]" mode="json-type">integer</xsl:template>
    
    <xsl:variable name="numeric-types" as="element()*">
        <type>decimal</type>
    </xsl:variable>
    
    <xsl:template match="@as-type[. = $numeric-types]" mode="json-type">number</xsl:template>
    
    
    <xsl:function name="m:path-map" as="element()*">
        <xsl:param name="expr"/>
        <xsl:variable name="parse.tree" select="p:parse-XPath($expr)"/>
        <xsl:apply-templates select="$parse.tree" mode="path-map"/>
    </xsl:function>
    
    
    <!--<xsl:template mode="find-target" match="*">
        <xsl:param name="from" as="node()" required="yes"/>
        <xsl:sequence select="$from"/>
    </xsl:template>-->
    
    <!-- Given a string, returns the same string with its
    node tests cast into the JSONized equivalent.
    
    It does this by passing into map-path mode, which performs
    a sibling traversal over steps represented in the reduced parse tree
    (path map).
    Nodes in the declaration map are passed through to provide
    execution context for finding each step.
    
    NB for any path, several or no JSONized paths may be returned -
    only paths viable in the metaschema (represented in the map)
    come back, but there can be multiple. -->
    <!--XXXX-->
    <xsl:function name="m:jsonize-path" as="xs:string">
        <xsl:param name="metapath" as="xs:string" required="yes"/>
        <xsl:variable name="path-map" select="m:path-map($metapath)"/>
        <xsl:variable name="alternatives" as="xs:string*">
            <xsl:apply-templates select="$path-map" mode="cast-path"/>
        </xsl:variable>
        <xsl:value-of select="string-join($alternatives,' | ')"/>
    </xsl:function>
    
    <!-- An absolute path starts from the top -->
    <xsl:template mode="cast-path" match="alternative[starts-with(.,'/')]">
        <xsl:apply-templates mode="#current" select="path/step[1]">
            <xsl:with-param name="from" select="$definition-map/*"/>
        </xsl:apply-templates>
    </xsl:template>
    
    <!-- An relative path starts from the top -->
    <xsl:template mode="cast-path" match="alternative">
        <xsl:variable name="start"/>
        <xsl:apply-templates mode="#current" select="path/step[1]">
            <xsl:with-param name="from" select="()"/>
        </xsl:apply-templates>
        <!--<xsl:apply-templates select="key('obj-by-gi',string(.),$definition-map)" mode="cast-node-test"/>-->
    </xsl:template>
    
    <xsl:template mode="cast-path" match="step">
<!-- $from defaults only for the first step in a relative path, otherwise
        it is provided by its ancestor 'alternative' (for an absolute path)
        or by the preceding sibling step - nb it could be several -->
        <xsl:param name="from" as="element()*" required="true"/>
        <xsl:variable name="here">
            <xsl:choose>
                <xsl:when test="empty($from)">
                    <xsl:sequence select="key('obj-by-gi',string(node),$definition-map)"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:apply-templates select="." mode="find-definition">
                        <xsl:with-param name="from" select="$from"/>
                    </xsl:apply-templates>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <!-- making all the steps to the JSON       -->
        <xsl:variable name="all-json-steps" as="xs:string*">
            <xsl:variable name="step-axis" select="axis"/>
            <xsl:iterate select="$here">
                <xsl:message expand-text="true">here: { $here/name()}, { $here/@gi }</xsl:message>
                <xsl:value-of>
                    <xsl:value-of select="$step-axis"/>
                    <xsl:apply-templates select="$here" mode="cast-node-test"/>
                </xsl:value-of>
            </xsl:iterate>
        </xsl:variable>
        <!-- dealing with duplicates -->
        <xsl:variable name="json-steps" select="distinct-values($all-json-steps)"/>
        
        <!-- and writing these out as a big union! -->
        <xsl:if test="exists($json-steps[2])">(</xsl:if>
        <xsl:value-of select="string-join($json-steps,' | ')"/>
        <xsl:if test="exists($json-steps[2])">)</xsl:if>
        
        <!-- now we have to write any filters, accounting for their paths -->
        
        <xsl:apply-templates select="filter" mode="#current">
            <xsl:with-param name="from" select="$here"/>
        </xsl:apply-templates>
<!-- then we traverse to the next sibling, with a new $from value       -->
        <xsl:apply-templates select="following-sibling::step[1]" mode="#current">
            <xsl:with-param name="from" select="$here"/>
        </xsl:apply-templates>
<!-- if there are no further siblings, we are done -->
    </xsl:template>



    <xsl:template mode="find-definition" priority="5" match="step[axis='child::'][node=$wildcard]">
        <xsl:param name="from" as="element()*"/>
        <xsl:variable name="recursors" select="$from/m:find-recursors(.)"/>
        <xsl:sequence select="($from|$recursors)/(.|group[empty(@gi)])/(group|assembly|field)[exists(@gi)]"/>
    </xsl:template>
    
    <xsl:template mode="find-definition" priority="5" match="step[axis='descendant::'][node=$wildcard]">
        <xsl:param name="from" as="element()*"/>
        <xsl:variable name="recursors" select="$from/m:find-recursors(.)"/>
        <xsl:sequence select="($from|$recursors)/(descendant::group|descendant::assembly|descendant::field)[exists(@gi)]"/>
    </xsl:template>
    
    <xsl:template mode="find-definition" priority="5" match="step[axis='descendant-or-self::'][node=$wildcard]">
        <xsl:param name="from" as="element()*"/>
        <xsl:variable name="recursors" select="$from/m:find-recursors(.)"/>
        <xsl:sequence select="($from|$recursors)/(descendant-or-self::group|descendant-or-self::assembly|descendant-or-self::field)[exists(@gi)]"/>
    </xsl:template>
    
    <xsl:template mode="find-definition" priority="5" match="step[axis='attribute::'][node=$wildcard]">
        <xsl:param name="from" as="element()*"/>
        <xsl:sequence select="$from/child::flag"/>
    </xsl:template>
    
    <xsl:template mode="find-definition" match="step[axis='child::']">
        <xsl:param name="from" as="element()*"/>
        <xsl:variable name="nodetest" select="node"/>
        <xsl:variable name="recursors" select="$from/m:find-recursors(.)"/>
        <xsl:sequence select="($from|$recursors)/(.|group[empty(@gi)])/(group|assembly|field)[@gi=$nodetest]"/>
    </xsl:template>
    
    <xsl:template mode="find-definition" match="step[axis='descendant::']">
        <xsl:param name="from" as="element()*"/>
        <xsl:variable name="nodetest" select="node"/>
        <xsl:variable name="recursors" select="$from/m:find-recursors(.)"/>
        <xsl:sequence select="($from|$recursors)/(descendant::group|descendant::assembly|descendant::field)[@gi=$nodetest]"/>
    </xsl:template>
    
    <xsl:template mode="find-definition" match="step[axis='descendant-or-self::']">
        <xsl:param name="from" as="element()*"/>
        <xsl:variable name="nodetest" select="node"/>
        <xsl:variable name="recursors" select="$from/m:find-recursors(.)"/>
        <xsl:sequence select="($from|$recursors)/(descendant-or-self::group|descendant-or-self::assembly|descendant-or-self::field)[@gi=$nodetest]"/>
    </xsl:template>
    
    <xsl:template mode="find-definition" match="step[axis='attribute::']">
        <xsl:param name="from" as="element()*"/>
        <xsl:variable name="nodetest" select="node"/>
        <xsl:variable name="recursors" select="$from/m:find-recursors(.)"/>
        <xsl:sequence select="$from/child::flag[@gi=$nodetest]"/>
    </xsl:template>
    
    <xsl:function name="m:find-recursors" as="element(assembly)*">
        <xsl:param name="from" as="element()*"/>
        <xsl:variable name="recursion-points"
            select="$from/descendant-or-self::assembly[@recursive = 'true']"/>
        <xsl:for-each select="$recursion-points">
            <xsl:variable name="recursing" select="@name"/>
            <xsl:sequence select="ancestor::assembly[@name = $recursing][1]"/>
        </xsl:for-each>
    </xsl:function>
    
</xsl:stylesheet>
