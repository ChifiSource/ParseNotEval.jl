"""
Created in April, 2022 by
[chifi - an open source software dynasty.](https://github.com/orgs/ChifiSource)
by team
[odd-data](https://github.com/orgs/ChifiSource/teams/odd-data)
This software is MIT-licensed.
### ParseNotEval
A module which extends Julia's parse() method to work with a set number of types.
This is useful for file readers and recieving types through a request. If you
    are using this module, it is likely through OddFrames -> OddStructures
##### Module Composition
- [**ParseNotEval**]() - High-level API
"""
module ParseNotEval
using Dates
import Base: parse
__precompile__()
"""
### parse(T::Type{Any}, s::AbstractString) -> ::Any
Trys to guess the type of a string implicitly. For a more explicit assumption
of type, try passing the type as the first argument.
**arguments**
- T <: DataType; type to parse **s** into.
- s <: AbstractString; string to be parsed into type **T**.
----------------
### example
```
example_input = "[5, 10, 15, 20]"
my_array::Array{Int64} = parse(Array, example_input)
[5, 10, 15, 20]

example_input = "5"
myint::Int64 = parse(Any, example_input)
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
### parse(T::Type{Array}, s::AbstractString) -> ::Array{typeof(parse(Any, **s**))}
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
    if ~(contains(s, "["))
        throw(ErrorException("$s not parsable as $T !");)
    end
    s::String = replace(s, "[" => "")
    s = replace(s, "]" => "")
    s = replace(s, " " => "")
    dims::Array = split(s, ",")
    T::DataType = typeof(parse(Any, string(dims[1]))) # <- we check type now by parsing any,
# so that way we can parse as something instead of as Any (waaaay faster.)
    [try; parse(T, d) catch; missing end for d in dims]::Vector
end

"""
### parse(T::Type{String}, s::AbstractString) -> ::String
Although parsing a string into a string is not necessary, the reason why the
binding exists is so that if dims are parsed by type, they can still have a
    normal return whenever they are strings.
**arguments**
- T <: DataType; type to parse **s** into.
- s <: AbstractString; string to be parsed into type **T**.
----------------
### example
```
example_input = "5"
myint::Int64 = parse(String, example_input)
typeof(myint) == String
true
```
"""
parse(T::Type{String}, s::AbstractString) = string(s)

"""
### parse(T::Type{Dict}, s::AbstractString) -> ::Dict
Parses a dict. Can inclkude any of the following examples of input:
- JSON data; e.g. "{A:5, x:6}"
- Dict data; e.g. "A => [5, 10, 15, 20], B => [5, 10, 15, 20]"
**arguments**
- T <: DataType; type to parse **s** into.
- s <: AbstractString; string to be parsed into type **T**.
----------------
### example
```
example_input::String = "{x => [5, 10, 15], y = [5, 8, 7]}"
my_dct::Dict = parse(Dict, example_input)

example_input::String = "{x : [5, 10, 15], y : [5, 8, 7]}"
my_dct::Dict = parse(Dict, example_input)

typeof(myint) == Dict
true
```
"""
function parse(T::Type{Dict}, s::AbstractString)
    s::String = replace(s, " " => "")
    # For Json formatted dict
    if contains(s, ":")
        s = replace(s, ":" => "=>")
    end
    # Get rid of spaces
    s = replace(s, " " => "")
    dims::Vector{SubString} = split(s, ",")
    char::Int64 = 0
    ret_dct::Dict = Dict()
    prior_separator = 0
    for dim in dims
        char += length(dim)
        if prior_separator != 0
            if char <= prior_separator

            end
            if char > prior_separator
                prior_separator = 0
            end
        else
            key_val::Vector{SubString} = split(dim, "=>")
            println(key_val)
            key::Symbol = parse(Symbol, key_val[1])
            # Check for other Array/Dict Seperators
            if contains(key_val[2], "[")
                pos = findnext("]", s, char)[1]
                val = parse(Array, s[char - 1:pos])
                prior_separator = pos
            elseif contains(key_val[2], "{")
                pos = findnext("}", s, char)[1]
                val = parse(Dict, s[char:pos])
                prior_separator = pos
            elseif contains(key_val[2], "(")
                pos = findnext(")", s, char)[1]
                val = parse(Tuple, s[char:pos])
                prior_separator = pos
            else
                val = key_val[2]
            end
            push!(ret_dct, key => val)
        end
    end
    ret_dct
end

"""
### parse(T::Type{Symbol}, s::AbstractString) -> ::Symbol
Parses a symbol, without the colon. It is really a simple binded call to the
constructor Symbol(::AbstractString).
**arguments**
- T <: DataType; type to parse **s** into.
- s <: AbstractString; string to be parsed into type **T**.
----------------
### example
```
example_input::String = "hello"
symb::Symbol = parse(Symbol, example_input)

:hello

typeof(myint) == Symbol
true
```
"""
parse(T::Type{Symbol}, s::AbstractString) = Symbol(s)

"""
### parse(T::Type{Date}, s::AbstractString) -> ::Date
Parses a date, with appropriate formatting, from string to date. Requires '-'
separators be used.
**arguments**
- T <: DataType; type to parse **s** into.
- s <: AbstractString; string to be parsed into type **T**.
----------------
### example
```
example_input::String = "1999-11-23"
symb::Date = parse(Date, example_input)
typeof(myint) == Date
true
```
"""
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

"""
### parse(T::Type{DateTime}, s::AbstractString) -> ::DateTime
Parses a date with time, with appropriate formatting, from string to date.
Requires '-' and ':' separators be used.
**arguments**
- T <: DataType; type to parse **s** into.
- s <: AbstractString; string to be parsed into type **T**.
----------------
### example
```
example_input::String = "1999-11-23:8000"
symb::DateTime = parse(DateTime, example_input)
typeof(myint) == DateTime
true
```
"""
function parse(T::Type{DateTime}, s::AbstractString)
    t::String = split(s, ":")[2]
    s::String = split(s, ":")[1]
    s = split(s, "-")
    if length(s) > 3
        throw(" Too many elements for a Date.")
    end
    y::Year = Dates.Year(parse(Int64, s[1]))
    m::Month = Dates.Month(parse(Int64, s[2]))
    d::Day = Dates.Day(parse(Int64, s[3]))
    t::Time = Dates.Time(parse(Int64, t))
    DateTime(y, m, d, t)::DateTime
end

"""
### parse(T::Type{Pair}, s::AbstractString) -> ::Pair
Parses a string **s** into type **T**.
**arguments**
- T <: DataType; type to parse **s** into.
- s <: AbstractString; string to be parsed into type **T**.
----------------
### example
```
example_input::String = "x => 5"
symb::Pair = parse(Pair, example_input)
typeof(myint) == Pair
true
```
"""
function parse(T::Type{Pair}, s::AbstractString)
    s::String = replace(s, " " => "")
    key_val::Vector = split(s, "=>")
    parse(Symbol, key_val[1]) => parse(Any, key_val)
end

"""
### parse(T::Type{Pair}, s::AbstractArray) -> ::Array{T}
Parses each element inside of of **s** into type **T**. Replaces
arguments that cannot be casted with missing.
**arguments**
- T <: DataType; type to parse **s** into.
- s <: AbstractArray; the array to be casted.
----------------
### example
```
example_input = ["55", "82", "hello"]
new = parse(Int64, example_input)
new
[55, 82, missing]
```
"""
parse(T::Type, x::AbstractArray) = begin
    [try; parse(T, d) catch; missing end for d in x]::Vector
end

"""
### parse(T::Type{Pair}, s::Pair) -> ::Pair{Symbol, T}
Parses the pair value **s[2]** into type **T**.
**arguments**
- T <: DataType; type to parse **s** into.
- s <: AbstractArray; the array to be casted.
----------------
### example
```
example_input::Pair = :A => "5"
new::Pair = parse(Int64, example_input)
new
:A => 5
```
"""
parse(type::Type, x::Pair) = x[2] => parse(type, x[2])

"""
### parse(s::AbstractString) -> ::Any
Binded call for parse(::DataType{Any}, ::AbstractString). Parses string into
    assumed type.
**arguments**
- T <: DataType; type to parse **s** into.
- s <: AbstractString; string to be parsed into type **T**.
----------------
### example
```
parse("55")
Int64(55)
```
"""
parse(str::AbstractString) = parse(Any, str)

export parse, Date, DateTime
end # module
