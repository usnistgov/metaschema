# Schema metrics

Works over a grammar as given in a formal schema (XSD, RNG, DTD)

Or on an 'implicit schema' derived to reflect data object (element/attribute) occurrence across a given data set (one or more documents)


Step one - make model tree
  represents node occurrence
  at leaves, shows
    path (back) to data
    average/mean/mode length
    some kind of frequency/distribution indicator?

Step two - count parent/child (immediate hierarchical) pairs

c is the number of distinct nodes (elements)
p is the number of distinct parents

note the parents/children are not distributed evenly

for each c there is a different number of p
average p for each c? if close to c, then the arbitrariness / containment is high. (high entropy.) if closer to 1, then containment is strict (low entropy).

high entropy: count p/c is close to (c*c) 

      
      
```
<a b="n">
          <a b="n">
              <b>
                  <a>
                      <b></b>
                  </a>
              </b>
          </a>
      </a>
```

A low entropy count p/c is close to count c, p/c^2 is low depending on c (no of children)

```
<bob>
        <jim>
            <jane>
                <bill></bill>
                <joe></joe>
            </jane>
        </jim>
        <mark>
            <mary></mary>
        </mark>
    </bob>
```



absolute count of object types (element|attribute names)

where { p/c } is a set of p/c instances
  - extant parent/child
  - or permissible via schema
  - count(p) / count(c)*count(c)
    
    larger schemas address greater semantic complexity
    but do not always provide advantages
    paradoxically they can be difficult to extend and adapt
    also, problem of 'many ways to do things' is not solved
      by having more ways to do things
    
    for every a/b pair, how many have a b/a pair?
    how many a permit a//a?
    
## Semantic ordering

Such as, paragraph ordering within a section or block

how many element types exhibit possible semantic ordering among their children (or siblings)?


e has semantic order if it contains some E such that
a sibling has a different name with a sibling named E

(following-sibling::* except following-sibling::E)/following-sibling::E

or group-adjacent by E and see if two groups have the same grouping key

SCHEMA
  element type count
  
  parent/child analysis
    entropy metric (more 'entropy' = more generic modeling)

SURVEY OF ELEMENTS
  list - distinct parent types
         distinct child types
         proportion exhibiting semantic ordering among children
         
         
      (exists preceding sibling of a different name following a preceding sibling of the same name)
      
Mixed content as a species of semantic ordering
