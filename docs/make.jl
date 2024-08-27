using FSSpec
using Documenter

DocMeta.setdocmeta!(FSSpec, :DocTestSetup, :(using FSSpec); recursive=true)

makedocs(;
    modules=[FSSpec],
    authors="Anshul Singhvi <anshulsinghvi@gmail.com> and contributors",
    sitename="FSSpec.jl",
    format=Documenter.HTML(;
        canonical="https://asinghvi17.github.io/FSSpec.jl",
        edit_link="main",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/asinghvi17/FSSpec.jl",
    devbranch="main",
)
