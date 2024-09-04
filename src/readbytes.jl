function readbytes(path::String, start::Integer, stop::Integer)
    @assert start < stop "In `readbytes`, start ($(start)) must be less than stop ($(stop))."
    open(path) do f
        seek(f, start)
        return read(f, stop - start)
    end
end

function readbytes(path::Zarr.AWSS3.S3Path, start::Integer, stop::Integer)
    @assert start < stop "In `readbytes`, start ($(start)) must be less than stop ($(stop))."
    return read(path; byte_range = start:stop)
end