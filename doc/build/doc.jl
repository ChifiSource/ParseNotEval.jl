using ParseNotEval, Documenter

Documenter.makedocs(root = "../",
       source = "src",
       build = "build",
       clean = true,
       doctest = true,
       modules = [ParseNotEval],
       repo = "https://github.com/ChifiSource/ParseNotEval.jl",
       highlightsig = true,
       sitename = "ParseNotEval.jl",
       expandfirst = [],
       pages = [
                "Overview" => "overview.md"
               ]
       )
