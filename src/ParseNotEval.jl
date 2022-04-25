module ParseNotEval
__precompile__()
using Dates
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
    x::String = replace(s, " " => "")
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
            x = parse(Pair, x)
        catch
            return(x)
        end
        return(x)
        # Bool
    elseif contains(x, "true") || contains(x, "false")
        x = replace(x, " " => "")
        try
            x = parse(Bool, x)
        catch
            return(x)
        end
        return(x)
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
### parse(T::Type{Array}, s::AbstractString) -> Array{typeof(parse(Any, **s**))}
Parses **s** into type **T**.
**arguments**
- T <: DataType; type to parse **s** into.
- s <: AbstractString; string to be parsed into type **T**.
----------------
### example
```
example_input = "[5, 10, 15, 20]"
my_array::Array{Int64} = parse(Array, example_input)
[5, 10, 15, 20]
my_array::Array{Float64} = parse(Float64, my_array)
[5.0, 10.0, 15.0, 20.0]
```
"""
function parse(T::Type{Array}, s::AbstractString)
    println("calling parse array")
    if ~(contains(s, "["))
        throw(ErrorException("$s not parsable as $T !");)
    end
    s::String = replace(s, "[" => "")
    s = replace(s, "]" => "")
    s = replace(s, " " => "")
    dims::Array = split(s, ",")
    T::DataType = typeof(parse(Any, string(dims[1]))) # <- we check type now by parsing any,
# so that way we can parse as something instead of as Any (waaaay faster.)
    [try; parse(T, d) catch; nothing end for d in dims]::Vector
end
"""

"""
parse(T::Type{String}, s::AbstractString) = string(s)
"""

"""
function parse(T::Type{Dict}, s::AbstractString)
    s::String = replace(s, " " => "")
    structures = Dict()
    # For Json formatted dict
    if contains(s, ":")
        s = replace(s, ":" => "=>")
    end
    # We need to make sure there are no arrays/dicts before we separate
    # pairs by ,
    points = findall("=>", s)
    points = [p[1] for p in points]
    if length(findall("{", s)) == 1
        # Checks for dictionaries, marks them
        s = replace(s, "{" => "")
        s = replace(s, "}" => "")
    else
        for pos in findall("{", s)
            pos = pos[1]
            if pos != 1
                close = findnext("}", s, pos)[1]
                println(pos:close)
                for point in 1:length(points)
                    if point != length(points) - 1
                        if point == length(points)
                            if close in Array(points[point]:points[point + 1])
                                push!(point => parse(Dict, s[pos:close]))
                                s = replace(s, s[pos:close] => "")
                            end
                        end
                    end
                    end
                end
            else

            end

        end
    end
    if contains(s, "[")

    end
    newdct = Dict()
    valsnkeys = split(s, ",")
    for val in 1:length(valsnkeys)
        keyval = split(valsnkeys[val], "=>")
        if val in keys(structures)
            push!(newdct,
             parse(Symbol, valsnkeys[val][1]) => parse(Any, structures[val]))
        else
            push!(newdct, parse(Symbol, keyval[1]) => parse(Any, keyval[2]))
        end
    end
    newdct
end

parse(T::Type{Symbol}, s::AbstractString) = Symbol(s)

function parse(T::Type{Date}, s::AbstractString)
    # 2013-07-01
    s = split(s, "-")
    if length(s) > 3
        throw(" Too many elements for a Date.")
    end
    y::Year = Dates.Year(parse(Int64, s[1]))
    m::Month = Dates.Month(parse(Int64, s[2]))
    d::Day = Dates.Day(parse(Int64, s[3]))
    Date(y, m, d)::Date
end

function parse(T::Type{DateTime}, s::AbstractString)
    
end

function parse(T::Type{Pair}, s::AbstractString)
    s = replace(s, " " => "")
    key_val = split(s, "=>")
    parse(Symbol, key_val[1]) => parse(Any, key_val)
end

function parse(T::Type{missing})
    return(missing)
end
"""
"""
parse(type::Type, x::Array) = [parse(type, val) for val in x]
parse(type::Type, x::Pair) = x[1] => parse(type, x[2])

export parse, Date
end # module
