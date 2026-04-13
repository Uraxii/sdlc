# Install SDLC Cline rules into the current project.
# Run from your project root: & "\path\to\install.ps1"

$ErrorActionPreference = 'Stop'

$PluginRoot = $PSScriptRoot
$ProjectRoot = Get-Location

Write-Host "SDLC (Cline) install: $PluginRoot -> $ProjectRoot"

$clDir = Join-Path $ProjectRoot ".clinerules"
if (-not (Test-Path $clDir)) { New-Item -ItemType Directory -Path $clDir | Out-Null }

$dest = Join-Path $ProjectRoot ".clinerules\sdlc.md"
if (Test-Path $dest) {
  Write-Host "  skip (exists): .clinerules\sdlc.md"
} else {
  Copy-Item (Join-Path $PluginRoot ".clinerules\sdlc.md") $dest
  Write-Host "  copied: .clinerules\sdlc.md"
}

Write-Host ""
Write-Host "Done. Cline will pick up .clinerules\sdlc.md automatically."
