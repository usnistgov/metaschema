# XSLT M4 Implementation Testing

Each folder contains one or more XSpecs, testing one or more functions or transformations specific to the XSLT M4 processing pipeline.

In the pipeline each of the transformations is executed in turn, each one reading for its inputs the results of the transformation preceding it. Together, they accomplish the entire operation of metaschema composition. These tests exercise the separate phases in isolation from one another, so these transitions can be exposed and managed.

See the `*.xspec` files in each folder for more details.

End to end tests for any metaschema composition process -- not only this set of XSLT transformations -- can be found [in its own folder in this repository](../../../../test-suite/metaschema-xspec/).

## Dev strategy

Each step needs tests specifically tailored to the functional requirements of that step. These are in progress.

Also, for each step we need not only standalone tests, but standoff file tests with externally maintained `expected` folders.

With these in place, each step can have at least one test that works on inputs in the `expected` folder of the preceding branch, to help maintain alignment among the tests.

TODO:
- update present tests
- build out more tests
  - work up to three variants? skeletal, basic and pathological (showing errors/exceptions)
  - also unit test any special handling or reasonable edge conditions 
- pull together 'predecessor' tests that formalize the chain
- extend XSD / Schematron to support final results?

## Entry points

See the [readme in the parent folder](../readme.md) for details about metaschema composition. The XProcs here are designed to test one or another of the single phases of transformation that are executed in the M4 metaschema composition sequence.

Accordingly, samples of metaschema inputs given with these tests will typically specify *intermediate* results that are not expected to persist in the system, ordinarily, after final results are delivered.

