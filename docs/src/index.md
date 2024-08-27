```@meta
CurrentModule = FSSpec
```

# FSSpec

## What is this thing?

It's a package that wraps Python's [fsspec](https://github.com/filesystem_spec/fsspec) library.  Specifically meant for integration with Zarr.jl and the DimensionalData ecosystem, but it can be used for other things too.

[`fsspec`](https://github.com/filesystem_spec/fsspec) is a Python library that provides a unified interface for working with various storage backends, from local directories to HTTP, S3, Tar archives, and even virtual filesystems defined by dictionaries.  It's used in `xarray` and similar packages to simplify the loading story for data.

Currently, FSSpec.jl only exports a Zarr storage backend called `FSStore`.  This wraps an fsspec filesystem, allowing you to use it as a Zarr storage backend.  The fsspec file system can be absolutely anything!

The quick start example shows how to load a Kerchunk catalog into a Zarr dataset, then wrap it in YAXArrays.jl to get a DimensionalArray, which works with the DimensionalData ecosystem.

Documentation for [FSSpec](https://github.com/asinghvi17/FSSpec.jl).

```@index
```

```@autodocs
Modules = [FSSpec]
```
