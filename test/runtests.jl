using JSObjectLiteral
using Test

e = π
g = "gee!"

a = @json {
  a: 1,
  b: [2, 3 * 3],
  c : {
    d: "doubly-quoted string",
    e
  },
  f: g
}

b = Dict{String, Any}(
  "a" => 1,
  "b" => [2, 9],
  "c" => Dict{String, Any}(
    "d" => "doubly-quoted string",
    "e" => π
  ),
  "f" => "gee!"
)

@test a == b

@test Dict{String, Any}( "a" => "a") == @json { a: "a" }

a = @json { b: { c: { d: 4 } } }
@test @get(a.b.c.d) == 4
@test @get(a.b.c) == Dict("d" => 4)
@test @get(a.b) == @json { c: { d: 4 } }

a = @json { f: x -> x^2, b: { g: √ } }

@test a["f"](5) == 25
@test @get(a.b.g)(49) == 7
