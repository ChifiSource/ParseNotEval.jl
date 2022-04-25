module ParseNotEval
__precompile__()
using Dates: Date
import Base: parse
"""
- ParseNotEval.jl
### parse(T::typeof(Any), s::AbstractString)
------------------------------------------
Guesses the type of some string data based on inference. Therefore, most of the
time it will likely parse data into the correct type, but there are times when
you might want to pass a type to parse. Will always fall back on string if the
correct type is not found.
```
parse(type)
```
"""
function parse(T::Type{Any}, s::AbstractString)
    x = replace(s, " " => "")
    if contains(x, ".")
        try
            x = parse(Float64, x)
        catch
            try
                x = parse(Date, x)
            catch
                x = x
            end
        end
        return(x)
        # Dict
    elseif contains(x, "{")
        try
            x = parse(Dict, x)
        catch
            x = x
        end
        return(x)
        # Array
    elseif contains(x, "[")
        try
            x = parse(Array, x)
        catch
            x = x
        end
        return(x)
        # Pair
    elseif contains(x, "=>")
        try
            parse(Pair, x)
        catch
            return(x)
        end
        # Bool
    elseif contains(x, "true") || contains(x, "false")
        x = replace(x, " " => "")
        try
            x = parse(Bool, x)
        catch
            return(x)
        end
        # Integers/Date/String
    else
        try
            x = parse(Int64, x)
        catch
            try
                x = parse(Date, x)
            catch
                x = x
            end
        end==#
        return(x)
    end
end
"""

"""
function parse(T::Type{Array}, s::AbstractString)
    println("calling parse array")
    if ~(contains(s, "["))
        throw(ErrorException("$s not parsable as $T !");)
    end
    s = replace(s, "[" => "")
    s = replace(s, "]" => "")
    s = replace(s, " " => "")
    dims = split(s, ",")
    T = typeof(parse(Any, string(dims[1]))) # <- we check type now by parsing any,
# so that way we can parse as something instead of as Any (waaaay faster.)
    [try; parse(T, d) catch; nothing end for d in dims]
end
"""

"""
parse(T::Type{String}, s::AbstractString) = string(s)
"""

"""
function parse(T::Type{Dict}, s::AbstractString)
    s = replace(s, "{" => "")
    s = replace(s, "}" => "")
    s = replace(s, " " => "")
    # Json formatted dict
    if contains(s, ":")
        s = replace(s, ":" => "=>")
    # Julia formatted dict
    end
    valsnkeys = split(s, "=>")
    vals = valsnkeys[2:2:length(valsnkeys)]
    keys = valsnkeys[1:2:length(valsnkeys)]
    newdct = Dict()
    for (key, val) in zip(keys, vals)
        push!(newdct, parse(Symbol, key) => parse(Any, val))
    end
    newdct
end

parse(T::Type{Symbol}, s::AbstractString) = Symbol(s)

function parse(T::Type{Date}, s::AbstractString)
    # 2013-07-01
end

function parse(T::Type{Pair}, s::AbstractString)
    s = replace(s, " " => "")
    key_val = split(s, "=>")
    parse(Symbol, key_val[1]) => parse(Any, key_val)
end

function parse(T::Type{missing})
    return(missing)
end

parse(type::Type, x::Array) = [parse(type, val) for val in x]
parse(type::Type, x::Pair) = x[1] => parse(type, x[2])

export parse, Date
end # module
