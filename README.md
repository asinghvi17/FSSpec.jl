# FSSpec.jl

A Julia wrapper around Python's [fsspec](https://github.com/filesystem_spec/fsspec) library.

[![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://asinghvi17.github.io/FSSpec.jl/stable/)
[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://asinghvi17.github.io/FSSpec.jl/dev/)
[![Build Status](https://github.com/asinghvi17/FSSpec.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/asinghvi17/FSSpec.jl/actions/workflows/CI.yml?query=branch%3Amain)

## Quick start

```julia
using FSSpec # you must load this before any other packages, to ensure that the Python environment is initialized correctly

store = FSSpec.FSStore("reference://"; fo = "catalog.json") # `fo` is the path to your Kerchunk catalog or directory thereof

using Zarr

z = Zarr.zopen(store)

using YAXArrays

y = YAXArrays.open_dataset(z)
```

