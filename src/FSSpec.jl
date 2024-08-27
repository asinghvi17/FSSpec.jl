module FSSpec

using CondaPkg
using PythonCall

using FilePathsBase

const fsspec = Ref{PythonCall.Py}() # this is loaded at `__init__()` time...

function __init__()
    fsspec[] = pyimport("fsspec")
end

end
