#!/usr/bin/env python3
"""
Convert a raw EGM2008 2.5' grid binary file to a GeoTIFF.
Usage:
  python convert_raw_grid_to_geotiff.py --input Und_min2.5x2.5_egm2008_isw=82_WGS84_TideFree_SE --output egm2008_geoid.tif --width 8640 --height 4320 --endian little

Requires: numpy, rasterio
"""
import argparse
import numpy as np
import rasterio
from rasterio.transform import from_origin

parser = argparse.ArgumentParser(description='Convert raw float32 grid to GeoTIFF')
parser.add_argument('--input', '-i', required=True, help='Input raw binary file')
parser.add_argument('--output', '-o', required=True, help='Output GeoTIFF file')
parser.add_argument('--width', type=int, default=8640, help='Grid width (pixels)')
parser.add_argument('--height', type=int, default=4320, help='Grid height (pixels)')
parser.add_argument('--endian', choices=['little', 'big'], default='little', help='Byte order of input (little=SE file)')
parser.add_argument('--dtype', default='float32', choices=['float32','float64','int16','int32'], help='Data type in file')
args = parser.parse_args()

dtype_map = {
    'float32': 'f4',
    'float64': 'f8',
    'int16': 'i2',
    'int32': 'i4'
}

np_dtype = dtype_map[args.dtype]
if args.endian == 'little':
    np_dtype = '<' + np_dtype
else:
    np_dtype = '>' + np_dtype

print(f"Reading {args.input} as {np_dtype} with size {args.width}x{args.height}...")

# Read binary
count = args.width * args.height
with open(args.input, 'rb') as f:
    data = np.fromfile(f, dtype=np_dtype, count=count)

if data.size != count:
    raise RuntimeError(f"Read {data.size} elements but expected {count}; check width/height/endian/dtype")

# reshape to 2D: the grid is usually ordered from north to south rows
arr = data.reshape((args.height, args.width))

# Create GeoTIFF with transform
pixel_size_x = 360.0 / args.width
pixel_size_y = 180.0 / args.height
transform = from_origin(-180.0, 90.0, pixel_size_x, pixel_size_y)

print('Writing GeoTIFF to', args.output)
with rasterio.open(
    args.output,
    'w',
    driver='GTiff',
    height=args.height,
    width=args.width,
    count=1,
    dtype='float32',
    crs='EPSG:4326',
    transform=transform,
    nodata=None
) as dst:
    dst.write(arr.astype('float32'), 1)

print('Done.')
