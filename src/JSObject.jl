## Can we make a JavaScript-like object that natively supports a.b[1].c notation?

import JSON

export JSObject, stripobject

struct JSObject{T} 
    data::T
end

const JSDict = Dict{String, Any}
const JSArray = Vector{Any}
const JSElement = Union{Integer, AbstractFloat, AbstractString}

JSObject(data::AbstractDict) = objectify(data)
JSObject(data::AbstractVector) = objectify(data)
JSObject(data::T) where T <: JSElement = JSObject{T}(data)

objectify(dict::AbstractDict) = JSObject{JSDict}(JSDict(String(key) => objectify(value) for (key, value) in dict))
objectify(array::AbstractVector) = JSObject{JSArray}(Any[objectify(item) for item in array])
objectify(x) = x

Base.length(object::JSObject) = length(object.data)
Base.size(object::JSObject) = size(object.data)
Base.getindex(object::JSObject, i...) = getindex(getfield(object, :data), i...)
Base.setindex!(object::JSObject, value, index...) = setindex!(getfield(object, :data), objectify(value), index...)
Base.show(io::IO, object::JSObject) = print(io, JSON.json(stripobject(object)))

Base.getproperty(object::JSObject{JSDict}, key::Symbol) = getindex(getfield(object, :data), String(key))
Base.setproperty!(object::JSObject{JSDict}, key::Symbol, value) = setindex!(getfield(object, :data), objectify(value), String(key))

## The reverse operations, going from JSObject to plain Julia dicts/vectors
Base.convert(::Type{Dict}, x::JSObject{JSDict}) = stripobject(x)
Base.convert(::Type{Array}, x::JSObject{JSArray}) = stripobject(x)

stripobject(x::JSObject{JSDict}) = JSDict(key => stripobject(value) for (key, value) in getfield(x, :data))
stripobject(x::JSObject{JSArray}) = Any[stripobject(element) for element in getfield(x, :data)]
stripobject(x::JSObject{T}) where T <: JSElement = getfield(x, :data)
stripobject(x) = x

