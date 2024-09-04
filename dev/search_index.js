var documenterSearchIndex = {"docs":
[{"location":"filepathsbase/#FilePathsBase-integration","page":"FilePathsBase integration","title":"FilePathsBase integration","text":"","category":"section"},{"location":"filepathsbase/","page":"FilePathsBase integration","title":"FilePathsBase integration","text":"We will expose a type FSPath that implements the FilePathsBase interface, but refers to some file relative to a filesystem.  Each FSPath will store a reference to the fsspec filesystem it came from, and a string that encodes the relative path.","category":"page"},{"location":"filepathsbase/","page":"FilePathsBase integration","title":"FilePathsBase integration","text":"We will implement a subset of the FilePathsBase interface, but things like tempdir are flat out impossible in a virtual filesystem for example.  In so far as possible we will endeavour to make this work for three purposes:","category":"page"},{"location":"filepathsbase/","page":"FilePathsBase integration","title":"FilePathsBase integration","text":"Reading files, or byte ranges of files\nExamining the structure of the filesystem (ls, stat, isdir, etc)\nJoining paths (join, dirname, basename, etc)","category":"page"},{"location":"filepathsbase/","page":"FilePathsBase integration","title":"FilePathsBase integration","text":"We may (as a stretch goal) support writing files, but this is not a priority.","category":"page"},{"location":"filepathsbase/","page":"FilePathsBase integration","title":"FilePathsBase integration","text":"We will likely not support modifying file structure (moving, deleting, etc).","category":"page"},{"location":"","page":"Home","title":"Home","text":"CurrentModule = FSSpec","category":"page"},{"location":"#FSSpec","page":"Home","title":"FSSpec","text":"","category":"section"},{"location":"#What-is-this-thing?","page":"Home","title":"What is this thing?","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"It's a package that wraps Python's fsspec library.  Specifically meant for integration with Zarr.jl and the DimensionalData ecosystem, but it can be used for other things too.","category":"page"},{"location":"","page":"Home","title":"Home","text":"fsspec is a Python library that provides a unified interface for working with various storage backends, from local directories to HTTP, S3, Tar archives, and even virtual filesystems defined by dictionaries.  It's used in xarray and similar packages to simplify the loading story for data.","category":"page"},{"location":"","page":"Home","title":"Home","text":"Currently, FSSpec.jl only exports a Zarr storage backend called FSStore.  This wraps an fsspec filesystem, allowing you to use it as a Zarr storage backend.  The fsspec file system can be absolutely anything!","category":"page"},{"location":"","page":"Home","title":"Home","text":"The quick start example shows how to load a Kerchunk catalog into a Zarr dataset, then wrap it in YAXArrays.jl to get a DimensionalArray, which works with the DimensionalData ecosystem.","category":"page"},{"location":"","page":"Home","title":"Home","text":"Documentation for FSSpec.","category":"page"},{"location":"","page":"Home","title":"Home","text":"","category":"page"},{"location":"","page":"Home","title":"Home","text":"Modules = [FSSpec]","category":"page"},{"location":"#FSSpec.FSStore","page":"Home","title":"FSSpec.FSStore","text":"FSStore(url; storage_options...)\n\nLoad data that can be accessed through any filesystem supported by the fsspec Python package.\n\nurl can be any path in the form protocol://path/to/file.\n\nKerchunk\n\nTo open a Kerchunk catalog, call FSStore(\"reference://\"; fo = \"path/to/catalog.json\").   fo may be any path that fsspec can read, or a Dict following the Kerchunk JSON structure.   If it is a Dict, it may not contain any values that cannot be translated directly to Python types.\n\n\n\n\n\n","category":"type"},{"location":"#FSSpec._get_file_bytes","page":"Home","title":"FSSpec._get_file_bytes","text":"_get_file_bytes(store::ReferenceStore, reference)\n\nBy hook or by crook, this function will return the bytes for the given reference. The reference could be a base64 encoded binary string, a path to a file, or a subrange of a file.\n\n\n\n\n\n","category":"function"},{"location":"#FSSpec._recursive_pyconvert-Tuple{AbstractDict}","page":"Home","title":"FSSpec._recursive_pyconvert","text":"_recursive_pyconvert(source::Dict)\n\nConvert a Julia dict to a Python dict, recursively.  Returns a PythonCall.Py object wrapping the Python dict.\n\nThis is a pure Python dict and not a Julia dict wrapped in Python, so it plays better with Python functions.\n\n\n\n\n\n","category":"method"},{"location":"#FSSpec.apply_templates-Tuple{ReferenceStore, String}","page":"Home","title":"FSSpec.apply_templates","text":"apply_templates(store::ReferenceStore, source::String)\n\nThis function applies the templates stored in store to the source string, and returns the resolved string.\n\nIt uses Mustache.jl under the hood, but all {{template}} values are set to not URI-encode characters.\n\n\n\n\n\n","category":"method"},{"location":"#FSSpec.materialize-Tuple{Union{String, FilePathsBase.AbstractPath}, ReferenceStore}","page":"Home","title":"FSSpec.materialize","text":"materialize(path, store::ReferenceStore)\n\nMaterialize a Zarr directory from a Kerchunk catalog.  This actually downloads and writes the files to the given path, and you can open that with any Zarr reader.\n\n\n\n\n\n","category":"method"},{"location":"#FSSpec.readbytes-Tuple{Any, Integer, Integer}","page":"Home","title":"FSSpec.readbytes","text":"readbytes(path, start::Integer, stop::Integer)::Vector{UInt8}\n\nRead bytes from a file at a given range.\n\n\n\n\n\n","category":"method"},{"location":"#FSSpec.resolve_uri-Union{Tuple{HasTemplates}, Tuple{ReferenceStore{<:Any, HasTemplates}, String}} where HasTemplates","page":"Home","title":"FSSpec.resolve_uri","text":"resolve_uri(store::ReferenceStore, source::String)\n\nThis function resolves a string which may or may not have templating to a URI.\n\n\n\n\n\n","category":"method"},{"location":"#What's-this-Kerchunk-thing?","page":"Home","title":"What's this Kerchunk thing?","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"kerchunk is a Python library that allows you to take a collection of files and turn them into a Zarr dataset.  In the days of yore, when dinosaurs roamed the (flat) Earth and we only had black and white TV, file size limits (and RAM limits) made it such that one had to spread out data across multiple files.  So, engineers turned to \"descriptive file paths\" where one could encode metadata in the file path or file name.  A nice example is having a folder for each timestep of a spatial simulation.","category":"page"},{"location":"","page":"Home","title":"Home","text":"However, each dataset basically had its own way of doing this.  So, if you wanted to load a dataset, you had to load it in the way the original engineer envisioned.  ","category":"page"},{"location":"","page":"Home","title":"Home","text":"This is where kerchunk comes in.  It will look at all the files and generate a \"catalog\" that describes a translation from the original file paths to a Zarr dataset!  This means that you can access the data as a single array, but still load by chunks (but chunks here are bitranges in files).  Kerchunk is super useful when you have an old dataset or pipeline which spits out tens of millions of files, that end users don't want to have to memorize the file structure of.","category":"page"},{"location":"","page":"Home","title":"Home","text":"Kerchunk \"catalogs\" are just JSON, but they come in a few varieties since the standard is not fully defined.  The most basic catalog is one which maps some files to a single Zarr dataset, and this is the only version which is loadable by fsspec.  Some kerchunk catalogs are distributed as multiple catalog objects in a single JSON, indexed by some key - this is something to check if you get a random error, like KeyError: \".zmetadata\".  In that case you should pass the value from a single key to Kerchunk.","category":"page"},{"location":"","page":"Home","title":"Home","text":"Kerchunk catalogs can also be directories of Parquet files for extremely large data, which fsspec can handle easily.","category":"page"}]
}
