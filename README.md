# JSObjectLiteral.jl

[![Build Status](https://travis-ci.org/davidavdav/JSObjectLiteral.jl.svg?branch=master)](https://travis-ci.org/davidavdav/JSObjectLiteral.jl)

Parse javascript-like object literals in Julia into a Julia object

This package provides a macro `@json` that parses a Julia expression, and tries to form a Julia object from that.  You can use javascript shortcuts like `@json { a: b }` to write `Dict("a" => b)` and even `@json { a }` to write `Dict("a" => a)`.

I am not sure if this is useful for anything else than for me trying to understand macros and evaluation in Julia...

## `@json` expression

Parses the Julia expression as a javascript object iteral.  String literals need to be doubly quoted.

### Example

```julia
## input
e = 5.0
g = "gee!"
@json {
  a: 1,
  b: [2, 3 * 3],
  c : {
    d: "doubly-quoted string",
    e
  },
  f: g
}
## results
Dict{String,Any} with 4 entries:
  "f" => "gee!"
  "c" => Dict{String,Any}("e"=>5.0,"d"=>"doubly-quoted string")
  "b" => [2, 9]
  "a" => 1
```

Please note that we can't fully parse all javascript object literals, as Julia can't interpret singly-quoted strings as strings, only single characters can be parsed like this.

## Deep object traversal with `@get`

`@get(dotted expression)` traverses a hierachical json-like object directly.

### Example
```julia
a = @json { b: { c: { d: 4 } } }
@get(a.b.c.d) == 4
@get(a.b.c) == Dict("d" => 4)
@get(a.b) == @json { c: { d: 4 } }
```

In the future we may allow assignment using a deep index expression.  
