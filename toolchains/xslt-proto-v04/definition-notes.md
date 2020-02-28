part
  - any assembly, field or flag anywhere named 'part'

part/prop
  - any assembly, field or flag named prop on an assembly or field named part
  


allowed values
regex pattern matching
existence/non-existance are conditions

uniqueness across a scope
  define the scope with a path (match pattern)
  values of key need to be selectable

define a named key
  use in co-occurrence constraints

path to a thing 
  e.g. param-id corresponds to a parameter someplace

constrain when conditioned
  (apply a set of constraints)
  as simple as value matches pattern
  


<define-flag name="prop">

<constrain when="@name='impact'">
  <allowed-values>
    <enum>LOW</enum>
	<enum>MODERATE</enum>
	<enum>HIGH</enum>
  </allowed-values>
</constrain>
  
If a property has flag x its value flag must be Y

("property 'impact' must have the value LOW, MODERATE or HIGH")

  (keyref, one of the set of values, or regex match)

@id is unique

<define-flag name="id">
  <constrain>
    <unique scope="group"/>
  </constrain>
</define-flag>
  

param-id corresponds to a param/@id


<define-assembly name="param">
  <define-flag name="param-id">
    <constrain>
	  <exists use-index="param-by-id" key="."/>
	</constrain>
  </define-flag>
</define-assembly>
  
<define-index name="param-by-id" assembly="param" by-flag="id"/>

<define-index name="control-by-label" assembly="control" by-field="prop[name='label']"/>


"Value of param-id must correspond to a param/@id in document scope)

control contains a single prop[name='label']

<define-assembly name="control">
  <constrain>
    <require>
	  <field name="prop" with="name='label'" occurrence="one-only"/>
	</require>
	<forbid>
	  <field name="prop" with="name='label'" occurrence="more-than-one"/>
	</forbid>
  </constrain>
</define-assembly>


When a/@href or link/@href starts with #, the following value must correspond to an @id in the document ...