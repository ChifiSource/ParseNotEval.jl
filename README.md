<div align="center" style = "box-pack: start;">
  </br>
  <img width = 300 src="https://github.com/ChifiSource/image_dump/blob/main/parsenoteval/logo.png" >
  
  
  [![version](https://juliahub.com/docs/Lathe/version.svg)](https://juliahub.com/ui/Packages/Lathe/6rMNJ)
[![deps](https://juliahub.com/docs/Lathe/deps.svg)](https://juliahub.com/ui/Packages/Lathe/6rMNJ?t=2)
[![pkgeval](https://juliahub.com/docs/Lathe/pkgeval.svg)](https://juliahub.com/ui/Packages/Lathe/6rMNJ)
  </br>
  </br>
  </div>

  **ParseNotEval** Is a core odd data package that acts as both an implicit and explicit type parser. The main usage for such a thing is in file/string reading, by being able to quickly parse strings into their appropriate types. This is helpful if you want to make secure and fast data readers. This module is moreso ecosystem geared.
  ###
  ### adding and using
  Until the team is ready to release a stable version (**very soon, likely today**,) you will need to add the package via URL:
  ```julia
  using Pkg
  Pkg.add(url = "https://github.com/ChifiSource/ParseNotEval.jl.git")
  ```
The only thing that this module exports is the [parse method](https://docs.julialang.org/en/v1/base/numbers/#Base.parse) and [Dates.DateTime + Dates.Date](https://docs.julialang.org/en/v1/stdlib/Dates/). The extensions provided to parse() allow for one to pass tons of different types and structures through in order to create them. For example, we could read a Dict in from a string:
```julia
dct_str = "A => [5, 10, 15], B => [5, 10, 15]"
parse(Dict, dct_string)
Dict(:A => [5, 10, 15], :B => [5, 10, 15])

# This also works with JSON.
dct_str = "{A : [5, 10, 15], B : [5, 10, 15]}"
parse(Dict, dct_string)
Dict(:A => [5, 10, 15], :B => [5, 10, 15])
```
There are a lot more structures involved as well, the best choice is to use ?(parse) to get the docs all of the methods for parse, or view the JuliaHub documentation. One notable other example is that of parse(Any, ::String).
```
typeof(parse(Any, 5.0))
Float64
typeof(parse(Any, 5))
Int64

```
