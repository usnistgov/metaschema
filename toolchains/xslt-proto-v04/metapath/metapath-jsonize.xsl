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
    
<!-- Testing:
    o all object types
       including grouped and ungrouped assemblies and fields
         including grouped with keys (a json key flag exists)
         also when group-json="SINGLETON_OR_ARRAY" (the *default* for groups) we should see two paths
       flags
    o values on fields including with value flags
    o recursive assemblies
    o filters! (predicates) both with and w/o paths
    o fields with @json-value-key - both the value, and the flag
    o paths including explicit XML groupings
    o paths to nodes that do not exist
      - should we see errors or report exceptions?
    o for better encapsulation, consider providing the definition map as an argument to m:jsonize-path(), tunneling it through mode "cast-path" as necessary
    -->
    
    <xsl:output indent="yes"/>
    
    <xsl:key name="obj-by-gi" match="*"       use="@gi"/>
    
<!-- Starting point for absolute paths   -->
    <xsl:key name="obj-by-gi" match="/model" use="'/'"/>
    
    <xsl:param name="px" as="xs:string">j</xsl:param>
    
    <xsl:param name="definition-map" select="document('../testing/models_definition-map.xml')"/>
    
    <!-- We have to detect wildcards on path steps with no node name (XML GI) -->
    <xsl:variable name="wildcard" as="xs:string+" select="'*','node()'"/>
    
    <xsl:variable name="tests">
        <test>/</test>
        <test>/*</test>
        <test>/EVERYTHING[field-1only='x']</test>
        <test>/EVERYTHING/EVERYTHING</test>
        <test>EVERYTHING/EVERYTHING/EVERYTHING</test>
        
        <!--<!-\-<test>//EVERYTHING//field-by-key</test>-\->
        <test>field-groupable[with-child/grandchild and x]</test>
        <!-\-<test>/</test>-\->                <!-\- returns /map-\->
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
    
    <xsl:template match="test" mode="testing">
        <xsl:variable name="map" select="m:path-map(string(.))"/>
        <test expr="{.}" expand="{string($map)}" json-path="{m:jsonize-path(.)}">
            <!--<xsl:apply-templates select="key('obj-by-gi',.,$definition-map)" mode="cast-node-test"/>-->
            <xsl:sequence select="m:path-map(.)"/>
            <!--<xsl:sequence select="p:parse-XPath(.)"/>-->
        </test>
    </xsl:template>
    
    <xsl:template match="/model" mode="cast-node-test">
        <expr>/{$px}:map</expr>
    </xsl:template>
    
    <xsl:template priority="2" match="group[@group-json='BY_KEY']/assembly" mode="cast-node-test">
        <expr>{$px}:map[@key='{../@key}']/{$px}:map</expr>
    </xsl:template>
    
    <xsl:template priority="2" match="group[@group-json='ARRAY']/assembly" mode="cast-node-test">
        <expr>{$px}:array[@key='{../@key}']/{$px}:map</expr>
    </xsl:template>
    
    <!-- Catches assembly grouped as SINGLETON_OR_ARRAY -->
    <xsl:template match="group/assembly" mode="cast-node-test">
        <expr>{$px}:assembly[@key='{../@key}']/{$px}:map</expr>
        <expr>{$px}:map[@key='{../@key}']</expr>
    </xsl:template>
    
    <xsl:template match="assembly" mode="cast-node-test">
        <expr>{$px}:map[@key='{@key}']</expr>
    </xsl:template>
    
    <!-- field grouped by key -->
    <xsl:template priority="3" match="group[@group-json='BY_KEY']/field" mode="cast-node-test">
        <xsl:variable name="type">
            <xsl:apply-templates select="." mode="object-type"/>
        </xsl:variable>
        <xsl:variable name="field-path">
            <xsl:next-match/>
        </xsl:variable>
        <expr>{$px}:map[@key='{../@key}']/{$field-path}</expr>
    </xsl:template>
    
    <xsl:template priority="3" match="group[@group-json='ARRAY']/field" mode="cast-node-test">
        <xsl:variable name="type">
            <xsl:apply-templates select="." mode="object-type"/>
        </xsl:variable>
        <xsl:variable name="field-path">
            <xsl:next-match/>
        </xsl:variable>
        <expr>{$px}:array[@key='{../@key}']/{$field-path}</expr>
    </xsl:template>
    
    <!-- Catches field grouped as SINGLETON-OR-ARRAY -->
    <xsl:template priority="2" match="group/field" mode="cast-node-test">
        <xsl:variable name="type">
            <xsl:apply-templates select="." mode="object-type"/>
        </xsl:variable>
        <xsl:variable name="field-path">
            <xsl:next-match/>
        </xsl:variable>
        <expr>{$px}:array[@key='{../@key}']/{$field-path}</expr>
        <expr>{$px}:{$type}[@key='{../@key}']</expr>
    </xsl:template>
    
    <!-- field with no flags apart from a json-key-flag points to itself as a value property -->
    <xsl:template match="field[empty(flag[not(@key = ../@json-key-flag)])]" mode="cast-node-test">
        <xsl:variable name="type">
            <xsl:apply-templates select="." mode="object-type"/>
        </xsl:variable>
        <expr>{$px}:{$type}[@key='{@key}']</expr>
    </xsl:template>
    
    <!-- field points to its value property -->
    <xsl:template match="field" mode="cast-node-test">
        <xsl:variable name="type">
            <xsl:apply-templates select="." mode="object-type"/>
        </xsl:variable>
        <expr>{$px}:map[@key='{@key}']/{$px}:{$type}[@key='{value/@key}']</expr>
    </xsl:template>
    
    <xsl:template match="flag" mode="cast-node-test">
        <xsl:variable name="type">
            <xsl:apply-templates select="." mode="object-type"/>
        </xsl:variable>
        <expr>{$px}:{$type}[@key='{@key}']</expr>
    </xsl:template>
    
    <!-- In the case of a json key flag, the node test on a relative path from its parent is ... "key" -->
    <xsl:template match="flag[@key = ../@json-key-flag]" mode="cast-node-test">key</xsl:template>
    
    <xsl:template match="*" mode="cast-node-test">
        <expr>OoopsFellThrough</expr>
        <expr>{$px}:*[@key='{../@key}']</expr>
    </xsl:template>
    
    <!-- object-type returns
      map for any field with flags not designated as json-key-flag
      appropriate data type for any other fields or flags (string, number, boolean)-->
      
    <xsl:template match="*" mode="object-type">map</xsl:template>
    
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
    
    <!-- Given string $str, function m:jsonize-path($str)
        returns the same string cast into the JSONized equivalent.
    
    It relies on mode "cast-path", which executes a sibling traversal over steps represented in the reduced parse tree (path map).
    Nodes in the declaration map are passed through to provide execution context for finding each step.
    
    NB for any path, several or no JSONized paths may be returned - only paths viable in the metaschema (represented in the map) come back, but there can be multiple. -->
    
    <xsl:function name="m:jsonize-path" as="xs:string">
        <xsl:param name="metapath" as="xs:string" required="yes"/>
        <xsl:variable name="path-map" select="m:path-map($metapath)"/>
        <xsl:variable name="alternatives" as="xs:string*">
            <xsl:apply-templates select="$path-map" mode="cast-path"/>
        </xsl:variable>
        <xsl:value-of select="string-join($alternatives,' | ')"/>
    </xsl:function>
    
    <!-- An absolute path -->
    <xsl:template mode="cast-path" as="xs:string" match="path[starts-with(.,'/')]">
        <xsl:value-of>
            <xsl:text expand-text="true">/{$px}:map</xsl:text>
            <xsl:apply-templates mode="#current" select="step[1]">
                <xsl:with-param name="starting" select="true()"/>
                <xsl:with-param name="relative" select="false()"/>
            </xsl:apply-templates>
        </xsl:value-of>
    </xsl:template>
    
    <!-- A relative path -->
    <xsl:template mode="cast-path" as="xs:string" match="path">
        <xsl:value-of>
            <xsl:apply-templates mode="#current" select="step[1]">
                <xsl:with-param name="starting" select="true()"/>
            </xsl:apply-templates>
        </xsl:value-of>
    </xsl:template>
    
    <xsl:template mode="cast-path" match="step">
<!-- $from gives us a node in the definition map providing the execution context for the step -->
        <xsl:param name="from" as="element()*"/>
        <xsl:param name="starting" as="xs:boolean" select="false()"/>
        <xsl:param name="relative" as="xs:boolean" select="true()"/>
        <xsl:if test="not($starting) or not($relative)">/</xsl:if>
        <xsl:variable name="here" as="element()*">
            <xsl:choose>
                <!-- the first step of an absolute path is located relative to the root -->
                <xsl:when test="$starting">
                    <xsl:choose>
                        <xsl:when test="$relative">
                            <!-- the first step of a relative path starts where it starts-->
                            <xsl:sequence select="key('obj-by-gi', string(node), $definition-map)"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <!-- an absolute path starts from the root -->
                            <xsl:apply-templates select="." mode="find-definition">
                                <xsl:with-param name="from" select="$definition-map/*"/>
                            </xsl:apply-templates>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
                <!-- if we are not starting, we have a $from to go from -->
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
            <xsl:for-each select="$here">
                <xsl:value-of>
                    <xsl:apply-templates mode="abbreviate-axis" select="$step-axis"/>
                    <xsl:apply-templates select="." mode="cast-node-test"/>
                </xsl:value-of>
            </xsl:for-each>
        </xsl:variable>
        <!-- removing duplicates -->
        <xsl:variable name="json-steps" select="distinct-values($all-json-steps)"/>
        
        <!-- and writing these out as a big union -->
        <!-- grouping multiple paths or none -->
        <xsl:if test="count($json-steps) ne 1">(</xsl:if>
        <xsl:value-of select="string-join($json-steps,' | ')"/>
        <xsl:if test="count($json-steps) ne 1">)</xsl:if>
        
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
        <xsl:variable name="recursors" select="$from/(.|group[empty(@gi)])/assembly[@recursive = 'true']"/>
        <xsl:variable name="recursors" as="element()*">
            <xsl:variable name="recursion-points"
                select="$from/(. | assembly | group[empty(@gi)])[@recursive = 'true']"/>
            <xsl:for-each select="$recursion-points">
                <xsl:variable name="recursing" select="@name"/>
                <xsl:sequence select="ancestor::assembly[@name = $recursing][1]"/>
            </xsl:for-each>
        </xsl:variable>
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
        <xsl:variable name="recursors" as="element()*">
            <xsl:variable name="recursion-points"
                select="$from/(. | assembly | group[empty(@gi)])[@recursive = 'true']"/>
            <xsl:for-each select="$recursion-points">
                <xsl:variable name="recursing" select="@name"/>
                <xsl:sequence select="ancestor::assembly[@name = $recursing][1]"/>
            </xsl:for-each>
        </xsl:variable>
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
    
    <xsl:template match="axis" mode="abbreviate-axis">
        <xsl:value-of select="."/>
    </xsl:template>
    
    <xsl:template match="axis[.='attribute::']" mode="abbreviate-axis">@</xsl:template>
    
    <xsl:template match="axis[.='child::']" mode="abbreviate-axis"/>
    
    
</xsl:stylesheet>
