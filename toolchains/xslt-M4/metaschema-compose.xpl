<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc"
  xmlns:c="http://www.w3.org/ns/xproc-step" version="1.0"
  xmlns:metaschema="http://csrc.nist.gov/ns/metaschema/1.0"
  type="metaschema:metaschema-compose" name="metaschema-compose">

<!-- further work refactoring composition pipeline

  unit tests including new error reporting (bad references, shadowing)
    x collect
    o other steps including resolve-use-names.xsl
    
  o refactor added attributes in pipeline with names starting with '_'

  o clean up and remove unused stylesheets and modules
  
  o factor out defaults into variables in collect.xsl

  x set globals for values defaulting settings
    x in-json, in-xml, as-type 'string' (DW will find)
  
  x emit EXCEPTION @level 
    from compose/metaschema-prune-unused-definitions.xsl
    o exception-allocation.xsl for final phase of pipeline

  Metaschema Schematron (for authoring)
    when importing metaschema shadows (redefines definitions) an imported module
         (descendant in import hierarchy)
    when a definition has no reference within its (import) scope - orphan definition

  clean up and update XSLTs and XProcs
  
  document @key-name and @key-ref as documentation details, not as part of Metaschema spec

  pipeline updates
    XSD production
    JSON Schema production
    convertor XSLT production
    docs production
    
  -->
  <!-- &&& &&& &&& &&& &&& &&& &&& &&& &&& &&& &&& &&& &&& &&& &&& &&& &&& &&& -->
  <!-- Ports -->
  
  <p:input port="source" primary="true"/>
  <p:input port="parameters" kind="parameter"/>

  <p:serialization port="_0_main-module" indent="true"/>
  <p:output        port="_0_main-module" primary="false">
    <p:pipe port="result" step="input"/>
  </p:output>

  <p:serialization port="_1_collected" indent="true"/>
  <p:output        port="_1_collected" primary="false">
    <p:pipe port="result" step="collect"/>
  </p:output>
  
  <p:serialization port="_2_refs-built" indent="true"/>
  <p:output        port="_2_refs-built" primary="false">
    <p:pipe port="result" step="build-refs"/>
  </p:output>
  
  <p:serialization port="_3_defs-pruned" indent="true"/>
  <p:output        port="_3_defs-pruned" primary="false">
    <p:pipe port="result" step="prune-defs"/>
  </p:output>
  
  <p:serialization port="_4_using-names-added" indent="true"/>
  <p:output port="_4_using-names-added" primary="false">
    <p:pipe port="result" step="add-use-names"/>
  </p:output>
  
  <!-- 'sibling name' indicates the name among the siblings (whether singular or grouped) -->
  <p:serialization port="_5_sibling-names-added" indent="true"/>
  <p:output port="_5_sibling-names-added" primary="false">
    <p:pipe port="result" step="add-sibling-names"/>
  </p:output>
  
  <p:serialization port="_6_digested" indent="true"/>
  <p:output port="_6_digested" primary="false">
    <p:pipe port="result" step="digest"/>
  </p:output>
  
  <p:serialization port="final"  indent="true"/>
  <p:output        port="final" primary="true">
    <p:pipe port="result" step="final"/>
  </p:output>

  <!-- &&& &&& &&& &&& &&& &&& &&& &&& &&& &&& &&& &&& &&& &&& &&& &&& &&& &&& -->
  <!-- Pipeline -->
  
  <p:identity name="input"/>
  
  <!-- pull modules together
       and mark all top-level definitions with key-names
       add scope='global' unless it is given -->
  
  <p:xslt name="collect">
    <p:input port="stylesheet">
      <p:document href="compose/metaschema-collect.xsl"/>
    </p:input>
  </p:xslt>
  <!--  With EXCEPTION for broken or circular imports -->
  
  <p:xslt name="build-refs">
    <p:input port="stylesheet">
      <p:document href="compose/metaschema-build-refs.xsl"/>
    </p:input>
  </p:xslt>
  <!--  With EXCEPTION for broken references (error) or shadowing definitions (warning) -->
  
  <p:xslt name="prune-defs">
    <p:input port="stylesheet">
      <p:document href="compose/metaschema-prune-unused-definitions.xsl"/>
    </p:input>
    <p:with-param name="show-warnings" select="'yes'"/>
  </p:xslt>
<!-- With EXCEPTION for no roots found, also
     when @show-warnings='yes'
       EXCEPTION level='warning' for definitions removed as unused
       TRACE listing all references found -->
  
  <!-- New @sibling-name will show names to check among siblings within models -->
  
  <!-- New @using-name exposes the name-in-use, whether given or derived -->
  <p:xslt name="add-use-names">
    <p:input port="stylesheet">
      <p:document href="compose/metaschema-resolve-use-names.xsl"/>
    </p:input>
  </p:xslt>
  <!-- No exceptions produced (everything gets a @using-name) -->
  
  <!-- New @in-xml-name and @in-json-name will show exposed names
       for checking among siblings within models -->
  <p:xslt name="add-sibling-names">
    <p:input port="stylesheet">
      <p:document href="compose/metaschema-resolve-sibling-names.xsl"/>
    </p:input>
  </p:xslt>
  <!-- No exceptions produced (everything gets a @sibling-name) -->
  
  
  <!--
  A
    B
  C
    D
    
       
including
   def A (root)
     ref B -> including:B
   def B * this is a shadowing problem due to included B *warning
     emit warning 
   UT 
     ref B -> including:B
     ref prop -> included:prop -> down the tree
     ref C * unresolvable reference error b/c local C is not in scope here UT
     
   included
      def prop
      def B
        ref C -> included:C
        ref G * this is an unresolvable reference *error UT
      def C scope=local
        ref B -> included:B
    
situation results in error     
    
    -->
  
  <!-- flatten and add defaults -->
  <p:xslt name="digest">
    <p:input port="stylesheet">
      <p:document href="compose/metaschema-digest.xsl"/>
    </p:input>
  </p:xslt>
  
  <p:identity name="final"/>
 
</p:declare-step>