module FSSpec

using CondaPkg
using PythonCall

using FilePathsBase

const fsspec = Ref{PythonCall.Py}() # this is loaded at `__init__()` time...

function __init__()
    fsspec[] = pyimport("fsspec")
end

include("python_utils.jl")
include("fsstore.jl")

include("readbytes.jl")
include("referencestore.jl")
include("materialize.jl")

end
