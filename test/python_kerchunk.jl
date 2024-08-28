using CondaPkg, PythonCall

using Test

const xr = pyimport("xarray")
const fsspec = pyimport("fsspec")
# const kerchunk = pyimport("kerchunk")

using FSSpec, Zarr, JSON3

json_file_path = "https://raw.githubusercontent.com/lsterzinger/2022-esip-kerchunk-tutorial/main/example_jsons/individual/OR_ABI-L2-SSTF-M6_G16_s20202100000205_e20202100059513_c20202100105456.json"

st = FSStore("reference://"; fo = json_file_path)

_zarr = Zarr.zopen(st; consolidated = false)

using YAXArrays

dataset = YAXArrays.open_dataset(_zarr)
