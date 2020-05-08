<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="#all"
    xmlns:p="metapath01"
    xmlns="http://csrc.nist.gov/ns/oscal/metaschema/1.0"
    xmlns:m="http://csrc.nist.gov/ns/oscal/metaschema/1.0"
    xpath-default-namespace="http://csrc.nist.gov/ns/oscal/metaschema/1.0"
    version="3.0"
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
    
    <xsl:variable name="px" as="xs:string">j</xsl:variable>
    
    <xsl:variable name="map" select="document('../testing/models_definition-map.xml')"/>
    
    <xsl:variable name="tests">
        <test>a/b//c/d[e=f]</test>
        <test>EVERYTHING//field-by-key</test>
        <test>field-groupable</test>
        <test>assembly-by-key</test>
        <test>/</test>                <!-- returns /map-->
        <test>field-boolean</test>                <!-- returns /map-->
        <test>id</test>                <!-- returns /map-->
        <test>EVERYTHING</test>       <!-- returns map[@key='EVERYTHING'] -->
        <test>field-1only</test>      <!-- returns *[@key='field-1only'] or string[@key='field-1only']-->
        <test>field-named-value</test><!-- returns map[@key='field-named-value']/string[@key='CUSTOM-VALUE-KEY'] -->
        <test>X</test><!-- returns nada -->
    </xsl:variable>
    
    <xsl:template match="/">
        <all-tests>
          <xsl:apply-templates select="$tests" mode="testing"/>
        </all-tests>
    </xsl:template>
    
    <!-- testing steps only -->
    <xsl:template match="test" mode="testing">
        <xsl:variable name="every" as="element()*">
            <xsl:apply-templates select="key('obj-by-gi',.,$map)" mode="cast-node-test"/>
        </xsl:variable>
        <test expr="{.}">
            <xsl:for-each-group select="$every" group-by="string(.)">
                <xsl:sequence select="."/>
            </xsl:for-each-group>
            
            <!--<xsl:sequence select="p:parse-XPath(.)"/>-->
        </test>
    </xsl:template>
    
    <xsl:template match="test" mode="testing">
        <test expr="{.}">
            
            
            <xsl:sequence select="m:cast-path(.)"/>
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
    
    <xsl:template match="@as-type[. = $integer-types]" mode="json-type">number</xsl:template>
    
    <xsl:variable name="numeric-types" as="element()*">
        <type>decimal</type>
    </xsl:variable>
    
    <xsl:template match="@as-type[.=$numeric-types]" mode="json-type">number</xsl:template>
    
    <!-- Given a string, returns the same string with its
    node tests cast into the JSONized equivalent.
    NB for any path, several or no JSONized paths may be returned -
    only paths viable in the metaschema (represented in the map)
    come back, but there can be multiple. -->
    <xsl:function name="m:cast-path">
        <xsl:param name="path" as="xs:string" required="yes"/>
        <xsl:variable name="parse.tree" select="p:parse-XPath($path)"/>
        <xsl:apply-templates select="$parse.tree" mode="cast-path"/>
    </xsl:function>
    
<!-- XXX   -->
    <!--Mode 'cast-path' moves one step at a time through a path,
    each step serving as context for retrieval of the next step with
    reference to the definition map. 
    Multiple paths may be returned. -->
    
    <xsl:template mode="cast-path" match="NodeTest" xpath-default-namespace="">
        <xsl:apply-templates select="key('obj-by-gi',string(.),$map)" mode="cast-node-test"/>
    </xsl:template>
    
</xsl:stylesheet>
