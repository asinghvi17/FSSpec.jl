import FilePathsBase

struct FSSpecPath <: FilePathsBase.AbstractPath
    store::FSStore
    segments::Vector{String}
end

FSSpecPath(string::String; storage_options...) = FSSpecPath(FSStore(string; storage_options...), [""])

function Base.getproperty(p::FSSpecPath, s::Symbol)
    if s == :separator
        return "/" # FSSpec always uses `/` as the separator
    elseif s == :root
        return _root(p.store)
    elseif s == :drive
        return _root(p.store)
    else
        return getfield(p, s)
    end
end

Base.propertynames(p::FSSpecPath) = (:separator, :root, :drive, :segments, :store)



function Base.tryparse(::Type{FSSpecPath}, str::String) # - For parsing string representations of your path
    return FSSpecPath(FSStore(str), [""])
end

function Base.read(path::FSSpecPath) # read data from path, return a Vector{UInt8}
    return pyconvert(Vector{UInt8}, path.store.mapper[join(path.segments, "/", "")])
end

function Base.write(path::FSSpecPath, data)#
    error("Not implemented yet for FSSpecPath.")
end

function Base.exists(path::FSSpecPath) # - whether the path exists
    return pyconvert(Bool, path.store.mapper.dirfs.exists(join(path.segments, "/", "")))
end

function Base.stat(path::FSSpecPath)# - File status describing permissions, size and creation/modified times

end

function Base.mkdir(path::FSSpecPath; kwargs...)# - Create a new directory

end

function Base.rm(path::FSSpecPath; kwags...)# - Remove a file or directory

end

function Base.readdir(path::FSSpecPath)# - Scan all files and directories at a specific path level

end