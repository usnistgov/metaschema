<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc"
  xmlns:c="http://www.w3.org/ns/xproc-step" version="1.0"
  xmlns:metaschema="http://csrc.nist.gov/ns/metaschema/1.0"
  type="metaschema:metaschema-compose" name="metaschema-compose">

<!-- further work refactoring composition pipeline
  

  unit tests
  Metaschema Schematron (for authoring)
    when importing metaschema shadows (redefines definitions) an imported module
         (descendant in import hierarchy)
    when a definition has no reference within its (import) scope - orphan definition

  clean up and update XSLTs and XProcs
  
  add to Metaschema model
    (optional) @key-name and @key-ref
    WARNING and ERROR messages
  
  pipeline updates
    XSD production
    JSON Schema production
    conversion XSLT production
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
  
  <p:serialization port="_2_built-refs" indent="true"/>
  <p:output        port="_2_built-refs" primary="false">
    <p:pipe port="result" step="build-refs"/>
  </p:output>
  
  <p:serialization port="_3_prune-defs" indent="true"/>
  <p:output        port="_3_prune-defs" primary="false">
    <p:pipe port="result" step="prune-defs"/>
  </p:output>
  
  <p:serialization port="_4_digested" indent="true"/>
  <p:output port="_4_digested" primary="false">
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
  
  <p:xslt name="build-refs">
    <p:input port="stylesheet">
      <p:document href="compose/metaschema-build-refs.xsl"/>
    </p:input>
  </p:xslt>
  
  <p:xslt name="prune-defs">
    <p:input port="stylesheet">
      <p:document href="compose/metaschema-prune-unused-definitions.xsl"/>
    </p:input>
  </p:xslt>
  
  
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