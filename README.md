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

## The JSObject struct

We also have some support for dot-notation of JS-like objects in a native Julia struct.  This might already have been implemented before, and probably better, so please submit an issue "irrelevant code" if you know of any better implementation. 

The `JSObject` struct can wrap a classic Dict/Array based JS-like object, thus providing native Julia support for dot notation, using the `getproperty()` function. 

Examples:
```julia
a = JSObject(@js({ b: { c: { d: 4 } } }))
a.b.c.d == 4 ## true
a["b"].c["d"] == 4 ## true

a.c = @js {d: { e: [5, 6] } }
a.c.d.e[2] == 6 ## true

b = JSObject(@js([{c: 3}, {d: [4, {e: 5}]}]))
b[1].c == 3
b[2].d[1] == 4
b[2].d[2].e == 5
```
The `JSObject` can hold a `Dict{String, Any}` or a `Vector{Any}` (or even a plain number or `String`, but that is not so useful).  

In assigning to a member of a `JSObject`, as in `a.c = @js {d: { e: [5, 6]}}`, the RHS is automatically wrapped in a `JSObject` for consistency. 

The constructors `JSObject()` parse all the values, and recursively make them into `JSObject`s in case they are of type `Dict` or `Vector`.  Other types are left as-is, so deeper `Int`s or floats are not unnecissarily wrapped.  

### Exporting to a plain old Julias JSON structure

You can access members of the `JSObject` struct using indexing `[]` and `.` notation.  But you may need to export the `JSObject` as a plain old JSON, consisting of ordinary `Dict`s and `Array`s.  You can do that using
```julia
stripobject(object::JSObject)
```

In fact, this happens in the `show(io::IO, object::JSObject)` function to consicely display a variable of type `JSObject`, using `JSON.json()`. 
