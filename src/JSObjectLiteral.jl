module JSObjectLiteral

export @js, @json, @get, @identity

macro identity(e)
    #ret = id(__module__, e)
    #dump(ret)
    :($(esc(e)))
end

id(m, e::Expr) = :($(esc(e)))
id(m, s::Symbol) = :($(esc(s)))
id(m, x) = x

## evaluate in calling environment
eeval(x) = Core.eval(Main, x)

macro js(expr::Expr)
    js(expr)
end

## for expressions, dispatch according to the head
js(expr::Expr) = js(Val{expr.head}, expr)
js(x) = eeval(x)

## assignment
function js(::Type{Val{:(=)}}, expr)
    println("assignment ", length(expr.args))
    left = js(expr.args[1])
    right = js(expr.args[2])
    return Expr(expr.head, left, right)
end

## key index
function js(::Type{Val{:.}}, expr)
    return Expr(:ref, js(expr.args[1]), string(expr.args[2].value))
end

## array index
function js(::Type{Val{:ref}}, expr)
    return Expr(:ref, js(expr.args[1]), expr.args[2])
end

## dictionary creation
function js(::Type{Val{:braces}}, expr)
    return Dict{String,Any}(pair(a) for a in expr.args)
end

function pair(e::Expr)
    if e.head != :call || length(e.args) !=3 || e.args[1] != :(:)
        error("Expected colon operator with 2 arguments")
    end
    return keyvalue(e.args[2], e.args[3])
end
pair(s::Symbol) = string(s) => js(s)

function keyvalue(key::Expr, value)
    key.head == :. || error("Expected . operator")
    expr = Expr(:braces, Expr(:call, :(:), key.args[2].value, value))
    return keyvalue(key.args[1], expr)
end
keyvalue(key::Symbol, value) = string(key) => js(value)
keyvalue(key::AbstractString, value) = key => js(value)

function js(x, expr)
    println("catchall")
    return eeval(expr)
end

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
function json(expr:: Expr)
    if expr.head == :braces
        return Dict(pair(a) for a in expr.args)
    elseif expr.head == :vect
        return [json(a) for a in expr.args]
    elseif expr.head == :.
        return eeval(get(expr.args...))
    elseif expr.head == :(=)
        return eeval(assign(expr.args...))
    else
        return eeval(e)
    end
end

json(x::Number) = x
json(s::AbstractString) = s
json(s::Symbol) = eeval(s)
json(c::Char) = string(c)
json(x::T) where T = error("Not a JSON literal type ", T)


macro get(expr::Expr)
    if expr.head == :.
        eeval(get(expr.args...))
    elseif expr.head == :(=)
        eeval(assign(expr.args...))
    else
        error("Expected . or = operator")
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

function assign(expr::Expr, value)
    dump(expr)
    dump(value)
    if expr.head == :.
        dict = get(expr.args...)
        return Expr(:(=), dict, value)
    end
end

macro ee(x)
    Core.eval(__module__, x)
end


end
