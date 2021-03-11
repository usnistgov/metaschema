# xslt3-ts XSLT 3 Typescript

Be sure to run `npm install` to resolve dependencies.

## Testing this installation

### Run `npm install`

This should update your libraries including `saxon-js` and its CL wrapper `xslt3`.

### Test Saxon-JS from the CL

#### Hello World!

Open a command prompt in the directory `xslt3-ts`.

Bash:

```bash
$ xslt3 -s:hello.xsl -xsl:hello.xsl
```

Windows Powershell:

```Powershell
> xslt3 "-s:hello.xsl" "-xsl:hello.xsl"
```

The processor should return

```xml
<?xml version="1.0" encoding="UTF-8"?><h1>Hello World!</h1>
```

(This XSLT will return the same result for any input document.)

#### XSLT processor/version report

```bash
$ xslt3 -s:processor-version.xsl -xsl:processor-version.xsl \!indent=true
```

Should return HTML reporting Saxon-JS (version 2.1 or later) from Saxonica.

In this command, `\!indent=true` is bash for `!indent=true`.

## Invoking XSLT from the command line

Syntax summary:

| argument | purpose/use | (note) |
|--|--|--|
| `-s:file` | XML source | A file or URI |
| `-json:file` | JSON source | Alternative to `-s`* |
| `-xsl:file` | XSLT | Or compiled SEF JSON |
| `-o:file` | output | Result target and base URI for `xsl:result-document` |
| `-im:mode` | initial mode |  |
| `-it:template` | initial template |  |
| `param=value` | XSLT runtime parameter |  |
| `!param=value` | output parameter | Provides or overrides `xsl:output` setting |

\* One of `-s`, `-json`, `-it` or `-nogo` must be used, and `-s` and `-json` (XML or JSON source) are mutually exclusive.

See SaxonJS documentation for more and for hints: https://www.saxonica.com/saxon-js/documentation/index.html#!nodejs/command-line

## How to compile into SEF from CL

The same docs have the arguments for compiling XSLT into SEF (Saxon Executable Format?), a JSON application format:

* `-export:file` export the XSLT as (compiled JSON) SEF - use suffix `.json`
* `-nogo` Don't run the transformation; only compile it (producing SEF JSON)

The resulting JSON file, a compiled transformation specification, can be applied to XML (or JSON) data from within scripts.

***Coming soon: How to invoke XSLT programmatically***
