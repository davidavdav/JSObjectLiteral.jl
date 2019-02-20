# JSObjectLiteral.jl

[![Build Status](https://travis-ci.org/davidavdav/JSObjectLiteral.jl.svg?branch=master)](https://travis-ci.org/davidavdav/JSObjectLiteral.jl)

Parse javascript-like object literals in Julia into a Julia object

This package provides a macro `@js` that parses a Julia expression interpreted as javascript, and tries to form a Julia object from that.  You can use javascript shortcuts like `@js { a: b }` to write `Dict("a" => b)` and even `@js { a }` to write `Dict("a" => a)`.

I am not sure if this is useful for anything else than for me trying to understand macros and evaluation in Julia...

## `@js` expression

Parses the Julia expression as a javascript object iteral.  It can be called either as `@js expression` or `@js(expression)`, the latter case explicitly delimits the extent of the expression being parsed by the macro.

### Example

```julia
## input
e = 5.0
g = "gee!"
@js {
  a: 1,
  b: [2, 3 * 3, √],
  c : {
    d: "doubly-quoted string",
    e
  },
  f.g: g
}
## results
Dict{String,Any} with 4 entries:
  "f" => Dict{String,Any}("g"=>"gee!")
  "c" => Dict{String,Any}("e"=>5.0,"d"=>"doubly-quoted string")
  "b" => Any[2, 9, sqrt]
  "a" => 1
```
All dicts created in the process are always of type `Dict{String,Any}`, and all arrays are of type `Array{Any}`, to cater for future assignments of the elements to different types. 

Please note that we can't fully parse all javascript object literals, as Julia can't interpret singly-quoted strings as strings, only single characters can be parsed like this.

## Deep object traversal with `@js`

`@js(dotted expression)` traverses a hierachical json-like object directly.

### Example
```julia
a = @js { b: { c: { d: 4 } } }
@js(a.b.c.d) == 4
@js(a.b.c) == Dict("d" => 4)
@js(a.b) == @js { c: { d: 4 } }
@js(a.b) == @js { c.d: 4 }
```
The RHS in the last expression shows object creation in deep traversal.  Standard javascript does not allow this.

You can mix strings as keys with indices.
```julia
d = @js { a: 1, b: [1, {c: 2}, 3], d: 4}
@js d.b[2].c
```

## Assignment

You make assignments in the `@js` expression:
```julia
@js a = { b: 3 }
@js a.b = 4
@js a.b = { c: 5 }
@js a.b.c = 6
@js a, b = [ { c: 3}, { d: 4} ]
@js dict = { d: π, e: [ 1, { f: 2}, 3], c: sin }
@js { c, d, e } = dict
c == sin ## true
d == π ## true
e == [ 1, Dict("f" => 2), 3] ## true
```
