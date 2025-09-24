# Geoid "Lumpy Potato" Viewer 🥔🌍

An interactive 3D Earth visualization showing the EGM2008 geoid with realistic displacement mapping, powered by Three.js.

## 🚀 Live Demo
**[View Live Demo →](https://yourusername.github.io/repo-name)**

## 🌍 Features
- **Interactive 3D Earth** with realistic geoid displacement
- **Exaggeration controls** (x1, x5, x10) to visualize Earth's gravitational "lumps"
- **Day/Night textures** with proper lighting
- **Realistic starfield** with Milky Way galactic plane
- **Graticule overlays** (major/minor grid lines)
- **Earth rotation** and axial tilt controls
- **Responsive controls** with collapsible UI

## 🎮 Controls
- **Mouse:** Rotate and zoom the Earth
- **Day/Night:** Switch between Earth textures
- **Exaggeration:** Use slider or preset buttons (x1, x5, x10)
- **Graticules:** Toggle coordinate grid overlays
- **Rotation:** Control Earth's spin with RPM slider

## 📁 Contents
- `index.html` — Main viewer application
- `assets/` — Earth textures, heightmap, and logo
- `tools/` — Scripts to process EGM2008 data
- `README.md` — This documentation

## 🛠️ Local Development
```bash
# Clone the repository
git clone https://github.com/yourusername/repo-name.git
cd repo-name

# Start local server (any of these work)
python -m http.server 8000
# OR
npx http-server -p 8000
# OR
php -S localhost:8000

# Open browser to http://localhost:8000
```

Recreate the heightmap PNG (PowerShell wrapper)
1. Ensure the raw grid file is present under `data/` (filename `Und_min2.5x2.5_egm2008_isw=82_WGS84_TideFree_SE`).
2. Run:
```powershell
cd 'C:\Users\alanm\Desktop\Code\standalone_geoid_viewer_site\tools'
.\make_geoid_png.ps1 -RawGrid ..\data\Und_min2.5x2.5_egm2008_isw=82_WGS84_TideFree_SE -Out ..\assets\heightmap_4096x2048.png
```

Linux / macOS (Python direct)
```bash
python3 -m pip install --user numpy rasterio pillow
cd standalone_geoid_viewer_site/tools
python3 convert_raw_grid_to_geotiff.py -i ../data/Und_min2.5x2.5_egm2008_isw=82_WGS84_TideFree_SE -o ../data/egm2008_geoid.tif --width 8640 --height 4320 --endian little
python3 geotiff_to_png.py ../data/egm2008_geoid.tif ../assets/heightmap_4096x2048.png --width 4096 --height 2048
```

Raw data source
- The EGM2008 interpolation grid can be obtained from official sources or distributors; a commonly used dataset is included in this repository under `EGM2008_Interpolation_Grid/`.
- Official EGM2008 downloads and documentation are available from the NGA / ICGEM providers. Example starting points:
	- https://earth-info.nga.mil (NGA data portal)
	- https://icgem.gfz-potsdam.de/ (International Centre for Global Earth Models)
Ensure you comply with dataset licensing when distributing or rehosting the raw grid.

Docker option
- A `Dockerfile` is included for reproducible conversions (install GDAL + Python packages). See the Dockerfile for usage.
