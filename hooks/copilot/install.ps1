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

Get-ChildItem -Path (Join-Path $PluginRoot "skills-copilot") -Directory | ForEach-Object {
  $name = $_.Name
  $src  = Join-Path $_.FullName "SKILL.md"
  if (-not (Test-Path $src)) { return }
  $destDir = Join-Path $ProjectRoot ".github\skills\$name"
  if (-not (Test-Path $destDir)) { New-Item -ItemType Directory -Path $destDir | Out-Null }
  $dest = Join-Path $destDir "SKILL.md"
  if (Test-Path $dest) {
    Write-Host "  skip (exists): .github\skills\$name\SKILL.md"
  } else {
    Copy-Item $src $dest
    Write-Host "  copied: .github\skills\$name\SKILL.md"
  }
}

Write-Host ""
Write-Host "Done."
Write-Host "  gh copilot CLI:    skills available under .github\skills\"
Write-Host "  Copilot Chat:      .github\copilot-instructions.md loaded as repo context"
