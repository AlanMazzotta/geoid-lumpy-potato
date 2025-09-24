#!/usr/bin/env python3
"""
Convert a GeoTIFF to a normalized 8-bit PNG and resize to target dimensions.
Usage:
  py geotiff_to_png.py input.tif output.png [--width 4096 --height 2048]

Requires: rasterio, pillow (PIL)
"""
import argparse

try:
    import rasterio
except Exception as e:
    print('This script requires rasterio. Install with: py -m pip install rasterio')
    raise

try:
    from PIL import Image
except Exception as e:
    print('This script requires Pillow. Install with: py -m pip install pillow')
    raise

parser = argparse.ArgumentParser(description='GeoTIFF -> PNG converter')
parser.add_argument('input', help='Input GeoTIFF path')
parser.add_argument('output', help='Output PNG path')
parser.add_argument('--width', type=int, default=4096, help='Output width')
parser.add_argument('--height', type=int, default=2048, help='Output height')
parser.add_argument('--stretch', action='store_true', help='Stretch full range to 0..255 even if data has negative values')
args = parser.parse_args()

inp = args.input
outp = args.output
w = args.width
h = args.height

with rasterio.open(inp) as src:
    arr = src.read(1).astype('float64')
    mask = None
    if src.nodata is not None:
        mask = (arr == src.nodata)
    if mask is not None:
        arr_masked = arr.copy()
        arr_masked[mask] = float('nan')
    else:
        arr_masked = arr

    mn = float(arr_masked.min())
    mx = float(arr_masked.max())

    if mn == mx:
        print('Warning: input has constant values. Producing flat PNG.')
        norm = (arr - mn) * 0
    else:
        norm = (arr - mn) / (mx - mn)
        norm = (norm * 255.0).clip(0,255)

    norm = norm.astype('uint8')

    img = Image.fromarray(norm)
    img = img.resize((w, h), Image.LANCZOS)
    img.save(outp, format='PNG')
    print(f'Wrote {outp} ({w}x{h}), source min={mn}, max={mx}')
