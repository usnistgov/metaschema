---
title: "Syntax"
Description: "Discusses the Metaschema module format and related structures."
weight: 30
aliases:
- /specification/syntax/
---

The following is an outline of the Metaschema module syntax.


<div class="highlight"><div class="chroma"><code class="language-xml" data-lang="xml">
<div class="line">
  <span class="cl"><span class="nt">&lt;<a href="/specification/syntax/module/#main-content">METASCHEMA</a></span> <span class="na">xmlns=</span><span class="s">"http://csrc.nist.gov/ns/oscal/metaschema/1.0"</span></span></div>
<div class="line">&nbsp;&nbsp;&nbsp;&nbsp;<a href="/specification/syntax/module/#abstract-modules"><span class="na">abstract</span></a><span class="na">=</span><span class="s">"yes|no"</span><span class="nt">&gt;</span></div>
<div class="line">&nbsp;&nbsp;<span class="cl"><span class="nt">&lt;<a href="/specification/syntax/module/#schema-name">schema-name</a>&gt;</span><a href="/specification/datatypes/#string">string</a><span class="nt">&lt;/schema-name&gt;</span></span></div>
<div class="line">&nbsp;&nbsp;<span class="cl"><span class="nt">&lt;<a href="/specification/syntax/module/#schema-version">schema-version</a>&gt;</span><a href="/specification/datatypes/#string">string</a><span class="nt">&lt;/schema-version&gt;</span></span></div>
<div class="line">&nbsp;&nbsp;<span class="cl"><span class="nt">&lt;<a href="/specification/syntax/module/#short-name">short-name</a>&gt;</span><a href="/specification/datatypes/#string">string</a><span class="nt">&lt;/short-name&gt;</span></span></div>
<div class="line">&nbsp;&nbsp;<span class="cl"><span class="nt">&lt;<a href="/specification/syntax/module/#xml-namespace">namespace</a>&gt;</span><a href="/specification/datatypes/#uri">uri</a><span class="nt">&lt;/namespace&gt;</span></span></div>
<div class="line">&nbsp;&nbsp;<span class="cl"><span class="nt">&lt;<a href="/specification/syntax/module/#json-base-uri">json-base-uri</a>&gt;</span><a href="/specification/datatypes/#uri">uri</a><span class="nt">&lt;/json-base-uri&gt;</span></span></div>
<div class="line">&nbsp;&nbsp;<span class="cl"><span class="nt">&lt;<a href="/specification/syntax/module/#import">import</a></span> <span class="na">href=</span><span class="s">"<a href="/specification/datatypes/#uri-reference"><span class="s">uri-reference</span></a>"</span><span class="nt">/&gt;</span></span></div>
<div class="line">&nbsp;&nbsp;<span class="cl"><span class="nt">&lt;<a href="/specification/syntax/module/#remarks">remarks</a>&gt;</span><a href="/specification/datatypes/#markup-multiline">markup-multiline</a><span class="nt">&lt;/remarks&gt;</span></span></div>
<div class="line"><span class="cl"><span class="nt">&lt;/METASCHEMA&gt;</span></span></div>
</code></div></div>