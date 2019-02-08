using JSObjectLiteral
using Test

e = π
g = "gee!"

a = @json {
  a: 1,
  b: [2, 3],
  c : {
    d: "doubly-quoted string",
    e
  },
  f: g
}

b = Dict{String, Any}(
  "a" => 1,
  "b" => [2, 3],
  "c" => Dict{String, Any}(
    "d" => "doubly-quoted string",
    "e" => π
  ),
  "f" => "gee!"
)

@test a == b

@test Dict{String, Any}( "a" => "a") == @json { a: "a" }
