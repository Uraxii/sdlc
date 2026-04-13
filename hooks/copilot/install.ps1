# Install SDLC Copilot instructions into the current project.
# Run from your project root: & "\path\to\install.ps1"

$ErrorActionPreference = 'Stop'

$PluginRoot = $PSScriptRoot
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

Write-Host ""
Write-Host "Done. Copilot will pick up .github\copilot-instructions.md automatically."
