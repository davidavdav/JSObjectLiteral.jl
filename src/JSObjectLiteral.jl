module JSObjectLiteral

export @json, @get

eeval(x) = Core.eval(Main, x)

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
        return Core.eval(Main, e)
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
json(x::T) where T = error("Not a JSON literal type ", T)


macro get(expr::Expr)
    if expr.head == :.
        eeval(get(expr.args...))
    else
        error("Expected . operator")
    end
end

macro get(x)
    eeval(x)
end

function get(dict::Symbol, key::QuoteNode)
    return Expr(:ref, dict, string(key.value))
end

function get(expr::Expr, key::QuoteNode)
    if expr.head == :.
        dict = get(expr.args...)
        return Expr(:ref, dict, string(key.value))
    end
end

end
