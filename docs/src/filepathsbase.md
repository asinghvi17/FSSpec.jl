# FilePathsBase integration

We will expose a type `FSPath` that implements the `FilePathsBase` interface, but refers to some file relative to a filesystem.  Each `FSPath` will store a reference to the `fsspec` filesystem it came from, and a string that encodes the relative path.

We will implement a subset of the FilePathsBase interface, but things like `tempdir` are flat out impossible in a virtual filesystem for example.  In so far as possible we will endeavour to make this work for three purposes:
- Reading files, or byte ranges of files
- Examining the structure of the filesystem (`ls`, `stat`, `isdir`, etc)
- Joining paths (`join`, `dirname`, `basename`, etc)

We may (as a stretch goal) support writing files, but this is not a priority.

We will likely not support modifying file structure (moving, deleting, etc).

