#=

# ReferenceStore

This is a first implementation of a key-value reference store that can store files as:
- base64 encoded UInt8 (byte) file contents
- references to other stores (`[filepath, start_byte_index, end_byte_index]`)

Currently, this only works for local files.  In future it will work on HTTP and S3 stores as well.

Future optimizations include:
- Lazy directory caching so that subdirs and subkeys are fast
- Parallel read strategy for concurrent reads
- Simple templating via Mustache or similar (kerchunk does not natively generate full Jinja templates, but could be extended to do so)

Things not in the immediate future are:
- Complex `jinja` template support

## Notes on templating

Mustache.jl performs URI character escaping on `{{template}}` values, which is apparently not done in Python.  
So we have to unescape them, except it doesn't percent encode, so we actually have to change the template and 
indicate that the no html encoding by modifying the `_type` field of each token.  Horrifying, I know. 

## Notes on file access

Files can be:
- base64 encoded string (in memory file)
- reference to a full file (file path in a single element vector)
- reference to a subrange of a file (`file path`, `start index`, `number of bytes to read` in a three element vector)

Files can aleo be generated, so we have to parse that and then actually materialize the store, at least for now.

## The JSON schema
```json
{
  "version": (required, must be equal to) 1,
  "templates": (optional, zero or more arbitrary keys) {
    "template_name": jinja-str
  },
  "gen": (optional, zero or more items) [
    "key": (required) jinja-str,
    "url": (required) jinja-str,
    "offset": (optional, required with "length") jinja-str,
    "length": (optional, required with "offset") jinja-str,
    "dimensions": (required, one or more arbitrary keys) {
      "variable_name": (required)
        {"start": (optional) int, "stop": (required) int, "step": (optional) int}
        OR
        [int, ...]
    }
  ],
  "refs": (optional, zero or more arbitrary keys) {
    "key_name": (required) str OR [url(jinja-str)] OR [url(jinja-str), offset(int), length(int)]
  }
}
```
=#
using JSON3, Base64 # for decoding

struct ReferenceStore{MapperType <: AbstractDict, MetadataType <: AbstractDict} <: Zarr.AbstractStore
    zmetadata::MetadataType
    mapper::MapperType
end

function Base.getindex(store::ReferenceStore, key::String)
    return store.mapper[key]
end

function Base.setindex!(store::ReferenceStore, value, key::String)
    error("ReferenceStore is read-only for now")
    #store.mapper[key] = value
end

function Base.exists(store::ReferenceStore, key::String)
    return haskey(store.mapper, key)
end

function Base.keys(store::ReferenceStore)
    return keys(store.mapper)
end

function Base.values(store::ReferenceStore)
    return values(store.mapper)
end

# Implement the Zarr interface

function Zarr.subdirs(store::ReferenceStore, key)
    path = rstrip(key, '/')
    l_path = length(path)
    return filter(keys(store)) do k
        startswith(k, key * "/") && # path is a child of the key
        '/' ∉ key[l_path+1:end] # path has no children
    end
end

function Zarr.subkeys(store::ReferenceStore, key::String)
    return keys(store.mapper)
end

function _get_file_bytes(store::ReferenceStore, bytes::String)
    # single file
    if startswith(bytes, "base64:") # base64 encoded binary
        # TODO: make this more efficient by reinterpret + view
        return base64decode(bytes[7:end])
    else # JSON file
        return Vector{UInt8}(bytes)
    end
end

function _get_file_bytes(store::ReferenceStore, file::JSON3.Array{<: Any, Base.CodeUnits{UInt8, String}, SubArray{UInt64, 1, Vector{UInt64}, Tuple{UnitRange{Int64}}, true}})
    # subpath to file
    filename, offset, length = file
    uri = resolve_uri(store, filename)
    return readbytes(uri, offset, offset + length)
end

function _get_file_bytes(store::ReferenceStore, file::JSON3.Array{<: Any, Base.CodeUnits{UInt8, String}, true})
    return read(resolve_uri(store, file))
end

function resolve_uri(store::ReferenceStore, source::String)
    uri = URIs.URI(uri)
    # check if relpath / abspath
    if isempty(uri.scheme)
        if isabspath(source)
            return FilePathsBase.SystemPath(source)
        elseif isrelpath(source)
            return FilePathsBase.SystemPath(joinpath(pwd(), source))
        else
            error("Invalid path, presumed local but not resolvable as absolute or relative path: $source")
        end
    end
    if uri.scheme == "file"
        return FilePathsBase.SystemPath(uri.path)
    elseif uri.scheme == "s3"
        return Zarr.AWSS3.S3Path(source)
    end # TODO: add more 
end