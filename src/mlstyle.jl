using MLStyle

mlstyle(node) = @match node begin
    :({ $(kvs...) }) =>
        let f = @λ begin
                :($k : $v) -> Expr(:call, =>, string(k), mlstyle(v))
                :($k) -> Expr(:call, =>, string(k), mlstyle(k))
            end
            
            Expr(:call, Dict, (f(kv) for kv in kvs if !(kv isa LineNumberNode))...)
        end
    :[$(elts...)] => Expr(:vect, map(mlstyle, elts)...)
    a :: Symbol || a :: T where T <: Number || a :: T where T <: AbstractString => a
end

macro mlstyle(expr)
    mlstyle(expr) |> esc
end
