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
## What's this Kerchunk thing?

[`kerchunk`](https://github.com/fsspec/kerchunk) is a Python library that allows you to take a collection of files and turn them into a Zarr dataset.  In the days of yore, when dinosaurs roamed the (flat) Earth and we only had black and white TV, file size limits (and RAM limits) made it such that one had to spread out data across multiple files.  So, engineers turned to "descriptive file paths" where one could encode metadata in the file path or file name.  A nice example is having a folder for each timestep of a spatial simulation.

However, each dataset basically had its own way of doing this.  So, if you wanted to load a dataset, you had to load it in the way the original engineer envisioned.  

This is where `kerchunk` comes in.  It will look at all the files and generate a "catalog" that describes a translation from the original file paths to a Zarr dataset!  This means that you can access the data as a single array, but still load by chunks (but chunks here are bitranges in files).  Kerchunk is super useful when you have an old dataset or pipeline which spits out tens of millions of files, that end users don't want to have to memorize the file structure of.

Kerchunk "catalogs" are just JSON, but they come in a few varieties since the standard is not fully defined.  The most basic catalog is one which maps some files to a single Zarr dataset, and this is the only version which is loadable by `fsspec`.  Some kerchunk catalogs are distributed as multiple catalog objects in a single JSON, indexed by some key - this is something to check if you get a random error, like `KeyError: ".zmetadata"`.  In that case you should pass the value from a single key to Kerchunk.

Kerchunk catalogs can also be directories of Parquet files for extremely large data, which fsspec can handle easily.