#=
# FSStore (a Zarr store)

Some notes on how FSSpec works:



=#

import Zarr

import URIs
using PythonCall

"""
    FSStore(url; storage_options...)

Load data that can be accessed through any filesystem supported by the [`fsspec`](https://github.com/fsspec/filesystem_spec) Python package.

`url` can be any path in the form `protocol://path/to/file`.

## Kerchunk

To open a Kerchunk catalog, call `FSStore("reference://"; fo = "path/to/catalog.json")`.  
`fo` may be any path that `fsspec` can read, or a Dict following the Kerchunk JSON structure.  
If it is a Dict, it may not contain any values that cannot be translated directly to Python types.
"""
struct FSStore <: Zarr.AbstractStore
    url::URIs.URI
    dirfs::Py
    mapper::Py
end

function Base.readdir(s::FSStore, p::String)
    return pyconvert(Vector{String}, s.mapper.fs.ls(p, detail=false))
end

function Base.stat(s::FSStore, p::String)
    return pyconvert(Py, s.dirfs.info(p))
end

function FSStore(url::String; storage_options...)
    fs, = fsspec[].core.url_to_fs(url; storage_options...)
    # We have to handle reference:// separately, since passing 
    # that as a URL to `fs.get_mapper` breaks it.
    mapper, dirfs = if url == "reference://"
        fs.get_mapper(""), fs
    else
        _m = fs.get_mapper(url)
        _m, _m.dirfs
    end
    return FSStore(URIs.URI(url), dirfs, mapper)
end

function Base.getindex(s::FSStore, k::String)
   return pyconvert(Vector{UInt8}, s.mapper[k])
end

function Zarr.storagesize(s::FSStore, p::String)
    return pyconvert(Int, s.dirfs.du(p; total = true))
end

function Zarr.read_items!(s::FSStore, c::AbstractChannel, p, i)
    cinds = [Zarr.citostring(ii) for ii in i]
    ckeys = ["$p/$cind" for cind in cinds]
    cdatas = s.mapper.getitems(ckeys, on_error="omit")
    for ii in i
        put!(c,(ii => pyconvert(Vector{UInt8}, cdatas[ckeys[ii]])))
    end
end

function Zarr.isinitialized(s::FSStore, p)
    return pyconvert(Bool, s.dirfs.exists(p))
end

function Zarr.isinitialized(s::FSStore, p, i)
    return pyconvert(Bool, s.dirfs.exists("$p/$i"))
end

function listdir(s::FSStore, p; nometa=false) 
    try
        listing = pyconvert(Vector{String}, s.dirfs.ls(p, detail=false))
        if nometa
          filter!(!startswith("."), listing)
        end
        return listing
    catch e
        return String[]
    end
end


Zarr.subdirs(s::FSStore, p) = filter(listdir(s, p; nometa = true)) do path
    pyconvert(Bool, s.dirfs.isdir(path))
end

Zarr.subkeys(s::FSStore, p) = filter(listdir(s, p; nometa = true)) do path
    pyconvert(Bool, s.dirfs.isfile(path))
end



Zarr.is_zarray(s::FSStore, p) = ((normpath(p) in ("/", ".")) ? ".zarray" : normpath("$p/.zarray")) in listdir(s, p, nometa=false) # TODO: this is where relative file utils could be SUPER helpful.
Zarr.is_zgroup(s::FSStore, p) = ((normpath(p) in ("/", ".")) ? ".zgroup" : normpath("$p/.zgroup")) in listdir(s, p, nometa=false)

# TODO: is it a requirement of the Zarr spec that each directory have a .zattrs file?  If not, should that be checked in getattrs?  This was an annoying bug...
Zarr.getattrs(s::FSStore, p) = pyconvert(Bool, s.dirfs.exists(normpath(p) in ("/", ".") ? ".zattrs" : "$p/.zattrs")) ? Zarr.JSON.parse(String(s[normpath(p) in ("/", ".") ? ".zattrs" : "$p/.zattrs"])) : Dict{String, Any}()

struct PyConcurrentRead end

Zarr.store_read_strategy(::FSStore) = PyConcurrentRead()
Zarr.channelsize(::PyConcurrentRead) = Zarr.concurrent_io_tasks[] 
Zarr.read_items!(s::FSStore, c::AbstractChannel, ::PyConcurrentRead, p, i) = Zarr.read_items!(s, c, p, i)
Zarr.read_items!(s::Zarr.ConsolidatedStore, c::AbstractChannel, ::PyConcurrentRead, p, i) = Zarr.read_items!(s.parent, c, p, i)

#= Test

data_url = "https://its-live-data.s3-us-west-2.amazonaws.com/datacubes/v2/N00E020/ITS_LIVE_vel_EPSG32735_G0120_X750000_Y10050000.zarr"

st = FSStore(data_url; ssl = false) # SSL is causing issues on my machine

g2 = Zarr.zopen(st; consolidated = true)


# Try out Kerchunk

json_file = download("https://raw.githubusercontent.com/lsterzinger/2022-esip-kerchunk-tutorial/main/example_jsons/individual/OR_ABI-L2-SSTF-M6_G16_s20202100000205_e20202100059513_c20202100105456.json", "catalog.json")

st = FSStore("reference://"; fo = "catalog.json")

g3 = Zarr.zopen(st; consolidated = false)






julia> url = "https://mur-sst.s3.us-west-2.amazonaws.com/zarr-v1"
"https://mur-sst.s3.us-west-2.amazonaws.com/zarr-v1"

julia> g = Zarr.zopen(url, consolidated=true)
ZarrGroup at Consolidated Consolidated Zarr.HTTPStore("https://mur-sst.s3.us-west-2.amazonaws.com/zarr-v1") and path 
Variables: lat analysed_sst analysis_error mask time lon sea_ice_fraction 

julia> s = g["analysed_sst"]
ZArray{Int16} of size 36000 x 17999 x 6443

julia> v1 = s[1:3600, 1:1799, 1:50];

julia> st = FSStore(url; ssl = false)
Zarr.FSStore("https://mur-sst.s3.us-west-2.amazonaws.com/zarr-v1", <py fsspec.mapping.FSMap object at 0x7f8fca721360>)

julia> g2 = Zarr.zopen(st, consolidated=true)
ZarrGroup at Consolidated Zarr.FSStore("https://mur-sst.s3.us-west-2.amazonaws.com/zarr-v1", <py fsspec.mapping.FSMap object at 0x7f8fca721360>) and path 
Variables: lat analysed_sst analysis_error mask time lon sea_ice_fraction 

julia> s2 = g2["analysed_sst"]
ZArray{Int16} of size 36000 x 17999 x 6443

julia> v2 = s2[1:3600, 1:1799, 1:50];

julia> all(v2 .== v1)
true
=#