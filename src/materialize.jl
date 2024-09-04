# This file is meant to materialize a Zarr directory from a Kerchunk catalog.

function materialize(path::String, store::ReferenceStore)
    mkpath(path)
    for key in keys(store.mapper)
        println("Writing $key")
        mkpath(splitdir(joinpath(path, string(key)))[1])
        write(joinpath(path, string(key)), _get_file_bytes(store, store.mapper[key]))
    end
end