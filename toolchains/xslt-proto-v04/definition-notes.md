# Addressing - returning objects (branches)

We are probably not able to express the query semantics we need entirely via tagging; a concise XPath-like notation is probably necessary.

Even if only a desideratum, designing such a notation - and perhaps maintaining a semantic-equivalent representation using tagging if possible - while keeping an effective XPath mapping running under tests - helps us understand the requirements.

So the examples below use a mix of explicit tagging semantics, and a specialized notation we inevitably call *Metapath*.

## Metapath

Metapath is XPath for Metaschema. It maps to equivalent XPath (for XML) or to a JSON addressing syntax as needed. It assumes a metaschema as a backbone, meaning its data model the Metaschema data model.

### Data model

Metaschema archictures are made of assemblies, which are composite data objects. They consist of an amalgam of assemblies and fields, with flags. The assemblies can have flags, and so can the fields.

This assembly of assemblies can be represented as a tree structure in which assemblies branch from one another. A structure described by a metaschema must always take this tree form, even if Metapath semantics (herein explained) make it possible to assert and enforcement alignment or "echoing" between branches, making it possible for such documents to represent arbitrary graph structures. But without such enforcement a basic metaschema model as derived from a parsed instance, will be a tree without cycles, 'tangles' or overlap.

Within this model, fields are special types of assemblies, which have nominal designated *values*. Every field has a value (whose name or label may be configured by the metaschema) whose type is declared and enforced in the metaschema. Thus the raw data contents of arbitrary marked-up content, produced for or outside of the metaschema's purview, can be represented. (While the metaschema does not support *arbitrary* mixed content, it provides an 80%-adequate, Markdown-friendly subset of what is commonly found in rough prose. In future its prose model may also be re/pluggable.)

Both assemblies and fields may additionally be enhanced with flags, which provide for further qualification, enhancement, specification and characterization of data over and above the raw contents typically assigned to fields.

This tripartite organization has the feature of composability, but only up to a point. By design, it stipulates a boundary point beyond which it will not try to assert data description. This boundary point is the point where data becomes (what we loosely call) "prose", namely ordered contents whose semantic description is typically *weak* and almost inevitably *implicit* in its features. This is what distinguishes Metaschema in its approach to data description: it accommodates 'rich' contents up to some definition of that, while nevertheless restricting itself to forms that are easily cast into a useful representation, in object-oriented systems that do not offer the same means as markup vocabularies of describing "semantic soup".

There are technologies that seek to provide for strong semantic characterization "all the way down" into arbitrary mixed contents: indeed all the great XML architectures (TEI, DITA, OASIS Docbook, NISO JATS/BITS/STS) can lay claim to offering this. These technologies can and should be brought to bear in systems using Metaschema-defined data, when such characterization is necessary. In contrast to all of these -- and complementary to them -- Metaschema offers a different tradeoff. The challenge is to identify where "murky ponds" of prose are permissible. Indeed the problem is not the murky ponds, but the fact that they hide information. If that information can *additionally* be abstracted and expressed, the murky pond where it lies latent does not actually need to be drained. We can keep it for any reason. This puts Metaschema at a pivot point between rich markup description (documentary data), and structured data (objects, databases) such as are typically deployed for large-scale data aggregation and processing.

In the limitations imposed by Metaschema on the builder, it offers certain affordances. The kinds of things it can describe at all, it should be able to describe very well. If it works, it should work in two ways, by providing for transparency and ease of use, while also offering greateer capability. Specifically, the capabilities offered by Metaschema include, over and above its neutrality between XML and JSON or YAML, its usefulness as a *modeling and constraint definition language*.

The model of a document described by a metaschema takes the form of a tree.

In this tree, the assemblies are branches, which can have branches and leaves (flags).

Fields are terminal branches, which can (like assemblies) have flags, but which can also have nominal values.

The sequence of hierarchy is always a nesting of assemblies, with fields at various levels, and flags everywhere.

### Notation

. the current branch (equiv XPath self::node())
^flag - a flag named 'flag' (XPath @flag)

name  - a field or assembly branch of the current branch, named 'name'

Operations - return booleans

= string equality
!= string inequality

Operations - return strings

replace($str,$replace,$replacement)

`@control` - an assembly named 'control'

`^id` - a flag named 'id'

`#ac-1` - an assembly or field with the id 'ac-1'

`:title` - a field named 'title'

`:prop^name` - a flag 'name' on a field 'prop'

`[]` filter expression

`:prop[^name]` - a field 'prop' with a flag 'name'

`:prop[^name='label']` - a 'prop' with 'name' flag equal 'label' alias `prop[name='label']`

`'token'` - a string token (must match `\i\c*` )

`"string"` - a string (Unicode)

*However* - any of `@` or `:` or `^` may be abbreviated as `/` and cast to XPath '//'
(i.e. it is 'greedy' wrt the descent)

So `@control/@control[:id='ac-2.1']` is the same as `/control[:id='ac-2.1']` is the same as `#ac-2.1`


`$var` - a variable reference

`||` - a string concatenator

node operators: `union`, `intersect`, `except`

For = and !=
  flags and fields are cast to their respective string values
  
  within markup-line and markup-multiline,
    cast to markdown strings?
  
  assemblies remain nodes so $assembly1 = $assembly2 is true
  when the sets are the same
 
  "declare identity" enabling 

    e.g. compare @id flags?
	

# Worked examples


If a property has flag x its value flag must be Y

("property 'impact' must have the value LOW, MODERATE or HIGH")

<define-field name="prop">

```xml
<constrain when="^name='impact'">
  <allowed-values>
    <enum>LOW</enum>
    <enum>MODERATE</enum>
    <enum>HIGH</enum>
  </allowed-values>
</constrain>
```

If an assembly has flag X=x1, then field Y must be one of y1, y2, y3
(i.e., like the last one, but declared with the assembly model, not on the global field definition)

```xml
<define-assembly>
  <flag ref="X"/>
  <let name="Xx" be="^X"/>  <!-- $Xx now refers to the flag 'X' -->
  <model>
	<field ref="Y">
	  <constrain when="$Xx='x1'> <!-- the condition can now be set in the context of field Y -->
  	    <allowed-values>
	  	  <enum>y1</enum>
		  <enum>y2</enum>
	      <enum>y3</enum>
	    </allowed-values>
	  </constrain> 
	</field>
  </model>
</define-assembly>
```

@id is unique

```xml
<define-flag name="id">
  <constrain>
    <unique within="catalog"/>
  </constrain>
</define-flag>
```  
  
control contains a single prop[^name='label']
control contains no prop elements not named 'label'

```xml
<define-assembly name="control">
  <constrain>
    <require>
      <field name="prop" with="^name='label'" occurrence="one-only"/>
    </require>
    <forbid>
      <field name="prop" with="^name ='label'" occurrence="more-than-one"/>
      <field name="prop" with="^name!='label'" occurrence="one-or-more"/>
    </forbid>
  </constrain>
</define-assembly>
```

`occurrence` can be "one-only", "one-or-more", "more-than-one" (the last of which is especially useful in `forbid`)

insert/param-id corresponds to a param/@id

```xml
<define-field name="insert">
  <flag name="param-id"/>
  <constrain>
    <require>
      <assembly name="param" use-index="param-by-id" within="control" key="^param-id" occurrence="one-only"/>
    </require>
  </constrain>
</define-assembly>
```  

Index definitions (for key-based retrievals)


```xml
<define-index name="param-by-id" assembly="param" by-flag="id"/>
```

```xml
<define-index name="param-by-id" assembly="param">
  <using><value of="^id"/></using>
</define-index>
```

```xml
<define-index name="control-by-label" assembly="control">
  <using><value of=":prop[^name='label']"/></using>
</define-index>
```

When a/@href or link/@href starts with #, the following value must correspond to an @id in the document ...

```xml
<define-flag name="href">
  <constrain when="matches(.,'^#')">
    <let name="target_ID" be="replace(.,'^#','')"/>
    <require>
      <either>
        <field    with="^id=$target_ID" within="catalog" occurrence="one-only"/>
        <assembly with="^id=$target_ID" within="catalog" occurrence="one-only"/>
      </either>
    </require>
  </constrain>
</define-flag>
```

@with is a boolean test; the requirement is satisfied if a field is returned from the scope that satisfies the test. 

this is equivalent to

```
<define-index name="link-targets" assembly="control" by-flag="id"/>
<define-index name="link-targets" assembly="part"    by-flag="id"/>

<define-flag name="href">
  <constrain>
    <let name="target_ID" be="replace(.,'^#','')"/>
    <require>
      <one-of>
        <field    with="^id=$target_ID" within="catalog" occurrence="one-only"/>
        <assembly with="^id=$target_ID" within="catalog" occurrence="one-only"/>
      </one-of>
    </require>
  </constrain>
</define-flag>

<let name="x">
  <replace value="'^#'" with="''"/>
</let>
  
<let name="x">
    <value of="replace('^#','')"/>
</let>
```

hmmm

```xml
<require>
 <one-of>
   <field within="catalog" occurrence="one-only"> <!-- notice any field will do here -->
     <flag name="id" with=".=$target_ID"/>
   </field>
   <assembly with="^id=$target_ID" within="catalog" occurrence="one-only"/>
 </one-of>
</require>
```
	
  
# Model so far

reduced rnc-like notation:

```
constrain { attribute when { text },
            let*, allowed-values?, unique?, require*, forbid* }


let { attribute name { NCName }, attribute be { text }?,
  ( value | replace)* }
  
allowed-values { attribute allow-other { 'yes' | 'no' },
   enum+ }

unique { attribute within { text } }

require { (test | assembly | field | flag | one-of | any-of )* }

forbid  { (test | assembly | field | flag | one-of | any-of )* }

one-of { (require*, forbid*) }

any-of { (require*, forbid*) }
