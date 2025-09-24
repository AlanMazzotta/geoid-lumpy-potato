param(
  [string]$RawGrid,
  [string]$Out,
  [int]$OutWidth = 4096,
  [int]$OutHeight = 2048,
  [int]$SrcWidth = 8640,
  [int]$SrcHeight = 4320,
  [ValidateSet('little','big')][string]$Endian = 'little',
  [string]$PythonExe = 'py',
  [switch]$UseGDAL
)

try {
  $ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
  $RepoRoot = Resolve-Path "$ScriptDir\.." | Select-Object -ExpandProperty Path

  if (-not $RawGrid) {
    $RawGrid = Join-Path $RepoRoot 'data\Und_min2.5x2.5_egm2008_isw=82_WGS84_TideFree_SE'
  }

  if (-not $Out) {
    $Out = Join-Path $RepoRoot 'assets\heightmap_4096x2048.png'
  }

  $convertRawScript = Join-Path $ScriptDir 'convert_raw_grid_to_geotiff.py'
  $toPngScript = Join-Path $ScriptDir 'geotiff_to_png.py'
  $tempTif = Join-Path $RepoRoot 'data\egm2008_geoid.tif'

  Write-Host "Raw grid: $RawGrid"
  Write-Host "Output PNG: $Out"

  if ($UseGDAL) {
    Write-Host "Using GDAL (gdalwarp/gdal_translate) to produce the PNG..."
    $reproj = Join-Path $env:TEMP 'reprojected_egm.tif'
    & gdalwarp -t_srs EPSG:4326 "$RawGrid" "$reproj"
    if ($LASTEXITCODE -ne 0) { throw 'gdalwarp failed' }
    & gdal_translate -of PNG -outsize $OutWidth $OutHeight -scale "$reproj" "$Out"
    if ($LASTEXITCODE -ne 0) { throw 'gdal_translate failed' }
    Remove-Item -Force "$reproj"
    Write-Host "Wrote $Out"
    exit 0
  }

  if (-not (Test-Path $convertRawScript)) { throw "Missing converter script: $convertRawScript" }
  if (-not (Test-Path $toPngScript)) { throw "Missing PNG script: $toPngScript" }

  $py = $PythonExe
  $found = & $py -V 2>$null
  if ($LASTEXITCODE -ne 0) {
    $py = 'python'
    $found = & $py -V 2>$null
    if ($LASTEXITCODE -ne 0) { throw 'Python not found (tried `py` and `python`). Install Python or set -PythonExe.' }
  }

  Write-Host "Running: $py $convertRawScript -i $RawGrid -o $tempTif --width $SrcWidth --height $SrcHeight --endian $Endian"
  & $py $convertRawScript -i "$RawGrid" -o "$tempTif" --width $SrcWidth --height $SrcHeight --endian $Endian
  if ($LASTEXITCODE -ne 0) { throw 'Raw->GeoTIFF conversion failed' }

  Write-Host "Running: $py $toPngScript $tempTif $Out --width $OutWidth --height $OutHeight"
  & $py $toPngScript "$tempTif" "$Out" --width $OutWidth --height $OutHeight
  if ($LASTEXITCODE -ne 0) { throw 'GeoTIFF->PNG conversion failed' }

  if (Test-Path $tempTif) { Remove-Item -Force $tempTif }

  Write-Host "Done. Output: $Out"
  exit 0

} catch {
  Write-Error "Error: $_"
  exit 1
}
