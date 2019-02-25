using JSObjectLiteral
using Test

e = π
g = "gee!"

a = @js {
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

@test Dict{String, Any}( "a" => "a") == @js { a: "a" }

a = @js { b: { c: { d: 4 } } }

@test a == @js { b.c.d: 4 }
@test @js(a.b.c.d) == 4
@test @js(a.b.c) == Dict("d" => 4)
@test @js(a.b) == @js { c: { d: 4 } }

a = @js { f: x -> x^2, b: { g: √ } }

@test a["f"](5) == 25
@test @js(a.b.g)(49) == 7

@test Dict("a" => "b") == @js { a: "b" }

b = @js { c: 3 }
@test Dict("a" => b) == @js { a: b }

a = 101
@test Dict("a" => a) == @js { a }
@test Dict("a" => a+1 ) == @js { a: a + 1 }

e = exp(1)
@test Dict("a" => a, "b" => Dict("c" => Dict("d" => 5), "e" => e), "f" => [1, Dict("g" => 2)]) == @js { a, b: { c: { d: 5 }, e }, f: [1, { g: 2} ] }
@test Dict("a" => Dict("b" => 3)) == @js { a.b: 3 }
@test [a, b, 3] == @js [ a, b, 3 ]

c = [1, 2, @js({d: 3})]
a = @js { c }
@test @js(a.c[3].d) == 3
@test @js(a.c[a.c[3].d].d) == 3

@js a = { b.c.d: 4 }
@test @js(a.b) == @js { c: { d: 4 } }
@test @js(a.b.c) == @js { d: 4 }

@js a = { b: "c" }
@test a == @js { b: "c" }

@js a.b = "d"
@test a == @js { b: "d" }

@js a.b = { c: "d" }
@test a == @js { b.c: "d" }

@js a.b.c = "e"
@test a == @js { b: { c: "e" } }

@js b = { c: 3 }
@js a.b = b.c
@test a == @js { b: 3 }

@js a, b = [ { a: 1 }, { b: 2} ]
@test a == @js { a: 1 }
@test b == @js { b: 2 }

@js dict = { d: π, e: [ 1, { f: 2}, 3], c: sin }
@js { c, d, e } = dict
@test c == sin
@test d == π
@test e == [ 1, Dict("f" => 2), 3]

## issue #2
@test Dict("Content-Type" => "application/json") == @js { "Content-Type": "application/json"}
