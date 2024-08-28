#=

# Python utilities

This file contains utilities to speed up interaction with Python from Julia.  

=#

#=
## Converting dictlike structures in Julia to pure Python dicts

In PythonCall.jl's `juliacall` Python module, all Julia wrapper objects are declared to be "callable".

This presents a problem in some code, because it assumes that if an object is callable, then it should be called.  

When wrapping a Julia dict in a Python wrapper, and sending it to Python, code like this tries to call the Julia dict like `some_dict()`,
which provokes an error on the Julia side - since the dict is not actually callable.

So, we have to pass a pure Python dictionary to Python, and to do that we need to convert everything in the dict, recursively, to a Python structure
before sending it to Python.
=#

function _recursive_pyconvert!(target::Dict, source::Dict)
    for (k, v) in source
        if k isa Symbol
            key = string(k)
        else
            key = k
        end
        if isa(v, Dict) # TODO: refactor to use multiple dispatch.
            td = Dict{String, Any}()
            _recursive_pyconvert!(td, v)
            target[key] = pydict(td)
        elseif v isa AbstractVector
            target[key] = pycollist(v)
        else
            target[key] = Py(v)
        end
    end
end

"""
    _recursive_pyconvert(source::Dict)

Convert a Julia dict to a Python dict, recursively.  Returns a `PythonCall.Py` object wrapping the Python dict.

This is a pure Python dict and not a Julia dict wrapped in Python, so it plays better with Python functions.
"""
function _recursive_pyconvert(source::Dict)
    target = Dict{String, Any}()
    _recursive_pyconvert!(target, source)
    return pydict(target)
end