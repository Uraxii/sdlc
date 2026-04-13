# Install SDLC Cursor rules and skills into the current project.
# Run from your project root: & "\path\to\install.ps1"

$ErrorActionPreference = 'Stop'

$PluginRoot = $PSScriptRoot
$ProjectRoot = Get-Location

Write-Host "SDLC (Cursor) install: $PluginRoot -> $ProjectRoot"

foreach ($d in @(".cursor\rules", ".cursor\skills\sdlc")) {
  $p = Join-Path $ProjectRoot $d
  if (-not (Test-Path $p)) { New-Item -ItemType Directory -Path $p | Out-Null }
}

$dest = Join-Path $ProjectRoot ".cursor\rules\sdlc.mdc"
if (Test-Path $dest) {
  Write-Host "  skip (exists): .cursor\rules\sdlc.mdc"
} else {
  Copy-Item (Join-Path $PluginRoot ".cursor\rules\sdlc.mdc") $dest
  Write-Host "  copied: .cursor\rules\sdlc.mdc"
}

$dest = Join-Path $ProjectRoot ".cursor\skills\sdlc\SKILL.md"
if (Test-Path $dest) {
  Write-Host "  skip (exists): .cursor\skills\sdlc\SKILL.md"
} else {
  Copy-Item (Join-Path $PluginRoot ".cursor\skills\sdlc\SKILL.md") $dest
  Write-Host "  copied: .cursor\skills\sdlc\SKILL.md"
}

Write-Host ""
Write-Host "Done. Cursor will pick up .cursor\rules\sdlc.mdc automatically."
