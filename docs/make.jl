using Documenter
using LMEASDRs

makedocs(
    sitename = "LMEASDRs",
    doctest=true,
    modules = [LMEASDRs],
    pages =[
        "Home" => "index.md",
        "Analysing ASDRs with MixedModels.jl" => "LME.md",
        "Parametric bootstrap for LMEASDRs" => "bootstrap.md",
        "The parameter estimation" => "parameter-estimation.md",
        "Reference" => "reference.md",

    ],
)

# Documenter can also automatically deploy documentation to gh-pages.
# See "Hosting Documentation" and deploydocs() in the Documenter manual
# for more information.
deploydocs(;
    repo = "github.com/RezaDastranj/LMEASDRs.jl", push_preview=true, devbranch="main"
)
