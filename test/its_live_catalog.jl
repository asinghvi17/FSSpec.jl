using JSON3, FSSpec, Zarr, YAXArrays
using Test

@testset "ITS_LIVE catalog" begin
    catalog_json = JSON3.read(open(joinpath(dirname(dirname(pathof(FSSpec))), "test", "its_live_catalog.json"))) 
    arbitrary_choice_dictionary = catalog_json[first(keys(catalog_json))]
    st = FSSpec.FSStore("reference://"; fo = arbitrary_choice_dictionary)
    za = Zarr.zopen(st)
    @test_nowarn za["vx"][1, 1] # test that reading works
end
