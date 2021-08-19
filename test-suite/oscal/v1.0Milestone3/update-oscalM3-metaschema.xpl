<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc"
  xmlns:c="http://www.w3.org/ns/xproc-step" version="1.0"
  xmlns:metaschema="http://csrc.nist.gov/ns/metaschema/1.0"
  type="metaschema:update-oscalM3-metaschema" name="update-oscalM3-metaschema">
  
  <!-- &&& &&& &&& &&& &&& &&& &&& &&& &&& &&& &&& &&& &&& &&& &&& &&& &&& &&& -->
  <!-- Ports -->
  
  <p:input port="source" primary="true"/>
  <p:input port="parameters" kind="parameter"/>
  
  <p:serialization port="a.echo-input" indent="true"/>
  <p:output        port="a.echo-input" primary="false">
    <p:pipe        port="result"       step="input"/>
  </p:output>
  
  <p:serialization port="b.modified" indent="true"/>
  <p:output        port="b.modified" primary="false">
    <p:pipe        port="result"     step="modify"/>
  </p:output>
  
  <p:serialization port="c.documented" indent="true"/>
  <p:output        port="c.documented" primary="false">
    <p:pipe        port="result" step="document"/>
  </p:output>
  
  <p:serialization port="d.patched" indent="true"/>
  <p:output        port="d.patched" primary="false">
    <p:pipe        port="result" step="patch"/>
  </p:output>
  
  <p:serialization port="f.final" indent="true" method="xml" omit-xml-declaration="false"/>
  <p:output        port="f.final" primary="true">
    <p:pipe        port="result" step="final"/>
  </p:output>
  
  <!-- &&& &&& &&& &&& &&& &&& &&& &&& &&& &&& &&& &&& &&& &&& &&& &&& &&& &&& -->
  <!-- Pipeline -->
  
  <p:identity name="input"/>
  
  <p:xslt name="modify">
    <p:input port="stylesheet">
      <p:document href="update-metaschema_declarations.xsl"/>
    </p:input>
  </p:xslt>
  
  <p:xslt name="document">
    <p:input port="stylesheet">
      <p:document href="update-metaschema_documentation.xsl"/>
    </p:input>
  </p:xslt>
  
  <p:xslt name="patch">
    <p:input port="stylesheet">
      <p:document href="update-metaschema_M3-patches.xsl"/>
    </p:input>
  </p:xslt>
  
  <p:xslt name="final">
    <p:input port="stylesheet">
      <p:document href="update-metaschema_finish.xsl"/>
    </p:input>
  </p:xslt>
  
 
</p:declare-step>