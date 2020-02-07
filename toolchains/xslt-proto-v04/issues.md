
## Overall goals

Stable implementation - runs without having to revisit
Easy to use - complexities are hidden from the casual user but traceable/verifiable by the expert
Well documented = both Metaschema spec and this toolkit
Support deployment as a library of functionalities over formats defined by an arbitrary metaschema

## Stabilize metaschema composition

* write spec (Github project wiki?)
* implement as pipeline with debug traceability
* XSD/RNG for both pre and post composition metaschema? (post is subset of pre)
* Schematron for pre-composition metaschema

deploy as pipeline w/ no micropipelining
  unit test stages (XSpec)
  XProc for debugging, XSLT wrapper for deployment

result of composition is:
  single standalone file instance
  including all samples as literals not callouts
  all field and flag definitions are collapsed and localized
  all assembly definitions are exposed as entry points
    all fields and flags definitions are localized

## Implement Metaschema exploder

The Metaschema exploder is the next step to 'ambidexterous' JSON/XML support. It is the pivot format from which native schemas are derived. We produce it by mapping from a (composed) Metaschema. Basically it maps constraint definitions over into an abstract model of a document.

It represents all JSON and XML features in normalized and tagged form, isomorphic to its targets.

A processor can go from this exploded form ('compiled') into XSD or JSON Schema

NB that much of this logic exists in the model map production pipeline

## Implement JSON Schema production

P1 Unit tests!

## Implement XSD production

P1 Unit tests!

## Implement XML to JSON converter

Build in two parts: XML to supermodel, supermodel to JSON

write a supermodel XSD/RNG generator?

Provide XProc and XSLT wrapper logic for these pipelines
  (XProc: nice for debugging in an IDE - XSLT: reduce dependency to SaxonHE)

## Migrate/update and possibly refactor docs production pipeline

(The main problem here is the development/debug cycle but there could also be feature requests)  

*Separate entry points* for docs production and model production.

## Migrate/update model map production