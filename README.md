# JSObjectLiteral.jl

[![Build Status](https://travis-ci.org/davidavdav/JSObjectLiteral.jl.svg?branch=master)](https://travis-ci.org/davidavdav/JSObjectLiteral.jl)

Parse javascript-like object literals in Julia into a Julia object

This package provides a macro `@js` that parses a Julia expression interpreted as javascript, and tries to form a Julia object from that.  You can use javascript shortcuts like `@js { a: b }` to write `Dict("a" => b)` and even `@js { a }` to write `Dict("a" => a)`.

I am not sure if this is useful for anything else than for me trying to understand macros and evaluation in Julia...

## `@js` expression

Parses the Julia expression as a javascript object literal.  It can be called either as `@js expression` or `@js(expression)`, the latter case explicitly delimits the extent of the expression being parsed by the macro.

### Example

```julia
pkg> add JSObjectLiteral

julia> using JSObjectLiteral

julia> e = 5.0
5.0

julia> g = "gee!"
"gee!"

julia> @js {
         a: 1,
         b: [2, 3 * 3, √],
         c : {
           d: "doubly-quoted string",
           e
         },
         f.g: g
       }
Dict{String, Any} with 4 entries:
  "f" => Dict{String, Any}("g"=>"gee!")
  "c" => Dict{String, Any}("e"=>5.0, "d"=>"doubly-quoted string")
  "b" => Any[2, 9, sqrt]
  "a" => 1

```
All dicts created in the process are always of type `Dict{String,Any}`, and all arrays are of type `Array{Any}`, to cater for future assignments of the elements to different types. 

Please note that we can't fully parse all javascript object literals, as Julia can't interpret singly-quoted strings as strings, only single characters can be parsed like this.

## Deep object traversal with `@js`

`@js(dotted expression)` traverses a hierachical json-like object directly.

### Example
```julia
julia> a = @js { b: { c: { d: 4 } } }
Dict{String, Any} with 1 entry:
  "b" => Dict{String, Any}("c"=>Dict{String, Any}("d"=>4))

julia> @js(a.b.c.d) == 4
true

julia> @js(a.b.c) == Dict("d" => 4)
true

julia> @js(a.b) == @js { c: { d: 4 } }
true

julia> @js(a.b) == @js { c.d: 4 }
true

```
The RHS in the last expression shows object creation in deep traversal.  Standard javascript does not allow this.

You can mix strings as keys with indices.
```julia
julia> d = @js { a: 1, b: [1, {c: 2}, 3], d: 4}
Dict{String, Any} with 3 entries:
  "b" => Any[1, Dict{String, Any}("c"=>2), 3]
  "a" => 1
  "d" => 4

julia> @js d.b[2].c
2

```

## Assignment

You make assignments in the `@js` expression:
```julia
julia> @js a = { b: 3 }
Dict{String, Any} with 1 entry:
  "b" => 3

julia> @js a.b = 4
4

julia> @js a.b = { c: 5 }
Dict{String, Any} with 1 entry:
  "c" => 5

julia> @js a.b.c = 6
6

julia> @js a, b = [ { c: 3}, { d: 4} ]
2-element Vector{Any}:
 Dict{String, Any}("c" => 3)
 Dict{String, Any}("d" => 4)

julia> @js dict = { d: π, e: [ 1, { f: 2}, 3], c: sin }
Dict{String, Any} with 3 entries:
  "c" => sin
  "e" => Any[1, Dict{String, Any}("f"=>2), 3]
  "d" => π

julia> @js { c, d, e } = dict
3-element Vector{Any}:
  sin (generic function with 13 methods)
 π = 3.1415926535897...
  Any[1, Dict{String, Any}("f" => 2), 3]

julia> c == sin ## true
true

julia> d == π ## true
true

julia> e == [ 1, Dict("f" => 2), 3] ## true
true

```

## The JSObject struct

We also have some support for dot-notation of JS-like objects in a native Julia struct.  This might already have been implemented before, and probably better, so please submit an issue "irrelevant code" if you know of any better implementation. 

The `JSObject` struct can wrap a classic Dict/Array based JS-like object, thus providing native Julia support for dot notation, using the `getproperty()` function. 

Examples:
```julia
julia> a = JSObject(@js({ b: { c: { d: 4 } } }))
{"b":{"c":{"d":4}}}

julia> a.b.c.d == 4 ## true
true

julia> a["b"].c["d"] == 4 ## true
true

julia> a.c = @js {d: { e: [5, 6] } }
Dict{String, Any} with 1 entry:
  "d" => Dict{String, Any}("e"=>Any[5, 6])

julia> a.c.d.e[2] == 6 ## true
true

julia> b = JSObject(@js([{c: 3}, {d: [4, {e: 5}]}]))
[{"c":3},{"d":[4,{"e":5}]}]

julia> b[1].c == 3
true

julia> b[2].d[1] == 4
true

julia> b[2].d[2].e == 5
true

```
The `JSObject` can hold a `Dict{String, Any}` or a `Vector{Any}` (or even a plain number or `String`, but that is not so useful).  

In assigning to a member of a `JSObject`, as in `a.c = @js {d: { e: [5, 6]}}`, the RHS is automatically wrapped in a `JSObject` for consistency. 

The constructors `JSObject()` parse all the values, and recursively make them into `JSObject`s in case they are of type `Dict` or `Vector`.  Other types are left as-is, so deeper `Int`s or floats are not unnecessarily wrapped.  

### Exporting to a plain old Julia JSON structure

You can access members of the `JSObject` struct using indexing `[]` and `.` notation.  But you may need to export the `JSObject` as a plain old JSON, consisting of ordinary `Dict`s and `Array`s.  You can do that using
```julia
julia> stripobject(b)
2-element Vector{Any}:
 Dict{String, Any}("c" => 3)
 Dict{String, Any}("d" => Any[4, Dict{String, Any}("e" => 5)])

```

In fact, this happens in the `show(io::IO, object::JSObject)` function to concisely display a variable of type `JSObject`, using `JSON.json()`. 
