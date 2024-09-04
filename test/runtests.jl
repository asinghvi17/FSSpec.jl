using FSSpec
using Test

@testset "FSSpec.jl" begin
    include("python_kerchunk.jl")
    include("its_live_catalog.jl")
end
