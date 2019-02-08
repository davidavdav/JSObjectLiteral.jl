# JSObjectLiteral.jl
Parse javascript-like object literals in Julia into a Julia object

This package provides a macro `@json` than parses a Julia expression, and tries to form Julia object from that.  You can use javascript shortcuts like `@json { a: b }` to write `Dict("a" => b)` and even `@json { a }` to write `Dict("a" => a)`.

I am not sure if this is useful for anything else than for me trying to understand macros and evaluation in Julia...

## Example

```julia
e = 5.0
g = "gee!"
@json {
  a: 1,
  b: [2, 3],
  c : {
    d: "doubly-quoted string",
    e
  },
  f: g
}
```

Please note that we can't fully parse all javascript object literals, as Julia can't interpret singly-quoted strings as strings, only single characters can be parsed like this.
