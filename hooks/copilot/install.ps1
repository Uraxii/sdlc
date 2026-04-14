# Install SDLC Copilot files into the current project.
# Run from your project root: & "\path\to\install.ps1"

$ErrorActionPreference = 'Stop'

$PluginRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
$ProjectRoot = Get-Location

Write-Host "SDLC (Copilot) install: $PluginRoot -> $ProjectRoot"

$ghDir = Join-Path $ProjectRoot ".github"
if (-not (Test-Path $ghDir)) { New-Item -ItemType Directory -Path $ghDir | Out-Null }

$dest = Join-Path $ProjectRoot ".github\copilot-instructions.md"
if (Test-Path $dest) {
  Write-Host "  skip (exists): .github\copilot-instructions.md"
} else {
  Copy-Item (Join-Path $PluginRoot ".github\copilot-instructions.md") $dest
  Write-Host "  copied: .github\copilot-instructions.md"
}

$extDir = Join-Path $ProjectRoot '.github\extensions\sdlc'
if (-not (Test-Path $extDir)) { New-Item -ItemType Directory -Path $extDir | Out-Null }
$dest = Join-Path $extDir 'extension.mjs'
if (Test-Path $dest) {
  Write-Host '  skip (exists): .github\extensions\sdlc\extension.mjs'
} else {
  Copy-Item (Join-Path $PluginRoot 'extensions\sdlc\extension.mjs') $dest
  Write-Host '  copied: .github\extensions\sdlc\extension.mjs'
}

Write-Host ""
Write-Host "Done."
Write-Host "  gh copilot CLI:    extension at .github\extensions\sdlc\extension.mjs"
Write-Host "  Copilot Chat:      .github\copilot-instructions.md loaded as repo context"
