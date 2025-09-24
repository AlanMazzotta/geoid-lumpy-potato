<#
Copies binary assets and the raw EGM grid from the repo root into the standalone site.
Run this from the repo root (where DawnPatrol_Dashboard lives).
#>
param(
  [string]$RepoRoot = "C:\Users\alanm\Desktop\Code\DawnPatrol_Dashboard",
  [string]$SiteRoot = "C:\Users\alanm\Desktop\Code\standalone_geoid_viewer_site"
)

Write-Host "Copying assets from $RepoRoot to $SiteRoot"

$files = @(
  @{ src = Join-Path $RepoRoot 'heightmap_4096x2048.png'; dst = Join-Path $SiteRoot 'assets\heightmap_4096x2048.png' },
  @{ src = Join-Path $RepoRoot 'texture.jpg'; dst = Join-Path $SiteRoot 'assets\texture.jpg' },
  @{ src = Join-Path $RepoRoot 'EGM2008_Interpolation_Grid\Und_min2.5x2.5_egm2008_isw=82_WGS84_TideFree_SE'; dst = Join-Path $SiteRoot 'data\Und_min2.5x2.5_egm2008_isw=82_WGS84_TideFree_SE' }
)

foreach($f in $files){
  if (Test-Path $f.src) {
    $d = Split-Path $f.dst -Parent
    if (-not (Test-Path $d)) { New-Item -ItemType Directory -Path $d -Force | Out-Null }
    Copy-Item -Path $f.src -Destination $f.dst -Force
    Write-Host "Copied $($f.src) -> $($f.dst)"
  } else {
    Write-Warning "Source not found: $($f.src)"
  }
}

Write-Host "Done."
