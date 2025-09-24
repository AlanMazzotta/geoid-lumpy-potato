# Usage:
# 1) Install GDAL (https://gdal.org/) and ensure gdalwarp/gdal_translate are on PATH.
# 2) Run in PowerShell: .\convert_geotiff_to_png.ps1 -Input input_geoid_or_dem.tif -Out geoid_4096x2048.png

param(
  [Parameter(Mandatory=$true)] [string]$Input,
  [Parameter(Mandatory=$true)] [string]$Out,
  [int]$Width = 4096,
  [int]$Height = 2048
)

$reprojected = "$($env:TEMP)\reprojected_temp.tif"
Write-Host "Reprojecting to EPSG:4326 -> $reprojected"
& gdalwarp -t_srs EPSG:4326 "$Input" "$reprojected"

Write-Host "Translating and resampling to $Width x $Height -> $Out"
& gdal_translate -of PNG -outsize $Width $Height -scale "$reprojected" "$Out"

Remove-Item -Force "$reprojected"
Write-Host "Done. Output: $Out"
