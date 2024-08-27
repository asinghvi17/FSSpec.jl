import Zarr


using PythonCall

"""
    FSStore
Load data that can be accessed through 
any filesystem supported by the fsspec python package.
"""
struct FSStore <: Zarr.AbstractStore
    url::String
    mapper::Py
end

function FSStore(url::String; storage_options...)
    fsspec = pyimport("fsspec")
    fs, = fsspec.core.url_to_fs(url; storage_options...)
    mapper = fs.get_mapper(url)
    return FSStore(url, mapper)
end

function Base.getindex(s::FSStore, k::String)
   return pyconvert(Vector, s.mapper[k])
end

function Zarr.storagesize(s::FSStore, p::String)
    return 0 # placeholder for now
    # The correct implementation is to walkdir through the filesystem and sum the sizes of all files
    # You can get the filesizes using s.mapper.fs.du(path, total=True)
    # return pyconvert(Int, s.mapper.fs.getsize(p))
end

function Zarr.read_items!(s::FSStore, c::AbstractChannel, p, i)
    cinds = [Zarr.citostring(ii) for ii in i]
    ckeys = ["$p/$cind" for cind in cinds]
    cdatas = s.mapper.getitems(ckeys, on_error="omit")
    for ii in i
        put!(c,(ii => pyconvert(Vector, cdatas[ckeys[ii]])))
    end
end

function Zarr.isinitialized(s::FSStore, p)
    return pyconvert(Bool, s.mapper.fs.exists(p))
end

function Zarr.isinitialized(s::FSStore, p, i)
    return pyconvert(Bool, s.mapper.fs.exists(p))
end

function listdir(s::FSStore, p; nometa=true) 
    try
        listing = pyconvert(Vector, s.mapper.fs.listdir(p, detail=false))
        if nometa
          listing = [za for za in listing if !startswith(za, ".")]
        end
        return listing
    catch e
        return String[]
    end
end


Zarr.subdirs(s::FSStore, p) = filter(listdir(s, p)) do path
    pyconvert(Bool, s.mapper.fs.isdir(path))
end

Zarr.subkeys(s::FSStore, p) = filter(listdir(s, p)) do path
    pyconvert(Bool, s.mapper.fs.isfile(path))
end



is_zarray(s::FSStore, p) = "$p/.zarray" in listdir(s, p, nometa=false)
is_zgroup(s::FSStore, p) = ".zgroup" in listdir(s, p, nometa=false)


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