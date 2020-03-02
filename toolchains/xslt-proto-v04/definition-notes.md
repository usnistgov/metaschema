# Addressing - returning objects (branches)

We are probably not able to express the query semantics we need entirely via tagging; a concise XPath-like notation is probably necessary.

Even if only a desideratum, designing such a notation - and perhaps maintaining a semantic-equivalent representation using tagging if possible - while keeping an effective XPath mapping running under tests - helps us understand the requirements.

So the examples below use a mix of explicit tagging semantics, and a specialized notation we inevitably call *Metapath*.

## Metapath

Metapath is XPath for Metaschema. It maps to equivalent XPath (for XML) or to a JSON addressing syntax as needed. It assumes a metaschema as a backbone, meaning its data model the Metaschema data model.

### Data model

In the Metaschema model, a document is an assembly comprised of assemblies. An assembly is an arbitrary but controlled amalgamation of data objects.

Objects grouped with an assembly include both assemblies, and fields, a specialized kind of assembly that carries, instead of assemblies of its own, a nominal *value* -- arbitrary, typed strings. Within an assembly, all assemblies and fields are labeled and (when appropriate) grouped for addressing.

Additionally, both assemblies and fields may have *flags*, a simple name-value pair that provides for additional information to be associated with them. Assemblies and fields are not limited in how large or complex they may be.

A Metapath expression, reading from left to right going "down" the hierarchy, will always proceed from assemblies to fields to flags.

### Notation

. the current branch (equiv XPath self::node())
^flag - a flag named 'flag' (XPath @flag)

name  - a field or assembly branch of the current branch, named 'name'
@name - an assembly named 'name'
:name - a field named 'name'
/ - an abbreviation for `@` or `:` or '^' (as informed by a metaschema)

So `/control/name` is the same as `@control^name`

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
  <replace replacing="'^#'" with="''"/>
</let>
  
<let name="x">
    <value of="replace(.,'^#','')"/>
</let>

<let name="x">
    <eval function="replace">
	  <arg>.</arg>
	  <arg>'^#'</arg>
	  <arg>''</arg>
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


'label' property on control must match regex:

```xml
<define-flag name="prop">
  <constrain when=":name='label'">
    <let name="regex" be="(AC|AT|MP)\-\d\d?"/>
    <require>
      <test eval="matches(.,$regex)">The label matches regex { $regex }</test>
    </require>
  </constrain>
</define-flag>
```	

... or ...

```xml
<define-flag name="prop">
  <constrain when="name='label'">
    <!-- alternative syntax: ^name='label' -->
    <let name="regex" be="(AC|AT|MP)\-\d\d?"/>
    <require>
      <test function="regex-match">
	    <arg>.</arg>
	    <arg>$regex</arg>
	    <report>The label matches regex { $regex }</report>
	  </test>
    </require>
  </constrain>
</define-flag>
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

forbid  { (test | assembly | field | flag)* }

one-of { (require*, forbid*) }

any-of { (require*, forbid*) }

assembly { flag*, field*, test* }

field { flag*, test* }

flag { test* }

```
