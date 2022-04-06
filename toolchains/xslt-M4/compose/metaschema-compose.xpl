<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc"
  xmlns:c="http://www.w3.org/ns/xproc-step" version="1.0"
  xmlns:metaschema="http://csrc.nist.gov/ns/metaschema/1.0"
  type="metaschema:metaschema-compose" name="metaschema-compose">


  <!-- Purpose: Produce a standalone Metaschema instance representing a data model, suitable for further processing  -->
  <!-- Input: A valid and correct OSCAL Metaschema instance linked to its modules (also valid and correct) -->
  <!-- Output: A completely standalone Metaschema instance fully resolving and disambiguating links among definitions, suitable for further processing. -->
  
  <!-- &&& &&& &&& &&& &&& &&& &&& &&& &&& &&& &&& &&& &&& &&& &&& &&& &&& &&& -->
  <!-- Ports //p:serialization/@port  => string-join(' ')-->
  
  <!-- _0_main-module           echoes input
       _1_collected             collects modules
       _2_refs-built            disambiguates names and references
       _3_extra-modules-trimmed removes any replicated modules
       _4_defs-pruned           removes unneeded definitions
       _5_using-names-added     decorates with names for use
       _6_sibling-names-added   decorates with group names in use
       _7_digested              flattens and removes cruft
       _8_annotated             provides extra annotations (pre-loading)
       final -->
  
  <!-- out of line XSLTs //p:xslt/p:input[@port='stylesheet']/p:*/@href  => string-join(' &#xA;') -->
  
  
<!-- Try on
    A. trivial model
    B. an OSCAL model
    C. OSCAL 'all'
    D. pathological tests see ../../../test-suite/
    
    document each step
    find / build out unit tests (including edge cases)
  
    -->
  
<!-- further work refactoring composition pipeline

  unit tests including new error reporting (bad references, shadowing)
    o collect (now broken) - including add defaults
    o other steps including resolve-use-names.xsl
    
  o refactor added attributes in pipeline with names starting with '_'
  o factor out defaults into variables in collect.xsl

  o clean up and remove unused stylesheets and modules
    o update Metaschema validation support pipelines
      rewire to reduce code overhead/duplication

  o README !!!! with docs about all entry points
    o describe pipelines

  x set globals for values defaulting settings
    x in-json, in-xml, as-type 'string' (DW will find)
  
  x emit EXCEPTION @level 
    from compose/metaschema-prune-unused-definitions.xsl
    o add @problem-type everywhere
    o exception-allocation.xsl for final phase of pipeline
    o problem-type
    o base-URI of issue
    o fully resolvable path
    
  ? (check over) Metaschema Schematron (for authoring)
    when importing metaschema shadows (redefines definitions) an imported module
         (descendant in import hierarchy)
    when a definition has no reference within its (import) scope - orphan definition

  document @key-name and @key-ref as implementation details, not as part of Metaschema spec
    
  //p:xslt/p:input[@port='stylesheet']/p:document/
  <transform version="3.0">{ string(@href) }</transform>
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
  
  <p:serialization port="_3_extra-modules-trimmed" indent="true"/>
  <p:output        port="_3_extra-modules-trimmed" primary="false">
    <p:pipe port="result" step="trim-extra-modules"/>
  </p:output>
  
  <p:serialization port="_4_defs-pruned" indent="true"/>
  <p:output        port="_4_defs-pruned" primary="false">
    <p:pipe port="result" step="prune-defs"/>
  </p:output>
  
  <p:serialization port="_5_using-names-added" indent="true"/>
  <p:output port="_5_using-names-added" primary="false">
    <p:pipe port="result" step="add-use-names"/>
  </p:output>
  
  <!-- 'sibling name' indicates the name among the siblings (whether singular or grouped) -->
  <p:serialization port="_6_sibling-names-added" indent="true"/>
  <p:output port="_6_sibling-names-added" primary="false">
    <p:pipe port="result" step="add-sibling-names"/>
  </p:output>
  
  <p:serialization port="_7_digested" indent="true"/>
  <p:output port="_7_digested" primary="false">
    <p:pipe port="result" step="digest"/>
  </p:output>
  
  <p:serialization port="_8_annotated" indent="true"/>
  <p:output port="_8_annotated" primary="false">
    <p:pipe port="result" step="annotate"/>
  </p:output>
  
  <p:serialization port="final"  indent="true"/>
  <p:output        port="final" primary="true">
    <p:pipe port="result" step="final"/>
  </p:output>

  <!-- &&& &&& &&& &&& &&& &&& &&& &&& &&& &&& &&& &&& &&& &&& &&& &&& &&& &&& -->
  <!-- Pipeline -->
  
  <p:identity name="input"/>
  
  <p:xslt name="collect">
    <!-- - Inlines each imported metaschema, checking for circular references.
         - Adds default values for metaschema attributes and elements.
         - Tracks source metaschema using @_base-uri.
         - Adds @_key-name for all top-level definitions, which provides a key lookup in future transforms.
    -->
    <p:input port="stylesheet">
      <p:document href="metaschema-collect.xsl"/>
    </p:input>
    <!-- With EXCEPTION problem-type="not-a-metaschema" if the processed document is not a metaschema -->
    <!-- With EXCEPTION problem-type="broken-import" for broken imports -->
    <!-- With EXCEPTION problem-type="import-not-a-metaschema" for imports that are not a metaschema -->
    <!-- With EXCEPTION problem-type="circular-import" for circular imports -->
  </p:xslt>
  
  <p:xslt name="build-refs">
    <!-- Generates @_key-ref entries for all assembly, field, and flag instances. -->
    <p:input port="stylesheet">
      <p:document href="metaschema-build-refs.xsl"/>
    </p:input>
    <!-- With EXCEPTION for broken references (error) or shadowing definitions (warning) -->
    <!-- With EXCEPTION problem-type="definition-shadowing" when a definition in an importing module clashes with an definition of the same type (i.e., flag, field, assembly) in an imported module or another downstream import -->
    <!-- With EXCEPTION problem-type="instance-invalid-reference" when an instance references a non-existant or out-of-scope definition -->
  </p:xslt>
  <!-- WITH EXCEPTION problem-type="metaschema-short-name-clash" when an imported modules short-name clashes with the importing module -->
  
  <p:xslt name="trim-extra-modules">
    <p:input port="stylesheet">
      <p:document href="metaschema-trim-extra-modules.xsl"/>
    </p:input>
  </p:xslt>
  <!--  With EXCEPTION for broken references (error) or shadowing definitions (warning) -->
  
  <!--<p:identity name="prune-defs"/>-->
  <p:xslt name="prune-defs">
    <p:input port="stylesheet">
      <p:document href="metaschema-prune-unused-definitions-a8.xsl"/>
    </p:input>
    <!--<p:with-param name="show-warnings" select="'yes'"/>-->
    <!-- With EXCEPTION problem-type="missing-root" for no roots found when the metaschema is not abstract -->
    <!-- With EXCEPTION problem-type="unused-definition" for definitions removed as unused -->
  </p:xslt>
  
  <p:xslt name="add-use-names">
    <!-- - @using-name exposes the name-in-use, whether given or derived -->
    <p:input port="stylesheet">
      <p:document href="metaschema-resolve-use-names.xsl"/>
    </p:input>
    <!-- No exceptions produced (everything gets a @using-name) -->
  </p:xslt>
  
  <p:xslt name="add-sibling-names">
    <!-- New @in-xml-name and @in-json-name will show exposed names for checking among siblings within models -->
    <p:input port="stylesheet">
      <p:document href="metaschema-resolve-sibling-names.xsl"/>
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
      <p:document href="metaschema-digest.xsl"/>
    </p:input>
  </p:xslt>
  
  <p:xslt name="annotate">
    <p:input port="stylesheet">
      <p:document href="annotate-composition.xsl"/>
    </p:input>
  </p:xslt>
  
  <p:identity name="final"/>
 
</p:declare-step>