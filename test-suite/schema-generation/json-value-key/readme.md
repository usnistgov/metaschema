# JSON value key

**Status** - untested, unknown - **TBD**

These tests are known to have run in the past but current status is not confirmed.

## Tasks

- replace `flag-name` with `flag-ref` throughout
- follow `@json-key-flag` assignment downstream in metaschema pipeline

## Summary

Assignment of either static or dynamic value keys for fields in JSON data

Only fields have 'value' properties that typically must be renamed in exposed data.

### Static value key

A static assignments sets the string that will be used as the value key.

### Dynamic value key

A dynamic assignment binds the key to a flag on the field. Whatever that flag's value is, this value is used as the *key* for the JSON property that will be treated as the value.

This weirdness is easiest to see by comparing XML to JSON.

So we declare a repeatable field called "holiday", with a flag and a value. The flag represents the ISO date form of a given date. The value names a holiday that occurs on that date. So,

```xml
<holiday date="2022-07-04">Independence Day 2022</holiday>
<holiday date="2022-11-11">Veteran's Day 2022</holiday>
```

The metaschema permits grouping these objects as "holidays", while also promoting the `date` flag to be the value key for each "holiday" object in the JSON:

```json
"holidays": [
  { "2022-07-04": "Independence Day 2022" }
  { "2022-11-11": "Veteran's Day 2022" }
]
```

Note: the *value* of the field is always its string (text) value in XML, aka its "content". (Note that in cases of markup-line and markup-multiline, this content may be markup or have markup.) In XML this value needs no explicit label.

Without this feature promoting a flag to serve as JSON key we could encode, less concisely,

```json
"holidays": [
  { date: "2022-07-04", name: "Independence Day 2022" },
  { date: "2022-11-11": name: "Veteran's Day 2022" }
]
```

We would achieve this by setting the json-value-key to "name" (since "name" is the name we give to the value).

Special note: assigning a flag this role also implies a new constraint, namely that this value is also distinctive among sibling objects.
