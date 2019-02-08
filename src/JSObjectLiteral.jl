module JSObjectLiteral

export @json, json

"""
@json expression

Tries to parse `expression` as a javascript object literal.

If `expression` is a valid Julia expression, and (almost) looks like a javascript
object literal, it is parsed and converted into a Julia json-like structure.

# Examples
```
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
"""
macro json(object)
    json(object)
end

"""json(Expr): turn expression into a json object"""
function json(e:: Expr)
    if e.head == :braces
        return Dict(pair(a) for a in e.args)
    elseif e.head == :vect
        return [json(a) for a in e.args]
    else
        return nothing
    end
end

function pair(e::Expr)
    if e.head != :call || length(e.args) !=3 || e.args[1] != :(:)
        error("Expected colon operator with 2 arguments")
    end
    return string(e.args[2]) => json(e.args[3])
end
pair(s::Symbol) = string(s) => Core.eval(Main, s)

json(x::Number) = x
json(s::AbstractString) = s
json(s::Symbol) = Core.eval(Main, s)
json(c::Char) = string(c)

end
